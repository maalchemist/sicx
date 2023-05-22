
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

@_CFG T_sic32_config  \
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

@_HEAP              dd 0                        ; process heap
@_FDATA             dd 0                        ; global function table
@_CDATA             dd 0                        ; global constant table
@_VDATA             dd 0                        ; global variable table
@_RDATA             dd 0                        ; global runtime table

@_EF.DHL            dd 0                        ; external function DLL handle list
@_EV.DHL            dd 0                        ; external variable DLL handle list

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

??.nop              dd 0

??.var.double       dd 0
??.var.complex      dd 0
??.var.integer      dd 0
??.var.string       dd 0

??.absolute         dd 0
??.assign           dd 0
??.reassign         dd 0

??.addr             dd 0
??.addr.1P          dd 0
??.addr.2P          dd 0

??.tcarg            dd 0

??.pdouble          dd 0
??.pcomplex         dd 0

??.copy             dd 0
??.copx             dd 0
??.xcopy            dd 0
??.swap             dd 0

??.ccopy            dd 0
??.cswap            dd 0

??.cadd             dd 0
??.csub             dd 0
??.csubr            dd 0
??.cmul             dd 0
??.cdiv             dd 0
??.cdivr            dd 0
??.cpow             dd 0
??.cpowr            dd 0
??.croot            dd 0
??.crootr           dd 0

??.co.chs           dd 0
??.co.sub           dd 0
??.co.rcopy         dd 0
??.co.rxcopy        dd 0

??.vint             dd 0
??..int             dd 0
??..intto           dd 0
??.vfrac            dd 0
??..frac            dd 0
??..fracto          dd 0
??.vround           dd 0
??..round           dd 0
??..roundto         dd 0

??.1D.1P.matrip     dd 0
??.1D.2P.matrip     dd 0
??.1D.matrip.rc     dd 0
??.2D.3P.matrip     dd 0
??.2D.4P.matrip     dd 0
??.2D.matrip.rc     dd 0

??.farr             dd 0
??.barr             dd 0
??.farw             dd 0
??.barw             dd 0
??.farv             dd 0
??.barv             dd 0

??.pfarr            dd 0
??.pbarr            dd 0
??.pfarw            dd 0
??.pbarw            dd 0

??.bt               dd 0
??.btc              dd 0
??.btr              dd 0
??.bts              dd 0

??.bnot             dd 0
??.bor              dd 0
??.bnor             dd 0
??.born             dd 0
??.bnorn            dd 0
??.borc             dd 0
??.bnorc            dd 0
??.bcor             dd 0
??.bcorn            dd 0
??.bxor             dd 0
??.bxnor            dd 0
??.band             dd 0
??.bnand            dd 0
??.bandn            dd 0
??.bnandn           dd 0
??.breset           dd 0
??.bset             dd 0
??.shr              dd 0
??.shl              dd 0
??.sar              dd 0
??.sal              dd 0
??.ror              dd 0
??.rol              dd 0

??.ot               dd 0
??.not              dd 0
??.or               dd 0
??.nor              dd 0
??.xor              dd 0
??.xnor             dd 0
??.and              dd 0
??.nand             dd 0

??.if.e             dd 0

??.fldz             dd 0
??.fld1             dd 0
??.setz             dd 0

??.sign             dd 0
; ??.isign            dd 0
??.nzero            dd 0

??.uplus            dd 0
??.chs              dd 0
??.abs              dd 0
??.nabs             dd 0
??.inv              dd 0
??.inc              dd 0
??.inc.pre          dd 0
??.inc.post         dd 0
??.dec              dd 0
??.dec.pre          dd 0
??.dec.post         dd 0
??.add              dd 0
??.add.pos          dd 0
??.sub              dd 0
??.sub.neg          dd 0
??.subr             dd 0
??.mul              dd 0
??.div              dd 0
??.divr             dd 0
??.quo              dd 0
??.quor             dd 0
??.mod              dd 0
??.modr             dd 0
??.min              dd 0
??.max              dd 0
??.mean             dd 0
??.adev             dd 0
??.pow              dd 0
??.pow.??           dd 0
??.powr             dd 0
??.powr.??          dd 0
??.pow2             dd 0
??.root             dd 0
??.rootr            dd 0
??.r2d              dd 0

??.hypot3           dd 0

??.int              dd 0
??.intto            dd 0
??.frac             dd 0
??.fracto           dd 0
??.round            dd 0
??.roundto          dd 0

??.varg.z           dd 0
??.varg.nz          dd 0
??.varg.az          dd 0
??.varg.aez         dd 0
??.varg.bz          dd 0
??.varg.bez         dd 0
??.varg.e           dd 0
??.varg.ne          dd 0
??.varg.a           dd 0
??.varg.ae          dd 0
??.varg.b           dd 0
??.varg.be          dd 0

??.exit             dd 0
??.exit.if.true     dd 0
??.exit.if.false    dd 0
??.return           dd 0
??.returnv          dd 0
??.returnv.if.true  dd 0
??.returnv.if.false dd 0

; ------------------------------------------------------------------------------

data64  ??d?0,\
        ??d?1,\
        ??d?2,\
        ??d?3

data32  ??i?0,\
        ??i?1,\
        ??i?2,\
        ??i?3

; ------------------------------------------------------------------------------

$ifdef _SSEX
S_SIC_DLL  db 'SICs32.DLL', 0
$else
S_SIC_DLL  db 'SICx32.DLL', 0
$end

S_UDF_FILE db 'SICx32.UDF', 0
S_UDC_FILE db 'SICx32.UDC', 0
S_UDV_FILE db 'SICx32.UDV', 0

; ------------------------------------------------------------------------------
