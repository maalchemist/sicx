
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
; -> ecx : function actual argument count
macro @@_CALL_32 fio
{
        local  .vararg, .fixarg, .inline, .call, .done, .stack, .bypass.exit, .exit
        local  .error.exit, .error.memory, .error.argument, .error.evaluate, .error.no.impl

        push    eax esi

        mov     [.FPU], 1                       ; use FPU

        xor     eax, eax
        mov     [.SPD], eax
        mov     [.mode], eax
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
        mov     [.coshift], eax

    if ~ fio in < edx, rdx >
        mov     edx, dword fio                  ; edx = function item offset
    end if

        mov     esi, [edx + fitem32.offset]     ; esi = function entry offset
        mov     [.fuoff], esi                   ; save function entry offset

        mov     [.ezx], ecx                     ; [.ezx] = function actual argument count

        movsx   eax, [edx + fitem32.retype]
        mov     [.fretype], ax                  ; [.fretype] = function return type
        mov     [.frecount], eax                ; [.frecount] = function return count
        cmp     ax, 'i'                         ; ? integer function
        jne     @F
        mov     [.frecount], 1
        mov     [.firesp], 1
    @@:

        mov     ax, [edx + fitem32.acount]
        mov     [.facount], ax                  ; [.facount] = function argument count

        movzx   eax, [edx + fitem32.cosize]     ; ax = function code size or flags

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

        pcase   esi,\
                @@addr         , .error.exit,\
                @@assign       , .error.exit,\
                @@reassign     , .error.exit
        pcase   esi,\
                @@vcopy        , .error.exit,\
                @@vcopx        , .error.exit
        pcase   esi,\
                @@swapr        , .error.exit,\
                @@swapl        , .error.exit
        pcase   esi,\
                @@if.or        , .error.exit,\
                @@if.nor       , .error.exit,\
                @@if.and       , .error.exit,\
                @@if.nand      , .error.exit
        pcase   esi,\
                @@ie.or        , .error.exit,\
                @@ie.nor       , .error.exit,\
                @@ie.and       , .error.exit,\
                @@ie.nand      , .error.exit
        pcase   esi,\
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
        pcase   esi,\
                @@xgoto        , .error.exit,\
                @@rxgoto       , .error.exit
        pcase   esi,\
                @@goto.if.or   , .error.exit,\
                @@goto.if.nor  , .error.exit,\
                @@goto.if.and  , .error.exit,\
                @@goto.if.nand , .error.exit
        pcase   esi,\
                @@calls        , .error.exit,\
                @@rcalls       , .error.exit,\
                @@xcall        , .error.exit,\
                @@rxcall       , .error.exit
        pcase   esi,\
                @@call.if.or   , .error.exit,\
                @@call.if.nor  , .error.exit,\
                @@call.if.and  , .error.exit,\
                @@call.if.nand , .error.exit,\
                @@call.ie.or   , .error.exit,\
                @@call.ie.nor  , .error.exit,\
                @@call.ie.and  , .error.exit,\
                @@call.ie.nand , .error.exit
        pcase   esi,\
                @@co.vminmax   , .error.exit,\
                @@co.vmaxmin   , .error.exit,\
                @@vncycle      , .error.exit,\
                @@vnstep       , .error.exit,\
                @@vpoly        , .error.exit
        pcase   esi,\
                @@matrip       , .error.exit,\
                @@matrip.rc    , .error.exit
        pcase   esi,\
                @@vcount       , .inline.vcount.varg
        jmp    .vararg.out
   .vararg:                                             ; variable number of arguments
        @@bound 5, .error.memory                        ; store argument count in ecx register
        mov     [edi + 0], byte 0xB9
        mov     [edi + 1], ecx
        add     edi, 5
        ; ----------------------------------------------
        ; MOV   ECX, ACOUNT     | B9 FFFFFFFF           ; argument count (5B)
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
        and     eax, 0xFF                               ; clear native function flags
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
        pcase   esi,\
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

        pcase   esi,\
                @@vcount        , .inline.vcount
        pcase   esi,\
                @@assign        , .inline.assign,\
                @@reassign      , .inline.reassign
        pcase   esi,\
                @@vcopy         , .inline.vcopy,\
                @@vcopx         , .inline.vcopx
        pcase   esi,\
                @@swapr         , .inline.swapr,\
                @@swapl         , .inline.swapl
        pcase   esi,\
                @@co.vminmax    , .inline.x2copyDV,\
                @@co.vmaxmin    , .inline.x2copyDV
        pcase   esi,\
                @@xgoto         , .inline.xgoto,\
                @@rxgoto        , .inline.rxgoto
        pcase   esi,\
                @@goto.if.or    , .inline.jump.v,\
                @@goto.if.nor   , .inline.jump.v,\
                @@goto.if.and   , .inline.jump.v,\
                @@goto.if.nand  , .inline.jump.v
        pcase   esi,\
                @@calls         , .inline.calls,\
                @@rcalls        , .inline.rcalls,\
                @@xcall         , .inline.xcall,\
                @@rxcall        , .inline.rxcall
        pcase   esi,\
                @@call.if.or    , .inline.jump.v,\
                @@call.if.nor   , .inline.jump.v,\
                @@call.if.and   , .inline.jump.v,\
                @@call.if.nand  , .inline.jump.v,\
                @@call.ie.or    , .inline.jump.v.2p,\
                @@call.ie.nor   , .inline.jump.v.2p,\
                @@call.ie.and   , .inline.jump.v.2p,\
                @@call.ie.nand  , .inline.jump.v.2p
        pcase   esi,\
                @@matrip        , .inline.matrip,\
                @@matrip.rc     , .inline.matrip
        pcase   esi,\
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
        pcase   esi,\
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
        pcase   esi,\
                @@is.x32        , .inline.is.x32,\
                @@is.n32        , .inline.is.n32,\
                @@is.x64        , .inline.is.x64,\
                @@is.n64        , .inline.is.n64,\
                @@dll.bits      , .inline.dll.bits
        pcase   esi,\
                @@result.get    , .inline.proc
        jmp    .inline.proc.0p.rr
   .inline.fixarg.0p.nr:                        ; fixed number of arguments ; no arguments ; no result
        pcase   esi,\
                @@proc.begin    , .inline.asm.instruction,\
                @@proc.end      , .inline.asm.instruction
        pcase   esi,\
                @@int3          , .inline.asm.instruction,\
                @@int.3         , .inline.asm.instruction
        pcase   esi,\
                @@finit         , .inline.fpu.instruction,\
                @@fninit        , .inline.fpu.instruction,\
                @@fclex         , .inline.fpu.instruction,\
                @@fnclex        , .inline.fpu.instruction,\
                @@fstp          , .inline.fpu.instruction
        pcase   esi,\
                @@retn          , .inline.retn
        pcase   esi,\
                @@exit          , .inline.exit
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.1p:                           ; fixed number of arguments ; 1 argument
        cmp     [.frecount], 0
        jz     .inline.fixarg.1p.nr
   .inline.fixarg.1p.rr:                        ; fixed number of arguments ; 1 argument ; returns result
        pcase   esi,\
                @@sizeof        , .inline.sizeof
        pcase   esi,\
                @@.addr.1P      , .inline.addr.1P,\
                @@saddr         , .inline.saddr
        pcase   esi,\
                @@result.set    , .inline.result.set
        pcase   esi,\
                @@pdouble       , .inline.pvalue,\
                @@pint          , .inline.pvalue,\
                @@pstr          , .inline.pvalue,\
                @@pint64        , .inline.pvalue
        pcase   esi,\
                @@pcomplex      , .inline.pcomplex
        pcase   esi,\
                @@vfloat        , .inline.vdouble,\
                @@vdouble       , .inline.vdouble,\
                @@vcomplex      , .inline.vcomplex,\
                @@vint          , .inline.vinteger,\
                @@vinteger      , .inline.vinteger,\
                @@vstr          , .inline.vstring,\
                @@vstring       , .inline.vstring
        pcase   esi,\
                @@.double       , .inline.double
        pcase   esi,\
                @@.int          , .inline.int32,\
                @@.int64        , .inline.int64
        pcase   esi,\
                @@covalue       , .inline.covalue,\
                @@restore       , .inline.restore
        pcase   esi,\
                @@inc.pre       , .inline.inc.pre,\
                @@inc.post      , .inline.inc.post,\
                @@dec.pre       , .inline.dec.pre,\
                @@dec.post      , .inline.dec.post
        pcase   esi,\
                @@setz          , .inline.setz,\
                @@set1          , .inline.set1,\
                @@int           , .inline.int,\
                @@frac          , .inline.frac,\
                @@round         , .inline.round,\
                @@factln        , .inline.factln,\
                @@fact          , .inline.fact,\
                @@fact2         , .inline.fact2
        pcase   esi,\
                @@signbit       , .inline.signbit,\
                @@rsignbit      , .inline.rsignbit,\
                @@trunc         , .inline.trunc
        pcase   esi,\
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
        pcase   esi,\
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
        pcase   esi,\
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
        pcase   esi,\
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
        pcase   esi,\
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
        pcase   esi,\
                @@kibi          , .inline.kibi,\
                @@mebi          , .inline.mebi,\
                @@gibi          , .inline.gibi,\
                @@tebi          , .inline.tebi,\
                @@pebi          , .inline.pebi,\
                @@exbi          , .inline.exbi,\
                @@zebi          , .inline.zebi,\
                @@yobi          , .inline.yobi,\
                @@robi          , .inline.robi,\
                @@quebi         , .inline.quebi
        pcase   esi,\
                @@kibo          , .inline.kibo,\
                @@mebo          , .inline.mebo,\
                @@gibo          , .inline.gibo,\
                @@tebo          , .inline.tebo,\
                @@pebo          , .inline.pebo,\
                @@exbo          , .inline.exbo,\
                @@zebo          , .inline.zebo,\
                @@yobo          , .inline.yobo,\
                @@robo          , .inline.robo,\
                @@quebo         , .inline.quebo
        pcase   esi,\
                @@deca          , .inline.deca,\
                @@hecto         , .inline.hecto,\
                @@kilo          , .inline.kilo,\
                @@mega          , .inline.mega,\
                @@giga          , .inline.giga,\
                @@tera          , .inline.tera,\
                @@peta          , .inline.peta,\
                @@exa           , .inline.exa,\
                @@zetta         , .inline.zetta,\
                @@yotta         , .inline.yotta,\
                @@ronna         , .inline.ronna,\
                @@quetta        , .inline.quetta
        pcase   esi,\
                @@deci          , .inline.deci,\
                @@centi         , .inline.centi,\
                @@milli         , .inline.milli,\
                @@micro         , .inline.micro,\
                @@nano          , .inline.nano,\
                @@pico          , .inline.pico,\
                @@femto         , .inline.femto,\
                @@atto          , .inline.atto,\
                @@zepto         , .inline.zepto,\
                @@yocto         , .inline.yocto,\
                @@ronto         , .inline.ronto,\
                @@quecto        , .inline.quecto
        pcase   esi,\
                @@co.chs        , .inline.co.chs,\
                @@co.abs        , .inline.co.abs,\
                @@co.nabs       , .inline.co.nabs,\
                @@co.rcopy      , .inline.co.rcopy,\
                @@co.rxcopy     , .inline.co.rcopy
        pcase   esi,\
                @@co.bnot       , .inline.co.bnot
        pcase   esi,\
                @@.1D.1P.matrip , .inline.matrip
        jmp    .inline.proc.1p.rr
   .inline.fixarg.1p.nr:                        ; fixed number of arguments ; 1 argument ; no result
        pcase   esi,\
                @@goto          , .inline.jump
        pcase   esi,\
                @@goto.if.x32   , .inline.jump,\
                @@goto.if.n32   , .inline.jump,\
                @@goto.if.x64   , .inline.jump,\
                @@goto.if.n64   , .inline.jump
        pcase   esi,\
                @@call          , .inline.jump
        pcase   esi,\
                @@call.if.x32   , .inline.jump,\
                @@call.if.n32   , .inline.jump,\
                @@call.if.x64   , .inline.jump,\
                @@call.if.n64   , .inline.jump
        pcase   esi,\
                @@fstsw         , .inline.fstxw,\
                @@fnstsw        , .inline.fstxw,\
                @@fstef         , .inline.fstxw,\
                @@fnstef        , .inline.fstxw,\
                @@fstcw         , .inline.fstxw,\
                @@fnstcw        , .inline.fstxw
        pcase   esi,\
                @@fldcw         , .inline.fldxw,\
                @@fmaske        , .inline.fldxw,\
                @@fnmaske       , .inline.fldxw
        pcase   esi,\
                @@exit.if.true  , .inline.exit.if,\
                @@exit.if.false , .inline.exit.if
        pcase   esi,\
                @@.returnv      , .inline.return
        pcase   esi,\
                @@reset         , .inline.restore
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.2p:                           ; fixed number of arguments ; 2 arguments
        cmp     [.frecount], 0
        jz     .inline.fixarg.2p.nr
   .inline.fixarg.2p.rr:                        ; fixed number of arguments ; 2 arguments ; returns result
        pcase   esi,\
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
        pcase   esi,\
                @@min           , .inline.min,\
                @@max           , .inline.max,\
                @@adev          , .inline.adev,\
                @@nadev         , .inline.nadev
        pcase   esi,\
                @@ipow          , .inline.ipow,\
                @@pow           , .inline.pow,\
                @@.pow.??       , .inline.pow.??,\      ; a^b  : pow  | bxor
                @@powr          , .inline.powr,\
                @@.powr.??      , .inline.powr.??,\     ; a~^b : powr | bxnor
                @@root          , .inline.root,\
                @@rootr         , .inline.rootr
        pcase   esi,\
                @@gcd           , .inline.gcd,\
                @@lcm           , .inline.lcm
        pcase   esi,\
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
        pcase   esi,\
                @@igcd          , .inline.igcd,\
                @@ilcm          , .inline.ilcm
        pcase   esi,\
                @@btc           , .inline.btc,\
                @@btr           , .inline.btr,\
                @@bts           , .inline.bts
        pcase   esi,\
                @@or            , .inline.or,\
                @@nor           , .inline.nor,\
                @@xor           , .inline.xor,\
                @@xnor          , .inline.xnor,\
                @@and           , .inline.and,\
                @@nand          , .inline.nand
        pcase   esi,\
                @@if.e          , .inline.if.e,\
                @@if.ne         , .inline.if.ne,\
                @@if.a          , .inline.if.a,\
                @@if.ae         , .inline.if.ae,\
                @@if.b          , .inline.if.b,\
                @@if.be         , .inline.if.be
        pcase   esi,\
                @@if.bea        , .inline.if.bea,\
                @@if.aeb        , .inline.if.aeb
        pcase   esi,\
                @@case.x32      , .inline.case.x32,\
                @@case.n32      , .inline.case.n32,\
                @@case.x64      , .inline.case.x64,\
                @@case.n64      , .inline.case.n64
        pcase   esi,\
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
        pcase   esi,\
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
        pcase   esi,\
                @@copy          , .inline.copy,\
                @@xcopy         , .inline.copy,\
                @@copx          , .inline.copx,\
                @@ycopx         , .inline.copx
        pcase   esi,\
                @@copy.int      , .inline.copy.int,\
                @@xcopy.int     , .inline.copy.int,\
                @@copx.int      , .inline.copx.int,\
                @@ycopx.int     , .inline.copx.int
        pcase   esi,\
                @@copy.frac     , .inline.copy.frac,\
                @@xcopy.frac    , .inline.copy.frac,\
                @@copx.frac     , .inline.copx.frac,\
                @@ycopx.frac    , .inline.copx.frac
        pcase   esi,\
                @@copy.round    , .inline.copy.round,\
                @@xcopy.round   , .inline.copy.round,\
                @@copx.round    , .inline.copx.round,\
                @@ycopx.round   , .inline.copx.round
        pcase   esi,\
                @@pcopy         , .inline.pcopy,\
                @@pxcopy        , .inline.pcopy,\
                @@pcopx         , .inline.pcopx,\
                @@pycopx        , .inline.pcopx
        pcase   esi,\
                @@swap          , .inline.swap
        pcase   esi,\
                @@swap.int      , .inline.swap.int,\
                @@swap.frac     , .inline.swap.frac,\
                @@swap.round    , .inline.swap.round
        pcase   esi,\
                @@farr          , .inline.xarr,\
                @@barr          , .inline.xarr
        pcase   esi,\
                @@pfarr         , .inline.pxarr,\
                @@pbarr         , .inline.pxarr
        pcase   esi,\
                @@fara          , .inline.fara,\
                @@bara          , .inline.bara
        pcase   esi,\
                @@pfara         , .inline.pxarr,\
                @@pbara         , .inline.pxarr
        pcase   esi,\
                @@farv          , .inline.farv,\
                @@barv          , .inline.barv
        pcase   esi,\
                @@.1D.2P.matrip , .inline.matrip,\
                @@.1D.matrip.rc , .inline.matrip
        pcase   esi,\
                @@.addr.2P      , .inline.addr.2P
        pcase   esi,\
                @@ipow          , .inline.stack.4
        pcase   esi,\
                @@ccovalue      , .inline.ccovalue,\
                @@crestore      , .inline.crestore
        pcase   esi,\
                @@czcopy        , .inline.ccopy.2p,\
                @@czrcopy       , .inline.ccopy.2p,\
                @@czicopy       , .inline.ccopy.2p
        jmp    .inline.proc.2p.rr
   .inline.fixarg.2p.nr:                        ; fixed number of arguments ; 2 arguments ; no result
        pcase   esi,\
                @@absolute      , .inline.absolute
        pcase   esi,\
                @@goto.if.true  , .inline.goto.if.true,\
                @@goto.if.false , .inline.goto.if.false,\
                @@goto.if.z     , .inline.goto.if.z,\
                @@goto.if.nz    , .inline.goto.if.nz,\
                @@goto.if.az    , .inline.goto.if.az,\
                @@goto.if.aez   , .inline.goto.if.aez,\
                @@goto.if.bz    , .inline.goto.if.bz,\
                @@goto.if.bez   , .inline.goto.if.bez
        pcase   esi,\
                @@call.ie.x32   , .inline.jump.2p,\
                @@call.ie.n32   , .inline.jump.2p,\
                @@call.ie.x64   , .inline.jump.2p,\
                @@call.ie.n64   , .inline.jump.2p
        pcase   esi,\
                @@call.if.true  , .inline.call.if.true,\
                @@call.if.false , .inline.call.if.false,\
                @@call.if.z     , .inline.call.if.z,\
                @@call.if.nz    , .inline.call.if.nz,\
                @@call.if.az    , .inline.call.if.az,\
                @@call.if.aez   , .inline.call.if.aez,\
                @@call.if.bz    , .inline.call.if.bz,\
                @@call.if.bez   , .inline.call.if.bez
        pcase   esi,\
                @@creset        , .inline.crestore
        pcase   esi,\
                @@czmove        , .inline.cmove.2p,\
                @@czrmove       , .inline.cmove.2p,\
                @@czimove       , .inline.cmove.2p
        pcase   esi,\
                @@.returnv.if.true  , .inline.return.if,\
                @@.returnv.if.false , .inline.return.if
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.3p:                           ; fixed number of arguments ; 3 arguments
        cmp     [.frecount], 0
        jz     .inline.fixarg.3p.nr
   .inline.fixarg.3p.rr:                        ; fixed number of arguments ; 3 arguments ; returns result
        pcase   esi,\
                @@farw          , .inline.xarr,\
                @@barw          , .inline.xarr
        pcase   esi,\
                @@pfarw         , .inline.pxarr,\
                @@pbarw         , .inline.pxarr
        pcase   esi,\
                @@co.fxtractse  , .inline.x2copyD,\
                @@co.fxtractes  , .inline.x2copyD
        pcase   esi,\
                @@co.sincos     , .inline.x2copyD,\
                @@co.cossin     , .inline.x2copyD,\
                @@co.shch       , .inline.x2copyD,\
                @@co.chsh       , .inline.x2copyD
        pcase   esi,\
                @@co.fsincos    , .inline.x2copyD,\
                @@co.fcossin    , .inline.x2copyD,\
                @@co.fsincospi  , .inline.x2copyD,\
                @@co.fcossinpi  , .inline.x2copyD,\
                @@co.fshch      , .inline.x2copyD,\
                @@co.fchsh      , .inline.x2copyD
        pcase   esi,\
                @@.2D.3P.matrip , .inline.matrip
        pcase   esi,\
                @@cxcopy        , .inline.ccopy.3p,\
                @@cxrcopy       , .inline.ccopy.3p,\
                @@cxicopy       , .inline.ccopy.3p
        pcase   esi,\
                @@cpcopy        , .inline.cpcopy.3p
        pcase   esi,\
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
        pcase   esi,\
                @@cpown         , .inline.stack.4,\
                @@crootn        , .inline.stack.4
        jmp    .inline.proc.3p.rr
   .inline.fixarg.3p.nr:                        ; fixed number of arguments ; 3 arguments ; no result
        pcase   esi,\
                @@call.ie.true  , .inline.call.ie.true,\
                @@call.ie.false , .inline.call.ie.false,\
                @@call.ie.z     , .inline.call.ie.z,\
                @@call.ie.nz    , .inline.call.ie.nz,\
                @@call.ie.az    , .inline.call.ie.az,\
                @@call.ie.aez   , .inline.call.ie.aez,\
                @@call.ie.bz    , .inline.call.ie.bz,\
                @@call.ie.bez   , .inline.call.ie.bez
        pcase   esi,\
                @@cxmove        , .inline.cmove.3p,\
                @@cxrmove       , .inline.cmove.3p,\
                @@cximove       , .inline.cmove.3p
        pcase   esi,\
                @@cpmove        , .inline.cpmove.3p
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.4p:                           ; fixed number of arguments ; 4 arguments and more
        cmp     [.frecount], 0
        jz     .inline.fixarg.4p.nr
   .inline.fixarg.4p.rr:                        ; fixed number of arguments ; 4 arguments and more ; returns result
        pcase   esi,\
                @@x2copy        , .inline.x2copy,\
                @@x3copy        , .inline.x3copy,\
                @@x4copy        , .inline.x4copy
        pcase   esi,\
                @@co.quo.mod    , .inline.x2copyD,\
                @@co.mod.quo    , .inline.x2copyD,\
                @@co.minmax     , .inline.x2copyD,\
                @@co.maxmin     , .inline.x2copyD
        pcase   esi,\
                @@co.lineco     , .inline.x2copyD
        pcase   esi,\
                @@co.deg2arc    , .inline.x3copyD,\
                @@co.rad2arc    , .inline.x3copyD,\
                @@co.grad2arc   , .inline.x3copyD,\
                @@co.cycle2arc  , .inline.x3copyD
        pcase   esi,\
                @@.2D.4P.matrip , .inline.matrip,\
                @@.2D.matrip.rc , .inline.matrip
        pcase   esi,\
                @@ccopy         , .inline.ccopy,\
                @@crrcopy       , .inline.ccopy,\
                @@ciicopy       , .inline.ccopy,\
                @@cswap         , .inline.cswap
        pcase   esi,\
                @@crootsn       , .inline.stack.8
        cmp     [.facount], 4
        jg     .inline.proc
        jmp    .inline.proc.4p.rr
   .inline.fixarg.4p.nr:                        ; fixed number of arguments ; 4 arguments and more ; no result
        pcase   esi,\
                @@cmove         , .inline.cmove,\
                @@crrmove       , .inline.cmove,\
                @@ciimove       , .inline.cmove,\
                @@cswop         , .inline.cswop
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.vcount:
        ; ----------------------------------------------
        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        mov     ecx, [.ezx]
        cmp     ecx, +127
        jg     .inline.vcount.d
        cmp     ecx, -128
        jl     .inline.vcount.d
    $ifndef _SSEX
        cmp     ecx, 1
        je     .inline.vcount.1
    $end
        test    ecx, ecx
        jz     .inline.vcount.0
   .inline.vcount.b:
    $ifdef _SSEX
        @@range 4, .error.memory
        mov     [edi + 0], dword 0xC12A0FF2
        @@xshr  edi, 4
        ; ----------------------------------------------
        ; MOV      ECX, ACOUNT | B9 CCCCCCCC            ; 5 BYTES
        ;*CVTSI2SD XMM0, ECX   | F20F2AC1               ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@range 8-5, .error.memory
        @@xshl  edi, 5
        mov     [edi + 0], byte 0x6A
        mov     [edi + 1], cl
        mov     [edi + 2], dword 0x832404DB
        mov     [edi + 6], word 0x04C4
        @@xshr  edi, 8
        ; ----------------------------------------------
        ;*PUSH  ACOUNT          | 6A CC                 ; 2 BYTES
        ; FILD  DWORD [ESP]     | DB04 24               ; 3 BYTES
        ; ADD   ESP, 4          | 83C4 04               ; 3 BYTES
        ;>
        ; ----------------------------------------------
    $end
        jmp    .done
   .inline.vcount.d:
    $ifdef _SSEX
        @@range 4, .error.memory
        mov     [edi + 0], dword 0xC12A0FF2
        @@xshr  edi, 4
        ; ----------------------------------------------
        ; MOV      ECX, ACOUNT | B9 CCCCCCCC            ; 5 BYTES
        ;*CVTSI2SD XMM0, ECX   | F20F2AC1               ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@range 6, .error.memory
        mov     [edi - 5], byte 0x68
        mov     [edi + 0], dword 0x832404DB
        mov     [edi + 4], word 0x04C4
        @@xshr  edi, 6
        ; ----------------------------------------------
        ; PUSH  ACOUNT          | 68 CCCCCCCC           ; 5 BYTES
        ;*FILD  DWORD [ESP]     | DB04 24               ; 3 BYTES
        ; ADD   ESP, 4          | 83C4 04               ; 3 BYTES
        ;>
        ; ----------------------------------------------
    $end
        jmp    .done
    $ifndef _SSEX
   .inline.vcount.1:
        @@xshl  edi, 5
        mov     [edi + 0], word 0xE8D9
        @@xshr  edi, 2
        ; ----------------------------------------------
        ;*FLD1                  | D9E8                  ; 2 BYTES
        ;>
        ; ----------------------------------------------
        jmp    .done
    $end
   .inline.vcount.0:
    $ifdef _SSEX
        @@xshl  edi, 5
        mov     [edi + 0], dword 0xC0570F66
        @@xshr  edi, 4
        ; ----------------------------------------------
        ;*XORPD XMM0, XMM0      | 660F57C0              ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@xshl  edi, 5
        mov     [edi + 0], word 0xEED9
        @@xshr  edi, 2
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
        @@range 4, .error.memory
        mov     [edi + 0], dword 0xC12A0FF2
        @@xshr  edi, 4
        ; ----------------------------------------------
        ;*CVTSI2SD XMM0, ECX   | F20F2AC1               ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@range 7, .error.memory
        mov     [edi + 00], dword 0x2404DB51
        mov     [edi + 04], word 0xC483
        mov     [edi + 06], byte 0x04
        @@xshr  edi, 7
        ; ----------------------------------------------
        ;*PUSH  ECX             | 51                    ; 1 BYTES
        ; FILD  DWORD [ESP]     | DB04 24               ; 3 BYTES
        ; ADD   ESP, 4          | 83C4 04               ; 3 BYTES
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
        mov     ecx, [.frecount]
        case    ecx,\
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
        movsd   qword [esp - 08], xmm7
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm6:
        movsd   qword [esp - 08], xmm6
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm5:
        movsd   qword [esp - 08], xmm5
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm4:
        movsd   qword [esp - 08], xmm4
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm3:
        movsd   qword [esp - 08], xmm3
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm2:
        movsd   qword [esp - 08], xmm2
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm1:
        movsd   qword [esp - 08], xmm1
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm0:
        movsd   qword [esp - 08], xmm0
;       jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm:
        mov     ecx, [esp - 08]
        mov     edx, [esp - 04]                             ; ecx:edx = double constant
        @@range 12, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], ecx
        mov     [edi + 10], word 0x5152
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
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
        fstp    qword [esp - 08]
        mov     ecx, [esp - 08]
        mov     edx, [esp - 04]
   .inline.ecx.edx.dcon:                                    ; ecx:edx = double constant
        @@range 12, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], ecx
        mov     [edi + 10], word 0x5152
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
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

   .inline.eax.icon:                                        ; eax = integer constant
        @@range 6, .error.memory
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0x50
        @@xshr  edi, 6
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'icon'
        jmp    .exit

   .inline.eax.scon:                                        ; eax = string constant
        @@range 6, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0x52
        @@xshr  edi, 6
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ; PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'scon'
        jmp    .exit

   .inline.proc.0p.rr:
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon

   .inline.proc.1p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [ESP]       | DD0424               ; 3 BYTES
        ;?FILD     DWORD [ESP]       | DB0424               ; 3 BYTES

        ;?MOVSD    XMM0, QWORD [ESP] | F20F100424           ; 5 BYTES
        ;?CVTSI2SD XMM0, DWORD [ESP] | F20F2A0424           ; 5 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                        | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.1p.rr.p1:
        cmp     [esi + 00], dword 0x04100FF2
        je     .inline.proc.1p.rr.p1.D?
        cmp     [esi + 00], dword 0x042A0FF2
        jne    .inline.proc
        ;
   .inline.proc.1p.rr.p1.I?:
   .inline.proc.1p.rr.p1.D?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.1p.rr.p1.I:
   .inline.proc.1p.rr.p1.D:
        mov     [.sid], 5
        jmp    .inline.proc.1p.rr.enter
    $else
        cmp     [esi + 02], byte 0x24
        jne    .inline.proc
        cmp     [esi + 00], word 0x04DD
        je     .inline.proc.1p.rr.p1.D
        cmp     [esi + 00], word 0x04DB
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
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_CON , .inline.proc.1p.rr.dcon,\
                OBJ_INT_CON    , .inline.proc.1p.rr.icon,\
                OBJ_STRING_CON , .inline.proc.1p.rr.icon
        jmp    .inline.proc
   .inline.proc.1p.rr.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        add     esp, 8
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 12
        add     [.RSP], 8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
   .inline.proc.1p.rr.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        add     esp, 4
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 6
        add     [.RSP], 4
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon

   .inline.proc.2p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [ESP]          | DD0424            ; 3 BYTES
        ;?FILD     DWORD [ESP]          | DB0424

        ;?MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ;?CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [ESP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     DWORD [ESP+FF]       | DB4424 FF

        ;?MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ;?CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.2p.rr.p1:
        cmp     [esi + 00], dword 0x04100FF2
        je     .inline.proc.2p.rr.p1.D?
        cmp     [esi + 00], dword 0x042A0FF2
        jne    .inline.proc
        ;
   .inline.proc.2p.rr.p1.I?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.I:
   .inline.proc.2p.rr.p1.I.p2:
        cmp     [esi + 05], dword 0x4C100FF2
        je     .inline.proc.2p.rr.p1.I.p2.D?
        cmp     [esi + 05], dword 0x4C2A0FF2
        jne    .inline.proc
        ;
   .inline.proc.2p.rr.p1.I.p2.I?:
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.I.p2.I:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6
        jmp    .inline.proc.2p.rr.enter
        ;
   .inline.proc.2p.rr.p1.I.p2.D?:
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.I.p2.D:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6
        jmp    .inline.proc.2p.rr.enter
        ;
   .inline.proc.2p.rr.p1.D?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.D:
   .inline.proc.2p.rr.p1.D.p2:
        cmp     [esi + 05], dword 0x4C100FF2
        je     .inline.proc.2p.rr.p1.D.p2.D?
        cmp     [esi + 05], dword 0x4C2A0FF2
        jne    .inline.proc
        ;
   .inline.proc.2p.rr.p1.D.p2.I?:
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.D.p2.I:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ; CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6
        jmp    .inline.proc.2p.rr.enter
        ;
   .inline.proc.2p.rr.p1.D.p2.D?:
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.D.p2.D:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ; MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6
        jmp    .inline.proc.2p.rr.enter
    $else
   .inline.proc.2p.rr.p1:
        cmp     [esi + 01], word 0x2404
        jne    .inline.proc
        cmp     [esi + 00], byte 0xDD
        je     .inline.proc.2p.rr.p1.out
        cmp     [esi + 00], byte 0xDB
        jne    .inline.proc
   .inline.proc.2p.rr.p1.out:
   .inline.proc.2p.rr.p2:
        cmp     [esi + 04], word 0x2444
        jne    .inline.proc
        cmp     [esi + 03], byte 0xDD
        je     .inline.proc.2p.rr.p2.out
        cmp     [esi + 03], byte 0xDB
        jne    .inline.proc
   .inline.proc.2p.rr.p2.out:
        mov     [.sid], 3+4
    $end
   .inline.proc.2p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_CON , .inline.proc.2p.rr.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.rr.icon,\
                OBJ_STRING_CON , .inline.proc.2p.rr.icon
        jmp    .inline.proc
   .inline.proc.2p.rr.dcon:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.2p.rr.dcon.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.rr.dcon.icon,\
                OBJ_STRING_CON , .inline.proc.2p.rr.dcon.icon
        jmp    .inline.proc
   .inline.proc.2p.rr.icon:
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.2p.rr.icon.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.rr.icon.icon,\
                OBJ_STRING_CON , .inline.proc.2p.rr.icon.icon
        jmp    .inline.proc
   .inline.proc.2p.rr.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 18]                             ; ecx = constant #2 LO
        mov     edx, [edi - 23]                             ; edx = constant #2 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm1, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        add     esp, 8+8
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 12+12
        add     [.RSP], 8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
   .inline.proc.2p.rr.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 17]                             ; ecx = constant #2
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        add     esp, 8+4
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 12+6
        add     [.RSP], 8+4
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
   .inline.proc.2p.rr.icon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 12]                             ; ecx = constant #2 LO
        mov     edx, [edi - 17]                             ; edx = constant #2 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm1, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        add     esp, 4+8
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 6+12
        add     [.RSP], 4+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
   .inline.proc.2p.rr.icon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 11]                             ; ecx = constant #2
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm1, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        add     esp, 4+4
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 6+6
        add     [.RSP], 4+4
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon

   .inline.proc.3p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [ESP]          | DD0424            ; 3 BYTES
        ;?FILD     DWORD [ESP]          | DB0424

        ;?MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ;?CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [ESP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     DWORD [ESP+FF]       | DB4424 FF

        ;?MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ;?CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [ESP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     DWORD [ESP+FF]       | DB4424 FF

        ;?MOVSD    XMM2, QWORD [ESP+FF] | F20F105424 FF     ; 6 BYTES
        ;?CVTSI2SD XMM2, DWORD [ESP+FF] | F20F2A5424 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.3p.rr.p1:
        cmp     [esi + 00], dword 0x04100FF2
        je     .inline.proc.3p.rr.p1.D?
        cmp     [esi + 00], dword 0x042A0FF2
        jne    .inline.proc
        ;
   .inline.proc.3p.rr.p1.I?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.I:
        cmp     [esi + 05], dword 0x4C2A0FF2
        jne    .inline.proc
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.I.p2.I:
        cmp     [esi + 11], dword 0x542A0FF2
        jne    .inline.proc
        cmp     [esi + 15], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.I.p2.I.p3.I:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; CVTSI2SD XMM2, DWORD [ESP+FF] | F20F2A5424 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6+6
        jmp    .inline.proc.3p.rr.enter
        ;
   .inline.proc.3p.rr.p1.D?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.D:
        cmp     [esi + 05], dword 0x4C100FF2
        jne    .inline.proc
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.D.p2.D:
        cmp     [esi + 11], dword 0x54100FF2
        jne    .inline.proc
        cmp     [esi + 15], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.D.p2.D.p3.D:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ; MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ; MOVSD    XMM2, QWORD [ESP+FF] | F20F105424 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6+6
        jmp    .inline.proc.3p.rr.enter
    $else
   .inline.proc.3p.rr.p1:
        cmp     [esi + 01], word 0x2404
        jne    .inline.proc
        cmp     [esi + 00], byte 0xDD
        je     .inline.proc.3p.rr.p1.out
        cmp     [esi + 00], byte 0xDB
        jne    .inline.proc
   .inline.proc.3p.rr.p1.out:
   .inline.proc.3p.rr.p2:
        cmp     [esi + 04], word 0x2444
        jne    .inline.proc
        cmp     [esi + 03], byte 0xDD
        je     .inline.proc.3p.rr.p2.out
        cmp     [esi + 03], byte 0xDB
        jne    .inline.proc
   .inline.proc.3p.rr.p2.out:
   .inline.proc.3p.rr.p3:
        cmp     [esi + 08], word 0x2444
        jne    .inline.proc
        cmp     [esi + 07], byte 0xDD
        je     .inline.proc.3p.rr.p3.out
        cmp     [esi + 07], byte 0xDB
        jne    .inline.proc
   .inline.proc.3p.rr.p3.out:
        mov     [.sid], 3+4+4
    $end
   .inline.proc.3p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
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
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.3p.rr.dcon.dcon
        jmp    .inline.proc
   .inline.proc.3p.rr.dcon.dcon:
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.3p.rr.dcon.dcon.dcon
        jmp    .inline.proc
        ;
   .inline.proc.3p.rr.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.3p.rr.icon.icon
        jmp    .inline.proc
   .inline.proc.3p.rr.icon.icon:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.3p.rr.icon.icon.icon
        jmp    .inline.proc
        ;
   .inline.proc.3p.rr.dcon.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 18]                             ; ecx = constant #2 LO
        mov     edx, [edi - 23]                             ; edx = constant #2 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm1, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 30]                             ; ecx = constant #3 LO
        mov     edx, [edi - 35]                             ; edx = constant #3 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm2, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        add     esp, 8+8+8
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 12+12+12
        add     [.RSP], 8+8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
        ;
   .inline.proc.3p.rr.icon.icon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 11]                             ; ecx = constant #2
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm1, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 17]                             ; ecx = constant #3
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm2, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        add     esp, 4+4+4
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 6+6+6
        add     [.RSP], 4+4+4
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon

   .inline.proc.4p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [ESP]          | DD0424            ; 3 BYTES
        ;?FILD     DWORD [ESP]          | DB0424

        ;?MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ;?CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [ESP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     DWORD [ESP+FF]       | DB4424 FF

        ;?MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ;?CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [ESP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     DWORD [ESP+FF]       | DB4424 FF

        ;?MOVSD    XMM2, QWORD [ESP+FF] | F20F105424 FF     ; 6 BYTES
        ;?CVTSI2SD XMM2, DWORD [ESP+FF] | F20F2A5424 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [ESP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     DWORD [ESP+FF]       | DB4424 FF

        ;?MOVSD    XMM3, QWORD [ESP+FF] | F20F105C24 FF     ; 6 BYTES
        ;?CVTSI2SD XMM3, DWORD [ESP+FF] | F20F2A5C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.4p.rr.p1:
        cmp     [esi + 00], dword 0x04100FF2
        je     .inline.proc.4p.rr.p1.D?
        cmp     [esi + 00], dword 0x042A0FF2
        jne    .inline.proc
        ;
   .inline.proc.4p.rr.p1.I?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I:
        cmp     [esi + 05], dword 0x4C2A0FF2
        jne    .inline.proc
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I.p2.I:
        cmp     [esi + 11], dword 0x542A0FF2
        jne    .inline.proc
        cmp     [esi + 15], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I.p2.I.p3.I:
        cmp     [esi + 17], dword 0x5C2A0FF2
        jne    .inline.proc
        cmp     [esi + 21], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I.p2.I.p3.I.p4.I:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, DWORD [ESP]    | F20F2A0424        ; 5 BYTES
        ; CVTSI2SD XMM1, DWORD [ESP+FF] | F20F2A4C24 FF     ; 6 BYTES
        ; CVTSI2SD XMM2, DWORD [ESP+FF] | F20F2A5424 FF     ; 6 BYTES
        ; CVTSI2SD XMM3, DWORD [ESP+FF] | F20F2A5C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6+6+6
        jmp    .inline.proc.4p.rr.enter
        ;
   .inline.proc.4p.rr.p1.D?:
        cmp     [esi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D:
        cmp     [esi + 05], dword 0x4C100FF2
        jne    .inline.proc
        cmp     [esi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D.p2.D:
        cmp     [esi + 11], dword 0x54100FF2
        jne    .inline.proc
        cmp     [esi + 15], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D.p2.D.p3.D:
        cmp     [esi + 17], dword 0x5C100FF2
        jne    .inline.proc
        cmp     [esi + 21], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D.p2.D.p3.D.p4.D:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [ESP]    | F20F100424        ; 5 BYTES
        ; MOVSD    XMM1, QWORD [ESP+FF] | F20F104C24 FF     ; 6 BYTES
        ; MOVSD    XMM2, QWORD [ESP+FF] | F20F105424 FF     ; 6 BYTES
        ; MOVSD    XMM3, QWORD [ESP+FF] | F20F105C24 FF     ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6+6+6
        jmp    .inline.proc.4p.rr.enter
    $else
   .inline.proc.4p.rr.p1:
        cmp     [esi + 01], word 0x2404
        jne    .inline.proc
        cmp     [esi + 00], byte 0xDD
        je     .inline.proc.4p.rr.p1.out
        cmp     [esi + 00], byte 0xDB
        jne    .inline.proc
   .inline.proc.4p.rr.p1.out:
   .inline.proc.4p.rr.p2:
        cmp     [esi + 04], word 0x2444
        jne    .inline.proc
        cmp     [esi + 03], byte 0xDD
        je     .inline.proc.4p.rr.p2.out
        cmp     [esi + 03], byte 0xDB
        jne    .inline.proc
   .inline.proc.4p.rr.p2.out:
   .inline.proc.4p.rr.p3:
        cmp     [esi + 08], word 0x2444
        jne    .inline.proc
        cmp     [esi + 07], byte 0xDD
        je     .inline.proc.4p.rr.p3.out
        cmp     [esi + 07], byte 0xDB
        jne    .inline.proc
   .inline.proc.4p.rr.p3.out:
   .inline.proc.4p.rr.p4:
        cmp     [esi + 12], word 0x2444
        jne    .inline.proc
        cmp     [esi + 11], byte 0xDD
        je     .inline.proc.4p.rr.p4.out
        cmp     [esi + 11], byte 0xDB
        jne    .inline.proc
   .inline.proc.4p.rr.p4.out:
        mov     [.sid], 3+4+4+4
    $end
   .inline.proc.4p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
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
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon.dcon
        jmp    .inline.proc
   .inline.proc.4p.rr.dcon.dcon:
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon.dcon.dcon
        jmp    .inline.proc
   .inline.proc.4p.rr.dcon.dcon.dcon:
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon.dcon.dcon.dcon
        jmp    .inline.proc
        ;
   .inline.proc.4p.rr.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.4p.rr.icon.icon
        jmp    .inline.proc
   .inline.proc.4p.rr.icon.icon:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.4p.rr.icon.icon.icon
        jmp    .inline.proc
   .inline.proc.4p.rr.icon.icon.icon:
        stdcall code_object, [.cooff], -18                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.4p.rr.icon.icon.icon.icon
        jmp    .inline.proc
        ;
   .inline.proc.4p.rr.dcon.dcon.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 18]                             ; ecx = constant #2 LO
        mov     edx, [edi - 23]                             ; edx = constant #2 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm1, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 30]                             ; ecx = constant #3 LO
        mov     edx, [edi - 35]                             ; edx = constant #3 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm2, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        mov     ecx, [edi - 42]                             ; ecx = constant #4 LO
        mov     edx, [edi - 47]                             ; edx = constant #4 HI
        push    edx
        push    ecx
    $ifdef _SSEX
        movsd   xmm3, qword [esp]
    $else
        fld     qword [esp]
    $end
        ;
        add     esp, 8+8+8+8
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 12+12+12+12
        add     [.RSP], 8+8+8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
        ;
   .inline.proc.4p.rr.icon.icon.icon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 11]                             ; ecx = constant #2
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm1, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 17]                             ; ecx = constant #3
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm2, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        mov     ecx, [edi - 23]                             ; ecx = constant #4
        push    ecx
    $ifdef _SSEX
       cvtsi2sd xmm3, dword [esp]
    $else
        fild    dword [esp]
    $end
        ;
        add     esp, 4+4+4+4
        add     esi, [.sid]
        ;
        push    edi ebx ; save registers when calling the built-in function
        call    esi
        pop     ebx edi
        ;
        @@xshl  edi, 6+6+6+6
        add     [.RSP], 4+4+4+4
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon

   .inline.sizeof:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, OFFSET       | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
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
        mov     ecx, 10
        jmp    .inline.sizeof.8
   .inline.sizeof.dcon:
        mov     ecx, 12
        jmp    .inline.sizeof.8
   .inline.sizeof.ivar:
        mov     ecx, 7
        jmp    .inline.sizeof.4
   .inline.sizeof.icon:
        mov     ecx, 6
        jmp    .inline.sizeof.4
   .inline.sizeof.svar:
        mov     ecx, 7
        jmp    .inline.sizeof.4
   .inline.sizeof.scon:
        mov     ecx, 6
        jmp    .inline.sizeof.4
   .inline.sizeof.ptr:
        mov     ecx, 9
;       jmp    .inline.sizeof.4
   .inline.sizeof.4:
        @@xshl  edi, ecx
        add     [.RSP], 4
        mov     eax, 4
        jmp    .inline.eax.icon
   .inline.sizeof.8:
        @@xshl  edi, ecx
        add     [.RSP], 8
        mov     eax, 8
        jmp    .inline.eax.icon

   .inline.absolute:
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_POINTER , .inline.absolute.ptr
        jmp    .error.argument
   .inline.absolute.ptr:
        stdcall code_object, [.cooff], -9                   ; ecx = object type
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
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 17]
        mov     ecx, [edi - 08]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.svar:
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA AAAAAAAA           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 15]
        test    edx, edx
        jz     .error.argument
        mov     edx, [edx]
        mov     ecx, [edi - 08]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.scon:
        ; --------------------------------------------------
        ; MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ; PUSH    EDX               | 52

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 14]
        mov     ecx, [edi - 08]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 AAAAAAAA           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 15]
        mov     ecx, [edi - 08]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 14]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        mov     edx, [edi - 14]
        mov     ecx, [edi - 08]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.dvar:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 AAAAAAAA           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 18]
        mov     ecx, [edi - 08]
   .inline.absolute.ptr.main:
        lea     ecx, [ecx + xitem32.value]
        mov     [ecx], edx
        jmp    .exit

   .inline.assign:
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090

        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        case    ecx,\
                OBJ_POINTER , .inline.assign.ptr
        jmp    .error.argument
   .inline.assign.ptr:
        stdcall code_object, [.cooff], -14                  ; ecx = object type
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
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 22]
        mov     ecx, [edi - 13]
        @@xshl  edi, 23
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.svar:
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA AAAAAAAA           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 20]
        test    edx, edx
        jz     .error.argument
        mov     edx, [edx]
        mov     ecx, [edi - 13]
        @@xshl  edi, 21
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.scon:
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ; PUSH    EDX               | 52

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 19]
        mov     ecx, [edi - 13]
        @@xshl  edi, 20
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 AAAAAAAA           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 20]
        mov     ecx, [edi - 13]
        @@xshl  edi, 21
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 19]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        mov     edx, [edi - 19]
        mov     ecx, [edi - 13]
        @@xshl  edi, 20
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 AAAAAAAA           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 AAAAAAAA           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 33]
        mov     edx, [edi - 23]
        mov     ecx, [edi - 13]
        sub     eax, edx
        cmp     eax, 8
        jne    .inline.assign.ptr.dvar.x
   .inline.assign.ptr.dvar.dvar.x:
        @@xshl  edi, 34
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.dvar:
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.assign.ptr.dvar.dvar
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 AAAAAAAA           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 23]
        mov     ecx, [edi - 13]
   .inline.assign.ptr.dvar.x:
        @@xshl  edi, 24
   .inline.assign.ptr.main:
        lea     ecx, [ecx + xitem32.value]
        mov     [ecx], edx
        mov     [.FPU], 0
        jmp    .exit

   .inline.reassign:
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090

        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        case    ecx,\
                OBJ_POINTER , .inline.reassign.ptr
        jmp    .error.argument
   .inline.reassign.ptr:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 13]
        @@xshl  edi, 14
   .inline.reassign.ptr.main:
        mov     edx, dword [ecx + xitem32.idata]
        lea     ecx, [ecx + xitem32.value]
        mov     [ecx], edx
        xor     edx, edx
        mov     [ecx + 4], edx
        mov     [.FPU], 0
        jmp    .exit

   .inline.addr.1P:
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 AAAAAAAA           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 AAAAAAAA           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EDX, OFFSET     | BA AAAAAAAA           ; string variable (7B)
        ;?PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.addr.1P.dvar,\
                OBJ_INT_VAR    , .inline.addr.1P.ivar,\
                OBJ_STRING_VAR , .inline.addr.1P.svar
        jmp    .error.argument
   .inline.addr.1P.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 AAAAAAAA           ; double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 5
        mov     [edi + 00], dword 0x90909051
        @@xshr  edi, 4
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 AAAAAAAA           ; pointer constant (9B)
        ;*PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 8
        jmp    .exit
   .inline.addr.1P.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 AAAAAAAA           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 9-7, .error.memory
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 AAAAAAAA           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 4
        jmp    .exit
   .inline.addr.1P.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA AAAAAAAA           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        @@range 9-7, .error.memory
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 AAAAAAAA           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 4
        jmp    .exit

   .inline.addr.2P:
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 AAAAAAAA           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.addr.2P.dvar
        jmp    .error.argument
   .inline.addr.2P.dvar:
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.addr.2P.dvar.dvar
        jmp    .error.argument
   .inline.addr.2P.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 AAAAAAAA           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31

        ; MOV   ECX, OFFSET     | B9 AAAAAAAA           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 19]
        mov     ecx, [edi - 09]
        sub     edx, ecx
        cmp     edx, 8
        jne    .error.argument
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 AAAAAAAA           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 16
        jmp    .exit

   .inline.saddr:
        ; --------------------------------------------------
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_STRING_VAR , .inline.saddr.svar,\
                OBJ_STRING_CON , .inline.saddr.scon
        jmp    .error.argument
   .inline.saddr.svar:
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA AAAAAAAA           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]
        test    edx, edx
        jz     .error.argument
        @@range 9-7, .error.memory
        mov     edx, [edx]
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 AAAAAAAA           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 4
        jmp    .exit
   .inline.saddr.scon:
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ; PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        @@range 9-6, .error.memory
        @@xshl  edi, 6
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 AAAAAAAA           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 4
        jmp    .exit

   .inline.vdouble:
        ; --------------------------------------------------
        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vdouble.icon,\
                OBJ_POINTER , .inline.vdouble.ptr
        jmp    .error.argument
   .inline.vdouble.icon:
        @@range 10-6, .error.memory
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 5]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        @@xshl  edi, 6
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        add     [.RSP], 4
        jmp    .exit
   .inline.vdouble.ptr:
        @@range 10-9, .error.memory
        ; --------------------------------------------------
        ;*MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 9
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        add     [.RSP], 4
        jmp    .exit

   .inline.vcomplex:
        ; --------------------------------------------------
        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vcomplex.icon,\
                OBJ_POINTER , .inline.vcomplex.ptr
        jmp    .error.argument
   .inline.vcomplex.icon:
        @@range 20-6, .error.memory
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 5]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        mov     ecx, [edi - 05]
        lea     edx, [ecx + 8]
        @@xshl  edi, 6
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], word 0xB931
        mov     [edi + 11], ecx
        mov     [edi + 15], dword 0xFF0471FF
        mov     [edi + 19], byte 0x31
        @@xshr  edi, 20
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        add     [.RSP], -4
        jmp    .exit
   .inline.vcomplex.ptr:
        @@range 20-9, .error.memory
        ; --------------------------------------------------
        ;*MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 08]
        lea     edx, [ecx + 8]
        @@xshl  edi, 9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], word 0xB931
        mov     [edi + 11], ecx
        mov     [edi + 15], dword 0xFF0471FF
        mov     [edi + 19], byte 0x31
        @@xshr  edi, 20
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        add     [.RSP], -4
        jmp    .exit

   .inline.vinteger:
        ; --------------------------------------------------
        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vinteger.icon,\
                OBJ_POINTER , .inline.vinteger.ptr
        jmp    .error.argument
   .inline.vinteger.icon:
        @@range 7-6, .error.memory
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 5]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        @@xshl  edi, 6
        mov     [edi + 05], word 0x30FF
        @@xshr  edi, 7
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ; --------------------------------------------------
        mov     [.cotype], 'ivar'
        add     [.RSP], 4
        jmp    .exit
   .inline.vinteger.ptr:
        ; --------------------------------------------------
        ;*MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], word 0x30FF
        @@xshr  edi, 7
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ; --------------------------------------------------
        mov     [.cotype], 'ivar'
        add     [.RSP], 4
        jmp    .exit

   .inline.vstring:
        ; --------------------------------------------------
        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vstring.icon,\
                OBJ_POINTER , .inline.vstring.ptr
        jmp    .error.argument
   .inline.vstring.icon:
        @@range 7-6, .error.memory
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 5]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        @@xshl  edi, 6
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], word 0x32FF
        @@xshr  edi, 7
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA FFFFFFFF           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ; --------------------------------------------------
        mov     [.cotype], 'svar'
        add     [.RSP], 4
        jmp    .exit
   .inline.vstring.ptr:
        ; --------------------------------------------------
        ;*MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], word 0x32FF
        @@xshr  edi, 7
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA FFFFFFFF           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ; --------------------------------------------------
        mov     [.cotype], 'svar'
        add     [.RSP], 4
        jmp    .exit

   .inline.pvalue:
        ; --------------------------------------------------
        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
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
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 2
        mov     [edi + 0], word 0x088B
        @@xshr  edi, 2
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*MOV     ECX, [EAX]        | 8B08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        mov     [.ezx], 0
;       dec     [.ezx]
        jmp    .inline.proc
   .inline.pvalue.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 5]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        mov     [edi - 6], byte 0xB9
        @@xshl  edi, 1
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc
   .inline.pvalue.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ;*
        ;>
        ; --------------------------------------------------
        pcase   esi,\
                @@pdouble , .inline.pvalue.irsp.rax.pdouble
   .inline.pvalue.irsp.rax.x:
        jmp    .error.argument
   .inline.pvalue.irsp.rax.pdouble:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424
        ;*MOV     ECX, EAX          | 89C1
        ; ADD     ESP, 4            | 83C404
        ;>
        ; --------------------------------------------------
        @@range 5, .error.memory
        mov     [edi + 0], word 0xC189
        mov     [edi + 2], word 0xC483
        mov     [edi + 4], byte 0x04
        @@xshr  edi, 5
        add     [.RSP], 4
        mov     [.ezx], 0
        jmp    .inline.proc
   .inline.pvalue.ptr:
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;*PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 4
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        mov     [.ezx], 0
        jmp    .inline.proc

   .inline.pcomplex:
        ; --------------------------------------------------
        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
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
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 2
        mov     [edi + 0], word 0x088B
        @@xshr  edi, 2
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*MOV     ECX, [EAX]        | 8B08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc
   .inline.pcomplex.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 5]
        stdcall tagettio, [sic], edx                        ; ?match any declared variable offset
        test    edx, edx
        jz     .error.pointer
        ;
        mov     [edi - 6], byte 0xB9
        @@xshl  edi, 1
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc
   .inline.pcomplex.ptr:
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;*PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 4
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc

   .inline.double:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ; PUSH    ECX               | 51
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
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*
        ;>
        ; ----------------------------------------------
        add     [.RSP], -4
        mov     esi, @@_io.eax_as_double
        mov     eax, @@_io.eax_as_double.size
        jmp    .inline.proc
   .inline.double.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 7-1, .error.memory
        @@xshl  edi, 1
        mov     [edi + 00], dword 0xC02A0FF2
        mov     [edi + 03], dword 0xF8C483C0
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV      EAX, VALUE | B9 SSSSSSSS
        ;*CVTSI2SD XMM0, EAX  | F20F2AC0
        ; ADD      ESP, -8    | 83C4 F8
        ;>
        ; ----------------------------------------------
    $else
        @@range 9-1, .error.memory
        @@xshl  edi, 1
        mov     [edi + 00], dword 0x89F8C483
        mov     [edi + 04], dword 0x04DB2404
        mov     [edi + 08], byte 0x24
        @@xshr  edi, 9
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B9 SSSSSSSS
        ;*ADD   ESP, -8         | 83C4 F8
        ; MOV   [ESP], EAX      | 890424
        ; FILD  DWORD [ESP]     | DB0424
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], -4
        jmp    .done
   .inline.double.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 7, .error.memory
        mov     [edi + 00], dword 0xC02A0FF2
        mov     [edi + 03], dword 0xFCC483C0
        @@xshr  edi, 7
        ; --------------------------------------------------
        ; ...                  | ...
        ; MOV       [ESP], EAX | 890424
        ;*CVTSI2SD  XMM0, EAX  | F20F2AC0
        ; ADD       ESP, -4    | 83C4 FC
        ;>
        ; --------------------------------------------------
    $else
        @@range 6, .error.memory
        mov     [edi + 00], dword 0x832404DB
        mov     [edi + 04], word 0xFCC4
        @@xshr  edi, 6
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424
        ;*FILD    DWORD [ESP]       | DB0424
        ; ADD     ESP, -4           | 83C4 FC
        ;>
        ; --------------------------------------------------
    $end
;       add     [.RSP], 0
        jmp    .done
   .inline.double.ptr:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ;*PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 4
        mov     [edi + 00], dword 0xC12A0FF2
        @@xshr  edi, 4
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV      ECX, VALUE       | B9 FFFFFFFF           ; pointer constant (9B)
        ;*CVTSI2SD XMM0, ECX        | F20F2AC1
        ;>
        ; --------------------------------------------------
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ;*NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@range 4-3, .error.memory
        @@xshl  edi, 3
        mov     [edi + 00], dword 0x592404DB
        @@xshr  edi, 4
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ;*FILD    DWORD [ESP]       | DB0424
        ; POP     ECX               | 59
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 4
        mov     [.ezx], 0
        jmp    .done

   .inline.int32:
        mov     [.firesp], 1
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ;?MOV     EDX, OFFSET       | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.int32.dst0,\
                OBJ_DOUBLE_SSE  , .inline.int32.dsse,\
                OBJ_DOUBLE_VAR  , .inline.int32.dvar,\
                OBJ_DOUBLE_CON  , .inline.int32.dcon,\
                OBJ_INT_VAR     , .inline.int32.ivar,\
                OBJ_INT_CON     , .inline.int32.icon,\
                OBJ_INT_RSP_RAX , .inline.int32.irsp.rax,\
                OBJ_STRING_VAR  , .inline.int32.svar,\
                OBJ_STRING_CON  , .inline.int32.scon,\
                OBJ_POINTER     , .inline.int32.ptr
        jmp    .error.argument
   .inline.int32.dst0:
   .inline.int32.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ;>
        ; --------------------------------------------------
;       add     [.RSP], 0
        mov     esi, @@_dv.esp_as_int32
        mov     eax, @@_dv.esp_as_int32.size
        jmp    .inline.proc
   .inline.int32.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 5                                  ; remove last PUSH... instructions
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS
        ;>
        ; ----------------------------------------------
;       add     [.RSP], 0
        mov     esi, @@_do.ecx_as_int32
        mov     eax, @@_do.ecx_as_int32.size
        jmp    .inline.proc
   .inline.int32.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = constant LO
        mov     edx, [edi - 11]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0x50
        @@xshr  edi, 6
        ; ----------------------------------------------
        ;*MOV   EAX, INT32      | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.cotype], 'icon'
        jmp    .exit
   .inline.int32.ivar:
   .inline.int32.icon:
   .inline.int32.irsp.rax:
   .inline.int32.svar:
   .inline.int32.scon:
   .inline.int32.ptr:
;       add     [.RSP], 0
;       jmp    .inline.proc
        jmp    .bypass.exit

   .inline.int64:
        mov     [.fi2resp], 1
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.int64.dst0,\
                OBJ_DOUBLE_SSE  , .inline.int64.dsse,\
                OBJ_DOUBLE_VAR  , .inline.int64.dvar,\
                OBJ_DOUBLE_CON  , .inline.int64.dcon,\
                OBJ_INT_VAR     , .inline.int64.ivar,\
                OBJ_INT_CON     , .inline.int64.icon,\
                OBJ_INT_RSP_RAX , .inline.int64.irsp.rax
        jmp    .error.argument
   .inline.int64.dst0:
   .inline.int64.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ;>
        ; --------------------------------------------------
;       add     [.RSP], 0
        mov     esi, @@_dv.esp_as_int64
        mov     eax, @@_dv.esp_as_int64.size
        jmp    .inline.proc
   .inline.int64.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 5                                  ; remove last PUSH... instructions
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 AAAAAAAA
        ;>
        ; ----------------------------------------------
;       add     [.RSP], 0
        mov     esi, @@_do.ecx_as_int64
        mov     eax, @@_do.ecx_as_int64.size
        jmp    .inline.proc
   .inline.int64.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = constant LO
        mov     edx, [edi - 11]                         ; edx = constant HI
        stdcall f2i64, ecx, edx                         ; eax:edx = int64 constant
        @@xshl  edi, 12
        mov     [edi + 00], byte 0x68
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0x68
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*PUSH  INT64.HI        | 68 FFFF..HI
        ; PUSH  INT64.LO        | 68 FFFF..LO
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .exit
   .inline.int64.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 5-2, .error.memory
        @@xshl  edi, 2
        mov     [edi + 00], dword 0x5299008B
        mov     [edi + 04], byte 0x50
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   EAX, DWORD [EAX]| 8B00
        ; CDQ                   | 99                    ; convert signed DWORD in EAX to a signed quad word in EDX:EAX
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
        jmp    .exit
   .inline.int64.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        @@range 3-1, .error.memory
        @@xshl  edi, 1
        mov     [edi + 00], byte 0x99
        mov     [edi + 01], word 0x5052
        @@xshr  edi, 3
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ;*CDQ                   | 99                    ; convert signed DWORD in EAX to a signed quad word in EDX:EAX
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
        jmp    .exit
   .inline.int64.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ;>
        ; --------------------------------------------------
        @@range 6-3, .error.memory
        @@xshl  edi, 3
        mov     [edi + 00], dword 0x9904C483
        mov     [edi + 04], word 0x5052
        @@xshr  edi, 6
        ; --------------------------------------------------
        ; ...                       | ...
        ;*ADD     ESP, 4            | 83C404
        ; CDQ                       | 99                    ; convert signed DWORD in EAX to a signed quad word in EDX:EAX
        ; PUSH    EDX               | 52
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        jmp    .exit

   .inline.is.x32:
        mov     eax, 1
;       add     [.RSP], 0
        jmp    .inline.eax.icon
   .inline.is.n32:
        mov     eax, 0
;       add     [.RSP], 0
        jmp    .inline.eax.icon
   .inline.is.x64:
        mov     eax, 0
;       add     [.RSP], 0
        jmp    .inline.eax.icon
   .inline.is.n64:
        mov     eax, 1
;       add     [.RSP], 0
        jmp    .inline.eax.icon
   .inline.dll.bits:
        mov     eax, 32
;       add     [.RSP], 0
        jmp    .inline.eax.icon

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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
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
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;*PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 5
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;*                          |
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        jmp    .inline.proc.1p.pp.proc
   .inline.proc.1p.pp.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.proc.1p.pp.svar:
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;*PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.proc.1p.pp.isvar:
        mov     [edi - 07], byte 0xB9
        @@xshl  edi, 2
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;*                          |
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
;       jmp    .inline.proc.1p.pp.proc.mode.1
   .inline.proc.1p.pp.proc.mode.1:
        mov     [.mode], 1
   .inline.proc.1p.pp.proc:
        dec     [.ezx]
        stdcall map_proc_x2, @x2_procs_1p_pp, [.proc], [.mode]
        jmp    .inline.proc
   .inline.proc.1p.pp.no.var:
        pcase   esi,\
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
   .inline.robi:
        mov     [.proc], @@robi.map.index
        jmp    .inline.proc.1p
   .inline.quebi:
        mov     [.proc], @@quebi.map.index
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
   .inline.robo:
        mov     [.proc], @@robo.map.index
        jmp    .inline.proc.1p
   .inline.quebo:
        mov     [.proc], @@quebo.map.index
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
   .inline.ronna:
        mov     [.proc], @@ronna.map.index
        jmp    .inline.proc.1p
   .inline.quetta:
        mov     [.proc], @@quetta.map.index
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
   .inline.ronto:
        mov     [.proc], @@ronto.map.index
        jmp    .inline.proc.1p
   .inline.quecto:
        mov     [.proc], @@quecto.map.index
        jmp    .inline.proc.1p
; ------
   .inline.proc.1p:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall map_proc_x3_ecx, @x3_procs_1p, [.proc], 2   ; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.1p.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.con.call:
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
        ;
   .inline.proc.1p.dst0:
   .inline.proc.1p.dsse:
   .inline.proc.1p.dvar:
        jmp    .inline.proc.1p.proc
   .inline.proc.1p.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
    $else
        fld     qword [esp - 08]
    $end
        @@xshl  edi, 12
        add     [.RSP], 8
        jmp    .inline.proc.1p.con
   .inline.proc.1p.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]
    $else
        fild    dword [edi - 05]
    $end
        @@xshl  edi, 6
        add     [.RSP], 4
        jmp    .inline.proc.1p.con
   .inline.proc.1p.irsp.rax:
        add     [.RSP], 4
   .inline.proc.1p.ivar:
   .inline.proc.1p.proc.mode.1:
        mov     [.mode], 1
        mov     [.fpatype], 'i'
   .inline.proc.1p.proc:
        stdcall map_proc_x3, @x3_procs_1p, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.signbit:
        mov     [.proc], @@signbit.map.index
        jmp    .inline.proc.1p.ir
   .inline.rsignbit:
        mov     [.proc], @@rsignbit.map.index
        jmp    .inline.proc.1p.ir
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
    $else
        fld     qword [esp - 08]
    $end
        @@xshl  edi, 12
        add     [.RSP], 8
        stdcall map_proc_x3_ecx, @x3_procs_1p_ir, [.proc], 1; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.1p.ir.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.ir.con.call:
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
        jmp    .inline.eax.icon
   .inline.proc.1p.ir.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xA1
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EAX, DWORD [FF+]  | A1 FFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        mov     [.ezx], 0
        mov     [.fpatype], 'i'
        stdcall map_proc_x3, @x3_procs_1p_ir, [.proc], 2
        jmp    .inline.proc
   .inline.proc.1p.ir.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 1
        add     [.RSP], 4
        stdcall map_proc_x3_ecx, @x3_procs_1p_ir, [.proc], 2; ecx = proc_reg offset
        test    ecx, ecx
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall map_proc_x3_ecx, @x3_procs_1p_xr, [.proc], 2; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.1p.xr.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.xr.con.call:
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
        ;
   .inline.proc.1p.xr.dst0:
   .inline.proc.1p.xr.dsse:
   .inline.proc.1p.xr.dvar:
        jmp    .inline.proc.1p.xr.proc
   .inline.proc.1p.xr.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
    $else
        fld     qword [esp - 08]
    $end
        @@xshl  edi, 12
        add     [.RSP], 8
        jmp    .inline.proc.1p.xr.con
   .inline.proc.1p.xr.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]
    $else
        fild    dword [edi - 05]
    $end
        @@xshl  edi, 6
        add     [.RSP], 4
        jmp    .inline.proc.1p.xr.con
   .inline.proc.1p.xr.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall map_proc_x3_ecx, @x3_procs_1p_xr, [.proc], 1; ecx = proc.enter offset
        test    ecx, ecx
        jz     .error.exit
        ;
;       @@range 5-7, .error.memory
;       mov     edx, [edi - 06]
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xA1
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EAX, DWORD [FF+]  | A1 FFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        mov     [.ezx], 0
        mov     [.fpatype], 'i'
        stdcall map_proc_x3, @x3_procs_1p_xr, [.proc], 1
        jmp    .inline.proc
   .inline.proc.1p.xr.irsp.rax:
        add     [.RSP], 4
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
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
        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall map_proc_x2_ecx, @x2_iprocs_i1p, [.proc], 1 ; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.iproc.i1p.con.call
        jmp    .error.exit
   .inline.iproc.i1p.con.call:
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
   .inline.iproc.i1p.con.icon:
        jmp    .inline.eax.icon
        ;
   .inline.iproc.i1p.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        @@xshl  edi, 12
        add     [.RSP], 8
        jmp    .inline.iproc.i1p.con
   .inline.iproc.i1p.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     eax, dword [edi - 05]
        @@xshl  edi, 6
        add     [.RSP], 4
        jmp    .inline.iproc.i1p.con
   .inline.iproc.i1p.irsp.rax:
        add     [.RSP], 4
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall map_proc_x3_ecx, @x3_procs_1p_dm, [.proc], 2; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.1p.dm.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.dm.con.call:
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
        ;
   .inline.proc.1p.dm.dst0:
   .inline.proc.1p.dm.dsse:
   .inline.proc.1p.dm.dvar:
        jmp    .inline.proc.1p.dm.proc
   .inline.proc.1p.dm.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
    $else
        fld     qword [esp - 08]
    $end
        @@xshl  edi, 12
        add     [.RSP], 8
        jmp    .inline.proc.1p.dm.con
   .inline.proc.1p.dm.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]
    $else
        fild    dword [edi - 05]
    $end
        @@xshl  edi, 6
        add     [.RSP], 4
        jmp    .inline.proc.1p.dm.con
   .inline.proc.1p.dm.irsp.rax:
        add     [.RSP], 4
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
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
;       stdcall map_proc_x3_ecx, @x3_procs_2p, [.proc], 2   ; ecx = proc.enter offset
        stdcall map_proc_x4_ecx, @x4_procs_2p, [.proc], 2   ; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.2p.con.con.call
    $ifndef _SSEX
        fstp    st0
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.2p.con.con.call:
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.eax.icon
        ;
   .inline.proc.2p.dst0:
   .inline.proc.2p.dsse:
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2p.dvar.dst0,\
                OBJ_DOUBLE_SSE , .inline.proc.2p.dvar.dsse,\
                OBJ_DOUBLE_VAR , .inline.proc.2p.dvar.dvar,\
                OBJ_DOUBLE_CON , .inline.proc.2p.dvar.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.dvar.icon
        jmp    .error.argument
   .inline.proc.2p.dvar.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 22-16, .error.memory
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 21]                      ; xmm0 = int32 as double
        movsd   qword [esp - 8], xmm0                       ; [esp - 8] = double constant
    $else
        fild    dword [edi - 15]                            ; st0 = int32 as double
        fstp    qword [esp - 8]                             ; [esp - 8] = double constant
    $end
        mov     ecx, [edi - 09]                             ; ecx = double variable offset
        @@xshl  edi, 16
        mov     [edi + 00], byte 0xBA
        mov     edx, [esp - 4]                              ; edx = double constant HI
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     edx, [esp - 8]                              ; edx = double constant LO
        mov     [edi + 06], edx
        mov     [edi + 10], dword 0x00B95152
        mov     [edi + 13], ecx
        mov     [edi + 17], dword 0xFF0471FF
        mov     [edi + 21], byte 0x31
        @@xshr  edi, 22
        add     [.RSP], -4
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.proc.2p.dvar.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        pcase   esi,\
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
        mov     ecx, [edi - 16]                             ; ecx = constant LO
        mov     edx, [edi - 21]                             ; edx = constant HI
        mov     [esp - 08], ecx
        mov     [esp - 04], edx
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        divsd   xmm0, qword [esp - 08]
    $else
        fld1
        fld     qword [esp - 08]
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
        movsd   qword [esp - 08], xmm0
    $else
        fstp    qword [esp - 08]
    $end
        mov     ecx, [esp - 08]
        mov     edx, [esp - 04]
        mov     [edi - 16], ecx
        mov     [edi - 21], edx
        mov     ecx, [.procn]
        mov     [.proc], ecx
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar.dcon.div.x.error:
    $ifndef _SSEX
;       fstp    qword [esp - 08]
        fstp    st0
    $end
        jmp    .error.evaluate
;       jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar.dvar:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, dword [edi - 09]
        mov     edx, dword [edi - 19]
        cmp     ecx, edx
        jne    .inline.proc.2p.proc
        pcase   esi,\
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
        pcase   esi,\
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
        @@xshl  edi, 20
    $ifdef _SSEX
        xorpd   xmm0, xmm0
        jmp    .inline.sse.dcon
    $else
        fldz
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.dvar.dvar.dcon.1:
        add     [.RSP], 16
        @@xshl  edi, 20
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        jmp    .inline.sse.dcon
    $else
        fld1
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.dvar.dvar.icon.0:
        add     [.RSP], 16
        @@xshl  edi, 20
        xor     eax, eax
        jmp    .inline.eax.icon
   .inline.proc.2p.dvar.dvar.icon.1:
        add     [.RSP], 16
        @@xshl  edi, 20
        mov     eax, 1
        jmp    .inline.eax.icon
   .inline.proc.2p.dvar.dst0:
   .inline.proc.2p.dvar.dsse:
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
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
        pcase   esi,\
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
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        mov     [esp - 08], ecx
        mov     [esp - 04], edx
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        divsd   xmm0, qword [esp - 08]
    $else
        fld1
        fld     qword [esp - 08]
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
        movsd   qword [esp - 08], xmm0
    $else
        fstp    qword [esp - 08]
    $end
        mov     ecx, [esp - 08]
        mov     edx, [esp - 04]
        mov     [edi - 06], ecx
        mov     [edi - 11], edx
        mov     ecx, [.procn]
        mov     [.proc], ecx
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon.dx.divr.x.error:
    $ifndef _SSEX
;       fstp    qword [esp - 08]
        fstp    st0
    $end
        jmp    .error.evaluate
;       jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
        mov     eax, [edi - 18]
        mov     [esp - 16], eax
        mov     edx, [edi - 23]
        mov     [esp - 12], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
        movsd   xmm1, qword [esp - 16]
    $else
        fld     qword [esp - 08]
        fld     qword [esp - 16]
    $end
        @@xshl  edi, 24
        add     [.RSP], 16
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
       cvtsi2sd xmm1, dword [edi - 17]
    $else
        fld     qword [esp - 08]
        fild    dword [edi - 17]
    $end
        @@xshl  edi, 18
        add     [.RSP], 12
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.dcon.ivar:
   .inline.proc.2p.dcon.irsp.rax:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   EDX, QWORD.HI   | BA FFFF..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 FFFF..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 50
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = constant LO
        mov     edx, [edi - 11]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0x50
        @@xshr  edi, 6
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   EAX, INT32      | B8 FFFFFFFF
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        jmp    .inline.proc.2p.mode.1
        ;
   .inline.proc.2p.irsp.rax:
        jmp    .inline.proc.2p.mode.1
   .inline.proc.2p.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.proc.2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.proc.2p.ivar.ivar,\
                OBJ_INT_CON     , .inline.proc.2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.proc.2p.icon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -6               ; ecx = object type
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
        ; FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        @@range 12-6, .error.memory
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]                      ; xmm0 = int32 as double
        movsd   qword [esp - 8], xmm0                       ; [esp - 8] = double constant
    $else
        fild    dword [edi - 05]                            ; st0 = int32 as double
        fstp    qword [esp - 8]                             ; [esp - 8] = double constant
    $end
        @@xshl  edi, 6
        mov     [edi + 00], byte 0xBA
        mov     edx, [esp - 4]                              ; edx = double constant HI
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     edx, [esp - 8]                              ; edx = double constant LO
        mov     [edi + 06], edx
        mov     [edi + 10], word 0x5152
        @@xshr  edi, 12
        add     [.RSP], -4
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        jmp    .inline.proc.2p.dcon.dst0
   .inline.proc.2p.icon.dvar:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        @@range 12-6, .error.memory
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]                      ; xmm0 = int32 as double
        movsd   qword [esp - 8], xmm0                       ; [esp - 8] = double constant
    $else
        fild    dword [edi - 05]                            ; st0 = int32 as double
        fstp    qword [esp - 8]                             ; [esp - 8] = double constant
    $end
        @@xshl  edi, 6
        mov     [edi + 00], byte 0xBA
        mov     edx, [esp - 4]                              ; edx = double constant HI
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     edx, [esp - 8]                              ; edx = double constant LO
        mov     [edi + 06], edx
        mov     [edi + 10], word 0x5152
        @@xshr  edi, 12
        add     [.RSP], -4
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        jmp    .inline.proc.2p.dcon.dvar
   .inline.proc.2p.icon.dcon:
        ; ----------------------------------------------
        ; MOV   EDX, QWORD.HI   | BA FFFF..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 FFFF..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 12]
        mov     [esp - 08], eax
        mov     edx, [edi - 17]
        mov     [esp - 04], edx
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]
        movsd   qword [esp - 08], xmm0
    $else
        fild    dword [edi - 05]
        fld     qword [esp - 08]
    $end
        @@xshl  edi, 18
        add     [.RSP], 12
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.icon.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, dword [edi - 05]
       cvtsi2sd xmm1, dword [edi - 11]
    $else
        fild    dword [edi - 05]
        fild    dword [edi - 11]
    $end
        @@xshl  edi, 12
        add     [.RSP], 8
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA FFFF..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 FFFF..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 13]                         ; ecx = constant LO
        mov     edx, [edi - 18]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], word 0xB850
        mov     [edi + 07], edx
        mov     [edi + 11], word 0x30FF
        @@xshr  edi, 13
        ; ----------------------------------------------
        ;*MOV   EAX, INT32      | B8 FFFFFFFF
        ; PUSH  EAX             | 50
        ; MOV   EAX, OFFSET     | B8 FFFFFFFF
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        jmp    .inline.proc.2p.mode.1
   .inline.proc.2p.ivar.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, dword [edi - 06]
        mov     edx, dword [edi - 13]
        cmp     ecx, edx
        je     .inline.proc.2p.ivar.ivar.x
        ;
        stdcall map_proc_x4_ecx, @x4_procs_2p, [.proc], 3   ; rcx = proc.enter offset
        test    ecx, ecx
        jz     .inline.proc.2p.mode.1
        ;
;       @@range 11-14, .error.memory
        mov     edx, [edi - 13]
        mov     eax, [edi - 06]
        @@xshl  edi, 14
        mov     [edi + 00], word 0x0D8B
        mov     [edi + 02], edx
        mov     [edi + 06], byte 0xA1
        mov     [edi + 07], eax
        @@xshr  edi, 11
        ; --------------------------------------------------
        ;*MOV     ECX, DWORD [FF+]  | 8B0D FFFFFFFF
        ; MOV     EAX, DWORD [FF+]  | A1   FFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.fpatype], 'i'
        stdcall map_proc_x4, @x4_procs_2p, [.proc], 3
        jmp    .inline.proc
   .inline.proc.2p.ivar.ivar.x:
        pcase   esi,\
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
        pcase   esi,\
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
        add     [.RSP], 8
        @@xshl  edi, 14
    $ifdef _SSEX
        xorpd   xmm0, xmm0
        jmp    .inline.sse.dcon
    $else
        fldz
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.ivar.ivar.dcon.1:
        add     [.RSP], 8
        @@xshl  edi, 14
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        jmp    .inline.sse.dcon
    $else
        fld1
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.ivar.ivar.icon.0:
        add     [.RSP], 8
        @@xshl  edi, 14
        xor     eax, eax
        jmp    .inline.eax.icon
   .inline.proc.2p.ivar.ivar.icon.1:
        add     [.RSP], 8
        @@xshl  edi, 14
        mov     eax, 1
        jmp    .inline.eax.icon
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
        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -9                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.2p.ptr.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.ptr.icon
        jmp    .error.argument
   .inline.proc.2p.ptr.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 15]                             ; ecx = constant LO
        mov     edx, [edi - 20]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     ecx, [edi - 08]                             ; ecx = offset value
        @@xshl  edi, 21
        add     [.RSP], 12
        jmp    .inline.proc.2p.ptr.proc
   .inline.proc.2p.ptr.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 14]                             ; eax = integer constant
        mov     ecx, [edi - 08]                             ; ecx = offset value
        @@xshl  edi, 15
        add     [.RSP], 8
;       jmp    .inline.proc.2p.ptr.proc
   .inline.proc.2p.ptr.proc:
        case    [.proc],\
                @@add.map.index, .inline.proc.2p.ptr.add,\
                @@sub.map.index, .inline.proc.2p.ptr.sub
        jmp    .error.argument
   .inline.proc.2p.ptr.sub:
        sub     ecx, eax
        jmp    .inline.proc.2p.ptr.main
   .inline.proc.2p.ptr.add:
        add     ecx, eax
   .inline.proc.2p.ptr.main:
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'pcon'
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
        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall map_proc_x2_edx, @x2_iprocs_i2p, [.proc], 1 ; edx = proc.enter offset
        test    edx, edx
        jnz    .inline.iproc.i2p.con.con.call
        jmp    .error.exit
   .inline.iproc.i2p.con.con.call:
        @@xshl  edi, [.xshl], eax
        push    edi ebx ; save registers when calling the built-in function
        mov     eax, [.icon1]
        mov     ecx, [.icon2]
        call    edx
        pop     ebx edi
   .inline.iproc.i2p.con.con.icon:
        jmp    .inline.eax.icon
        ;
   .inline.iproc.i2p.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.ivar.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.ivar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 13]                             ; ecx = constant LO
        mov     edx, [edi - 18]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [edi - 06]                             ; edx = offset value
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0x50
        mov     [edi + 06], byte 0xB8
        mov     [edi + 07], edx
        mov     [edi + 11], word 0x30FF
        @@xshr  edi, 13
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF
        ; PUSH    EAX               | 50
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF
        ; PUSH    DWORD [EAX]       | FF30
        ; --------------------------------------------------
        add     [.RSP], 4
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.ivar.ivar:
;       add     [.RSP], 0
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.ivar.icon:
;       add     [.RSP], 0
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.ivar.irsp.rax:
        add     [.RSP], 4
        jmp    .inline.iproc.i2p.proc
        ;
   .inline.iproc.i2p.irsp.rax:
        jmp    .inline.iproc.i2p.proc
        ;
   .inline.iproc.i2p.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.dcon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.dcon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.dcon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.dcon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.dcon.ivar:
        add     [.RSP], 4
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.dcon.irsp.rax:
        add     [.RSP], 8
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 24
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon1], eax
        mov     ecx, [edi - 18]                             ; ecx = constant LO
        mov     edx, [edi - 23]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 18
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon1], eax
        mov     eax, [edi - 17]                             ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 12
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.icon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.icon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.icon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.icon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.icon.ivar:
;       add     [.RSP], 0
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.icon.irsp.rax:
        add     [.RSP], 4
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.icon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 18
        mov     eax, [edi - 05]                             ; eax = int32 constant
        mov     [.icon1], eax
        mov     ecx, [edi - 12]                             ; ecx = constant LO
        mov     edx, [edi - 17]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 12
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.icon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 12
        mov     eax, [edi - 05]                             ; eax = int32 constant
        mov     [.icon1], eax
        mov     eax, [edi - 11]                             ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 8
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
        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall map_proc_x4_edx, @x4_iprocs_i2p, [.proc], 1 ; edx = proc.enter offset
        test    edx, edx
        jnz    .inline.iproc.i2p.iv.con.con.call
        jmp    .error.exit
   .inline.iproc.i2p.iv.con.con.call:
        @@xshl  edi, [.xshl], eax
        push    edi ebx ; save registers when calling the built-in function
        mov     eax, [.icon1]
        mov     ecx, [.icon2]
        call    edx
        pop     ebx edi
   .inline.iproc.i2p.iv.con.con.icon:
        jmp    .inline.eax.icon
        ;
   .inline.iproc.i2p.iv.irsp.rax:
        jmp    .inline.iproc.i2p.iv.proc
        ;
   .inline.iproc.i2p.iv.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.dcon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.dcon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.dcon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.dcon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.iv.dcon.ivar:
        add     [.RSP], 4
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.dcon.irsp.rax:
        add     [.RSP], 8
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 24
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon1], eax
        mov     ecx, [edi - 18]                             ; ecx = constant LO
        mov     edx, [edi - 23]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 18
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon1], eax
        mov     eax, [edi - 17]                             ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 12
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.icon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.icon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.icon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.icon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.iv.icon.ivar:
;       add     [.RSP], 0
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.icon.irsp.rax:
        add     [.RSP], 4
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.icon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 18
        mov     eax, [edi - 05]                             ; eax = int32 constant
        mov     [.icon1], eax
        mov     ecx, [edi - 12]                             ; ecx = constant LO
        mov     edx, [edi - 17]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 12
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.icon.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 12
        mov     eax, [edi - 05]                             ; eax = int32 constant
        mov     [.icon1], eax
        mov     eax, [edi - 11]                             ; eax = int32 constant
        mov     [.icon2], eax
        add     [.RSP], 8
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.proc:
        stdcall map_proc_x4, @x4_iprocs_i2p, [.proc], [.mode]
        jmp    .inline.proc
        ;
   .inline.iproc.i2p.iv.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.ivar.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.ivar.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.ivar.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.iv.ivar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 13]                             ; ecx = constant LO
        mov     edx, [edi - 18]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [edi - 06]                             ; edx = offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EAX, INT32        | B8 FFFFFFFF
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     [.mode], 3
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.ivar.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = offset
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EAX, INT32        | B8 FFFFFFFF
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.mode], 3
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF
        ; ADD     ESP, 4            | 83C4 04
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.mode], 3
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.ivar.ivar:
        @@xshl  edi, 7
        mov     [edi + 0], byte 0xB9
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     [.mode], 2
        jmp    .inline.iproc.i2p.iv.proc

; ------
   .inline.ipow:
        cmp     [.arg.count], 2
        jl     .error.argument
        mov     ecx, [.arg.cursor]
        cmp     byte [ecx - 1], 'f'                         ; argument #1 data type
        jne    .error.argument
        cmp     byte [ecx - 3], 'i'                         ; argument #2 data type
        jne    .error.argument
        add     [.SPD], 4                                   ; one 4-byte argument
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ;-integer constant (6B)
        ;?PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_SSE , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_VAR , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_CON , .inline.proc.2ps.dvar.dcon
        jmp    .error.argument
        ;
   .inline.proc.2ps.dvar.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                             ; ecx = double constant LO
        test    ecx, ecx
        jnz    .inline.proc.2ps.proc
        mov     ecx, [edi - 21]                             ; ecx = double constant HI
        case    ecx,\
                [??.0.0.H.HI], .inline.proc.2ps.dvar.dcon.0,\
                [??.1.0.H.HI], .inline.proc.2ps.dvar.dcon.1,\
                [??.2.0.H.HI], .inline.proc.2ps.dvar.dcon.2,\
                [??.3.0.H.HI], .inline.proc.2ps.dvar.dcon.3,\
                [??.4.0.H.HI], .inline.proc.2ps.dvar.dcon.4
   .inline.proc.2ps.dvar.dcon.x:
        jmp    .inline.proc.2ps.proc
        ;
   .inline.proc.2ps.dvar.dcon.0:
;       mov     [.moden], 3
        stdcall map_proc_x8, @x8_procs_2ps, [.proc], 3
        test    esi, esi
        jz     .inline.proc.2ps.proc
        @@xshl  edi, 22
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
        test    esi, esi
        jz     .inline.proc.2ps.proc
        mov     edx, [edi - 09]                             ; edx = double variable offset
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
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
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_SSE , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_VAR , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_CON , .inline.proc.2ps.dcon.dcon
        jmp    .error.argument
        ;
   .inline.proc.2ps.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 18]
        mov     dword [.dcon1 + 00], eax
        mov     edx, [edi - 23]
        mov     dword [.dcon1 + 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [.dcon1]
        call    @@frac.enter
        movsd   qword [.dcon2], xmm0
    $else
        fld     qword [.dcon1]
        call    @@frac.enter
        fstp    qword [.dcon2]
    $end
        mov     ecx, dword [.dcon2 + 00]
        or      ecx, dword [.dcon2 + 04]
        test    ecx, ecx
        jnz    .inline.proc.2ps.dcon.dcon.main
    $ifdef _SSEX
        movsd   xmm0, qword [.dcon1]
      cvttsd2si ecx, xmm0
    $else
        fld     qword [.dcon1]
        call    @@int.enter
        fistp   dword [.icon1]
        mov     ecx, dword [.icon1]
    $end
   .inline.proc.2ps.dcon.dcon.i:
        test    ecx, 1
        jnz    .inline.proc.2ps.dcon.dcon.main
   .inline.proc.2ps.dcon.dcon.i.even:
;       mov     [.moden], 1
        stdcall map_proc_x8_ecx, @x8_procs_2ps, [.proc], 1  ; ecx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2ps.dcon.dcon.main:
;       mov     [.moden], 2
        stdcall map_proc_x8_ecx, @x8_procs_2ps, [.proc], 2  ; ecx = proc.enter offset
        test    ecx, ecx
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2pr.dcon.x,\
                OBJ_DOUBLE_SSE , .inline.proc.2pr.dcon.x,\
                OBJ_DOUBLE_VAR , .inline.proc.2pr.dcon.x,\
                OBJ_DOUBLE_CON , .inline.proc.2pr.dcon.dcon
        jmp    .error.argument
        ;
   .inline.proc.2pr.dcon.x:
        mov     ecx, [edi - 06]                             ; ecx = double constant LO
        test    ecx, ecx
        jnz    .inline.proc.2pr.proc
        mov     ecx, [edi - 11]                             ; ecx = double constant HI
        case    ecx,\
                [??.0.0.H.HI], .inline.proc.2pr.dcon.0,\
                [??.1.0.H.HI], .inline.proc.2pr.dcon.1,\
                [??.2.0.H.HI], .inline.proc.2pr.dcon.2,\
                [??.3.0.H.HI], .inline.proc.2pr.dcon.3,\
                [??.4.0.H.HI], .inline.proc.2pr.dcon.4
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
        test    esi, esi
        jz     .inline.proc.2pr.proc
        @@xshl  edi, 12
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
        ;
   .inline.proc.2pr.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     dword [.dcon1 + 00], eax
        mov     edx, [edi - 11]
        mov     dword [.dcon1 + 04], edx
    $ifdef _SSEX
        movsd   xmm0, qword [.dcon1]
        call    @@frac.enter
        movsd   qword [.dcon2], xmm0
    $else
        fld     qword [.dcon1]
        call    @@frac.enter
        fstp    qword [.dcon2]
    $end
        mov     ecx, dword [.dcon2 + 00]
        or      ecx, dword [.dcon2 + 04]
        test    ecx, ecx
        jnz    .inline.proc.2pr.dcon.dcon.main
    $ifdef _SSEX
        movsd   xmm0, qword [.dcon1]
      cvttsd2si ecx, xmm0
    $else
        fld     qword [.dcon1]
        call    @@int.enter
        fistp   dword [.icon1]
        mov     ecx, dword [.icon1]
    $end
   .inline.proc.2pr.dcon.i.dcon:
        test    ecx, 1
        jnz    .inline.proc.2pr.dcon.dcon.main
   .inline.proc.2pr.dcon.i.even.dcon:
;       mov     [.moden], 1
        stdcall map_proc_x8_ecx, @x8_procs_2pr, [.proc], 1  ; rcx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2pr.dcon.dcon.main:
;       mov     [.moden], 2
        stdcall map_proc_x8_ecx, @x8_procs_2pr, [.proc], 2  ; rcx = proc.enter offset
        test    ecx, ecx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2pr.proc:
        stdcall map_proc_x8, @x8_procs_2pr, [.proc], [.mode]
        jmp    .inline.proc
; ------
; ------
   .inline.proc.2px.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 06]
        mov     [esp - 08], eax
        mov     edx, [edi - 11]
        mov     [esp - 04], edx
        mov     eax, [edi - 18]
        mov     [esp - 16], eax
        mov     edx, [edi - 23]
        mov     [esp - 12], edx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 08]
        movsd   xmm1, qword [esp - 16]
    $else
        fld     qword [esp - 08]
        fld     qword [esp - 16]
    $end
        @@xshl  edi, 24
        push    edi ebx ; save registers when calling the built-in function
        call    ecx
        pop     ebx edi
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
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.co.proc.1p.dvar,\
                OBJ_INT_VAR    , .inline.co.proc.1p.ivar
        jmp    .error.argument
   .inline.co.proc.1p.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 5                                  ; remove last PUSH... instructions
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.proc
   .inline.co.proc.1p.ivar:
        mov     [.mode], 1
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     [edi - 7], byte 0xB9
        @@xshl  edi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
        mov     [.ezx], 0
   .inline.co.proc.1p.ivar.proc:
        stdcall map_proc_x2, @x2_co_procs_1p, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.co.bnot:
; ------
   .inline.co.iproc.1p:
        ; ----------------------------------------------
        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.co.iproc.1p.ivar
        jmp    .error.argument
   .inline.co.iproc.1p.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     [edi - 7], byte 0xB9
        @@xshl  edi, 2
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.co.proc.2p.dvar.x:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 5                                  ; remove last PUSH... instructions
        ; ----------------------------------------------
        ; ...
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.co.proc.2p.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 17-12, .error.memory
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0x002A0FF2
        mov     [edi + 09], dword 0xF2F8C483
        mov     [edi + 13], dword 0x2404110F
        @@xshr  edi, 17
        ; ----------------------------------------------
        ; MOV      EAX, OFFSET       | B8 SSSSSSSS
        ;*MOV      ECX, OFFSET       | B9 DDDDDDDD
        ; CVTSI2SD XMM0, DWORD [EAX] | F20F2A00
        ; ADD      ESP, -8           | 83C4F8
        ; MOVSD    QWORD [ESP], XMM0 | F20F110424
        ;>
        ; ----------------------------------------------
    $else
        @@range 13-12, .error.memory
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0xC48300DB
        mov     [edi + 09], dword 0x241CDDF8
        @@xshr  edi, 13
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; FILD  DWORD [EAX]     | DB00
        ; ADD   ESP, -8         | 83C4F8
        ; FSTP  QWORD [ESP]     | DD1C24
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc
   .inline.co.proc.2p.dvar.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 15-10, .error.memory
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], word 0xB950
        mov     [edi + 02], edx
        mov     [edi + 06], dword 0xC02A0FF2
        mov     [edi + 10], dword 0x04110FF2
        mov     [edi + 14], byte 0x24
        @@xshr  edi, 15
        ; ----------------------------------------------
        ; MOV      EAX, VALUE        | B8 SSSSSSSS
        ; PUSH     EAX               | 50
        ;*PUSH     EAX               | 50
        ; MOV      ECX, OFFSET       | B9 DDDDDDDD
        ; CVTSI2SD XMM0, EAX         | F20F2AC0
        ; MOVSD    QWORD [ESP], XMM0 | F20F110424
        ;>
        ; ----------------------------------------------
    $else
        @@range 12-10, .error.memory
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], word 0xB950
        mov     [edi + 02], edx
        mov     [edi + 06], dword 0xDD2404DB
        mov     [edi + 10], word 0x241C
        @@xshr  edi, 12
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ; PUSH  EAX             | 50
        ;*PUSH  EAX             | 50
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; FILD  DWORD [ESP]     | DB0424
        ; FSTP  QWORD [ESP]     | DD1C24
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc
   .inline.co.proc.2p.dvar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 17-13, .error.memory
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0xC02A0FF2
        mov     [edi + 09], dword 0xF2FCC483
        mov     [edi + 13], dword 0x2404110F
        @@xshr  edi, 17
        ; ----------------------------------------------
        ; ...                        | ...
        ;*MOV      ECX, OFFSET       | B9 DDDDDDDD
        ; CVTSI2SD XMM0, EAX         | F20F2AC0
        ; ADD      ESP, -4           | 83C4 FC
        ; MOVSD    QWORD [ESP], XMM0 | F20F110424
        ;>
        ; ----------------------------------------------
    $else
        @@range 9-5, .error.memory
        @@xshl  edi, 5
        mov     [edi + 00], dword 0x832404DB
        mov     [edi + 04], dword 0x1CDDFCC4
        mov     [edi + 08], byte 0x24
        @@xshr  edi, 9
        ; ----------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;*FILD    DWORD [ESP]       | DB0424
        ; ADD     ESP, -4           | 83C4 FC
        ; FSTP    QWORD [ESP]       | DD1C24
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
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
        ;*FSTP  QWORD [ESP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 12-10, .error.memory
        mov     ecx, @@__int32                          ; ecx = "int" proc offset
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x00B9D2FF
        mov     [edi + 08], edx
        @@xshr  edi, 12
        ; ----------------------------------------------
        ;*MOV   EDX, @@__int32  | BA PPPPPPPP
        ; CALL  EDX             | FFD2
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
;       @@range 9-12, .error.memory
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0xC02C0FF2
        mov     [edi + 04], byte 0xB9
        mov     [edi + 05], edx
        @@xshr  edi, 9
        ; --------------------------------------------------
        ;*CVTTSD2SI  EAX, XMM0   | F20F2CC0
        ; MOV        ECX, OFFSET | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 13-12, .error.memory
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0x01100FF2
        mov     [edi + 04], dword 0xC02C0FF2
        mov     [edi + 08], byte 0xB9
        mov     [edi + 09], edx
        @@xshr  edi, 13
        ; ----------------------------------------------
        ; MOV        ECX, OFFSET       | B9 SSSSSSSS
        ;*MOVSD      XMM0, QWORD [ECX] | F20F1001
        ; CVTTSD2SI  EAX, XMM0         | F20F2CC0
        ; MOV        ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        @@range 14-12, .error.memory
        mov     ecx, @@__int32                          ; ecx = "int" proc offset
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0x00BA01DD
        mov     [edi + 03], ecx
        mov     [edi + 07], dword 0x00B9D2FF
        mov     [edi + 10], edx
        @@xshr  edi, 14
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS
        ;*FLD   QWORD [ECX]     | DD01
        ; MOV   EDX, @@__int32  | BA PPPPPPPP
        ; CALL  EDX             | FFD2
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 13]                         ; ecx = constant LO
        mov     edx, [edi - 18]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        mov     edx, [edi - 06]                         ; edx = destination offset
        cmp     eax, +1
        je     .inline.co.proc.2p.ivar.dcon.p1
        cmp     eax, -1
        je     .inline.co.proc.2p.ivar.dcon.m1
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, INT32      | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dcon.p1:
        mov     [.mode], 2
   .inline.co.proc.2p.ivar.dcon.p1.x:
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dcon.m1:
        mov     [.mode], 3
   .inline.co.proc.2p.ivar.dcon.m1.x:
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], dword 0x00B9008B
        mov     [edi + 03], edx
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   EAX, [EAX]      | 8B00
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 12]                         ; edx = integer constant
        mov     edx, [edi - 06]                         ; edx = destination offset
        cmp     eax, +1
        je     .inline.co.proc.2p.ivar.icon.p1
        cmp     eax, -1
        je     .inline.co.proc.2p.ivar.icon.m1
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; ADD     ESP, 4            | 83C4 04
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.icon.p1:
        mov     [.mode], 2
   .inline.co.proc.2p.ivar.icon.p1.x:
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.icon.m1:
        mov     [.mode], 3
   .inline.co.proc.2p.ivar.icon.m1.x:
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
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
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
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
        stdcall code_object, [.cooff], -7               ; ecx = object type
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
        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.co.iproc.i2p.ivar
        jmp    .error.argument
   .inline.co.iproc.i2p.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.co.iproc.i2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.co.iproc.i2p.ivar.x,\
                OBJ_INT_CON     , .inline.co.iproc.i2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.co.iproc.i2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.co.iproc.i2p.ivar.irsp.rax:
        add     [.RSP], 4
   .inline.co.iproc.i2p.ivar.x:
        mov     [edi - 7], byte 0xB9
        @@xshl  edi, 2
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = destination offset
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.co.iproc.i2p.ivar.proc
   .inline.co.iproc.i2p.ivar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 13]                             ; ecx = constant LO
        mov     edx, [edi - 18]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], word 0xB850
        mov     [edi + 07], edx
        mov     [edi + 11], word 0x30FF
        @@xshr  edi, 13

        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
   .inline.co.iproc.i2p.ivar.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 13
        mov     eax, [edi - 12]                             ; eax = int32 constant
        mov     edx, [edi - 06]                             ; edx = destination offset
   .inline.co.iproc.i2p.ivar.icon.x:
        test    eax, eax
        jz     .inline.co.iproc.i2p.ivar.con.0
        cmp     eax, 1
        je     .inline.co.iproc.i2p.ivar.con.1
        cmp     eax, -1
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
        @@xshl  edi, [.xshl], eax
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
;       jmp    .inline.co.iproc.i2p.ivar.proc
   .inline.co.iproc.i2p.ivar.proc:
        stdcall map_proc_x4, @x4_co_iprocs_i2p, [.proc], [.mode]
        jmp    .inline.proc

   .inline.covalue:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.covalue.dvar,\
                OBJ_INT_VAR    , .inline.covalue.ivar,\
                OBJ_STRING_VAR , .inline.covalue.svar
        jmp    .error.argument
   .inline.covalue.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]
        test    ecx, ecx
        jz     .error.argument
    $ifdef _SSEX
        movsd   xmm0, qword [ecx]
    $else
        fld     qword [ecx]
    $end
        @@xshl  edi, 10
        add     [.RSP], 8
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end
   .inline.covalue.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]
        test    ecx, ecx
        jz     .error.argument
        ;
        mov     eax, [ecx]
        @@xshl  edi, 7
        add     [.RSP], 4
        jmp    .inline.eax.icon
   .inline.covalue.svar:
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]
        test    ecx, ecx
        jz     .error.argument
        ;
        mov     eax, [ecx]
        @@xshl  edi, 7
        add     [.RSP], 4
        jmp    .inline.eax.scon

   .inline.restore:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.restore.dvar,\
                OBJ_INT_VAR    , .inline.restore.ivar,\
                OBJ_STRING_VAR , .inline.restore.svar
        jmp    .error.argument
   .inline.restore.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 20-10, .error.memory
        mov     ecx, [edi - 09]
        test    ecx, ecx
        jz     .error.argument
    $ifdef _SSEX
        movsd   xmm0, qword [ecx]
        movsd   qword [esp - 8], xmm0
    $else
        fld     qword [ecx]
        fst     qword [esp - 8]
    $end
        mov     eax, [esp - 8]
        mov     edx, [esp - 4]
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], byte 0xBA
        mov     [edi + 11], edx
        mov     [edi + 15], dword 0x89045189
        mov     [edi + 19], byte 0x01
        @@xshr  edi, 20
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EAX, FF+          | B8 FFFFFFFF
        ; MOV     EDX, FF+          | BA FFFFFFFF
        ; MOV     [ECX+4], EDX      | 895104
        ; MOV     [ECX], EAX        | 8901
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
    $ifdef _SSEX
        pcase   esi, @@restore, .inline.sse.dcon.test
    $else
        pcase   esi, @@restore, .inline.st0.dcon.test
        fstp    st0
    $end
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done
   .inline.restore.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 12-7, .error.memory
        mov     ecx, [edi - 06]
        test    ecx, ecx
        jz     .error.argument
        ;
        mov     eax, [ecx]
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], eax
        mov     [edi + 10], word 0x0889
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     ECX, FF+          | B9 FFFFFFFF
        ; MOV     DWORD [EAX], ECX  | 8908
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        pcase   esi, @@restore, .inline.eax.icon
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done
   .inline.restore.svar:
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        @@range 12-7, .error.memory
        mov     ecx, [edi - 06]
        test    ecx, ecx
        jz     .error.argument
        ;
        mov     eax, [ecx]
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], eax
        mov     [edi + 10], word 0x0A89
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, FF+          | B9 FFFFFFFF
        ; MOV     DWORD [EDX], ECX  | 890A
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        pcase   esi, @@restore, .inline.eax.scon
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ;?MOV     EDX, OFFSET       | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
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
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], word 0x15DD
        mov     [edi + 02], edx
        @@xshr  edi, 6
        ; --------------------------------------------------
        ;*FST     QWORD [DD+]       | DD15 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copy.dvar.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 15
        mov     [edi + 00], dword 0x05110FF2
;       mov     [edi + 00], dword 0x05D60F66
        mov     [edi + 04], edx
        @@xshr  edi, 8
        ; --------------------------------------------------
        ;*MOVSD   QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; --------------------------------------------------
        ;*MOVQ    QWORD [DD+], XMM0 | 660FD605 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copy.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        mov     eax, [edi - 19]                             ; eax = source offset
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], dword 0x05100FF2
;       mov     [edi + 00], dword 0x057E0FF3
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x05110FF2
;       mov     [edi + 08], dword 0x05D60F66
        mov     [edi + 12], edx
        @@xshr  edi, 16
        ; --------------------------------------------------
        ;*MOVSD   XMM0, QWORD [SS+] | F20F1005 SSSSSSSS
        ; MOVSD   QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; --------------------------------------------------
        ;*MOVQ    XMM0, QWORD [SS+] | F30F7E05 SSSSSSSS
        ; MOVQ    QWORD [DD+], XMM0 | 660FD605 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $else
        mov     eax, [edi - 19]                             ; eax = source offset
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0x15DD
        mov     [edi + 08], edx
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*FLD     QWORD [SS+]       | DD05 SSSSSSSS
        ; FST     QWORD [DD+]       | DD15 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.dvar.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 13-10, .error.memory
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], dword 0x04100FF2
        mov     [edi + 04], dword 0x110FF224
        mov     [edi + 08], byte 0x05
        mov     [edi + 09], edx
        @@xshr  edi, 13
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;*MOVSD   XMM0, QWORD [ESP] | F20F100424
        ; MOVSD   QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $else
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], dword 0xDD2404DD
        mov     [edi + 04], byte 0x15
        mov     [edi + 05], edx
        @@xshr  edi, 9
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;*FLD     QWORD [ESP]       | DD0424
        ; FST     QWORD [DD+]       | DD15 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copy.dvar.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        mov     eax, [edi - 16]                             ; eax = source offset
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], dword 0x052A0FF2
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x05110FF2
        mov     [edi + 12], edx
        @@xshr  edi, 16
        ; --------------------------------------------------
        ;*CVTSI2SD  XMM0, DWORD [SS+] | F20F2A05 SSSSSSSS
        ; MOVSD     QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $else
        mov     eax, [edi - 16]                             ; eax = source offset
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], word 0x05DB
        mov     [edi + 02], eax
        mov     [edi + 06], word 0x15DD
        mov     [edi + 08], edx
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*FILD    DWORD [SS+]       | DB05 SSSSSSSS
        ; FST     QWORD [DD+]       | DD15 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.dvar.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 15-10, .error.memory
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], dword 0xC02A0FF2
        mov     [edi + 04], dword 0x05110FF2
        mov     [edi + 08], edx
        mov     [edi + 12], byte 0x83
        mov     [edi + 13], word 0x04C4
        @@xshr  edi, 15
        ; ----------------------------------------------
        ; MOV       EAX, VALUE        | B8 SSSSSSSS
        ; PUSH      EAX               | 50
        ;*CVTSI2SD  XMM0, EAX         | F20F2AC0
        ; MOVSD     QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ; ADD       ESP, 4            | 83C404
        ;>
        ; ----------------------------------------------
    $else
        @@range 12-10, .error.memory
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], dword 0xDD2404DB
        mov     [edi + 04], byte 0x15
        mov     [edi + 05], edx
        mov     [edi + 09], byte 0x83
        mov     [edi + 10], word 0x04C4
        @@xshr  edi, 12
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ; PUSH  EAX             | 50
        ;*FILD  DWORD [ESP]     | DB0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ; ADD   ESP, 4          | 83C404
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.dvar.irsp.rax:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 15-13, .error.memory
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], dword 0xC02A0FF2
        mov     [edi + 04], dword 0x05110FF2
        mov     [edi + 08], edx
        mov     [edi + 12], word 0xC483
        mov     [edi + 14], byte 0x04
        @@xshr  edi, 15
        ; --------------------------------------------------
        ; ...                         | ...
        ;*CVTSI2SD  XMM0, EAX         | F20F2AC0
        ; MOVSD     QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ; ADD       ESP, 4            | 83C404
        ;>
        ; --------------------------------------------------
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 12-10, .error.memory
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], dword 0xDD2404DB
        mov     [edi + 04], byte 0x15
        mov     [edi + 05], edx
        mov     [edi + 09], word 0xC483
        mov     [edi + 11], byte 0x04
        @@xshr  edi, 12
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424
        ;*FILD    DWORD [ESP]       | DB0424
        ; FST     QWORD [DD+]       | DD15 DDDDDDDD
        ; ADD     ESP, 4            | 83C404
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 12
        mov     [.ezx], 0
        jmp    .done
; ------
   .inline.copy.ivar:
        stdcall code_object, [.cooff], -7                   ; ecx = object type
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
        ;*FSTP  QWORD [ESP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_io.ecx_dv.st0
        mov     eax, @@_copy_io.ecx_dv.st0.size
        jmp    .inline.proc
    $end
   .inline.copy.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_io.ecx_dv.xmm0
        mov     eax, @@_copy_io.ecx_dv.xmm0.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_do.eax
        mov     eax, @@_copy_io.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copy.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 13]                         ; ecx = constant LO
        mov     edx, [edi - 18]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, INT32      | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xA1
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, [OFFSET]   | A1 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copy.ivar.esp.proc
   .inline.copy.ivar.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], dword 0x00B9028B
        mov     [edi + 03], edx
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA SSSSSSSS
        ;*MOV   EAX, [EDX]      | 8B02
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.ptr:
        ; ----------------------------------------------
        ;*MOV   ECX, VALUE      | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 16
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.proc:
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc
   .inline.copy.ivar.esp.proc:
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax_esp
        mov     eax, @@_copy_io.ecx_iv.eax_esp.size
        jmp    .inline.proc
; ------
   .inline.copy.svar:
        stdcall code_object, [.cooff], -7               ; ecx = object type
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
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 13]                         ; eax = source offset
        mov     eax, [eax]                              ; eax = source value
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], dword 0x00BA008B
        mov     [edi + 03], edx
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   EAX, [EAX]      | 8B00
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.svar.eax.proc
   .inline.copy.svar.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 12]                             ; eax = source value
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.svar.eax.proc
   .inline.copy.svar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xA3
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [DD+], EAX        | A3 DDDDDDDD
        ; ADD     ESP, 4            | 83C404
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
   .inline.copy.svar.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 13]                         ; eax = source offset
        mov     eax, [eax]                              ; eax = source value
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], dword 0x00BA028B
        mov     [edi + 03], edx
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA SSSSSSSS
        ;*MOV   EAX, [EDX]      | 8B02
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.svar.eax.proc
   .inline.copy.svar.scon:
        ; ----------------------------------------------
        ;*MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ; PUSH  EDX             | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 12]                         ; eax = source value
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.svar.eax.proc
   .inline.copy.svar.ptr:
        ; ----------------------------------------------
        ;*MOV   ECX, VALUE      | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 15]                         ; eax = source value
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 16
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
;       jmp    .inline.copy.svar.eax.proc
   .inline.copy.svar.eax.proc:
      $ifdef SIC_FORCE_ASSIGN
        test    edx, edx
        jz     .error.argument
        mov     [edx], eax ; assign string value at compile time
      $end
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@_copy_so.edx_sv.eax
        mov     eax, @@_copy_so.edx_sv.eax.size
        jmp    .inline.proc

   .inline.copy.int:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.copy.int.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.int.dvar,\
                OBJ_INT_VAR    , .inline.copy.ivar          ; copy.int() EQU copy()
        jmp    .error.argument
; ------
   .inline.copy.int.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.int_do.ecx_dv.cpu
        mov     eax, @@_copy.int_do.ecx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.int.dvar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = destination offset
        @@xshl  edi, 15
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.int_do.ecx_dv.cpu
        mov     eax, @@_copy.int_do.ecx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.int.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        mov     ecx, [edi - 19]                             ; ecx = source offset
        @@xshl  edi, 20
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], ecx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ; MOV   EAX, OFFSET         | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.int_do.ecx_do.eax
        mov     eax, @@_copy.int_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copy.int.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                             ; ecx = source value LO
        mov     edx, [edi - 21]                             ; edx = source value HI
        stdcall f2f.int, ecx, edx                           ; eax:edx = int(source)
        mov     ecx, [edi - 09]                             ; ecx = destination offset
    $ifdef _SSEX
        @@range 28-22, .error.memory
        @@xshl  edi, 22
;       mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        mov     [edi + 25], byte 0x83
        mov     [edi + 26], word 0x08C4
        @@xshr  edi, 28
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ; ADD   ESP, 8            | 83C408
        ;>
        ; ----------------------------------------------
    $else
        @@range 24-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        mov     [edi + 21], byte 0x83
        mov     [edi + 22], word 0x08C4
        @@xshr  edi, 24
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ; ADD   ESP, 8          | 83C408
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.copy.frac.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.frac.dvar,\
                OBJ_INT_VAR    , .inline.copy.frac.ivar
        jmp    .error.argument
; ------
   .inline.copy.frac.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.frac_do.ecx_dv.cpu
        mov     eax, @@_copy.frac_do.ecx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.frac.dvar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = destination offset
        @@xshl  edi, 15
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.frac_do.ecx_dv.cpu
        mov     eax, @@_copy.frac_do.ecx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.frac.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        mov     ecx, [edi - 19]                             ; ecx = source offset
        @@xshl  edi, 20
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], ecx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.frac_do.ecx_do.eax
        mov     eax, @@_copy.frac_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copy.frac.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                             ; ecx = source value LO
        mov     edx, [edi - 21]                             ; edx = source value HI
        stdcall f2f.frac, ecx, edx                          ; eax:edx = frac(source)
        mov     ecx, [edi - 09]                             ; ecx = destination offset
    $ifdef _SSEX
        @@range 28-22, .error.memory
        @@xshl  edi, 22
;       mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        mov     [edi + 25], byte 0x83
        mov     [edi + 26], word 0x08C4
        @@xshr  edi, 28
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ; ADD   ESP, 8            | 83C408
        ;>
        ; ----------------------------------------------
    $else
        @@range 24-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        mov     [edi + 21], byte 0x83
        mov     [edi + 22], word 0x08C4
        @@xshr  edi, 24
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ; ADD   ESP, 8          | 83C408
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.frac.dvar.ivar:
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        jmp    .inline.copy.frac.dvar.assign.zero
   .inline.copy.frac.dvar.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 16
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        jmp    .inline.copy.frac.dvar.assign.zero
   .inline.copy.frac.dvar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0x83
        mov     [edi + 06], word 0x04C4
        @@xshr  edi, 8
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; ADD     ESP, 4            | 83C404
        ;>
        ; --------------------------------------------------
;       jmp    .inline.copy.frac.dvar.assign.zero
   .inline.copy.frac.dvar.assign.zero:
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_assign.zero_do.ecx
        mov     eax, @@_assign.zero_do.ecx.size
        jmp    .inline.proc
; ------
   .inline.copy.frac.ivar:
        stdcall code_object, [.cooff], -7                   ; ecx = object type
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
        ; FSTP  QWORD [ESP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 8-7, .error.memory
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0x83
        mov     [edi + 06], word 0x08C4
        @@xshr  edi, 8
        ; ----------------------------------------------
        ; FSTP  QWORD [ESP]     | DD1C24
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; ADD   ESP, 8          | 83C408
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copy.frac.ivar.assign.zero
    $end
   .inline.copy.frac.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 06]                             ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0x83
        mov     [edi + 06], word 0x08C4
        @@xshr  edi, 8
        ; ----------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; ADD     ESP, 8            | 83C408
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copy.frac.ivar.assign.zero
    $else
        jmp    .error.argument
    $end
   .inline.copy.frac.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.icon:
        ; ----------------------------------------------
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.irsp.rax:
        ; ----------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424            ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD       ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0x83
        mov     [edi + 06], word 0x04C4
        @@xshr  edi, 8
        ; ----------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; ADD     ESP, 4            | 83C404
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
;       jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.assign.zero:
        mov     [.ezx], 0
        mov     esi, @@_assign.zero_io.ecx
        mov     eax, @@_assign.zero_io.ecx.size
        jmp    .inline.proc

   .inline.copy.round:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.copy.round.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.round.dvar,\
                OBJ_INT_VAR    , .inline.copy.round.ivar
        jmp    .error.argument
; ------
   .inline.copy.round.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = destination offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.round_do.ecx_dv.cpu
        mov     eax, @@_copy.round_do.ecx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.round.dvar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = destination offset
        @@xshl  edi, 15
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.round_do.ecx_dv.cpu
        mov     eax, @@_copy.round_do.ecx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.round.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = destination offset
        mov     ecx, [edi - 19]                             ; ecx = source offset
        @@xshl  edi, 20
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], ecx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.round_do.ecx_do.eax
        mov     eax, @@_copy.round_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copy.round.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                             ; ecx = source value LO
        mov     edx, [edi - 21]                             ; edx = source value HI
        stdcall f2f.round, ecx, edx                         ; eax:edx = round(source)
        mov     ecx, [edi - 09]                             ; ecx = destination offset
    $ifdef _SSEX
        @@range 28-22, .error.memory
        @@xshl  edi, 22
;       mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        mov     [edi + 25], byte 0x83
        mov     [edi + 26], word 0x08C4
        @@xshr  edi, 28
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ; ADD   ESP, 8            | 83C408
        ;>
        ; ----------------------------------------------
    $else
        @@range 24-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        mov     [edi + 21], byte 0x83
        mov     [edi + 22], word 0x08C4
        @@xshr  edi, 24
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ; ADD   ESP, 8          | 83C408
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
; ------
   .inline.copy.round.ivar:
        stdcall code_object, [.cooff], -7                   ; ecx = object type
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
        ;*FSTP  QWORD [ESP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = destination offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy.round_io.ecx_dv.cpu
        mov     eax, @@_copy.round_io.ecx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.round.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV   ECX, OFFSET         | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy.round_io.ecx_dv.cpu
        mov     eax, @@_copy.round_io.ecx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.round.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        mov     ecx, [edi - 16]                         ; ecx = source offset
        @@xshl  edi, 17
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], ecx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.round_io.ecx_do.eax
        mov     eax, @@_copy.round_io.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copy.round.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 13]                         ; ecx = source value LO
        mov     edx, [edi - 18]                         ; edx = source value HI
        stdcall f2ir, ecx, edx                          ; eax = int32 constant: round(source)
        mov     ecx, [edi - 06]                         ; ecx = destination offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, INT32      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc

   .inline.pcopy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ;?MOV     EDX, OFFSET       | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopy.ivar
        jmp    .error.argument
        ;
   .inline.pcopy.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        mov     edx, [edi - 6]                              ; edx = integer variable offset
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
        ;*FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; ------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_doo.edx_dv.st0
        mov     eax, @@_copy_doo.edx_dv.st0.size
        jmp    .inline.proc
    $end
   .inline.pcopy.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; ------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_doo.edx_dv.xmm0
        mov     eax, @@_copy_doo.edx_dv.xmm0.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.pcopy.ivar.dvar:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;*PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 SSSSSSSS
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_doo.edx_do.ecx
        mov     eax, @@_copy_doo.edx_do.ecx.size
        jmp    .inline.proc
   .inline.pcopy.ivar.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_doo.edx_dv.esp
        mov     eax, @@_copy_doo.edx_dv.esp.size
        jmp    .inline.proc
   .inline.pcopy.ivar.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_ioo.edx_io.eax
        mov     eax, @@_copy_ioo.edx_io.eax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_ioo.edx_iv.eax
        mov     eax, @@_copy_ioo.edx_iv.eax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; ADD     ESP, 4            | 83C4 04
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_ioo.edx_iv.eax
        mov     eax, @@_copy_ioo.edx_iv.eax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.svar:
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA SSSSSSSS           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EAX, OFFSET       | B8 SSSSSSSS
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@_copy_soo.edx_so.eax
        mov     eax, @@_copy_soo.edx_so.eax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.scon:
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ; PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@_copy_soo.edx_sv.eax
        mov     eax, @@_copy_soo.edx_sv.eax.size
        jmp    .inline.proc

   .inline.copx:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50

        ;?MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH  DWORD [EDX]     | FF32

        ;?MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH  EDX             | 52

        ;?MOV   ECX, VALUE      | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH  ECX             | 51
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
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.dvar.ivar
        jmp    .error.argument
   .inline.copx.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        mov     eax, [edi - 09]                         ; eax = source offset
        mov     edx, [edi - 19]                         ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x05110FF2
        mov     [edi + 12], edx
        @@xshr  edi, 16
        ; ----------------------------------------------
        ;*MOVSD XMM0, QWORD [SS+] | F20F1005 SSSSSSSS
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        mov     eax, [edi - 09]                         ; eax = source offset
        mov     edx, [edi - 19]                         ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0x15DD
        mov     [edi + 08], edx
        @@xshr  edi, 12
        ; ----------------------------------------------
        ;*FLD   QWORD [SS+]     | DD05 SSSSSSSS
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copx.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = source offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_do.eax
        mov     eax, @@_copy_io.ecx_do.eax.size
        jmp    .inline.proc
; ------
   .inline.copx.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.dcon.ivar
        jmp    .error.argument
   .inline.copx.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 11]                         ; edx = source value HI
        mov     eax, [edi - 06]                         ; eax = source value LO
        mov     ecx, [edi - 21]                         ; ecx = destination offset
    $ifdef _SSEX
        @@range 25-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        @@xshr  edi, 25
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        @@xshr  edi, 21
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copx.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; edx = source value LO
        mov     edx, [edi - 11]                         ; ecx = source value HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, INT32      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc
; ------
   .inline.copx.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.ivar.dvar,\
                OBJ_INT_VAR    , .inline.copx.ivar.ivar,\
                OBJ_STRING_VAR , .inline.copx.ivar.svar
        jmp    .error.argument
   .inline.copx.ivar.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = source offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_do.ecx_io.eax
        mov     eax, @@_copy_do.ecx_io.eax.size
        jmp    .inline.proc
   .inline.copx.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = source offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_io.eax
        mov     eax, @@_copy_io.ecx_io.eax.size
        jmp    .inline.proc
   .inline.copx.ivar.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 13]                         ; edx = destination offset
        mov     eax, [edi - 06]                         ; eax = source offset
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], word 0x008B
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   EAX, [EAX]      | 8B00
        ;>
        ; ----------------------------------------------
        mov     eax, [eax]                              ; eax = source value
        add     [.RSP], 8
        jmp    .inline.copx.eax.svar.proc
; ------
   .inline.copx.icon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -6               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.icon.dvar,\
                OBJ_INT_VAR    , .inline.copx.icon.ivar,\
                OBJ_STRING_VAR , .inline.copx.icon.svar
        jmp    .error.argument
   .inline.copx.icon.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 5]                          ; edx = source value
        @@xshl  edi, 11
        mov     [edi + 0], byte 0xB8
        mov     [edi + 1], edx
        mov     [edi + 5], word 0x5050
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ; PUSH  EAX             | 50
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_do.ecx_iv.esp
        mov     eax, @@_copy_do.ecx_iv.esp.size
        jmp    .inline.proc
   .inline.copx.icon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 51
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 5]                          ; edx = source value
        @@xshl  edi, 13
        mov     [edi + 0], byte 0xB9
        mov     [edi + 5], byte 0xB8
        mov     [edi + 6], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc
   .inline.copx.icon.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 51
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 12]                         ; edx = destination offset
        mov     eax, [edi - 05]                         ; eax = source value
        @@xshl  edi, 8
        mov     [edi + 0], byte 0xB8
        mov     [edi + 1], eax
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.copx.eax.svar.proc
; ------
   .inline.copx.svar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR    , .inline.copx.svar.ivar,\
                OBJ_STRING_VAR , .inline.copx.svar.svar
        jmp    .error.argument
   .inline.copx.svar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = source offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        mov     [edi + 10], word 0x008B
        @@xshr  edi, 12
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   EAX, [EAX]      | 8B00
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc
   .inline.copx.svar.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 13]                         ; edx = destination offset
        mov     eax, [edi - 06]                         ; eax = source offset
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], word 0x008B
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   EAX, [EAX]      | 8B00
        ;>
        ; ----------------------------------------------
        mov     eax, [eax]                              ; eax = source value
        add     [.RSP], 8
        jmp    .inline.copx.eax.svar.proc
; ------
   .inline.copx.scon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ; PUSH  EDX             | 52
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -6               ; ecx = object type
        case    ecx,\
                OBJ_STRING_VAR , .inline.copx.scon.svar
        jmp    .error.argument
   .inline.copx.scon.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ; PUSH  EDX             | 52
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 12]                         ; edx = destination offset
        mov     eax, [edi - 05]                         ; eax = source value
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copx.eax.svar.proc
; ------
   .inline.copx.ptr:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, VALUE      | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -9               ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR    , .inline.copx.ptr.ivar,\
                OBJ_STRING_VAR , .inline.copx.ptr.svar
        jmp    .error.argument
   .inline.copx.ptr.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, VALUE      | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 8]                          ; edx = source value
        @@xshl  edi, 16
        mov     [edi + 0], byte 0xB9
        mov     [edi + 5], byte 0xB8
        mov     [edi + 6], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, VALUE      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc
   .inline.copx.ptr.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;*PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, VALUE      | B9 SSSSSSSS           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 15]                         ; edx = destination offset
        mov     eax, [edi - 08]                         ; eax = source value
        @@xshl  edi, 11
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], eax
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA DDDDDDDD
        ;*MOV   EAX, VALUE      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
;       jmp    .inline.copx.eax.svar.proc
   .inline.copx.eax.svar.proc:
      $ifdef SIC_FORCE_ASSIGN
        test    edx, edx
        jz     .error.argument
        mov     [edx], eax ; assign string value at compile time
      $end
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@_copy_so.edx_sv.eax
        mov     eax, @@_copy_so.edx_sv.eax.size
        jmp    .inline.proc

   .inline.copx.int:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50
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
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.int.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.dvar.ivar ; copx.int() EQU copx()
        jmp    .error.argument
   .inline.copx.int.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = source offset
        @@xshl  edi, 20
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.int_do.ecx_do.eax
        mov     eax, @@_copy.int_do.ecx_do.eax.size
        jmp    .inline.proc
; ------
   .inline.copx.int.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.int.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.dcon.ivar ; copx.int() EQU copx()
        jmp    .error.argument
   .inline.copx.int.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = source value LO
        mov     edx, [edi - 11]                         ; edx = source value HI
        stdcall f2f.int, ecx, edx                       ; eax:edx = int(source)
        mov     ecx, [edi - 21]                         ; ecx = destination offset
    $ifdef _SSEX
        @@range 28-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        mov     [edi + 25], byte 0x83
        mov     [edi + 26], word 0x08C4
        @@xshr  edi, 28
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ; ADD   ESP, 8            | 83C408
        ;>
        ; ----------------------------------------------
    $else
        @@range 24-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        mov     [edi + 21], byte 0x83
        mov     [edi + 22], word 0x08C4
        @@xshr  edi, 24
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ; ADD   ESP, 8          | 83C408
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
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50
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
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.dvar.ivar
        jmp    .error.argument
   .inline.copx.frac.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = source offset
        @@xshl  edi, 20
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.frac_do.ecx_do.eax
        mov     eax, @@_copy.frac_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copx.frac.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB9
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copx.frac.ivar.assign.zero
; ------
   .inline.copx.frac.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.dcon.ivar
        jmp    .error.argument
   .inline.copx.frac.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = source value LO
        mov     edx, [edi - 11]                         ; edx = source value HI
        stdcall f2f.frac, ecx, edx                      ; eax:edx = frac(source)
        mov     ecx, [edi - 21]                         ; ecx = destination offset
    $ifdef _SSEX
        @@range 25-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        @@xshr  edi, 25
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        @@xshr  edi, 21
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copx.frac.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copx.frac.ivar.assign.zero
; ------
   .inline.copx.frac.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.ivar.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.ivar.ivar
        jmp    .error.argument
   .inline.copx.frac.ivar.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 12
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.copx.frac.dvar.assign.zero
   .inline.copx.frac.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB9
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        jmp    .inline.copx.frac.ivar.assign.zero
; ------
   .inline.copx.frac.icon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -6               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.icon.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.icon.ivar
        jmp    .error.argument
   .inline.copx.frac.icon.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 11
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
;       jmp    .inline.copx.frac.dvar.assign.zero
   .inline.copx.frac.dvar.assign.zero:
        mov     [.ezx], 0
        mov     esi, @@_assign.zero_do.ecx
        mov     eax, @@_assign.zero_do.ecx.size
        jmp    .inline.proc
   .inline.copx.frac.icon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 51
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
;       jmp    .inline.copx.frac.ivar.assign.zero
   .inline.copx.frac.ivar.assign.zero:
        mov     [.ezx], 0
        mov     esi, @@_assign.zero_io.ecx
        mov     eax, @@_assign.zero_io.ecx.size
        jmp    .inline.proc

   .inline.copx.round:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50
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
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.round.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.round.dvar.ivar
        jmp    .error.argument
   .inline.copx.round.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = source offset
        @@xshl  edi, 20
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_copy.round_do.ecx_do.eax
        mov     eax, @@_copy.round_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.copx.round.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = source offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy.round_io.ecx_do.eax
        mov     eax, @@_copy.round_io.ecx_do.eax.size
        jmp    .inline.proc
; ------
   .inline.copx.round.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.round.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.round.dcon.ivar
        jmp    .error.argument
   .inline.copx.round.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; ecx = source value LO
        mov     edx, [edi - 11]                         ; edx = source value HI
        stdcall f2f.round, ecx, edx                     ; eax:edx = round(source)
        mov     ecx, [edi - 21]                         ; ecx = destination offset
    $ifdef _SSEX
        @@range 25-22, .error.memory
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x0FF25052
        mov     [edi + 14], dword 0xF2240410
        mov     [edi + 17], dword 0x05110FF2
        mov     [edi + 21], ecx
        @@xshr  edi, 25
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI     | BA SSSS..HI
        ; MOV   EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH  EDX               | 52
        ; PUSH  EAX               | 50
        ; MOVSD XMM0, QWORD [ESP] | F20F100424
        ; MOVSD QWORD [DD+], XMM0 | F20F1105 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        mov     [edi + 10], dword 0x04DD5052
        mov     [edi + 14], dword 0x0015DD24
        mov     [edi + 17], ecx
        @@xshr  edi, 21
        ; ----------------------------------------------
        ;*MOV   EDX, QWORD.HI   | BA SSSS..HI
        ; MOV   EAX, QWORD.LO   | B8 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  EAX             | 50
        ; FLD   QWORD [ESP]     | DD0424
        ; FST   QWORD [DD+]     | DD15 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copx.round.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 06]                         ; edx = source value LO
        mov     edx, [edi - 11]                         ; ecx = source value HI
        stdcall f2ir, ecx, edx                          ; eax = int32 constant: round(source)
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB9
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ; MOV   EAX, INT32      | B8 SSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_io.ecx_iv.eax
        mov     eax, @@_copy_io.ecx_iv.eax.size
        jmp    .inline.proc

   .inline.pcopx:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   ECX, VALUE      | B9 DDDDDDDD           ;>pointer constant (9B)
        ;?PUSH  ECX             | 51
        ;?NOP3                  | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50

        ;?MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH  DWORD [EDX]     | FF32

        ;?MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH  EDX             | 52
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
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        mov     eax, [edi - 09]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.dvar.ivar
        jmp    .error.argument
   .inline.pcopx.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_copy_doo.edx_do.eax
        mov     eax, @@_copy_doo.edx_do.eax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.dcon:
        ; ----------------------------------------------
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        mov     edx, [edi - 11]
        mov     eax, [edi - 06]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.dcon.ivar
        jmp    .error.argument
   .inline.pcopx.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, QWORD.HI   | BA SSSS..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 SSSS..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], ecx
        mov     [edi + 10], byte 0xB8
        mov     [edi + 11], eax
        mov     [edi + 15], word 0x5051
        @@xshr  edi, 17
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, QWORD.HI     | B9 SSSS..HI
        ; MOV     EAX, QWORD.LO     | B8 SSSS..LO
        ; PUSH    ECX               | 51
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        mov     esi, @@_copy_doo.edx_dv.esp
        mov     eax, @@_copy_doo.edx_dv.esp.size
        jmp    .inline.proc
        ;
   .inline.pcopx.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        mov     eax, [edi - 6]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.ivar.ivar
        jmp    .error.argument
   .inline.pcopx.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_ioo.edx_io.eax
        mov     eax, @@_copy_ioo.edx_io.eax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -6               ; ecx = object type
        mov     eax, [edi - 5]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.icon.ivar
        jmp    .error.argument
   .inline.pcopx.icon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     EAX, VALUE        | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_copy_ioo.edx_iv.eax
        mov     eax, @@_copy_ioo.edx_iv.eax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.svar:
        ; ----------------------------------------------
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        mov     eax, [edi - 6]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.svar.ivar
        jmp    .error.argument
   .inline.pcopx.svar.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@_copy_soo.edx_so.eax
        mov     eax, @@_copy_soo.edx_so.eax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.scon:
        ; ----------------------------------------------
        ; MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ; PUSH  EDX             | 52
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -6               ; ecx = object type
        mov     eax, [edi - 5]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.scon.ivar
        jmp    .error.argument
   .inline.pcopx.scon.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, VALUE      | BA SSSSSSSS           ; string constant (6B)
        ; PUSH  EDX             | 52
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB8
        mov     [edi + 06], eax
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     EAX, VALUE        | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@_copy_soo.edx_sv.eax
        mov     eax, @@_copy_soo.edx_sv.eax.size
        jmp    .inline.proc

   .inline.x2copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 09]                             ; eax = x_1 offset
        mov     edx, [edi - 19]                             ; edx = x_2 offset
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        mov     esi, @@.x2copy.d
        mov     eax, @@.x2copy.d.size
        jmp    .inline.proc
   .inline.x2copy.ivar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 06]                             ; eax = x_1 offset
        mov     edx, [edi - 13]                             ; edx = x_2 offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@.x2copy.i
        mov     eax, @@.x2copy.i.size
        jmp    .inline.proc
   .inline.x2copy.svar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 06]                             ; eax = x_1 offset
        mov     edx, [edi - 13]                             ; edx = x_2 offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@.x2copy.s
        mov     eax, @@.x2copy.s.size
        jmp    .inline.proc

   .inline.x2copyD:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ;
        mov     eax, [edi - 09]                             ; eax = x_1 offset
        mov     edx, [edi - 19]                             ; edx = x_2 offset
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        sub     [.ezx], 2
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        jmp    .inline.proc

   .inline.x2copyDV:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -15                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ;
        mov     eax, [edi - 14]                             ; eax = x_1 offset
        mov     edx, [edi - 24]                             ; edx = x_2 offset
        @@xshl  edi, 25
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        sub     [.ezx], 2
        mov     ecx, [.ezx]
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        @@xshr  edi, 15
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        jmp    .inline.proc

   .inline.x3copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 09]                             ; eax = x_1 offset
        mov     edx, [edi - 19]                             ; edx = x_2 offset
        mov     ecx, [edi - 29]                             ; ecx = x_3 offset
        @@xshl  edi, 30
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        @@xshr  edi, 15
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 48
        mov     [.ezx], 0
        mov     esi, @@.x3copy.d
        mov     eax, @@.x3copy.d.size
        jmp    .inline.proc
   .inline.x3copy.ivar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -14                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 06]                             ; eax = x_1 offset
        mov     edx, [edi - 13]                             ; edx = x_2 offset
        mov     ecx, [edi - 20]                             ; ecx = x_3 offset
        @@xshl  edi, 21
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        @@xshr  edi, 15
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 24
        mov     [.ezx], 0
        mov     esi, @@.x3copy.i
        mov     eax, @@.x3copy.i.size
        jmp    .inline.proc
   .inline.x3copy.svar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -14                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 06]                             ; eax = x_1 offset
        mov     edx, [edi - 13]                             ; edx = x_2 offset
        mov     ecx, [edi - 20]                             ; ecx = x_3 offset
        @@xshl  edi, 21
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        @@xshr  edi, 15
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 24
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@.x3copy.s
        mov     eax, @@.x3copy.s.size
        jmp    .inline.proc

   .inline.x3copyD:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ;
        mov     eax, [edi - 09]                             ; eax = x_1 offset
        mov     edx, [edi - 19]                             ; edx = x_2 offset
        mov     ecx, [edi - 29]                             ; ecx = x_3 offset
        @@xshl  edi, 30
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        @@xshr  edi, 15
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 24
        sub     [.ezx], 3
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        jmp    .inline.proc

   .inline.x4copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -30                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 09]                             ; eax = x_1 offset
        mov     edx, [edi - 19]                             ; edx = x_2 offset
        mov     ecx, [edi - 39]                             ; ecx = x_4 offset
        mov     [esp - 4], ecx                              ; [esp - 4] = x_4 offset
        mov     ecx, [edi - 29]                             ; ecx = x_3 offset
        @@xshl  edi, 40
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     ecx, [esp - 4]
        mov     [edi + 15], byte 0xBB
        mov     [edi + 16], ecx
        @@xshr  edi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EBX, OFFSET       | BB DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 64
        mov     [.ezx], 0
        mov     esi, @@.x4copy.d
        mov     eax, @@.x4copy.d.size
        jmp    .inline.proc
   .inline.x4copy.ivar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -14                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -21                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 06]                             ; eax = x_1 offset
        mov     edx, [edi - 13]                             ; edx = x_2 offset
        mov     ecx, [edi - 27]                             ; ecx = x_4 offset
        mov     [esp - 4], ecx                              ; [esp - 4] = x_4 offset
        mov     ecx, [edi - 20]                             ; ecx = x_3 offset
        @@xshl  edi, 28
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     ecx, [esp - 4]
        mov     [edi + 15], byte 0xBB
        mov     [edi + 16], ecx
        @@xshr  edi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EBX, OFFSET       | BB DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        mov     esi, @@.x4copy.i
        mov     eax, @@.x4copy.i.size
        jmp    .inline.proc
   .inline.x4copy.svar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32

        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -14                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -21                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        ;
        mov     eax, [edi - 06]                             ; eax = x_1 offset
        mov     edx, [edi - 13]                             ; edx = x_2 offset
        mov     ecx, [edi - 27]                             ; ecx = x_4 offset
        mov     [esp - 4], ecx                              ; [esp - 4] = x_4 offset
        mov     ecx, [edi - 20]                             ; ecx = x_3 offset
        @@xshl  edi, 28
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     ecx, [esp - 4]
        mov     [edi + 15], byte 0xBB
        mov     [edi + 16], ecx
        @@xshr  edi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EBX, OFFSET       | BB DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     esi, @@.x4copy.s
        mov     eax, @@.x4copy.s.size
        jmp    .inline.proc

   .inline.x4copyD:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -30                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ;
        mov     eax, [edi - 09]                             ; eax = x_1 offset
        mov     edx, [edi - 19]                             ; edx = x_2 offset
        mov     ecx, [edi - 39]                             ; ecx = x_4 offset
        mov     [esp - 4], ecx                              ; [esp - 4] = x_4 offset
        mov     ecx, [edi - 29]                             ; ecx = x_3 offset
        @@xshl  edi, 40
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     ecx, [esp - 4]
        mov     [edi + 15], byte 0xBB
        mov     [edi + 16], ecx
        @@xshr  edi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EBX, OFFSET       | BB DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        sub     [.ezx], 4
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        jmp    .inline.proc

   .inline.swap:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ;?PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar,\
                OBJ_STRING_VAR , .inline.swap.svar
        jmp    .error.argument
   .inline.swap.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.dvar.ivar
        jmp    .error.argument
   .inline.swap.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.ivar.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar.ivar,\
                OBJ_STRING_VAR , .inline.swap.ivar.svar
        jmp    .error.argument
   .inline.swap.svar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR    , .inline.swap.svar.ivar,\
                OBJ_STRING_VAR , .inline.swap.svar.svar
        jmp    .error.argument
; ------
   .inline.swap.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_swap_do.ecx_do.eax
        mov     eax, @@_swap_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.swap.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_swap_do.ecx_io.eax
        mov     eax, @@_swap_do.ecx_io.eax.size
        jmp    .inline.proc
; ------
   .inline.swap.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_swap_io.ecx_do.eax
        mov     eax, @@_swap_io.ecx_do.eax.size
        jmp    .inline.proc
   .inline.swap.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_swap_io.ecx_io.eax
        mov     eax, @@_swap_io.ecx_io.eax.size
        jmp    .inline.proc
   .inline.swap.ivar.svar:
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 13]                         ; eax = source offset
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        test    edx, edx
        jz     .error.argument
        mov     esi, [eax]
        mov     ecx, [edx]
        mov     [eax], ecx ; assign values at compile time
        mov     [edx], esi
      $end
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_swap_io.ecx_io.eax
        mov     eax, @@_swap_io.ecx_io.eax.size
        jmp    .inline.proc
; ------
   .inline.swap.svar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 13]                         ; eax = source offset
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        test    edx, edx
        jz     .error.argument
        mov     esi, [eax]
        mov     ecx, [edx]
        mov     [eax], ecx ; assign values at compile time
        mov     [edx], esi
      $end
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_swap_io.ecx_io.eax
        mov     eax, @@_swap_io.ecx_io.eax.size
        jmp    .inline.proc
   .inline.swap.svar.svar:
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA SSSSSSSS           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA DDDDDDDD           ; string variable (7B)
        ; PUSH  DWORD [EDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     eax, [edi - 13]                         ; eax = source offset
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 14
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        test    edx, edx
        jz     .error.argument
        mov     esi, [eax]
        mov     ecx, [edx]
        mov     [eax], ecx ; assign values at compile time
        mov     [edx], esi
      $end
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_swap_io.ecx_io.eax
        mov     eax, @@_swap_io.ecx_io.eax.size
        jmp    .inline.proc

   .inline.swap.int:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
   .inline.swap.int.x:
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.int.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar      ; swap.int() EQU swap()
        jmp    .error.argument
   .inline.swap.int.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.int.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.dvar.ivar ; swap.int() EQU swap()
        jmp    .error.argument
; ------
   .inline.swap.int.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_swap.int_do.ecx_do.eax
        mov     eax, @@_swap.int_do.ecx_do.eax.size
        jmp    .inline.proc

   .inline.swap.frac:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
   .inline.swap.frac.x:
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.frac.dvar,\
                OBJ_INT_VAR    , .inline.swap.frac.ivar
        jmp    .error.argument
   .inline.swap.frac.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.frac.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.frac.dvar.ivar
        jmp    .error.argument
   .inline.swap.frac.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.frac.ivar.dvar,\
                OBJ_INT_VAR    , .inline.swap.frac.ivar.ivar
        jmp    .error.argument
; ------
   .inline.swap.frac.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_swap.frac_do.ecx_do.eax
        mov     eax, @@_swap.frac_do.ecx_do.eax.size
        jmp    .inline.proc
   .inline.swap.frac.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_assign.zeroes_do.ecx_io.eax
        mov     eax, @@_assign.zeroes_do.ecx_io.eax.size
        jmp    .inline.proc
; ------
   .inline.swap.frac.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_assign.zeroes_io.ecx_do.eax
        mov     eax, @@_assign.zeroes_io.ecx_do.eax.size
        jmp    .inline.proc
   .inline.swap.frac.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 9
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     esi, @@_assign.zeroes_io.ecx_io.eax
        mov     eax, @@_assign.zeroes_io.ecx_io.eax.size
        jmp    .inline.proc

   .inline.swap.round:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   ECX, OFFSET     | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH  DWORD [ECX+4]   | FF71 04
        ;?PUSH  DWORD [ECX]     | FF31

        ;?MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
   .inline.swap.round.x:
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.round.dvar,\
                OBJ_INT_VAR    , .inline.swap.round.ivar
        jmp    .error.argument
   .inline.swap.round.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -10              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.round.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.round.dvar.ivar
        jmp    .error.argument
   .inline.swap.round.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -7               ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.round.ivar.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar.ivar ; swap.round() EQU swap()
        jmp    .error.argument
; ------
   .inline.swap.round.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xBA
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     esi, @@_swap.round_do.ecx_do.edx
        mov     eax, @@_swap.round_do.ecx_do.edx.size
        jmp    .inline.proc
   .inline.swap.round.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = destination offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS
        ;*MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_swap.round_do.ecx_io.eax
        mov     eax, @@_swap.round_do.ecx_io.eax.size
        jmp    .inline.proc
; ------
   .inline.swap.round.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 SSSSSSSS           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EAX, OFFSET     | B8 DDDDDDDD           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 06]                         ; edx = destination offset
        @@xshl  edi, 17
        mov     [edi + 00], byte 0xB8
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        mov     [.ezx], 0
        mov     esi, @@_swap.round_io.ecx_do.eax
        mov     eax, @@_swap.round_io.ecx_do.eax.size
        jmp    .inline.proc

   .inline.vcopy:
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;
        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        mov     ecx, [.ezx]
        mov     [.zzx], ecx
        dec     [.zzx]
        @@xshl  edi, 5
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.vcopy.dvar,\
                OBJ_INT_VAR    , .inline.vcopy.ivar,\
                OBJ_STRING_VAR , .inline.vcopy.svar
        jmp    .error.argument
   .inline.vcopy.dvar:
    $ifdef _SSEX
        ; (8*acount)-(10*acount+5) = -(acount*2+5)
    $else
        ; (6*acount)-(10*acount+5) = -(acount*4+5)
    $end
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.vcopy.dvar.x:
        @@xshl  edi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopy.dvar.x
        ;
        @@xshl  edi, 10
        lea     edx, [edi + 1]
        mov     ecx, dword [edx]
        mov     [.ecx], ecx
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopy.dvar.push:
        add     edx, 10
        push    dword [edx]
        dec     ecx
        jnz    .inline.vcopy.dvar.push
        ;
        ; --------------------------------------------------
        ;*FLD     QWORD [SSSSSSSS]  | DD05 SSSSSSSS         ; 6 BYTES
        ;
        ; FST     QWORD [DDDDDDDD]  | DD15 DDDDDDDD         ; 6 BYTES
        ; FST     QWORD [DDDDDDDD]  | DD15 DDDDDDDD         ; 6 BYTES
        ; ...                       |
        ; FST     QWORD [DDDDDDDD]  | DD15 DDDDDDDD         ; 6 BYTES
        ;>
        ; --------------------------------------------------
        ;
        ; ---------------------------------------------------
        ;*MOVSD   XMM0, QWORD [SSSSSSSS] | F20F1005 SSSSSSSS ; 8 BYTES
        ;
        ; MOVSD   QWORD [DDDDDDDD], XMM0 | F20F1105 DDDDDDDD ; 8 BYTES
        ; MOVSD   QWORD [DDDDDDDD], XMM0 | F20F1105 DDDDDDDD ; 8 BYTES
        ; ...                            |
        ; MOVSD   QWORD [DDDDDDDD], XMM0 | F20F1105 DDDDDDDD ; 8 BYTES
        ;>
        ; ---------------------------------------------------
        mov     ecx, [.ecx]
    $ifdef _SSEX
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], ecx
        @@xshr  edi, 8
    $else
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], ecx
        @@xshr  edi, 6
    $end
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopy.dvar.pop:
    $ifdef _SSEX
        mov     [edi + 00], dword 0x05110FF2
        pop     dword [edi + 04]
        @@xshr  edi, 8
    $else
        mov     [edi + 00], word 0x15DD
        pop     dword [edi + 02]
        @@xshr  edi, 6
    $end
        dec     ecx
        jnz    .inline.vcopy.dvar.pop
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopy.ivar:
    $ifdef _SSEX
        ; (5*acount+6)-(7*acount+5) = -(acount*2-1)
    $else
        ; (5*acount+4)-(7*acount+5) = -(acount*2+1)
    $end
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.vcopy.ivar.x:
        @@xshl  edi, 7
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopy.ivar.x
        ;
        @@xshl  edi, 7
        lea     edx, [edi + 1]
        mov     ecx, dword [edx]
        mov     [.ecx], ecx
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopy.ivar.push:
        add     edx, 7
        push    dword [edx]
        dec     ecx
        jnz    .inline.vcopy.ivar.push
        ;
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; 5 BYTES
        ; FILD    DWORD [ECX]       | DB01                  ; 2 BYTES
        ; MOV     EAX, [ECX]        | 8B01                  ; 2 BYTES
        ;
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; ...                       |
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ;>
        ; --------------------------------------------------
        ;
        ; --------------------------------------------------
        ;*MOV      ECX, OFFSET       | B9 SSSSSSSS           ; 5 BYTES
        ; CVTSI2SD XMM0, DWORD [ECX] | F20F2A01              ; 4 BYTES
        ; MOV      EAX, [ECX]        | 8B01                  ; 2 BYTES
        ;
        ; MOV      [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; MOV      [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; ...                        |
        ; MOV      [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ;>
        ; --------------------------------------------------
        mov     ecx, [.ecx]
    $ifdef _SSEX
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x012A0FF2
        mov     [edi + 09], word 0x018B
        @@xshr  edi, 11
    $else
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x018B01DB
        @@xshr  edi, 9
    $end
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopy.ivar.pop:
        mov     [edi + 00], byte 0xA3
        pop     dword [edi + 01]
        @@xshr  edi, 5
        dec     ecx
        jnz    .inline.vcopy.ivar.pop
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopy.svar:
        ; (5*acount+2)-(7*acount+5) = -(acount*2+3)
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.vcopy.svar.x:
        @@xshl  edi, 7
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopy.svar.x
        ;
        @@xshl  edi, 7
        lea     edx, [edi + 1]
        mov     ecx, dword [edx]
        mov     [.ecx], ecx
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopy.svar.push:
        add     edx, 7
        push    dword [edx]
        dec     ecx
        jnz    .inline.vcopy.svar.push
        ;
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; 5 BYTES
        ; MOV     EAX, [ECX]        | 8B01                  ; 2 BYTES
        ;
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; ...                       |
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ;>
        ; --------------------------------------------------
        mov     ecx, [.ecx]
        mov     eax, [ecx] ; get string value
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], word 0x018B
        @@xshr  edi, 7
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopy.svar.pop:
        mov     [edi + 00], byte 0xA3
        pop     edx
      $ifdef SIC_FORCE_ASSIGN
        test    edx, edx
        jz     .error.argument
        mov     [edx], eax ; assign string value at compile time
      $end
        mov     [edi + 01], edx
        @@xshr  edi, 5
        dec     ecx
        jnz    .inline.vcopy.svar.pop
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.vcopx:
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;
        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        mov     ecx, [.ezx]
        mov     [.zzx], ecx
        dec     [.zzx]
        @@xshl  edi, 5
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.vcopx.dvar,\
                OBJ_INT_VAR    , .inline.vcopx.ivar,\
                OBJ_STRING_VAR , .inline.vcopx.svar
        jmp    .error.argument
   .inline.vcopx.dvar:
        mov     ecx, dword [edi - 09]
        mov     [.ecx], ecx
    $ifdef _SSEX
        ; (8*acount)-(10*acount+5) = -(acount*2+5)
    $else
        ; (6*acount)-(10*acount+5) = -(acount*4+5)
    $end
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.vcopx.dvar.x:
        @@xshl  edi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopx.dvar.x
        ;
        @@xshl  edi, 10
        lea     edx, [edi + 1]
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopx.dvar.push:
        push    dword [edx]
        add     edx, 10
        dec     ecx
        jnz    .inline.vcopx.dvar.push
        ;
        ; --------------------------------------------------
        ;*FLD     QWORD [SSSSSSSS]  | DD05 SSSSSSSS         ; 6 BYTES
        ;
        ; FST     QWORD [DDDDDDDD]  | DD15 DDDDDDDD         ; 6 BYTES
        ; FST     QWORD [DDDDDDDD]  | DD15 DDDDDDDD         ; 6 BYTES
        ; ...
        ; FST     QWORD [DDDDDDDD]  | DD15 DDDDDDDD         ; 6 BYTES
        ;>
        ; --------------------------------------------------
        ;
        ; ---------------------------------------------------
        ;*MOVSD   XMM0, QWORD [SSSSSSSS] | F20F1005 SSSSSSSS ; 8 BYTES
        ;
        ; MOVSD   QWORD [DDDDDDDD], XMM0 | F20F1105 DDDDDDDD ; 8 BYTES
        ; MOVSD   QWORD [DDDDDDDD], XMM0 | F20F1105 DDDDDDDD ; 8 BYTES
        ; ...
        ; MOVSD   QWORD [DDDDDDDD], XMM0 | F20F1105 DDDDDDDD ; 8 BYTES
        ;>
        ; ---------------------------------------------------
        mov     ecx, [.ecx]
    $ifdef _SSEX
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], ecx
        @@xshr  edi, 8
    $else
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], ecx
        @@xshr  edi, 6
    $end
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopx.dvar.pop:
    $ifdef _SSEX
        mov     [edi + 00], dword 0x05110FF2
        pop     dword [edi + 04]
        @@xshr  edi, 8
    $else
        mov     [edi + 00], word 0x15DD
        pop     dword [edi + 02]
        @@xshr  edi, 6
    $end
        dec     ecx
        jnz    .inline.vcopx.dvar.pop
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopx.ivar:
        mov     ecx, dword [edi - 06]
        mov     [.ecx], ecx
    $ifdef _SSEX
        ; (5*acount+6)-(7*acount+5) = -(acount*2-1)
    $else
        ; (5*acount+4)-(7*acount+5) = -(acount*2+1)
    $end
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.vcopx.ivar.x:
        @@xshl  edi, 7
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopx.ivar.x
        ;
        @@xshl  edi, 7
        lea     edx, [edi + 1]
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopx.ivar.push:
        push    dword [edx]
        add     edx, 7
        dec     ecx
        jnz    .inline.vcopx.ivar.push
        ;
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; 5 BYTES
        ; FILD    DWORD [ECX]       | DB01                  ; 2 BYTES
        ; MOV     EAX, [ECX]        | 8B01                  ; 2 BYTES
        ;
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; ...
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ;>
        ; --------------------------------------------------
        ;
        ; --------------------------------------------------
        ;*MOV      ECX, OFFSET       | B9 SSSSSSSS          ; 5 BYTES
        ; CVTSI2SD XMM0, DWORD [ECX] | F20F2A01             ; 4 BYTES
        ; MOV      EAX, [ECX]        | 8B01                 ; 2 BYTES
        ;
        ; MOV      [DDDDDDDD], EAX   | A3 DDDDDDDD          ; 5 BYTES
        ; MOV      [DDDDDDDD], EAX   | A3 DDDDDDDD          ; 5 BYTES
        ; ...
        ; MOV      [DDDDDDDD], EAX   | A3 DDDDDDDD          ; 5 BYTES
        ;>
        ; --------------------------------------------------
        mov     ecx, [.ecx]
    $ifdef _SSEX
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x012A0FF2
        mov     [edi + 09], word 0x018B
        @@xshr  edi, 11
    $else
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0x018B01DB
        @@xshr  edi, 9
    $end
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopx.ivar.pop:
        mov     [edi + 00], byte 0xA3
        pop     dword [edi + 01]
        @@xshr  edi, 5
        dec     ecx
        jnz    .inline.vcopx.ivar.pop
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopx.svar:
        mov     ecx, dword [edi - 06]
        mov     [.ecx], ecx
        ; (5*acount+2)-(7*acount+5) = -(acount*2+3)
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.vcopx.svar.x:
        @@xshl  edi, 7
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopx.svar.x
        ;
        @@xshl  edi, 7
        lea     edx, [edi + 1]
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopx.svar.push:
        push    dword [edx]
        add     edx, 7
        dec     ecx
        jnz    .inline.vcopx.svar.push
        ;
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 SSSSSSSS           ; 5 BYTES
        ; MOV     EAX, [ECX]        | 8B01                  ; 2 BYTES
        ;
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ; ...                       |
        ; MOV     [DDDDDDDD], EAX   | A3 DDDDDDDD           ; 5 BYTES
        ;>
        ; --------------------------------------------------
        mov     ecx, [.ecx]
        mov     eax, [ecx] ; get string value
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], word 0x018B
        @@xshr  edi, 7
        mov     ecx, [.ezx]
        dec     ecx
   .inline.vcopx.svar.pop:
        mov     [edi + 00], byte 0xA3
        pop     edx
      $ifdef SIC_FORCE_ASSIGN
        test    edx, edx
        jz     .error.argument
        mov     [edx], eax ; assign string value at compile time
      $end
        mov     [edi + 01], edx
        @@xshr  edi, 5
        dec     ecx
        jnz    .inline.vcopx.svar.pop
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.swapr:
        mov     [.XSP], 0
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;
        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        @@xshl  edi, 5
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swapr.dvar,\
                OBJ_INT_VAR    , .inline.swapr.ivar,\
                OBJ_STRING_VAR , .inline.swapr.svar
        jmp    .error.argument
   .inline.swapr.dvar:
    $ifdef _SSEX
        ; (16*acount)-(10*acount+5) = 6*acount-5
        mov     ecx, [.ezx]
        mov     eax, 6
        mul     ecx
        sub     eax, 5
        js     .inline.swapr.dvar.x
    $else
        ; (12*acount)-(10*acount+5) = 2*acount-5
        mov     ecx, [.ezx]
        mov     eax, 2
        mul     ecx
        sub     eax, 5
        js     .inline.swapr.dvar.x
    $end
        @@range eax, .error.memory
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.swapr.dvar.x:
        mov     ecx, [.ezx]
        mov     [.zzx], ecx
   .inline.swapr.dvar.push:
        push    dword [edi - 09]                            ; PUSH X(1), X(2), ... , X(N-1), X(N)
        add     [.XSP], 8
        @@xshl  edi, 10
        dec     [.zzx]
        jz     .inline.swapr.dvar.push.out
        ;
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .inline.swapr.error
        jmp    .inline.swapr.dvar.push
   .inline.swapr.dvar.push.out:
        ; ----------------------------------------------
        ; X(N) -> ST0
        ;*FLD   QWORD [X(N)]    | DD05 FFFFFFFF         ; 6 BYTES
        ;
        ; X(N-1) -> X(N)
        ; FLD   QWORD [X(N-1)]  | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(N)]    | DD1D FFFFFFFF
        ;
        ; X(N-2) -> X(N-1)
        ; FLD   QWORD [X(N-2)]  | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(N-1)]  | DD1D FFFFFFFF
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; FLD   QWORD [X(2)]    | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(3)]    | DD1D FFFFFFFF
        ;
        ; X(1) -> X(2)
        ; FLD   QWORD [X(1)]    | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(2)]    | DD1D FFFFFFFF
        ;
        ; X(N) -> X(1)
        ; FST   QWORD [X(1)]    | DD15 FFFFFFFF         ; 6 BYTES
        ;>
        ; ----------------------------------------------
        ;
        ; -----------------------------------------------
        ; X(N) -> ST0
        ;*MOVSD XMM0, QWORD [X(N)]   | F20F1005 FFFFFFFF ; 8 BYTES
        ;
        ; X(N-1) -> X(N)
        ; MOVSD XMM1, QWORD [X(N-1)] | F20F100D FFFFFFFF ; 16 BYTES
        ; MOVSD QWORD [X(N)], XMM1   | F20F110D FFFFFFFF
        ;
        ; X(N-2) -> X(N-1)
        ; *     QWORD [X(N-2)]       | F20F100D FFFFFFFF ; 16 BYTES
        ; *     QWORD [X(N-1)]       | F20F110D FFFFFFFF
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; *     QWORD [X(2)]         | F20F100D FFFFFFFF ; 16 BYTES
        ; *     QWORD [X(3)]         | F20F110D FFFFFFFF
        ;
        ; X(1) -> X(2)
        ; *     QWORD [X(1)]         | F20F100D FFFFFFFF ; 16 BYTES
        ; *     QWORD [X(2)]         | F20F110D FFFFFFFF
        ;
        ; X(N) -> X(1)
        ; MOVSD QWORD [X(1)], XMM0   | F20F1105 FFFFFFFF ; 8 BYTES
        ;>
        ; -----------------------------------------------
    $ifdef _SSEX
        mov     [edi + 0], dword 0x05100FF2
        pop     eax
        mov     dword [edi + 4], eax
        @@xshr  edi, 8
    $else
        mov     [edi + 0], word 0x05DD
        pop     eax
        mov     dword [edi + 2], eax
        @@xshr  edi, 6
    $end
        mov     ecx, [.ezx]
        dec     ecx
   .inline.swapr.dvar.pop:
    $ifdef _SSEX
        mov     [edi + 08], dword 0x0D110FF2
        mov     [edi + 12], eax
        pop     eax
        mov     [edi + 00], dword 0x0D100FF2
        mov     dword [edi + 04], eax
        @@xshr  edi, 16
    $else
        mov     [edi + 6], word 0x1DDD
        mov     [edi + 8], eax
        pop     eax
        mov     [edi + 0], word 0x05DD
        mov     dword [edi + 2], eax
        @@xshr  edi, 12
    $end
        dec     ecx
        jnz    .inline.swapr.dvar.pop
        ;
    $ifdef _SSEX
        mov     [edi + 0], dword 0x05110FF2
        mov     dword [edi + 4], eax
        @@xshr  edi, 8
    $else
        mov     [edi + 0], word 0x15DD
        mov     dword [edi + 2], eax
        @@xshr  edi, 6
    $end
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapr.ivar:
    $ifdef _SSEX
        ; (12*acount+6)-(7*acount+5) = 5*acount+1
        mov     ecx, [.ezx]
        mov     eax, 5
        mul     ecx
        add     eax, 1
        js     .inline.swapr.ivar.x
    $else
        ; (12*acount+4)-(7*acount+5) = 5*acount-1
        mov     ecx, [.ezx]
        mov     eax, 5
        mul     ecx
        sub     eax, 1
        js     .inline.swapr.ivar.x
    $end
        @@range eax, .error.memory
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.swapr.ivar.x:
        mov     ecx, [.ezx]
        mov     [.zzx], ecx
   .inline.swapr.ivar.push:
        push    dword [edi - 06]                            ; PUSH X(1), X(2), ... , X(N-1), X(N)
        add     [.XSP], 8
        @@xshl  edi, 7
        dec     [.zzx]
        jz     .inline.swapr.ivar.push.out
        ;
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .inline.swapr.error
        jmp    .inline.swapr.ivar.push
   .inline.swapr.ivar.push.out:
        ; ----------------------------------------------
        ; X(N) -> EAX
        ;*MOV   EAX, [X(N)]     | A1 FFFFFFFF           ; 5 BYTES
        ;
        ; X(N-1) -> X(N)
        ; MOV   ECX, [X(N-1)]   | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N)], ECX     | 890D FFFFFFFF
        ;
        ; X(N-2) -> X(N-1)
        ; MOV   ECX, [X(N-2)]   | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N-1)], ECX   | 890D FFFFFFFF
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; MOV   ECX, [X(2)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(3)], ECX     | 890D FFFFFFFF
        ;
        ; X(1) -> X(2)
        ; MOV   ECX, [X(1)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(2)], ECX     | 890D FFFFFFFF
        ;
        ; X(N) -> X(1)
        ; MOV   [X(1)], EAX     | A3 FFFFFFFF           ; 11 BYTES
        ; FILD  DWORD [X(1)]    | DB05 FFFFFFFF
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(N) -> X(1)
        ; MOV      [X(1)], EAX        | A3 FFFFFFFF     ; 13 BYTES
        ; CVTSI2SD XMM0, DWORD [X(1)] | F20F2A05 FFFFFFFF
        ;>
        ; ----------------------------------------------
        mov     [edi + 0], byte 0xA1
        pop     eax
        mov     dword [edi + 1], eax
        @@xshr  edi, 5
        mov     ecx, [.ezx]
        dec     ecx
   .inline.swapr.ivar.pop:
        mov     [edi + 6], word 0x0D89
        mov     [edi + 8], eax
        pop     eax
        mov     [edi + 0], word 0x0D8B
        mov     dword [edi + 2], eax
        @@xshr  edi, 12
        dec     ecx
        jnz    .inline.swapr.ivar.pop
        ;
    $ifdef _SSEX
        mov     [edi + 0], byte 0xA3
        mov     dword [edi + 1], eax
        mov     [edi + 5], dword 0x052A0FF2
        mov     dword [edi + 9], eax
        @@xshr  edi, 13
    $else
        mov     [edi + 0], byte 0xA3
        mov     dword [edi + 1], eax
        mov     [edi + 5], word 0x05DB
        mov     dword [edi + 7], eax
        @@xshr  edi, 11
    $end
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapr.svar:
        ; (12*acount-2)-(7*acount+5) = 5*acount-7
        mov     ecx, [.ezx]
        mov     eax, 5
        mul     ecx
        sub     eax, 7
        js     .inline.swapr.svar.x
        @@range eax, .error.memory
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.swapr.svar.x:
        mov     ecx, [.ezx]
        mov     [.zzx], ecx
   .inline.swapr.svar.push:
        push    dword [edi - 06]                            ; PUSH X(1), X(2), ... , X(N-1), X(N)
        add     [.XSP], 8
        @@xshl  edi, 7
        dec     [.zzx]
        jz     .inline.swapr.svar.push.out
        ;
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .inline.swapr.error
        jmp    .inline.swapr.svar.push
   .inline.swapr.svar.push.out:
        ; ----------------------------------------------
        ; X(N) -> EAX
        ;*MOV   EAX, [X(N)]     | A1 FFFFFFFF           ; 5 BYTES
        ;
        ; X(N-1) -> X(N)
        ; MOV   ECX, [X(N-1)]   | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N)], ECX     | 890D FFFFFFFF
        ;
        ; X(N-2) -> X(N-1)
        ; MOV   ECX, [X(N-2)]   | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N-1)], ECX   | 890D FFFFFFFF
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; MOV   ECX, [X(2)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(3)], ECX     | 890D FFFFFFFF
        ;
        ; X(1) -> X(2)
        ; MOV   ECX, [X(1)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(2)], ECX     | 890D FFFFFFFF
        ;
        ; X(N) -> X(1)
        ; MOV   [X(1)], EAX     | A3 FFFFFFFF           ; 5 BYTES
        ;>
        ; ----------------------------------------------
        mov     [edi + 0], byte 0xA1
        pop     edx
        mov     dword [edi + 1], edx
        push    dword [edx]
        pop     dword [.edx]
        @@xshr  edi, 5
        mov     ecx, [.ezx]
        dec     ecx
   .inline.swapr.svar.pop:
        mov     [edi + 6], word 0x0D89
        mov     [edi + 8], edx
        pop     eax
        mov     [edi + 0], word 0x0D8B
        mov     dword [edi + 2], eax
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        test    edx, edx
        jz     .error.argument
        push    dword [eax]
        pop     dword [edx] ; assign string value at compile time
      $end
        mov     edx, eax
        @@xshr  edi, 12
        dec     ecx
        jnz    .inline.swapr.svar.pop
        ;
        mov     [edi + 0], byte 0xA3
        mov     dword [edi + 1], eax
        mov     edx, [.edx]
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        mov     [eax], edx ; assign string value at compile time
      $end
        @@xshr  edi, 5
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapr.error:
        add     esp, [.XSP]
        jmp    .error.argument

   .inline.swapl:
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ;?PUSH    DWORD [EDX]       | FF32
        ;
        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        mov     ecx, [.ezx]
        mov     [.zzx], ecx
        dec     [.zzx]
        @@xshl  edi, 5
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swapl.dvar,\
                OBJ_INT_VAR    , .inline.swapl.ivar,\
                OBJ_STRING_VAR , .inline.swapl.svar
        jmp    .error.argument
   .inline.swapl.dvar:
        mov     ecx, [edi - 09]
        mov     [.ecx], ecx                                 ; [.ecx] = X(1)
    $ifdef _SSEX
        ; (16*acount)-(10*acount+5) = 6*acount-5
        mov     ecx, [.ezx]
        mov     eax, 6
        mul     ecx
        sub     eax, 5
        js     .inline.swapl.dvar.x
    $else
        ; (12*acount)-(10*acount+5) = 2*acount-5
        mov     ecx, [.ezx]
        mov     eax, 2
        mul     ecx
        sub     eax, 5
        js     .inline.swapl.dvar.x
    $end
        @@range eax, .error.memory
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.swapl.dvar.x:
        @@xshl  edi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.swapl.dvar.x
        ;
        @@xshl  edi, 10
        lea     edx, [edi + 1]
        mov     ecx, [.ezx]
        dec     ecx
        ;
        push    [.ecx]                                      ; PUSH X(1)
   .inline.swapl.dvar.push:
        push    dword [edx]                                 ; PUSH X(N), X(N-1), ... , X(3), X(2)
        add     edx, 10
        dec     ecx
        jnz    .inline.swapl.dvar.push
        ;
        ; ----------------------------------------------
        ; X(2) -> ST0
        ;*FLD   QWORD [X(2)]    | DD05 FFFFFFFF         ; 6 BYTES
        ;
        ; X(3) -> X(2)
        ; FLD   QWORD [X(3)]    | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(2)]    | DD1D FFFFFFFF
        ;
        ; X(4) -> X(3)
        ; FLD   QWORD [X(4)]    | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(3)]    | DD1D FFFFFFFF
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; FLD   QWORD [X(N)]    | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(N-1)]  | DD1D FFFFFFFF
        ;
        ; X(1) -> X(N)
        ; FLD   QWORD [X(1)]    | DD05 FFFFFFFF         ; 12 BYTES
        ; FSTP  QWORD [X(N)]    | DD1D FFFFFFFF
        ;
        ; X(2) -> X(1)
        ; FST   QWORD [X(1)]    | DD15 FFFFFFFF         ; 6 BYTES
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; X(2) -> ST0
        ;*MOVSD XMM0, QWORD [X(2)] | F20F1005 FFFFFFFF  ; 8 BYTES
        ;
        ; X(3) -> X(2)
        ; MOVSD XMM1, QWORD [X(3)] | F20F100D FFFFFFFF  ; 16 BYTES
        ; MOVSD QWORD [X(2)], XMM1 | F20F110D FFFFFFFF
        ;
        ; X(4) -> X(3)
        ; *     QWORD [X(4)]       | F20F100D FFFFFFFF  ; 16 BYTES
        ; *     QWORD [X(3)]       | F20F110D FFFFFFFF
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; *     QWORD [X(N)]       | F20F100D FFFFFFFF  ; 16 BYTES
        ; *     QWORD [X(N-1)]     | F20F110D FFFFFFFF
        ;
        ; X(1) -> X(N)
        ; *     QWORD [X(1)]       | F20F100D FFFFFFFF  ; 16 BYTES
        ; *     QWORD [X(N)]       | F20F110D FFFFFFFF
        ;
        ; X(2) -> X(1)
        ; MOVSD QWORD [X(1)], XMM0 | F20F1105 FFFFFFFF  ; 8 BYTES
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        mov     [edi + 0], dword 0x05100FF2
        pop     eax
        mov     dword [edi + 4], eax
        @@xshr  edi, 8
    $else
        mov     [edi + 0], word 0x05DD
        pop     eax
        mov     dword [edi + 2], eax
        @@xshr  edi, 6
    $end
        mov     ecx, [.ezx]
        dec     ecx
   .inline.swapl.dvar.pop:
    $ifdef _SSEX
        mov     [edi + 08], dword 0x0D110FF2
        mov     [edi + 12], eax
        pop     eax
        mov     [edi + 00], dword 0x0D100FF2
        mov     dword [edi + 04], eax
        @@xshr  edi, 16
    $else
        mov     [edi + 6], word 0x1DDD
        mov     [edi + 8], eax
        pop     eax
        mov     [edi + 0], word 0x05DD
        mov     dword [edi + 2], eax
        @@xshr  edi, 12
    $end
        dec     ecx
        jnz    .inline.swapl.dvar.pop
        ;
    $ifdef _SSEX
        mov     [edi + 0], dword 0x05110FF2
        mov     dword [edi + 4], eax
        @@xshr  edi, 8
    $else
        mov     [edi + 0], word 0x15DD
        mov     dword [edi + 2], eax
        @@xshr  edi, 6
    $end
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapl.ivar:
        mov     ecx, [edi - 06]
        mov     [.ecx], ecx                                 ; [.ecx] = X(1)
    $ifdef _SSEX
        ; (12*acount+6)-(7*acount+5) = 5*acount+1
        mov     ecx, [.ezx]
        mov     eax, 5
        mul     ecx
        add     eax, 1
        js     .inline.swapl.ivar.x
    $else
        ; (12*acount+4)-(7*acount+5) = 5*acount-1
        mov     ecx, [.ezx]
        mov     eax, 5
        mul     ecx
        sub     eax, 1
        js     .inline.swapl.ivar.x
    $end
        @@range eax, .error.memory
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD           ;>integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.swapl.ivar.x:
        @@xshl  edi, 7
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.swapl.ivar.x
        ;
        @@xshl  edi, 7
        lea     edx, [edi + 1]
        mov     ecx, [.ezx]
        dec     ecx
        ;
        push    [.ecx]                                      ; PUSH X(1)
   .inline.swapl.ivar.push:
        push    dword [edx]                                 ; PUSH X(N), X(N-1), ... , X(3), X(2)
        add     edx, 7
        dec     ecx
        jnz    .inline.swapl.ivar.push
        ;
        ; ----------------------------------------------
        ; X(2) -> EAX
        ;*MOV   EAX, [X(2)]     | A1 FFFFFFFF           ; 5 BYTES
        ;
        ; X(3) -> X(2)
        ; MOV   ECX, [X(3)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(2)], ECX     | 890D FFFFFFFF
        ;
        ; X(4) -> X(3)
        ; MOV   ECX, [X(4)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(3)], ECX     | 890D FFFFFFFF
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; MOV   ECX, [X(N)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N-1)], ECX   | 890D FFFFFFFF
        ;
        ; X(1) -> X(N)
        ; MOV   ECX, [X(1)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N)], ECX     | 890D FFFFFFFF
        ;
        ; X(2) -> X(1)
        ; MOV   [X(1)], EAX     | A3 FFFFFFFF           ; 11 BYTES
        ; FILD  DWORD [X(1)]    | DB05 FFFFFFFF
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(2) -> X(1)
        ; MOV      [X(1)], EAX        | A3 FFFFFFFF     ; 13 BYTES
        ; CVTSI2SD XMM0, DWORD [X(1)] | F20F2A05 FFFFFFFF
        ;>
        ; ----------------------------------------------
        mov     [edi + 0], byte 0xA1
        pop     eax
        mov     dword [edi + 1], eax
        @@xshr  edi, 5
        mov     ecx, [.ezx]
        dec     ecx
   .inline.swapl.ivar.pop:
        mov     [edi + 6], word 0x0D89
        mov     [edi + 8], eax
        pop     eax
        mov     [edi + 0], word 0x0D8B
        mov     dword [edi + 2], eax
        @@xshr  edi, 12
        dec     ecx
        jnz    .inline.swapl.ivar.pop
        ;
    $ifdef _SSEX
        mov     [edi + 0], byte 0xA3
        mov     dword [edi + 1], eax
        mov     [edi + 5], dword 0x052A0FF2
        mov     dword [edi + 9], eax
        @@xshr  edi, 13
    $else
        mov     [edi + 0], byte 0xA3
        mov     dword [edi + 1], eax
        mov     [edi + 5], word 0x05DB
        mov     dword [edi + 7], eax
        @@xshr  edi, 11
    $end
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapl.svar:
        mov     ecx, [edi - 06]
        mov     [.ecx], ecx                                 ; [.ecx] = X(1)
        ; (12*acount-2)-(7*acount+5) = 5*acount-7
        mov     ecx, [.ezx]
        mov     eax, 5
        mul     ecx
        sub     eax, 7
        js     .inline.swapl.svar.x
        @@range eax, .error.memory
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA DDDDDDDD           ;>string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.swapl.svar.x:
        @@xshl  edi, 7
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.swapl.svar.x
        ;
        @@xshl  edi, 7
        lea     edx, [edi + 1]
        mov     ecx, [.ezx]
        dec     ecx
        ;
        push    [.ecx]                                      ; PUSH X(1)
   .inline.swapl.svar.push:
        push    dword [edx]                                 ; PUSH X(N), X(N-1), ... , X(3), X(2)
        add     edx, 7
        dec     ecx
        jnz    .inline.swapl.svar.push
        ;
        ; ----------------------------------------------
        ; X(2) -> EAX
        ;*MOV   EAX, [X(2)]     | A1 FFFFFFFF           ; 5 BYTES
        ;
        ; X(3) -> X(2)
        ; MOV   ECX, [X(3)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(2)], ECX     | 890D FFFFFFFF
        ;
        ; X(4) -> X(3)
        ; MOV   ECX, [X(4)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(3)], ECX     | 890D FFFFFFFF
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; MOV   ECX, [X(N)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N-1)], ECX   | 890D FFFFFFFF
        ;
        ; X(1) -> X(N)
        ; MOV   ECX, [X(1)]     | 8B0D FFFFFFFF         ; 12 BYTES
        ; MOV   [X(N)], ECX     | 890D FFFFFFFF
        ;
        ; X(2) -> X(1)
        ; MOV   [X(1)], EAX     | A3 FFFFFFFF           ; 5 BYTES
        ;>
        ; ----------------------------------------------
        mov     [edi + 0], byte 0xA1
        pop     edx
        mov     dword [edi + 1], edx
        push    dword [edx]
        pop     dword [.edx]
        @@xshr  edi, 5
        mov     ecx, [.ezx]
        dec     ecx
   .inline.swapl.svar.pop:
        mov     [edi + 6], word 0x0D89
        mov     [edi + 8], edx
        pop     eax
        mov     [edi + 0], word 0x0D8B
        mov     dword [edi + 2], eax
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        test    edx, edx
        jz     .error.argument
        push    dword [eax]
        pop     dword [edx] ; assign string value at compile time
      $end
        mov     edx, eax
        @@xshr  edi, 12
        dec     ecx
        jnz    .inline.swapl.svar.pop
        ;
        mov     [edi + 0], byte 0xA3
        mov     dword [edi + 1], eax
        mov     edx, [.edx]
      $ifdef SIC_FORCE_ASSIGN
        test    eax, eax
        jz     .error.argument
        mov     [eax], edx ; assign string value at compile time
      $end
        @@xshr  edi, 5
        ;
        mov     ecx, [.ezx]
        shl     ecx, 2
        add     [.RSP], ecx
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccopy.dvar
        jmp    .error.argument
   .inline.ccopy.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccopy.dvar.dvar
        jmp    .error.argument
   .inline.ccopy.dvar.dvar:
        ; --------------------------------------------------
        ;?...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -20                  ; ecx = object type
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
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]
        mov     edx, [edi - 19]
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        sub     [.ezx], 2
        jmp    .inline.proc

   .inline.ccovalue:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccovalue.dvar
        jmp    .error.argument
   .inline.ccovalue.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccovalue.dvar.dvar
        jmp    .error.argument
   .inline.ccovalue.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        mov     ecx, [edi - 09]
        movsd   xmm0, qword [ecx]
        mov     ecx, [edi - 19]
        movsd   xmm1, qword [ecx]
    $else
        mov     ecx, [edi - 09]
        fld     qword [ecx]
        mov     ecx, [edi - 19]
        fld     qword [ecx]
    $end
        @@xshl  edi, 20
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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.crestore.dvar
        jmp    .error.argument
   .inline.crestore.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.crestore.dvar.dvar
        jmp    .error.argument
   .inline.crestore.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 40-20, .error.memory
    $ifdef _SSEX
        mov     ecx, [edi - 09]
        movsd   xmm0, qword [ecx]
        movsd   qword [esp - 08], xmm0
        mov     edx, [edi - 19]
        movsd   xmm1, qword [edx]
        movsd   qword [esp - 16], xmm1
    $else
        mov     ecx, [edi - 09]
        fld     qword [ecx]
        fst     qword [esp - 08]
        mov     edx, [edi - 19]
        fld     qword [edx]
        fst     qword [esp - 16]
    $end
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xB8
        mov     eax, [esp - 08]
        mov     [edi + 06], eax
        mov     [edi + 10], byte 0xBA
        mov     eax, [esp - 04]
        mov     [edi + 11], eax
        mov     [edi + 15], dword 0x89045189
        mov     [edi + 19], byte 0x01
        ;
        mov     [edi + 20], byte 0xB9
        mov     [edi + 21], edx
        mov     [edi + 25], byte 0xB8
        mov     eax, [esp - 16]
        mov     [edi + 26], eax
        mov     [edi + 30], byte 0xBA
        mov     eax, [esp - 12]
        mov     [edi + 31], eax
        mov     [edi + 35], dword 0x89045189
        mov     [edi + 39], byte 0x01
        @@xshr  edi, 40
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EAX, FF+          | B8 FFFFFFFF
        ; MOV     EDX, FF+          | BA FFFFFFFF
        ; MOV     [ECX+4], EDX      | 895104
        ; MOV     [ECX], EAX        | 8901

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EAX, FF+          | B8 FFFFFFFF
        ; MOV     EDX, FF+          | BA FFFFFFFF
        ; MOV     [ECX+4], EDX      | 895104
        ; MOV     [ECX], EAX        | 8901
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
    $ifdef _SSEX
        pcase   esi, @@crestore, .inline.sse.dcon.test
    $else
        pcase   esi, @@crestore, .inline.st0.dcon.test
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
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccopy.2p.dvar
        jmp    .error.argument
   .inline.ccopy.2p.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccopy.2p.dvar.dvar
        jmp    .error.argument
   .inline.ccopy.2p.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]
        mov     edx, [edi - 19]
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
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
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccopy.3p.dvar
        jmp    .error.argument
   .inline.ccopy.3p.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccopy.3p.dvar.dvar
        jmp    .error.argument
   .inline.ccopy.3p.dvar.dvar:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -20                  ; ecx = object type
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
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]
        mov     edx, [edi - 19]
        @@xshl  edi, 20
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        sub     [.ezx], 2
        jmp    .inline.proc

   .inline.cpmove.3p:
        mov     [.FPU], 0
   .inline.cpcopy.3p:
        ; --------------------------------------------------
        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;?PUSH    ECX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.cpcopy.3p.ivar,\
                OBJ_POINTER , .inline.cpcopy.3p.ptr
        jmp    .error.argument
   .inline.cpcopy.3p.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 2
        mov     [edi + 0], word 0x088B
        @@xshr  edi, 2
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*MOV     ECX, [EAX]        | 8B08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc
   .inline.cpcopy.3p.ptr:
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS           ; pointer constant (9B)
        ;*PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 4
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 SSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        dec     [.ezx]
        jmp    .inline.proc

   .inline.cswop:
        mov     [.FPU], 0
   .inline.cswap:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.cswap.dvar
        jmp    .error.argument
   .inline.cswap.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.cswap.dvar.dvar
        jmp    .error.argument
   .inline.cswap.dvar.dvar:
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.cswap.dvar.dvar.dvar
        jmp    .error.argument
   .inline.cswap.dvar.dvar.dvar:
        stdcall code_object, [.cooff], -30                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.cswap.dvar.dvar.dvar.dvar
        jmp    .error.argument
   .inline.cswap.dvar.dvar.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        push    eax ebx
        mov     ecx, [edi - 09]
        mov     edx, [edi - 19]
        mov     eax, [edi - 29]
        mov     ebx, [edi - 39]
        @@xshl  edi, 40
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], byte 0xBA
        mov     [edi + 06], edx
        mov     [edi + 10], byte 0xB8
        mov     [edi + 11], eax
        mov     [edi + 15], byte 0xBB
        mov     [edi + 16], ebx
        @@xshr  edi, 20
        pop     ebx eax
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; MOV     EDX, OFFSET       | BA DDDDDDDD
        ; MOV     EAX, OFFSET       | B8 DDDDDDDD
        ; MOV     EBX, OFFSET       | BB DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        jmp    .inline.proc

   .inline.bara:
        mov     [.neg], 1
   .inline.fara:
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        ;
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 15]                             ; eax = int32 constant
        mov     edx, [edi - 09]                             ; edx = variable offset
        ;
        add     [.RSP], 12
        @@xshl  edi, 16
        jmp    .inline.xara.index.con
   .inline.xara.index.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                             ; ecx = constant LO
        mov     edx, [edi - 21]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [edi - 09]                             ; edx = variable offset
        ;
        add     [.RSP], 16
        @@xshl  edi, 22
   .inline.xara.index.con:
        cmp     [.neg], 0
        jz      @F
        neg     eax
    @@:
        lea     edx, [edx + eax*8]
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], dword 0x90909051
        @@xshr  edi, 9
        ; ----------------------------------------------
        ;*MOV   ECX, OFFSET     | B9 AAAAAAAA           ; pointer constant (9B)
        ; PUSH  ECX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        jmp    .exit

   .inline.xarr:
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
   .inline.xarr.index:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 IIIIIIII           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 IIIIIIII           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*FSTP  QWORD [ESP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        @@range 15-13, .error.memory
        mov     eax, @@__int32                          ; eax = "int" proc offset
        mov     edx, [edi - 09]                         ; edx = variable offset
        @@xshl  edi, 13
        mov     [edi + 00], dword 0xBA08C483
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x00B9D2FF
        mov     [edi + 11], edx
        @@xshr  edi, 15
        ; ----------------------------------------------
        ;*ADD   ESP, 8          | 83C408
        ; MOV   EDX, @@__int32  | BA PPPPPPPP
        ; CALL  EDX             | FFD2
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
;       @@range 12-15, .error.memory
        mov     edx, [edi - 09]                             ; edx = variable offset
        @@xshl  edi, 15
        mov     [edi + 00], dword 0xF208C483
        mov     [edi + 04], dword 0xB9C02C0F
        mov     [edi + 08], edx
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*ADD        ESP, 8      | 83C408
        ; CVTTSD2SI  EAX, XMM0   | F20F2CC0
        ; MOV        ECX, OFFSET | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.dvar:
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 IIIIIIII           ; double variable (10B)
        ;*PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        mov     edx, [edi - 09]                         ; edx = variable offset
        @@xshl  edi, 15
        mov     [edi + 00], dword 0x01100FF2
        mov     [edi + 04], dword 0xC02C0FF2
        mov     [edi + 08], byte 0xB9
        mov     [edi + 09], edx
        @@xshr  edi, 13
        ; ----------------------------------------------
        ; MOV        ECX, OFFSET       | B9 IIIIIIII
        ;*MOVSD      XMM0, QWORD [ECX] | F20F1001
        ; CVTTSD2SI  EAX, XMM0         | F20F2CC0
        ; MOV        ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        mov     eax, @@__int32                          ; eax = "int" proc offset
        mov     edx, [edi - 09]                         ; edx = variable offset
        @@xshl  edi, 15
        mov     [edi + 00], dword 0x00BA01DD
        mov     [edi + 03], eax
        mov     [edi + 07], dword 0x00B9D2FF
        mov     [edi + 10], edx
        @@xshr  edi, 14
        ; ----------------------------------------------
        ; MOV   ECX, OFFSET     | B9 IIIIIIII
        ;*FLD   QWORD [ECX]     | DD01
        ; MOV   EDX, @@__int32  | BA PPPPPPPP
        ; CALL  EDX             | FFD2
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                             ; ecx = constant LO
        mov     edx, [edi - 21]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [edi - 09]                             ; edx = variable offset
        @@xshl  edi, 22
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EAX, INT32        | B8 FFFFFFFF
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.ivar:
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 IIIIIIII           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH  DWORD [ECX+4]   | FF71 04
        ; PUSH  DWORD [ECX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 09]                         ; edx = variable offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0x00B9008B
        mov     [edi + 03], edx
        @@xshr  edi, 7
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 IIIIIIII
        ;*MOV   EAX, [EAX]      | 8B00
        ; MOV   ECX, OFFSET     | B9 DDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 12
        jmp    .inline.xarr.proc
   .inline.xarr.index.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = variable offset
        @@xshl  edi, 11
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        jmp    .inline.xarr.proc
   .inline.xarr.index.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 09]                             ; edx = variable offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; ADD     ESP, 4            | 83C4 04
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.proc:
        mov     [.ezx], 0
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        pcase   esi,\
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
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_INT_VAR                            ; ecx = object type
        jne    .error.argument
   .inline.pxarr.index:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 IIIIIIII           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 IIIIIIII           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -7                   ; ecx = object type
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
        ;*FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 15-10, .error.memory
        mov     eax, @@__int32                              ; eax = "int" proc offset
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 10
        mov     [edi + 00], dword 0xBA08C483
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x00B9D2FF
        mov     [edi + 11], edx
        @@xshr  edi, 15
        ; --------------------------------------------------
        ;*ADD     ESP, 8            | 83C408
        ; MOV     EDX, @@__int32    | BA PPPPPPPP
        ; CALL    EDX               | FFD2
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
;       @@range 12-12, .error.memory
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0xF208C483
        mov     [edi + 04], dword 0xB9C02C0F
        mov     [edi + 08], edx
        @@xshr  edi, 12
        ; --------------------------------------------------
        ;*ADD        ESP, 8      | 83C408
        ; CVTTSD2SI  EAX, XMM0   | F20F2CC0
        ; MOV        ECX, OFFSET | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.dvar:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 IIIIIIII           ; double variable (10B)
        ;*PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 13-12, .error.memory
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0x01100FF2
        mov     [edi + 04], dword 0xC02C0FF2
        mov     [edi + 08], byte 0xB9
        mov     [edi + 09], edx
        @@xshr  edi, 13
        ; --------------------------------------------------
        ; MOV        ECX, OFFSET       | B9 IIIIIIII
        ;*MOVSD      XMM0, QWORD [ECX] | F20F1001
        ; CVTTSD2SI  EAX, XMM0         | F20F2CC0
        ; MOV        ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $else
        @@range 14-12, .error.memory
        mov     eax, @@__int32                              ; eax = "int" proc offset
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 12
        mov     [edi + 00], dword 0x00BA01DD
        mov     [edi + 03], eax
        mov     [edi + 07], dword 0x00B9D2FF
        mov     [edi + 10], edx
        @@xshr  edi, 14
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 IIIIIIII
        ;*FLD     QWORD [ECX]       | DD01
        ; MOV     EDX, @@__int32    | BA PPPPPPPP
        ; CALL    EDX               | FFD2
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 12
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 13]                             ; ecx = constant LO
        mov     edx, [edi - 18]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 19
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], edx
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     EAX, INT32        | B8 FFFFFFFF
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 IIIIIIII           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 9
        mov     [edi + 00], dword 0x00B9008B
        mov     [edi + 03], edx
        @@xshr  edi, 7
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 IIIIIIII
        ;*MOV     EAX, [EAX]        | 8B00
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 6]                              ; edx = variable offset
        @@xshl  edi, 10
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD
        ; ADD     ESP, 4            | 83C4 04
        ;>
        ; --------------------------------------------------
        add     [.RSP], 12
        jmp    .inline.pxarr.proc
   .inline.pxarr.proc:
        mov     [.ezx], 0
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        pcase   esi,\
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
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.xarv.dvar
        jmp    .error.argument
   .inline.xarv.dvar:
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.xarv.dvar.dcon,\
                OBJ_INT_CON    , .inline.xarv.dvar.icon
        jmp    .error.argument
   .inline.xarv.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 16]                         ; ecx = constant LO
        mov     edx, [edi - 21]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        mov     ecx, [edi - 09]
        ;
        @@xshl  edi, 22
        add     [.RSP], 16
        jmp    .inline.xarv.proc
   .inline.xarv.dvar.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     eax, [edi - 15]
        mov     ecx, [edi - 09]
        ;
        @@xshl  edi, 16
        add     [.RSP], 12
   .inline.xarv.proc:
        cmp     [.neg], 0
        jz     .inline.xarv.proc.x
        neg     eax
   .inline.xarv.proc.x:
        lea     ecx, [ecx + eax*8]
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        @@xshr  edi, 10
        ; --------------------------------------------------
        ;*MOV     ECX, OFFSET       | B9 DDDDDDDD           ;>double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        jmp    .exit

   .inline.matrip:
        mov     [.fpatype], 'i'
        ; --------------------------------------------------
        ;?MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ;?PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        ;?MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     [.proc_o], esi
        mov     [.proc_z], eax
        push    [.ezx]
        pop     [.ecx]
        mov     [.edi], edi
        pcase   esi,\
                @@matrip    , .inline.matrip.va,\
                @@matrip.rc , .inline.matrip.va
        jmp    .inline.matrip.arg
   .inline.matrip.va:
        ; --------------------------------------------------
        ; ...                       | ...
        ; --------------------------------------------------
        ; MOV     ECX, ACOUNT       | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        sub     [.edi], 5
        sub     [.coshift], 5
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
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ;*PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 9-5, .error.memory
        @@xshl  edi, 5
        mov     [edi + 00], dword 0x01100FF2
        mov     [edi + 04], dword 0xC02C0FF2
        mov     [edi + 09], byte 0x50
        @@xshr  edi, 9
        ; --------------------------------------------------
        ; MOV        ECX, OFFSET       | B9 SSSSSSSS
        ;*MOVSD      XMM0, QWORD [ECX] | F20F1001
        ; CVTTSD2SI  EAX, XMM0         | F20F2CC0
        ; PUSH       EAX               | 50
        ;>
        ; --------------------------------------------------
    $else
        @@range 10-5, .error.memory
        mov     ecx, @@__int32                              ; ecx = "int" proc offset
        @@xshl  edi, 5
        mov     [edi + 00], dword 0x00BA01DD
        mov     [edi + 03], ecx
        mov     [edi + 07], word 0xD2FF
        mov     [edi + 09], byte 0x50
        @@xshr  edi, 10
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 SSSSSSSS
        ;*FLD     QWORD [ECX]       | DD01
        ; MOV     EDX, @@__int32    | BA PPPPPPPP
        ; CALL    EDX               | FFD2
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
    $end
        sub     [.edi], 10
        sub     [.coshift], 10
        jmp    .inline.matrip.next
   .inline.matrip.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     eax, [.edi]
        mov     ecx, [eax - 06]                             ; ecx = constant LO
        mov     edx, [eax - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        mov     edx, [.edi]
        mov     [edx - 12], byte 0xB8
        mov     [edx - 11], eax
        mov     [edx - 07], byte 0x50
        mov     [edx - 06], dword 0x90909090
        mov     [edx - 02], word 0x9090
        ; --------------------------------------------------
        ; MOV     EAX, INT32        | B8 FFFFFFFF
        ; PUSH    EAX               | 50
        ; NOP                       | 90
        ; NOP                       | 90
        ; NOP                       | 90
        ; NOP                       | 90
        ; NOP                       | 90
        ; NOP                       | 90
        ;>
        ; --------------------------------------------------
        sub     [.edi], 12
        sub     [.coshift], 12
        jmp    .inline.matrip.next
   .inline.matrip.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        sub     [.edi], 7
        sub     [.coshift], 7
        jmp    .inline.matrip.next
   .inline.matrip.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        sub     [.edi], 6
        sub     [.coshift], 6
;       jmp    .inline.matrip.next
   .inline.matrip.next:
        dec     [.ecx]
        jnz    .inline.matrip.arg
        mov     esi, [.proc_o]
        mov     eax, [.proc_z]
        jmp    .inline.proc

   .inline.calls:
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;
        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; acount * 5 + 5
        ; ----------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        mov     ecx, [.ezx]
        ;
        ; acount * 7 - (acount * 5 + 5) = acount * 2 - 5
        lea     eax, [2*ecx - 5]                        ; eax = acount * 2 - 5
        @@range eax, .error.memory
        ;
        lea     eax, [5*ecx + 5]                        ; eax = acount * 5 + 5
        @@xshl  edi, eax
        ;
;       mov     edx, edi
;       add     edx, 1
        lea     edx, [edi + 1]
        mov     [.acount], 0
   .inline.calls.push:
        mov     eax, dword [edx]
        test    eax, eax
        jz     .inline.calls.push.next
        push    eax
        inc     [.acount]
   .inline.calls.push.next:
        add     edx, 5
        dec     ecx
        jnz    .inline.calls.push
        ;
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;
        ; ...                   |
        ;
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;>
        ; ----------------------------------------------
        ; acount * 7
        ; ----------------------------------------------
        mov     ecx, [.acount]
        test    ecx, ecx
        jz     .inline.calls.no.proc
        mov     eax, 7
        mul     ecx                                     ; eax = acount * 7
        ;
        mov     edx, edi
   .inline.calls.pop:
        mov     [edx + 0], byte 0xBA
        pop     dword [edx + 1]
        mov     [edx + 5], word 0x12FF
        add     edx, 7
        dec     ecx
        jnz    .inline.calls.pop
        ;
        @@xshr  edi, eax
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
   .inline.calls.no.proc:
        mov     edx, [sic]
        or      [edx + T_sic_data.coops], SIC_OPT_FLAG_BYPASS
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.rcalls:
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;
        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; acount * 5 + 5
        ; ----------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        mov     ecx, [.ezx]
        ;
        ; acount * 7 - (acount * 5 + 5) = acount * 2 - 5
        lea     eax, [2*ecx - 5]                        ; eax = acount * 2 - 5
        @@range eax, .error.memory
        ;
        lea     edx, [edi - 9]
        mov     [.acount], 0
   .inline.rcalls.push:
        mov     eax, dword [edx]
        test    eax, eax
        jz     .inline.rcalls.push.next
        push    eax
        inc     [.acount]
   .inline.rcalls.push.next:
        sub     edx, 5
        dec     ecx
        jnz    .inline.rcalls.push
        ; acount * 5 + 5
        mov     ecx, [.ezx]
        lea     eax, [5*ecx + 5]                        ; eax = acount * 5 + 5
        @@xshl  edi, eax
        ;
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;
        ; ...                   |
        ;
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ; CALL  DWORD [EDX]     | FF12
        ;>
        ; ----------------------------------------------
        ; acount * 7
        ; ----------------------------------------------
        mov     ecx, [.acount]
        test    ecx, ecx
        jz     .inline.rcalls.no.proc
        mov     eax, 7
        mul     ecx                                     ; eax = acount * 7
        ;
        mov     edx, edi
   .inline.rcalls.pop:
        mov     [edx + 0], byte 0xBA
        pop     dword [edx + 1]
        mov     [edx + 5], word 0x12FF
        add     edx, 7
        dec     ecx
        jnz    .inline.rcalls.pop
        ;
        @@xshr  edi, eax
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
   .inline.rcalls.no.proc:
        mov     edx, [sic]
        or      [edx + T_sic_data.coops], SIC_OPT_FLAG_BYPASS
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.xgoto:
        mov     word [.opcode], 0x22FF                  ; JMP DWORD [EDX]  | FF22
        jmp    .inline.xgoca
   .inline.xcall:
        mov     word [.opcode], 0x12FF                  ; CALL DWORD [EDX] | FF12
        jmp    .inline.xgoca

   .inline.xgoca:
        ; ----------------------------------------------
        ;*
        ;?MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50

        ; ...                   | ...
        ;?MOV   [ESP], EAX      | 890424                ; integer RSP RAX (3B)

        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        mov     ecx, [.ezx]
        lea     eax, [5*ecx]                            ; eax = acount * 5
        @@xshl  edi, eax
        ; ----------------------------------------------
        ;?MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50

        ; ...                   | ...
        ;?MOV   [ESP], EAX      | 890424                ; integer RSP RAX (3B)

        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], 0                ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.xgoca.dcon,\
                OBJ_INT_VAR     , .inline.xgoca.ivar,\
                OBJ_INT_CON     , .inline.xgoca.icon,\
                OBJ_INT_RSP_RAX , .inline.xgoca.irsp.rax
        jmp    .error.argument
        ;
   .inline.xgoca.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30

        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 7
        ; acount * 5 + 7
        ; ----------------------------------------------
        ; -> acount * 5 + 51
        ; ----------------------------------------------
        @@range (51-7), .error.memory
        ;
        @@xshl  edi, 7
        mov     eax, [edi + 01]
        mov     [.eax], eax
        ;
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = (acount - 1)
        lea     eax, [5*ecx]                            ; eax = (acount - 1) * 5
        lea     edx, [edi + eax + 7 + 1 - 5]
   .inline.xgoca.ivar.push:
        push    dword [edx]
        sub     edx, 5
        dec     ecx
        jnz    .inline.xgoca.ivar.push
        ;
        mov     ecx, [.ezx]
        dec     ecx
        mov     [edi + 00], byte 0xE9
        mov     [edi + 01], eax                         ; eax = (acount - 1) * 5
        lea     edx, [edi + 05]
   .inline.xgoca.ivar.pop:
        mov     [edx + 00], byte 0xBB
        pop     dword [edx + 01]
        add     edx, 5
        dec     ecx
        jnz    .inline.xgoca.ivar.pop
        ;
        mov     ecx, [.ezx]
        lea     eax, [ecx - 1]                          ; eax = acount-1
        mov     [edx + 00], byte 0xB9
        mov     [edx + 01], eax
        mov     eax, [.eax]
        mov     [edx + 05], byte 0xB8
        mov     [edx + 06], eax
        mov     [edx + 10], word 0x008B
        mov     [edx + 12], dword 0x0F00F883
        mov     [edx + 16], byte 0x8C
        mov     [edx + 17], dword (2+6+5+4+5+8)
        mov     [edx + 21], dword 0x8D0FC839
        mov     [edx + 25], dword (5+4+5+8)
        mov     [edx + 29], dword 0x000000E8
        mov     [edx + 33], dword 0xEA835A00
        mov     [edx + 37], dword 0x80048D26
        mov     [edx + 41], dword 0x128BC229
        mov     [edx + 45], dword 0x0274D285
        mov     ax, word [.opcode]                      ; FF12 | FF22
        mov     [edx + 49], ax
        ;
        ; ----------------------------------------------
        ;*JMP   LA:             | E9 FFFFFFFF           ; (5B)

        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; ...                   |
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
                                                        ; =(acount-1)*5B
        ; LA:
        ; MOV   ECX, ACOUNT-1   | B9 CCCCCCCC           ; (5B) argument count - 1
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; (7B) integer variable
        ; MOV   EAX, DWORD [EAX]| 8B00

        ; CMP   EAX, 0          | 83F800                ; (3B)
        ; JL    LC:             | 0F8C FFFFFFFF         ; (6B) +2+6+5+4+5+8
        ; CMP   EAX, ECX        | 39C8                  ; (2B)
        ; JGE   LC:             | 0F8D FFFFFFFF         ; (6B) +5+4+5+8
                                                        ; =17B
        ; LB:
        ; CALL  P:              | E8 00000000           ; (5B) get EIP in EDX | call $+5 | pop edx
        ; P:
        ; POP   EDX             | 5A                    ; (1B) EDX = EIP
        ; SUB   EDX, 38         | 83EA26                ; (3B) 38 = 5+17+7+5+4 | EDX = label#n offset address
                                                        ; =4B

        ; LEA   EAX, [EAX*5]    | 8D0480                ; (3B) EAX = index * 5
        ; SUB   EDX, EAX        | 29C2                  ; (2B) EDX = label#index offset address
                                                        ; =5B

        ; MOV   EDX, DWORD [EDX]| 8B12                  ; (2B) EDX = label#index offset
        ; TEST  EDX, EDX        | 85D2                  ; (2B)
        ; JZ    @F              | 7402                  ; (2B)
        ;?CALL  DWORD [EDX]     | FF12                  ; (2B)
        ;?JMP   DWORD [EDX]     | FF22                  ; (2B)
        ; @@:                                           ; =8B

        ; LC:
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 5 + 7 + 17 + 5 + 4 + 5 + 8
        ; acount * 5 + 51
        ; ----------------------------------------------
        lea     eax, [5*ecx + 51]                       ; eax = acount * 5 + 51
        @@xshr  edi, eax
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
        ;
   .inline.xgoca.irsp.rax:
        ; ----------------------------------------------
        ; ...                   | ...
        ;*MOV   [ESP], EAX      | 890424                ; integer RSP RAX (3B)

        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 3
        ; acount * 5 + 3
        ; ----------------------------------------------
        ; -> acount * 5 + 47
        ; ----------------------------------------------
        @@range (47-3), .error.memory
        ;
        @@xshl  edi, 3
        ;
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = (acount - 1)
        lea     eax, [5*ecx]                            ; eax = (acount - 1) * 5
        lea     edx, [edi + eax + 3 + 1 - 5]
   .inline.xgoca.irsp.rax.push:
        push    dword [edx]
        sub     edx, 5
        dec     ecx
        jnz    .inline.xgoca.irsp.rax.push
        ;
        mov     ecx, [.ezx]
        dec     ecx
        mov     [edi + 00], dword 0xE904C483
        mov     [edi + 04], eax                         ; eax = (acount - 1) * 5
        lea     edx, [edi + 08]
   .inline.xgoca.irsp.rax.pop:
        mov     [edx + 00], byte 0xBB
        pop     dword [edx + 01]
        add     edx, 5
        dec     ecx
        jnz    .inline.xgoca.irsp.rax.pop
        ;
        mov     ecx, [.ezx]
        lea     eax, [ecx - 1]                          ; eax = acount-1
        mov     [edx + 00], byte 0xB9
        mov     [edx + 01], eax
        mov     [edx + 05], byte 0x83
        mov     [edx + 06], dword 0x8C0F00F8
        mov     [edx + 10], dword (2+6+5+4+5+8)
        mov     [edx + 14], dword 0x8D0FC839
        mov     [edx + 18], dword (5+4+5+8)
        mov     [edx + 22], byte 0xE8
        mov     [edx + 23], dword 0x00000000
        mov     [edx + 27], byte 0x5A
        mov     [edx + 28], dword 0x8D1FEA83
        mov     [edx + 32], dword 0xC2298004
        mov     [edx + 36], word 0x128B
        mov     [edx + 38], dword 0x0274D285
        mov     ax, word [.opcode]                      ; FF12 | FF22
        mov     [edx + 42], ax
        ;
        ; ----------------------------------------------
        ; ...                   | ...                   ; EAX = index
        ;*ADD   ESP, 4          | 83C404                ; (3B)
        ; JMP   LA:             | E9 FFFFFFFF           ; (5B)

        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; ...                   |
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
                                                        ; =(acount-1)*5B
        ; LA:
        ; MOV   ECX, ACOUNT-1   | B9 CCCCCCCC           ; (5B) argument count - 1

        ; CMP   EAX, 0          | 83F800                ; (3B)
        ; JL    LC:             | 0F8C FFFFFFFF         ; (6B) +2+6+5+4+5+8
        ; CMP   EAX, ECX        | 39C8                  ; (2B)
        ; JGE   LC:             | 0F8D FFFFFFFF         ; (6B) +5+4+5+8
                                                        ; =17B
        ; LB:
        ; CALL  P:              | E8 00000000           ; (5B) get EIP in EDX | call $+5 | pop edx
        ; P:
        ; POP   EDX             | 5A                    ; (1B) EDX = EIP
        ; SUB   EDX, 31         | 83EA1F                ; (3B) 31 = 5+17+5+4 | EDX = label#n offset address
                                                        ; =4B

        ; LEA   EAX, [EAX*5]    | 8D0480                ; (3B) EAX = index * 5
        ; SUB   EDX, EAX        | 29C2                  ; (2B) EDX = label#index offset address
                                                        ; =5B

        ; MOV   EDX, DWORD [EDX]| 8B12                  ; (2B) EDX = label#index offset
        ; TEST  EDX, EDX        | 85D2                  ; (2B)
        ; JZ    @F              | 7402                  ; (2B)
        ;?CALL  DWORD [EDX]     | FF12                  ; (2B)
        ;?JMP   DWORD [EDX]     | FF22                  ; (2B)
        ; @@:                                           ; =8B

        ; LC:
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 3 + 5 + 5 + 17 + 5 + 4 + 5 + 8
        ; acount * 5 + 47
        ; ----------------------------------------------
        lea     eax, [5*ecx + 47]                       ; eax = acount * 5 + 47
        @@xshr  edi, eax
        add     [.RSP], 4
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
        ;
   .inline.xgoca.dcon:
        ; ----------------------------------------------
        ; MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51

        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 12
        ; acount * 5 + 12
        ; ----------------------------------------------
        mov     [.shl], 12
        mov     ecx, [edi - 06]                         ; ecx = constant LO
        mov     edx, [edi - 11]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        mov     [.int32], eax
        cmp     eax, 0
        jl     .inline.xgoca.con.no.proc
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = acount-1
        cmp     eax, ecx
        jge    .inline.xgoca.con.no.proc
        jmp    .inline.xgoca.con.proc
        ;
   .inline.xgoca.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50

        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 6
        ; acount * 5 + 6
        ; ----------------------------------------------
        mov     [.shl], 6
        mov     eax, [edi - 10]                         ; eax = int32 constant
        cmp     eax, 0
        jl     .inline.xgoca.con.no.proc
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = acount-1
        cmp     eax, ecx
        jge    .inline.xgoca.con.no.proc
;       jmp    .inline.xgoca.con.proc
        ;
   .inline.xgoca.con.proc:
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ;?CALL  DWORD [EDX]     | FF12
        ;?JMP   DWORD [EDX]     | FF22
        ;>
        ; ----------------------------------------------
        neg     eax                                     ; eax = -index
        lea     eax, [ecx + eax - 1]                    ; eax = (acount-1 - index - 1)
        mov     ecx, 5
        mul     ecx                                     ; eax = 5 * (acount-1 - index - 1)
        mov     edx, [edi + eax + 1]                    ; edx = offset
        test    edx, edx
        jz     .inline.xgoca.con.no.proc
        mov     eax, [.shl]
        @@xshl  edi, eax
        mov     [edi + 0], byte 0xBA
        mov     [edi + 1], edx
        mov     ax, word [.opcode]                      ; FF12 | FF22
        mov     [edi + 5], ax
        @@xshr  edi, 7
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
        ;
   .inline.xgoca.con.no.proc:
        mov     eax, [.shl]
        @@xshl  edi, eax
        mov     edx, [sic]
        or      [edx + T_sic_data.coops], SIC_OPT_FLAG_BYPASS
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.rxgoto:
        mov     word [.opcode], 0x22FF                  ; JMP DWORD [EDX]  | FF22
        jmp    .inline.rxgoca
   .inline.rxcall:
        mov     word [.opcode], 0x12FF                  ; CALL DWORD [EDX] | FF12
        jmp    .inline.rxgoca

   .inline.rxgoca:
        ; ----------------------------------------------
        ;*
        ;?MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50

        ; ...                   | ...
        ;?MOV   [ESP], EAX      | 890424                ; integer RSP RAX (3B)

        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        mov     ecx, [.ezx]
        lea     eax, [5*ecx]                            ; eax = acount * 5
        @@xshl  edi, eax
        ; ----------------------------------------------
        ;?MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ;?MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ;?PUSH  EDX             | 52
        ;?PUSH  ECX             | 51

        ;?MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH  DWORD [EAX]     | FF30

        ;?MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH  EAX             | 50

        ; ...                   | ...
        ;?MOV   [ESP], EAX      | 890424                ; integer RSP RAX (3B)

        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], 0                ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.rxgoca.dcon,\
                OBJ_INT_VAR     , .inline.rxgoca.ivar,\
                OBJ_INT_CON     , .inline.rxgoca.icon,\
                OBJ_INT_RSP_RAX , .inline.rxgoca.irsp.rax
        jmp    .error.argument
        ;
   .inline.rxgoca.ivar:
        ; ----------------------------------------------
        ;*MOV   EAX, OFFSET     | B8 SSSSSSSS           ; integer variable (7B)
        ; PUSH  DWORD [EAX]     | FF30

        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 7
        ; acount * 5 + 7
        ; ----------------------------------------------
        ; -> acount * 5 + 51
        ; ----------------------------------------------
        @@range (51-7), .error.memory
        ;
        @@xshl  edi, 7
        mov     eax, [edi + 01]
        mov     [.eax], eax
        ;
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = (acount - 1)
        lea     eax, [5*ecx]                            ; eax = (acount - 1) * 5
        lea     edx, [edi + 7 + 1]
   .inline.rxgoca.ivar.push:
        push    dword [edx]
        add     edx, 5
        dec     ecx
        jnz    .inline.rxgoca.ivar.push
        ;
        mov     ecx, [.ezx]
        dec     ecx
        mov     [edi + 00], byte 0xE9
        mov     [edi + 01], eax                         ; eax = (acount - 1) * 5
        lea     edx, [edi + 05]
   .inline.rxgoca.ivar.pop:
        mov     [edx + 00], byte 0xBB
        pop     dword [edx + 01]
        add     edx, 5
        dec     ecx
        jnz    .inline.rxgoca.ivar.pop
        ;
        mov     ecx, [.ezx]
        lea     eax, [ecx - 1]                          ; eax = acount-1
        mov     [edx + 00], byte 0xB9
        mov     [edx + 01], eax
        mov     eax, [.eax]
        mov     [edx + 05], byte 0xB8
        mov     [edx + 06], eax
        mov     [edx + 10], word 0x008B
        mov     [edx + 12], dword 0x0F00F883
        mov     [edx + 16], byte 0x8C
        mov     [edx + 17], dword (2+6+5+4+5+8)
        mov     [edx + 21], dword 0x8D0FC839
        mov     [edx + 25], dword (5+4+5+8)
        mov     [edx + 29], dword 0x000000E8
        mov     [edx + 33], dword 0xEA835A00
        mov     [edx + 37], dword 0x80048D26
        mov     [edx + 41], dword 0x128BC229
        mov     [edx + 45], dword 0x0274D285
        mov     ax, word [.opcode]                      ; FF12 | FF22
        mov     [edx + 49], ax
        ;
        ; ----------------------------------------------
        ;*JMP   LA:             | E9 FFFFFFFF           ; (5B)

        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; ...                   |
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
                                                        ; =(acount-1)*5B
        ; LA:
        ; MOV   ECX, ACOUNT-1   | B9 CCCCCCCC           ; (5B) argument count - 1
        ; MOV   EAX, OFFSET     | B8 SSSSSSSS           ; (7B) integer variable
        ; MOV   EAX, DWORD [EAX]| 8B00

        ; CMP   EAX, 0          | 83F800                ; (3B)
        ; JL    LC:             | 0F8C FFFFFFFF         ; (6B) +2+6+5+4+5+8
        ; CMP   EAX, ECX        | 39C8                  ; (2B)
        ; JGE   LC:             | 0F8D FFFFFFFF         ; (6B) +5+4+5+8
                                                        ; =17B
        ; LB:
        ; CALL  P:              | E8 00000000           ; (5B) get EIP in EDX | call $+5 | pop edx
        ; P:
        ; POP   EDX             | 5A                    ; (1B) EDX = EIP
        ; SUB   EDX, 38         | 83EA26                ; (3B) 38 = 5+17+7+5+4 | EDX = label#n offset address
                                                        ; =4B

        ; LEA   EAX, [EAX*5]    | 8D0480                ; (3B) EAX = index * 5
        ; SUB   EDX, EAX        | 29C2                  ; (2B) EDX = label#index offset address
                                                        ; =5B

        ; MOV   EDX, DWORD [EDX]| 8B12                  ; (2B) EDX = label#index offset
        ; TEST  EDX, EDX        | 85D2                  ; (2B)
        ; JZ    @F              | 7402                  ; (2B)
        ;?CALL  DWORD [EDX]     | FF12                  ; (2B)
        ;?JMP   DWORD [EDX]     | FF22                  ; (2B)
        ; @@:                                           ; =8B

        ; LC:
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 5 + 7 + 17 + 5 + 4 + 5 + 8
        ; acount * 5 + 51
        ; ----------------------------------------------
        lea     eax, [5*ecx + 51]                       ; eax = acount * 5 + 51
        @@xshr  edi, eax
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
        ;
   .inline.rxgoca.irsp.rax:
        ; ----------------------------------------------
        ; ...                   | ...
        ;*MOV   [ESP], EAX      | 890424                ; integer RSP RAX (3B)

        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 3
        ; acount * 5 + 3
        ; ----------------------------------------------
        ; -> acount * 5 + 47
        ; ----------------------------------------------
        @@range (47-3), .error.memory
        ;
        @@xshl  edi, 3
        ;
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = (acount - 1)
        lea     eax, [5*ecx]                            ; eax = (acount - 1) * 5
        lea     edx, [edi + 3 + 1]
   .inline.rxgoca.irsp.rax.push:
        push    dword [edx]
        add     edx, 5
        dec     ecx
        jnz    .inline.rxgoca.irsp.rax.push
        ;
        mov     ecx, [.ezx]
        dec     ecx
        mov     [edi + 00], dword 0xE904C483
        mov     [edi + 04], eax                         ; eax = (acount - 1) * 5
        lea     edx, [edi + 08]
   .inline.rxgoca.irsp.rax.pop:
        mov     [edx + 00], byte 0xBB
        pop     dword [edx + 01]
        add     edx, 5
        dec     ecx
        jnz    .inline.rxgoca.irsp.rax.pop
        ;
        mov     ecx, [.ezx]
        lea     eax, [ecx - 1]                          ; eax = acount-1
        mov     [edx + 00], byte 0xB9
        mov     [edx + 01], eax
        mov     [edx + 05], byte 0x83
        mov     [edx + 06], dword 0x8C0F00F8
        mov     [edx + 10], dword (2+6+5+4+5+8)
        mov     [edx + 14], dword 0x8D0FC839
        mov     [edx + 18], dword (5+4+5+8)
        mov     [edx + 22], byte 0xE8
        mov     [edx + 23], dword 0x00000000
        mov     [edx + 27], byte 0x5A
        mov     [edx + 28], dword 0x8D1FEA83
        mov     [edx + 32], dword 0xC2298004
        mov     [edx + 36], word 0x128B
        mov     [edx + 38], dword 0x0274D285
        mov     ax, word [.opcode]                      ; FF12 | FF22
        mov     [edx + 42], ax
        ;
        ; ----------------------------------------------
        ; ...                   | ...                   ; EAX = index
        ;*ADD   ESP, 4          | 83C404                ; (3B)
        ; JMP   LA:             | E9 FFFFFFFF           ; (5B)

        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
        ; ...                   |
        ; MOV   EBX, OFFSET     | BB FFFFFFFF           ; (5B) label offset
                                                        ; =(acount-1)*5B
        ; LA:
        ; MOV   ECX, ACOUNT-1   | B9 CCCCCCCC           ; (5B) argument count - 1

        ; CMP   EAX, 0          | 83F800                ; (3B)
        ; JL    LC:             | 0F8C FFFFFFFF         ; (6B) +2+6+5+4+5+8
        ; CMP   EAX, ECX        | 39C8                  ; (2B)
        ; JGE   LC:             | 0F8D FFFFFFFF         ; (6B) +5+4+5+8
                                                        ; =17B
        ; LB:
        ; CALL  P:              | E8 00000000           ; (5B) get EIP in EDX | call $+5 | pop edx
        ; P:
        ; POP   EDX             | 5A                    ; (1B) EDX = EIP
        ; SUB   EDX, 31         | 83EA1F                ; (3B) 31 = 5+17+5+4 | EDX = label#n offset address
                                                        ; =4B

        ; LEA   EAX, [EAX*5]    | 8D0480                ; (3B) EAX = index * 5
        ; SUB   EDX, EAX        | 29C2                  ; (2B) EDX = label#index offset address
                                                        ; =5B

        ; MOV   EDX, DWORD [EDX]| 8B12                  ; (2B) EDX = label#index offset
        ; TEST  EDX, EDX        | 85D2                  ; (2B)
        ; JZ    @F              | 7402                  ; (2B)
        ;?CALL  DWORD [EDX]     | FF12                  ; (2B)
        ;?JMP   DWORD [EDX]     | FF22                  ; (2B)
        ; @@:                                           ; =8B

        ; LC:
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 3 + 5 + 5 + 17 + 5 + 4 + 5 + 8
        ; acount * 5 + 47
        ; ----------------------------------------------
        lea     eax, [5*ecx + 47]                       ; eax = acount * 5 + 47
        @@xshr  edi, eax
        add     [.RSP], 4
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
        ;
   .inline.rxgoca.dcon:
        ; ----------------------------------------------
        ; MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51

        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 12
        ; acount * 5 + 12
        ; ----------------------------------------------
        mov     [.shl], 12
        mov     ecx, [edi - 06]                         ; ecx = constant LO
        mov     edx, [edi - 11]                         ; edx = constant HI
        stdcall f2i, ecx, edx                           ; eax = int32 constant
        mov     [.int32], eax
        cmp     eax, 0
        jl     .inline.rxgoca.con.no.proc
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = acount-1
        cmp     eax, ecx
        jge    .inline.rxgoca.con.no.proc
        jmp    .inline.rxgoca.con.proc
        ;
   .inline.rxgoca.icon:
        ; ----------------------------------------------
        ; MOV   EAX, VALUE      | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH  EAX             | 50

        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; ...                   |
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)

        ; MOV   ECX, ACOUNT     | B9 CCCCCCCC           ; argument count (5B)
        ;>
        ; ----------------------------------------------
        ; (acount - 1) * 5 + 5 + 6
        ; acount * 5 + 6
        ; ----------------------------------------------
        mov     [.shl], 6
        mov     eax, [edi - 10]                         ; eax = int32 constant
        cmp     eax, 0
        jl     .inline.rxgoca.con.no.proc
        mov     ecx, [.ezx]                             ; ecx = argument count
        dec     ecx                                     ; ecx = acount-1
        cmp     eax, ecx
        jge    .inline.rxgoca.con.no.proc
;       jmp    .inline.rxgoca.con.proc
        ;
   .inline.rxgoca.con.proc:
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF           ; 7 BYTES
        ;?CALL  DWORD [EDX]     | FF12
        ;?JMP   DWORD [EDX]     | FF22
        ;>
        ; ----------------------------------------------
        lea     eax, [5*eax]                            ; eax = 5 * index
        mov     edx, [edi + eax + 1]                    ; edx = offset
        test    edx, edx
        jz     .inline.xgoca.con.no.proc
        mov     eax, [.shl]
        @@xshl  edi, eax
        mov     [edi + 0], byte 0xBA
        mov     [edi + 1], edx
        mov     ax, word [.opcode]                      ; FF12 | FF22
        mov     [edi + 5], ax
        @@xshr  edi, 7
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
        ;
   .inline.rxgoca.con.no.proc:
        mov     eax, [.shl]
        @@xshl  edi, eax
        mov     edx, [sic]
        or      [edx + T_sic_data.coops], SIC_OPT_FLAG_BYPASS
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.jump:
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        jmp    .inline.proc

   .inline.jump.2p:
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; label offset (5B)
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        mov     [edi - 10], byte 0xB9
        jmp    .inline.proc

   .inline.jump.v:
        mov     edx, [.ezx]
        dec     edx
        shl     edx, 3
        add     [.RSP], edx
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;?MOV     ECX, VALUE        | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        jmp    .inline.proc

   .inline.jump.v.2p:
        mov     edx, [.ezx]
        sub     edx, 2
        shl     edx, 3
        add     [.RSP], edx
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;?MOV     ECX, VALUE        | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; label offset (5B)
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        mov     [edi - 15], byte 0xB8
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
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 BBBBBBBB           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA BBBB..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 BBBB..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 BBBBBBBB           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 BBBBBBBB           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -5                   ; ecx = object type
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
        ;*MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 17
        mov     edx, [edi + 13]                         ; edx = label offset
        mov     ecx, [edi + 01]                         ; ecx = double constant HI
        mov     [esp - 4], ecx
        mov     ecx, [edi + 06]                         ; ecx = double constant LO
        mov     [esp - 8], ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 8]                   ; xmm0 = x
        xorpd   xmm5, xmm5                              ; xmm5 = 0
    $else
        fld     qword [esp - 8]
    $end
        ;
        xor     ecx, ecx
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
   .inline.jump.if_xz.dcon..z:                          ; ecx = 0
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .inline.jump.if_xz.icon.x
   .inline.jump.if_xz.dcon..az:                         ; ecx = +1
        inc     ecx
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .inline.jump.if_xz.icon.x
   .inline.jump.if_xz.dcon..bz:                         ; ecx = -1
        dec     ecx
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .inline.jump.if_xz.icon.x
        ;
   .inline.jump.if_xz.icon:
        add     [.RSP], 4
        mov     [.mode], 2
        ; ----------------------------------------------
        ;*MOV   EAX, VALUE      | B8 BBBBBBBB           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 11
        mov     edx, [edi + 07]                         ; edx = label offset
        mov     ecx, [edi + 01]                         ; ecx = integer constant
   .inline.jump.if_xz.icon.x:
        pcase   esi,\
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
        cmp     ecx, 0                                  ; compare x to 0
        je     .inline.jump.if_xz.icon.exec             ; exec if x = 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.nz:
        cmp     ecx, 0                                  ; compare x to 0
        jne    .inline.jump.if_xz.icon.exec             ; exec if x != 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.az:
        cmp     ecx, 0                                  ; compare x to 0
        jg     .inline.jump.if_xz.icon.exec             ; exec if x > 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.aez:
        cmp     ecx, 0                                  ; compare x to 0
        jge    .inline.jump.if_xz.icon.exec             ; exec if x >= 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.bz:
        cmp     ecx, 0                                  ; compare x to 0
        jl     .inline.jump.if_xz.icon.exec             ; exec if x < 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.bez:
        cmp     ecx, 0                                  ; compare x to 0
        jle    .inline.jump.if_xz.icon.exec             ; exec if x <= 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.no.exec:
        or      [.rcode], RCODE_FLAG_ZERO_SIZE
        jmp    .exit
   .inline.jump.if_xz.icon.exec:
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.if_xz.proc
        ;
   .inline.jump.if_xz.ivar:
        add     [.RSP], 4
        mov     [.mode], 1
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 BBBBBBBB           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; ----------------------------------------------
        mov     edx, [edi - 04]                         ; edx = label offset
        @@xshl  edi, 7
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 BBBBBBBB
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.if_xz.proc
   .inline.jump.if_xz.irsp.rax:
        add     [.RSP], 8
        mov     [.mode], 2
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        mov     edx, [edi - 04]                             ; edx = label offset
        @@xshl  edi, 8
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], word 0xC483
        mov     [edi + 07], byte 0x04
        @@xshr  edi, 8
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     EDX, OFFSET       | BA FFFFFFFF
        ; ADD     ESP, 4            | 83C404
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
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;?MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        stdcall code_object, [.cooff], -5                   ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 BBBBBBBB           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA BBBB..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 BBBB..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 BBBBBBBB           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 BBBBBBBB           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
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
        ;*MOV   EDX, QWORD.HI   | BA BBBB..HI           ; double constant (12B)
        ; MOV   ECX, QWORD.LO   | B9 BBBB..LO
        ; PUSH  EDX             | 52
        ; PUSH  ECX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 22
        mov     eax, [edi + 13]                         ; eax = label offset
        mov     edx, [edi + 18]                         ; edx = label offset
        mov     ecx, [edi + 01]                         ; ecx = double constant HI
        mov     [esp - 4], ecx
        mov     ecx, [edi + 06]                         ; ecx = double constant LO
        mov     [esp - 8], ecx
    $ifdef _SSEX
        movsd   xmm0, qword [esp - 8]                   ; xmm0 = x
        xorpd   xmm5, xmm5                              ; xmm5 = 0
    $else
        fld     qword [esp - 8]
    $end
        mov     [esp - 4], eax                          ; save eax
        ;
        xor     ecx, ecx
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
   .inline.jump.ie_xz.dcon..z:                          ; ecx = 0
    $ifndef _SSEX
        fstp    st0
    $end
        mov     eax, [esp - 4]                          ; restore eax
        jmp    .inline.jump.ie_xz.icon.x
   .inline.jump.ie_xz.dcon..az:                         ; ecx = +1
        inc     ecx
    $ifndef _SSEX
        fstp    st0
    $end
        mov     eax, [esp - 4]                          ; restore eax
        jmp    .inline.jump.ie_xz.icon.x
   .inline.jump.ie_xz.dcon..bz:                         ; ecx = -1
        dec     ecx
    $ifndef _SSEX
        fstp    st0
    $end
        mov     eax, [esp - 4]                          ; restore eax
        jmp    .inline.jump.ie_xz.icon.x
        ;
   .inline.jump.ie_xz.icon:
        add     [.RSP], 4
        mov     [.mode], 2
        ; ----------------------------------------------
        ;*MOV   EAX, VALUE      | B8 BBBBBBBB           ; integer constant (6B)
        ; PUSH  EAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; ----------------------------------------------
        @@xshl  edi, 16
        mov     eax, [edi + 07]                         ; eax = label offset
        mov     edx, [edi + 12]                         ; edx = label offset
        mov     ecx, [edi + 01]                         ; ecx = integer constant
   .inline.jump.ie_xz.icon.x:
        pcase   esi,\
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
        cmp     ecx, 0                                  ; compare x to 0
        je     .inline.jump.ie_xz.icon.if.exec          ; exec if x = 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.nz:
        cmp     ecx, 0                                  ; compare x to 0
        jne    .inline.jump.ie_xz.icon.if.exec          ; exec if x != 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.az:
        cmp     ecx, 0                                  ; compare x to 0
        jg     .inline.jump.ie_xz.icon.if.exec          ; exec if x > 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.aez:
        cmp     ecx, 0                                  ; compare x to 0
        jge    .inline.jump.ie_xz.icon.if.exec          ; exec if x >= 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.bz:
        cmp     ecx, 0                                  ; compare x to 0
        jl     .inline.jump.ie_xz.icon.if.exec          ; exec if x < 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.bez:
        cmp     ecx, 0                                  ; compare x to 0
        jle    .inline.jump.ie_xz.icon.if.exec          ; exec if x <= 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.else.exec:
        mov     edx, eax
   .inline.jump.ie_xz.icon.if.exec:
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; ----------------------------------------------
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.ie_xz.proc
        ;
   .inline.jump.ie_xz.ivar:
        add     [.RSP], 4
        mov     [.mode], 1
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 BBBBBBBB           ; integer variable (7B)
        ;*PUSH  DWORD [EAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ; MOV   EDX, OFFSET     | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; ----------------------------------------------
        mov     ecx, [edi - 09]                         ; ecx = label offset
        mov     edx, [edi - 04]                         ; edx = label offset
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], ecx
        @@xshr  edi, 10
        ; ----------------------------------------------
        ; MOV   EAX, OFFSET     | B8 BBBBBBBB
        ;*MOV   EDX, OFFSET     | BA FFFFFFFF
        ; MOV   ECX, OFFSET     | B9 FFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.ie_xz.proc
   .inline.jump.ie_xz.irsp.rax:
        add     [.RSP], 8
        mov     [.mode], 2
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 09]                             ; ecx = label offset
        mov     edx, [edi - 04]                             ; edx = label offset
        @@xshl  edi, 13
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], ecx
        mov     [edi + 10], word 0xC483
        mov     [edi + 12], byte 0x04
        @@xshr  edi, 13
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     EDX, OFFSET       | BA FFFFFFFF
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF
        ; ADD     ESP, 4            | 83C404
        ;>
        ; --------------------------------------------------
        jmp    .inline.jump.ie_xz.proc
   .inline.jump.ie_xz.proc:
        stdcall map_proc_x3, @x3_jump_procs_ie_xz, [.proc], [.mode]
        jmp    .inline.proc

   .inline.fstxw:
        ; --------------------------------------------------
        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.fstxw.ivar
        jmp    .error.argument
   .inline.fstxw.ivar:
        pcase   esi,\
                @@fstsw  , .inline.fstsw.ivar,\
                @@fnstsw , .inline.fnstsw.ivar,\
                @@fstef  , .inline.fstef.ivar,\
                @@fnstef , .inline.fnstef.ivar,\
                @@fstcw  , .inline.fstcw.ivar,\
                @@fnstcw , .inline.fnstcw.ivar
        jmp    .error.exit
   .inline.fstsw.ivar:
        mov     esi, @@_fstsw_io.eax
        mov     eax, @@_fstsw_io.eax.size
        jmp    .inline.fstxw.proc
   .inline.fnstsw.ivar:
        mov     esi, @@_fnstsw_io.eax
        mov     eax, @@_fnstsw_io.eax.size
        jmp    .inline.fstxw.proc
   .inline.fstef.ivar:
        mov     esi, @@_fstef_io.eax
        mov     eax, @@_fstef_io.eax.size
        jmp    .inline.fstxw.proc
   .inline.fnstef.ivar:
        mov     esi, @@_fnstef_io.eax
        mov     eax, @@_fnstef_io.eax.size
        jmp    .inline.fstxw.proc
   .inline.fstcw.ivar:
        mov     esi, @@_fstcw_io.eax
        mov     eax, @@_fstcw_io.eax.size
        jmp    .inline.fstxw.proc
   .inline.fnstcw.ivar:
        mov     esi, @@_fnstcw_io.eax
        mov     eax, @@_fnstcw_io.eax.size
        jmp    .inline.fstxw.proc
   .inline.fstxw.proc:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 2
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS
        ;*                          |
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.fldxw:
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA BBBB..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 BBBB..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.fldxw.dcon,\
                OBJ_INT_VAR    , .inline.fldxw.ivar,\
                OBJ_INT_CON    , .inline.fldxw.icon
        jmp    .error.argument
   .inline.fldxw.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA BBBB..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 BBBB..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EAX, INT32        | B8 SSSSSSSS
        ;>
        ; --------------------------------------------------
        pcase   esi,\
                @@fldcw   , .inline.fldcw.dcon,\
                @@fmaske  , .inline.fmaske.dcon,\
                @@fnmaske , .inline.fnmaske.dcon
        jmp    .error.exit
   .inline.fldcw.dcon:
        mov     esi, @@_fldcw_iv.eax
        mov     eax, @@_fldcw_iv.eax.size
        jmp    .inline.fldxw.d.proc
   .inline.fmaske.dcon:
        mov     esi, @@_fmaske_iv.eax
        mov     eax, @@_fmaske_iv.eax.size
        jmp    .inline.fldxw.d.proc
   .inline.fnmaske.dcon:
        mov     esi, @@_fnmaske_iv.eax
        mov     eax, @@_fnmaske_iv.eax.size
        jmp    .inline.fldxw.d.proc
   .inline.fldxw.ivar:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;*PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 2
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 SSSSSSSS
        ;*                          |
        ;>
        ; --------------------------------------------------
        pcase   esi,\
                @@fldcw   , .inline.fldcw.ivar,\
                @@fmaske  , .inline.fmaske.ivar,\
                @@fnmaske , .inline.fnmaske.ivar
        jmp    .error.exit
   .inline.fldcw.ivar:
        mov     esi, @@_fldcw_io.eax
        mov     eax, @@_fldcw_io.eax.size
        jmp    .inline.fldxw.i.proc
   .inline.fmaske.ivar:
        mov     esi, @@_fmaske_io.eax
        mov     eax, @@_fmaske_io.eax.size
        jmp    .inline.fldxw.i.proc
   .inline.fnmaske.ivar:
        mov     esi, @@_fnmaske_io.eax
        mov     eax, @@_fnmaske_io.eax.size
        jmp    .inline.fldxw.i.proc
   .inline.fldxw.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;*PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        @@xshl  edi, 1
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS
        ;*                          |
        ;>
        ; --------------------------------------------------
        pcase   esi,\
                @@fldcw   , .inline.fldcw.icon,\
                @@fmaske  , .inline.fmaske.icon,\
                @@fnmaske , .inline.fnmaske.icon
        jmp    .error.exit
   .inline.fldcw.icon:
        mov     esi, @@_fldcw_iv.eax
        mov     eax, @@_fldcw_iv.eax.size
        jmp    .inline.fldxw.i.proc
   .inline.fmaske.icon:
        mov     esi, @@_fmaske_iv.eax
        mov     eax, @@_fmaske_iv.eax.size
        jmp    .inline.fldxw.i.proc
   .inline.fnmaske.icon:
        mov     esi, @@_fnmaske_iv.eax
        mov     eax, @@_fnmaske_iv.eax.size
        jmp    .inline.fldxw.i.proc
   .inline.fldxw.d.proc:
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc
   .inline.fldxw.i.proc:
        add     [.RSP], 4
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.result.set:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        mov     esi, @@.result.set.double
        mov     eax, @@.result.set.double.size
        jmp    .inline.proc
   .inline.result.set.ivar:
   .inline.result.set.icon:
   .inline.result.set.irsp.rax:
        mov     esi, @@.result.set.int
        mov     eax, @@.result.set.int.size
        jmp    .inline.proc

   .inline.exit:
        push    eax ecx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     ecx eax
        test    edx, edx                                    ; edx = table item offset value
        jz     .error.exit
        lea     edx, [edx + citem32.offset]
        test    edx, edx                                    ; edx = offset
        jz     .error.exit
   .inline.exit.proc:
        @@range 5, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA SSSSSSSS
        ;>
        ; --------------------------------------------------
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.exit.if:
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        push    eax
        mov     ecx, [edi - 06]                             ; ecx = constant LO
        mov     edx, [edi - 11]                             ; edx = constant HI
        stdcall f2i, ecx, edx                               ; eax = int32 constant
        @@xshl  edi, 12
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], eax
        mov     [edi + 05], byte 0x50
        @@xshr  edi, 6
        pop     eax
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        add     [.RSP], 4
   .inline.exit.if.icon:
        add     [.RSP], 4
        jmp    .inline.exit.if.main
   .inline.exit.if.irsp.rax:
        add     [.RSP], 8
        jmp    .inline.exit.if.main
   .inline.exit.if.ivar:
        add     [.RSP], 4
;       jmp    .inline.exit.if.main
   .inline.exit.if.main:
        push    eax ecx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     ecx eax
        test    edx, edx                                    ; edx = table item offset value
        jz     .error.exit
        lea     edx, [edx + citem32.offset]
        test    edx, edx                                    ; edx = offset
        jz     .error.exit
   .inline.exit.if.proc:
        @@range 5, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA SSSSSSSS
        ;>
        ; --------------------------------------------------
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.return:
        push    ecx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     ecx
        test    edx, edx                                    ; edx = table item offset value
        jz     .error.exit
        lea     edx, [edx + citem32.offset]
        test    edx, edx                                    ; edx = offset
        jz     .error.exit
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        add     [.RSP], 8
        mov     esi, @@.return.double
        mov     eax, @@.return.double.size
        jmp    .inline.return.proc
   .inline.return.irsp.rax:
        add     [.RSP], 8
        mov     esi, @@.return.int
        mov     eax, @@.return.int.size
        jmp    .inline.return.proc
   .inline.return.ivar:
   .inline.return.icon:
        add     [.RSP], 4
        mov     esi, @@.return.int
        mov     eax, @@.return.int.size
;       jmp    .inline.return.proc
   .inline.return.proc:
        @@range 5, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA SSSSSSSS
        ;>
        ; --------------------------------------------------
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.return.if:
        push    ecx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     ecx
        test    edx, edx                                    ; edx = table item offset value
        jz     .error.exit
        lea     edx, [edx + citem32.offset]
        test    edx, edx                                    ; edx = offset
        jz     .error.exit
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     ECX, OFFSET       | B9 SSSSSSSS           ; double variable (10B)
        ;?PUSH    DWORD [ECX+4]     | FF71 04
        ;?PUSH    DWORD [ECX]       | FF31

        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, OFFSET       | B8 SSSSSSSS           ; integer variable (7B)
        ;?PUSH    DWORD [EAX]       | FF30

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ; ...                       | ...
        ;?MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
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
        add     [.RSP], 12
        pcase   esi,\
                @@.returnv.if.true  , .inline.return.double.if.true,\
                @@.returnv.if.false , .inline.return.double.if.false
        jmp    .error.exit
   .inline.return.double.if.true:
        mov     esi, @@.return.double.if.true
        mov     eax, @@.return.double.if.true.size
        jmp    .inline.return.if.proc
   .inline.return.double.if.false:
        mov     esi, @@.return.double.if.false
        mov     eax, @@.return.double.if.false.size
        jmp    .inline.return.if.proc
   .inline.return.if.ivar:
   .inline.return.if.icon:
        add     [.RSP], 8
        pcase   esi,\
                @@.returnv.if.true  , .inline.return.int.if.true,\
                @@.returnv.if.false , .inline.return.int.if.false
        jmp    .error.exit
   .inline.return.if.irsp.rax:
        add     [.RSP], 12
        pcase   esi,\
                @@.returnv.if.true  , .inline.return.int.if.true,\
                @@.returnv.if.false , .inline.return.int.if.false
        jmp    .error.exit
   .inline.return.int.if.true:
        mov     esi, @@.return.int.if.true
        mov     eax, @@.return.int.if.true.size
        jmp    .inline.return.if.proc
   .inline.return.int.if.false:
        mov     esi, @@.return.int.if.false
        mov     eax, @@.return.int.if.false.size
;       jmp    .inline.return.if.proc
   .inline.return.if.proc:
        @@range 5, .error.memory
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], edx
        @@xshr  edi, 5
        ; --------------------------------------------------
        ;*MOV     EDX, VALUE        | BA SSSSSSSS
        ;>
        ; --------------------------------------------------
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.retn:
        @@range 1, .error.memory
        mov     [edi + 00], byte 0xC3
        @@xshr  edi, 1
        ; --------------------------------------------------
        ;*RETN                      | C3
        ;>
        ; --------------------------------------------------
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.stack.4:
        add     [.SPD], 4
        jmp    .inline.proc

   .inline.stack.8:
        add     [.SPD], 8
        jmp    .inline.proc

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
        lea     ecx, [eax - 1]                              ; exclude RETN (0xC3) instruction
        @@bound ecx, .error.memory
        cld
        rep     movsb
        jmp    .done

   .inline.proc.exit:
        lea     ecx, [eax - 1]                              ; exclude RETN (0xC3) instruction
        @@bound ecx, .error.memory
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
        fstp    qword [esp - 8]
        movsd   xmm0, qword [esp - 8]
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end
   .call.xcon.result.I1:
        movsx   eax, al
        jmp    .inline.eax.icon
   .call.xcon.result.I2:
        movsx   eax, ax
        jmp    .inline.eax.icon
   .call.xcon.result.I4:
        jmp    .inline.eax.icon
   .call.xcon.result.I8:
        mov     [esp - 8], eax
        mov     [esp - 4], edx
    $ifdef _SSEX
        fild    qword [esp - 8]
        fstp    qword [esp - 8]
        movsd   xmm0, qword [esp - 8]
        jmp    .inline.sse.dcon.test
    $else
        fild    qword [esp - 8]
        jmp    .inline.st0.dcon.test
    $end
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
        mov     cx, [edx + fitem32.cosize]                  ; cx = function flags
        mov     eax, [.ezx]                                 ; ax = function actual argument count
        ;
        mov     [.RET], cx
        shr     [.RET], 8
        and     [.RET], 0x000F                              ; byte [.RET] = return type (00001111)
        ;
        cmp     ax, 0
        jl     .call.enter
        jz     .call.0p
        cmp     ax, 1
        je     .call.1p
        cmp     ax, 2
        je     .call.2p
        cmp     ax, 3
        je     .call.3p
        cmp     ax, 4
        je     .call.4p
        jmp    .call.main
        ;
   .call.0p:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.enter
        cmp     [.dynamic], 0
        jnz    .call.enter
   .call.0p.call:
        call    esi
        jmp    .call.xcon.result
   .call.0p.out:
        ;
   .call.1p:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.main
        cmp     [.dynamic], 0
        jnz    .call.main
   .call.1p.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.main                                   ; bypass void
        cmp     byte [.RET], 8
        je     .call.main                                   ; bypass I8
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.1p.dcon,\
                OBJ_INT_CON    , .call.1p.icon,\
                OBJ_STRING_CON , .call.1p.icon
        jmp    .call.main
        ;
   .call.1p.icon:
        ; --------------------------------------------------
        ;*MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
        ;
        call    esi                                         ; esp = argument #1 : integer
        ;
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 4
    @@:
        @@xshl  edi, 6
        add     [.RSP], 4
        jmp    .call.xcon.result
        ;
   .call.1p.dcon:
        ; --------------------------------------------------
        ;*MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
        ;
        call    esi                                         ; esp = argument #1 : double
        ;
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 8
    @@:
        @@xshl  edi, 12
        add     [.RSP], 8
        jmp    .call.xcon.result
        ;
   .call.2p:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.main
        cmp     [.dynamic], 0
        jnz    .call.main
   .call.2p.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.main                                   ; bypass void
        cmp     byte [.RET], 8
        je     .call.main                                   ; bypass I8
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.2p.dcon,\
                OBJ_INT_CON    , .call.2p.icon,\
                OBJ_STRING_CON , .call.2p.icon
        jmp    .call.main
   .call.2p.dcon:
        push    ecx edx
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.2p.dcon.dcon,\
                OBJ_INT_CON    , .call.2p.dcon.icon,\
                OBJ_STRING_CON , .call.2p.dcon.icon
        jmp    .call.main
   .call.2p.icon:
        push    ecx edx
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.2p.icon.dcon,\
                OBJ_INT_CON    , .call.2p.icon.icon,\
                OBJ_STRING_CON , .call.2p.icon.icon
        jmp    .call.main
        ;
   .call.2p.dcon.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 18]                             ; ecx = constant #2 LO
        mov     edx, [edi - 23]                             ; edx = constant #2 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
        ;
        call    esi                                         ; esp   = argument #1 : double
        ;                                                   ; esp+8 = argument #2 : double
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 8+8
    @@:
        @@xshl  edi, 12+12
        add     [.RSP], 8+8
        jmp    .call.xcon.result
        ;
   .call.2p.dcon.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 17]                             ; ecx = constant #2
        push    ecx
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
        ;
        call    esi                                         ; esp   = argument #1 : double
        ;                                                   ; esp+8 = argument #2 : integer
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 8+4
    @@:
        @@xshl  edi, 12+6
        add     [.RSP], 8+4
        jmp    .call.xcon.result
        ;
   .call.2p.icon.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 12]                             ; ecx = constant #2 LO
        mov     edx, [edi - 17]                             ; edx = constant #2 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
        ;
        call    esi                                         ; esp   = argument #1 : integer
        ;                                                   ; esp+4 = argument #2 : double
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 4+8
    @@:
        @@xshl  edi, 6+12
        add     [.RSP], 4+8
        jmp    .call.xcon.result
        ;
   .call.2p.icon.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 11]                             ; ecx = constant #2
        push    ecx
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
        ;
        call    esi                                         ; esp   = argument #1 : integer
        ;                                                   ; esp+4 = argument #2 : integer
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 4+4
    @@:
        @@xshl  edi, 6+6
        add     [.RSP], 4+4
        jmp    .call.xcon.result
        ;
   .call.3p:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.main
        cmp     [.dynamic], 0
        jnz    .call.main
   .call.3p.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.main                                   ; bypass void
        cmp     byte [.RET], 8
        je     .call.main                                   ; bypass I8
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.3p.dcon,\
                OBJ_INT_CON    , .call.3p.icon
        jmp    .call.main
        ;
   .call.3p.dcon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.3p.dcon.dcon
        jmp    .call.main
   .call.3p.dcon.dcon:
        push    ecx edx
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.3p.dcon.dcon.dcon
        jmp    .call.main
        ;
   .call.3p.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_INT_CON , .call.3p.icon.icon
        jmp    .call.main
   .call.3p.icon.icon:
        push    ecx edx
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_INT_CON , .call.3p.icon.icon.icon
        jmp    .call.main
        ;
   .call.3p.dcon.dcon.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 30]                             ; ecx = constant #3 LO
        mov     edx, [edi - 35]                             ; edx = constant #3 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 18]                             ; ecx = constant #2 LO
        mov     edx, [edi - 23]                             ; edx = constant #2 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
        ;
        call    esi                                         ; esp    = argument #1 : double
        ;                                                   ; esp+8  = argument #2 : double
        ;                                                   ; esp+16 = argument #3 : double
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 8+8+8
    @@:
        @@xshl  edi, 12+12+12
        add     [.RSP], 8+8+8
        jmp    .call.xcon.result
        ;
   .call.3p.icon.icon.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 17]                             ; ecx = constant #3
        push    ecx
        mov     ecx, [edi - 11]                             ; ecx = constant #2
        push    ecx
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
        ;
        call    esi                                         ; esp   = argument #1 : integer
        ;                                                   ; esp+4 = argument #2 : integer
        ;                                                   ; esp+8 = argument #3 : integer
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 4+4+4
    @@:
        @@xshl  edi, 6+6+6
        add     [.RSP], 4+4+4
        jmp    .call.xcon.result
        ;
   .call.4p:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.main
        cmp     [.dynamic], 0
        jnz    .call.main
   .call.4p.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.main                                   ; bypass void
        cmp     byte [.RET], 8
        je     .call.main                                   ; bypass I8
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ;?MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ;?PUSH    EDX               | 52
        ;?PUSH    ECX               | 51

        ;?MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ;?PUSH    EAX               | 50

        ;?MOV     EDX, VALUE        | BA SSSSSSSS           ; string constant (6B)
        ;?PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.4p.dcon,\
                OBJ_INT_CON    , .call.4p.icon
        jmp    .call.main
        ;
   .call.4p.dcon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.4p.dcon.dcon
        jmp    .call.main
   .call.4p.dcon.dcon:
        push    ecx edx
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.4p.dcon.dcon.dcon
        jmp    .call.main
   .call.4p.dcon.dcon.dcon:
        push    ecx edx
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.4p.dcon.dcon.dcon.dcon
        jmp    .call.main
        ;
   .call.4p.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        push    ecx edx
        stdcall code_object, [.cooff], -6                   ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_INT_CON , .call.4p.icon.icon
        jmp    .call.main
   .call.4p.icon.icon:
        push    ecx edx
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_INT_CON , .call.4p.icon.icon.icon
        jmp    .call.main
   .call.4p.icon.icon.icon:
        push    ecx edx
        stdcall code_object, [.cooff], -18                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     edx ecx
        case    [.OBJ],\
                OBJ_INT_CON , .call.4p.icon.icon.icon.icon
        jmp    .call.main
        ;
   .call.4p.dcon.dcon.dcon.dcon:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EDX, QWORD.HI     | BA SSSS..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 SSSS..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 42]                             ; ecx = constant #4 LO
        mov     edx, [edi - 47]                             ; edx = constant #4 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 30]                             ; ecx = constant #3 LO
        mov     edx, [edi - 35]                             ; edx = constant #3 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 18]                             ; ecx = constant #2 LO
        mov     edx, [edi - 23]                             ; edx = constant #2 HI
        push    edx
        push    ecx
        mov     ecx, [edi - 06]                             ; ecx = constant #1 LO
        mov     edx, [edi - 11]                             ; edx = constant #1 HI
        push    edx
        push    ecx
        ;
        call    esi                                         ; esp    = argument #1 : double
        ;                                                   ; esp+8  = argument #2 : double
        ;                                                   ; esp+16 = argument #3 : double
        ;                                                   ; esp+24 = argument #4 : double
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 8+8+8+8
    @@:
        @@xshl  edi, 12+12+12+12
        add     [.RSP], 8+8+8+8
        jmp    .call.xcon.result
        ;
   .call.4p.icon.icon.icon.icon:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     EAX, VALUE        | B8 SSSSSSSS           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        mov     ecx, [edi - 23]                             ; ecx = constant #4
        push    ecx
        mov     ecx, [edi - 17]                             ; ecx = constant #3
        push    ecx
        mov     ecx, [edi - 11]                             ; ecx = constant #2
        push    ecx
        mov     ecx, [edi - 05]                             ; ecx = constant #1
        push    ecx
        ;
        call    esi                                         ; esp    = argument #1 : integer
        ;                                                   ; esp+4  = argument #2 : integer
        ;                                                   ; esp+8  = argument #3 : integer
        ;                                                   ; esp+12 = argument #4 : integer
        cmp     [.stdcall], 0
        jnz     @F
        add     esp, 4+4+4+4
    @@:
        @@xshl  edi, 6+6+6+6
        add     [.RSP], 4+4+4+4
        jmp    .call.xcon.result
        ;
   .call.main:
        cmp     [.stdcall], 0
        jz     .call.cdecl
   .call.stdcall:
        mov     eax, [.ezx]                     ; eax = function argument count
        shl     eax, 3
        mov     [.ezx], 0
        mov     cx, [.RET]                      ; cl = return type (00001111)
        cmp     cl, 1001B ; 0x09
        je     .call.stdcall.D2
        cmp     cl, 1010B ; 0x0A
        je     .call.stdcall.D3
        cmp     cl, 1100B ; 0x0C
        je     .call.stdcall.D4
        jmp    .call.enter
   .call.stdcall.D2:
        add     [.RSP], eax
        jmp    .call.enter
   .call.stdcall.D3:
        add     [.RSP], eax
        jmp    .call.enter
   .call.stdcall.D4:
        add     [.RSP], eax
        jmp    .call.enter
   .call.cdecl:
        xor     eax, eax
        mov     ax, cx                          ; ax = function flags
        and     ax, 0x00FF                      ; al = 4-byte argument count
        shl     eax, 2                          ; eax = eax * 4
        add     [.SPD], eax
   .call.enter:
        ; ----------------------------------------------
        ; MOV   EAX, <OFFSET>  | B8 44332211
        ; CALL  EAX            | FFD0
        ; ----------------------------------------------
        @@bound 7, .error.memory
        mov     eax, [edx + fitem32.offset]     ; eax = function entry offset
        mov     [edi + 0], byte 0xB8            ; near, absolute indirect function call
        mov     [edi + 1], dword eax
        mov     [edi + 5], word 0xD0FF
        add     edi, 7

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
        mov     [edi + 00], dword 0xC0570F66
        add     edi, 4
        jmp    .call.result.out
    $else
        ; ----------------------------------------------
        ; FLDZ                       | D9EE
        ; ----------------------------------------------
        @@bound 2, .error.memory
        mov     [edi + 00], word 0xEED9
        add     edi, 2
        jmp    .call.result.out
    $end
   .call.result.I1:
        mov     [.int.bytes], 1
        ; ----------------------------------------------
        ; MOVSX EAX, AL              | 0FBEC0
        ; ----------------------------------------------
        @@bound 3, .error.memory
        mov     [edi + 00], word 0xBE0F
        mov     [edi + 02], byte 0xC0
        add     edi, 3
        jmp    .call.result.out
   .call.result.I2:
        mov     [.int.bytes], 2
        ; ----------------------------------------------
        ; MOVSX EAX, AX              | 0FBFC0
        ; ----------------------------------------------
        @@bound 3, .error.memory
        mov     [edi + 00], word 0xBF0F
        mov     [edi + 02], byte 0xC0
        add     edi, 3
        jmp    .call.result.out
   .call.result.I4:
        mov     [.int.bytes], 4
        jmp    .call.result.out
   .call.result.I8:
        mov     [.int.bytes], 8
        jmp    .call.result.out
   .call.result.D4:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM3, QWORD [ESP-8] | F2 0F 10 5C 24 F8
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM2, QWORD [ESP-8] | F2 0F 10 54 24 F8
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM1, QWORD [ESP-8] | F2 0F 10 4C 24 F8
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [ESP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 40, .error.memory
        mov     [edi + 00], dword 0xF8245CDD
        mov     [edi + 04], dword 0x5C100FF2
        mov     [edi + 08], word 0xF824
        mov     [edi + 10], dword 0xF8245CDD
        mov     [edi + 14], dword 0x54100FF2
        mov     [edi + 18], word 0xF824
        mov     [edi + 20], dword 0xF8245CDD
        mov     [edi + 24], dword 0x4C100FF2
        mov     [edi + 28], word 0xF824
        mov     [edi + 30], dword 0xF8245CDD
        mov     [edi + 34], dword 0x44100FF2
        mov     [edi + 38], word 0xF824
        add     edi, 40
        jmp    .call.result.out
    $end
        jmp    .call.result.out
   .call.result.D3:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM2, QWORD [ESP-8] | F2 0F 10 54 24 F8
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM1, QWORD [ESP-8] | F2 0F 10 4C 24 F8
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [ESP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 30, .error.memory
        mov     [edi + 00], dword 0xF8245CDD
        mov     [edi + 04], dword 0x54100FF2
        mov     [edi + 08], word 0xF824
        mov     [edi + 10], dword 0xF8245CDD
        mov     [edi + 14], dword 0x4C100FF2
        mov     [edi + 18], word 0xF824
        mov     [edi + 20], dword 0xF8245CDD
        mov     [edi + 24], dword 0x44100FF2
        mov     [edi + 28], word 0xF824
        add     edi, 30
        jmp    .call.result.out
    $end
        jmp    .call.result.out
   .call.result.D2:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM1, QWORD [ESP-8] | F2 0F 10 4C 24 F8
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [ESP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 20, .error.memory
        mov     [edi + 00], dword 0xF8245CDD
        mov     [edi + 04], dword 0x4C100FF2
        mov     [edi + 08], word 0xF824
        mov     [edi + 10], dword 0xF8245CDD
        mov     [edi + 14], dword 0x44100FF2
        mov     [edi + 18], word 0xF824
        add     edi, 20
        jmp    .call.result.out
    $end
        jmp    .call.result.out
   .call.result.double:
    $ifdef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [ESP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [ESP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 10, .error.memory
        mov     [edi + 00], dword 0xF8245CDD
        mov     [edi + 04], dword 0x44100FF2
        mov     [edi + 08], word 0xF824
        add     edi, 10
;       jmp    .call.result.out
    $end
   .call.result.out:

   .done:
        mov     ecx, [.ezx]                     ; ecx = function argument count
        cmp     [.fpatype], 'i'
        jne     @F
        lea     edx, [4 * ecx]
        add     [.SPD], edx
    @@:
        lea     edx, [8 * ecx - 8]              ; edx = (acount - 1) * 8
        sub     edx, [.SPD]
        dec     ebx
        jnz    .stack
        add     edx, 8

   .stack:
        inc     ebx                             ; restore rpn items counter
        cmp     [.frecount], 1
        jle     @F
        mov     ecx, [.frecount]
        lea     ecx, [ecx * 8 - 8]
        sub     edx, ecx
    @@:
        test    edx, edx
        jz     .stack.out
        cmp     edx, +127
        jg     .stack.dword
        cmp     edx, -128
        jl     .stack.dword
        ;
   .stack.byte:                                 ; -128 <= EDX <= 127
        add     [.RSP], edx
        ; --------------------------------------
        ; ADD ESP, FF | 83C4 FF
        ; --------------------------------------
        @@bound 3, .error.memory
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], dl
        add     edi, 3
        jmp    .stack.out
        ;
   .stack.dword:                                ; (EDX < -128) or (EDX > 127)
        add     [.RSP], edx
        ; --------------------------------------
        ; ADD ESP, FFFFFFFF | 81C4 FFFFFFFF
        ; --------------------------------------
        @@bound 6, .error.memory
        mov     [edi + 0], word 0xC481
        mov     [edi + 2], edx
        add     edi, 6
;       jmp    .stack.out
        ;
   .stack.out:

   .call..result:
   .call..result.?I:
        cmp     [.fretype], 'i'
        jne    .call..result.I.out
   .call..result.I:
        cmp     ebx, 1                          ; ebx = rpn items counter
        je     .call..result.I.ST0
   .call..result.I.ESP:                         ; function result is parameter of function
        mov     [.firesp], 1                    ; return integer result in ESP
        ; --------------------------------------
        ; ADD   ESP, 4      | 83C404
        ; MOV   [ESP], EAX  | 890424
        ; --------------------------------------
        add     [.RSP], 4
        @@bound 6, .error.memory
        mov     [edi + 0], dword 0x8904C483
        mov     [edi + 4], word 0x2404
        add     edi, 6
        jmp    .call..result.out
   .call..result.I.ST0:                         ; return integer result in ST0
    $ifdef _SSEX
        ; --------------------------------------
        ; CVTSI2SD XMM0, EAX | F20F2AC0
        ; --------------------------------------
        @@bound 4, .error.memory
        mov     [edi + 0], dword 0xC02A0FF2
        add     edi, 4
    $else
        ; --------------------------------------
        ; PUSH  EAX         | 50
        ; FILD  DWORD [ESP] | DB0424
        ; POP   EAX         | 58
        ; --------------------------------------
        @@bound 5, .error.memory
        mov     [edi + 0], dword 0x2404DB50
        mov     [edi + 4], byte 0x58
        add     edi, 5
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
                4, .call..result.I4,\
                2, .call..result.I2,\
                1, .call..result.I1,\
                8, .call..result.I8
        jmp    .call..result.out
   .call..result.I8:
        cmp     ebx, 1                          ; ebx = rpn items counter
        je     .call..result.IQ.ST0
   .call..result.IQ.ESP:                        ; function result is parameter of function
        mov     [.firesp], 1                    ; return integer result in ESP
        ; --------------------------------------
        ; ADD   ESP, 8      | 83C408
        ; CDQ               | 99                ; convert signed DWORD in EAX to a signed quad word in EDX:EAX
        ; PUSH  EDX         | 52
        ; PUSH  EAX         | 50
        ;>
        ; --------------------------------------
        @@bound 6, .error.memory
        mov     [edi + 0], dword 0x9908C483
        mov     [edi + 4], word 0x5052
        add     edi, 6
        jmp    .call..result.out
   .call..result.IQ.ST0:                        ; return integer result in ST0
    $ifdef _SSEX
        ; --------------------------------------
        ; PUSH  EDX                 | 52
        ; PUSH  EAX                 | 50
        ; FILD  QWORD [ESP]         | DF2C|24
        ; FSTP  QWORD [ESP-8]       | DD5C24|F8
        ; MOVSD XMM0, QWORD [ESP-8] | F20F10|4424F8
        ; POP   EAX                 | 58|
        ; POP   EDX                 | 5A
        ; --------------------------------------
        @@bound 17, .error.memory
        mov     [edi + 00], dword 0x2CDF5052
        mov     [edi + 04], dword 0x245CDD24
        mov     [edi + 08], dword 0x100FF2F8
        mov     [edi + 12], dword 0x58F82444
        mov     [edi + 16], byte 0x5A
        add     edi, 17
    $else
        ; --------------------------------------
        ; PUSH  EDX         | 52
        ; PUSH  EAX         | 50
        ; FILD  QWORD [ESP] | DF2C24
        ; POP   EAX         | 58
        ; POP   EDX         | 5A
        ; --------------------------------------
        @@bound 7, .error.memory
        mov     [edi + 0], dword 0x2CDF5052
        mov     [edi + 3], dword 0x5A58242C
        add     edi, 7
    $end
        jmp    .call..result.out
   .call..result.I4:
   .call..result.I2:
   .call..result.I1:
        cmp     ebx, 1                          ; ebx = rpn items counter
        je     .call..result.ID.ST0
   .call..result.ID.ESP:                        ; function result is parameter of function
        mov     [.firesp], 1                    ; return integer result in ESP
        ; --------------------------------------
        ; ADD   ESP, 4      | 83C404
        ; MOV   [ESP], EAX  | 890424
        ; --------------------------------------
        cmp     [.stdcall], 0
        jz      @F
        add     [.RSP], 4
    @@:
        @@bound 6, .error.memory
        mov     [edi + 0], dword 0x8904C483
        mov     [edi + 4], word 0x2404
        add     edi, 6
        jmp    .call..result.out
   .call..result.ID.ST0:                        ; return integer result in ST0
    $ifdef _SSEX
        ; --------------------------------------
        ; CVTSI2SD XMM0, EAX | F20F2AC0
        ; --------------------------------------
        @@bound 4, .error.memory
        mov     [edi + 0], dword 0xC02A0FF2
        add     edi, 4
    $else
        ; --------------------------------------
        ; PUSH  EAX         | 50
        ; FILD  DWORD [ESP] | DB0424
        ; POP   EAX         | 58
        ; --------------------------------------
        @@bound 5, .error.memory
        mov     [edi + 0], dword 0x2404DB50
        mov     [edi + 4], byte 0x58
        add     edi, 5
    $end
;       jmp    .call..result.out
   .call..result.IX.out:
   .call..result.out:

        jmp    .exit

   .error.exit:
        pop     esi eax
        jmp    .cb.error

   .error.memory:
        pop     esi eax
        jmp    .cb.error.memory

   .error.argument:
        pop     esi eax
        jmp    .cb.error.argument

   .error.evaluate:
        pop     esi eax
        jmp    .cb.error.evaluate

   .error.no.impl:
        pop     esi eax
        jmp    .cb.error.no.impl

   .error.pointer:
        pop     esi eax
        jmp    .cb.error.pointer

   .bypass.exit:
        mov     [.fbypass], 1

   .exit:
        pop     esi eax
}

; ------------------------------------------------------------------------------
