
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; variables

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_V:

; ------------------------------------------------------------------------------

include '..\xCommon\SICCO.ASM'

; ------------------------------------------------------------------------------

@_CFG T_sic64_config  \
      0              ,\
      mem_block_size ,\
      0              ,\
      section_code   ,\
      section_data   ,\
      section_idata  ,\
      section_edata  ,\
      section_rsrc   ,\
      section_reloc  ,\
      fcode_size     ,\
      fdata_size     ,\
      fdata_count    ,\
      cdata_size     ,\
      cdata_count    ,\
      vdata_size     ,\
      vdata_count    ,\
      rdata_size     ,\
      rdata_count    ,\
      stack_size     ,\
      stack_count    ,\
      rpn_size       ,\
      rpn_count      ,\
      code_size      ,\
      fitem.nsize    ,\
      citem.nsize    ,\
      vitem.nsize    ,\
      255

; ------------------------------------------------------------------------------

@_HEAP              dq 0                        ; process heap
@_FDATA             dq 0                        ; global function table
@_CDATA             dq 0                        ; global constant table
@_VDATA             dq 0                        ; global variable table
@_RDATA             dq 0                        ; global runtime table

@_EF.DHL            dq 0                        ; external function DLL handle list
@_EV.DHL            dq 0                        ; external variable DLL handle list

@_FDATA.REFS        dd 0                        ; global function table reference count
@_CDATA.REFS        dd 0                        ; global constant table reference count
@_VDATA.REFS        dd 0                        ; global variable table reference count
@_RDATA.REFS        dd 0                        ; global runtime table reference count

@_EF.REFS           dd 0                        ; external function DLL reference count
@_EF.DC             dd 0                        ; external function DLL count
@_EF.IC             dd 0                        ; external function item count

@_EV.REFS           dd 0                        ; external variable DLL reference count
@_EV.DC             dd 0                        ; external variable DLL count
@_EV.IC             dd 0                        ; external variable item count

; ------------------------------------------------------------------------------

??.nop              dq 0

??.var.double       dq 0
??.var.complex      dq 0
??.var.integer      dq 0
??.var.string       dq 0

??.absolute         dq 0
??.assign           dq 0
??.reassign         dq 0

??.addr             dq 0
??.addr.1P          dq 0
??.addr.2P          dq 0

??.tcarg            dq 0

??.pdouble          dq 0
??.pcomplex         dq 0

??.copy             dq 0
??.copx             dq 0
??.xcopy            dq 0
??.swap             dq 0

??.ccopy            dq 0
??.cswap            dq 0

??.cadd             dq 0
??.csub             dq 0
??.csubr            dq 0
??.cmul             dq 0
??.cdiv             dq 0
??.cdivr            dq 0
??.cpow             dq 0
??.cpowr            dq 0
??.croot            dq 0
??.crootr           dq 0

??.co.chs           dq 0
??.co.sub           dq 0
??.co.rcopy         dq 0
??.co.rxcopy        dq 0

??.vint             dq 0
??..int             dq 0
??..intto           dq 0
??.vfrac            dq 0
??..frac            dq 0
??..fracto          dq 0
??.vround           dq 0
??..round           dq 0
??..roundto         dq 0

??.1D.1P.matrip     dq 0
??.1D.2P.matrip     dq 0
??.1D.matrip.rc     dq 0
??.2D.3P.matrip     dq 0
??.2D.4P.matrip     dq 0
??.2D.matrip.rc     dq 0

??.farr             dq 0
??.barr             dq 0
??.farw             dq 0
??.barw             dq 0
??.farv             dq 0
??.barv             dq 0

??.pfarr            dq 0
??.pbarr            dq 0
??.pfarw            dq 0
??.pbarw            dq 0

??.bt               dq 0
??.btc              dq 0
??.btr              dq 0
??.bts              dq 0

??.bnot             dq 0
??.bor              dq 0
??.bnor             dq 0
??.born             dq 0
??.bnorn            dq 0
??.borc             dq 0
??.bnorc            dq 0
??.bcor             dq 0
??.bcorn            dq 0
??.bxor             dq 0
??.bxnor            dq 0
??.band             dq 0
??.bnand            dq 0
??.bandn            dq 0
??.bnandn           dq 0
??.breset           dq 0
??.bset             dq 0
??.shr              dq 0
??.shl              dq 0
??.sar              dq 0
??.sal              dq 0
??.ror              dq 0
??.rol              dq 0

??.ot               dq 0
??.not              dq 0
??.or               dq 0
??.nor              dq 0
??.xor              dq 0
??.xnor             dq 0
??.and              dq 0
??.nand             dq 0

??.if.e             dq 0

??.fldz             dq 0
??.fld1             dq 0
??.setz             dq 0

??.sign             dq 0
; ??.isign            dq 0
??.nzero            dq 0

??.uplus            dq 0
??.chs              dq 0
??.abs              dq 0
??.nabs             dq 0
??.inv              dq 0
??.inc              dq 0
??.inc.pre          dq 0
??.inc.post         dq 0
??.dec              dq 0
??.dec.pre          dq 0
??.dec.post         dq 0
??.add              dq 0
??.add.pos          dq 0
??.sub              dq 0
??.sub.neg          dq 0
??.subr             dq 0
??.mul              dq 0
??.div              dq 0
??.divr             dq 0
??.quo              dq 0
??.quor             dq 0
??.mod              dq 0
??.modr             dq 0
??.min              dq 0
??.max              dq 0
??.mean             dq 0
??.adev             dq 0
??.pow              dq 0
??.pow.??           dq 0
??.powr             dq 0
??.powr.??          dq 0
??.pow2             dq 0
??.root             dq 0
??.rootr            dq 0
??.r2d              dq 0

??.hypot3           dq 0

??.int              dq 0
??.intto            dq 0
??.frac             dq 0
??.fracto           dq 0
??.round            dq 0
??.roundto          dq 0

??.varg.z           dq 0
??.varg.nz          dq 0
??.varg.az          dq 0
??.varg.aez         dq 0
??.varg.bz          dq 0
??.varg.bez         dq 0
??.varg.e           dq 0
??.varg.ne          dq 0
??.varg.a           dq 0
??.varg.ae          dq 0
??.varg.b           dq 0
??.varg.be          dq 0

??.exit             dq 0
??.exit.if.true     dq 0
??.exit.if.false    dq 0
??.return           dq 0
??.returnv          dq 0
??.returnv.if.true  dq 0
??.returnv.if.false dq 0

; ------------------------------------------------------------------------------

data64  ??d?0,\
        ??d?1,\
        ??d?2,\
        ??d?3

data64  ??i?0,\
        ??i?1,\
        ??i?2,\
        ??i?3

; ------------------------------------------------------------------------------

$ifdef _SSEX
S_SIC_DLL  db 'SICs64.DLL', 0
$else
S_SIC_DLL  db 'SICx64.DLL', 0
$end

S_UDF_FILE db 'SICx64.UDF', 0
S_UDC_FILE db 'SICx64.UDC', 0
S_UDV_FILE db 'SICx64.UDV', 0

; ------------------------------------------------------------------------------
