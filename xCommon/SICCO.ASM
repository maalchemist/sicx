
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; common constants

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_CO:

; ------------------------------------------------------------------------------

$align 16

; section_code
if defined SIC_EOF_section_code
  section_code  = SIC_EOF_section_code - SIC_BOF_section_code
else
  section_code  = 0
end if

; section_data
if defined SIC_EOF_section_data
  section_data  = SIC_EOF_section_data - SIC_BOF_section_data
else
  section_data  = 0
end if

; section_idata
if defined SIC_EOF_section_idata
  section_idata = SIC_EOF_section_idata - SIC_BOF_section_idata
else
  section_idata = 0
end if

; section_edata
if defined SIC_EOF_section_edata
  section_edata = SIC_EOF_section_edata - SIC_BOF_section_edata
else
  section_edata = 0
end if

; section_rsrc
if defined SIC_EOF_section_rsrc
  section_rsrc  = SIC_EOF_section_rsrc - SIC_BOF_section_rsrc
else
  section_rsrc  = 0
end if

; section_reloc
if defined SIC_EOF_section_reloc
  section_reloc = SIC_EOF_section_reloc - SIC_BOF_section_reloc
else
  section_reloc = 0
end if

; fcode_size
if defined SIC_EOF_F_BASE
  fcode_size    = SIC_EOF_F_BASE - SIC_F_BASE
else
  fcode_size    = 0
end if

; ------------------------------------------------------------------------------

; !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~

; !"#$%&'()*+,-./0
; 123456789:;<=>?@
; ABCDEFGHIJKLMNOP
; QRSTUVWXYZ[\]^_`
; abcdefghijklmnop
; qrstuvwxyz{|}~

; escape chars conversion table
;  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0
;  1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @
;  A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P
;  Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `
;  a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p
;  q   r   s   t   u   v   w   x   y   z   {   |   }   ~
@_E2X db \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1        ; \

; escape chars conversion table
;  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
;  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
;  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
;  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
;  p   q   r   s   t   u   v
@_E2B? db \
   0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 92, -1, -1, -1, \
  -1,  7,  8, -1, -1, 27, 12, -1, -1, -1, -1, -1, -1, -1, 10, -1, \
  -1, -1, 13, -1,  9, -1, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1; \

; escape chars conversion table
;  \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k
;  l   m   n   o   p   q   r   s   t   u   v
@_E2B db \
  92, -1, -1, -1, -1,  7,  8, -1, -1, 27, 12, -1, -1, -1, -1, -1, \
  -1, -1, 10, -1, -1, -1, 13, -1,  9, -1, 11, -1, -1, -1, -1, -1; \

; oct digit chars conversion table
;  0   1   2   3   4   5   6   7
@_O2B db \
   0,  1,  2,  3,  4,  5,  6,  7, -1, -1, -1, -1, -1, -1, -1, -1; \

; hex digit chars conversion table
;  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
;  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
;  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
;  `   a   b   c   d   e   f
@_H2B db \
   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1, \
  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1; \

; ------------------------------------------------------------------------------

macro proc_map map, n, [proc]
{
  common
    local @count, @index, @order
    @count = 0
    @index = 0
    @order = 0

    map:
  forward
    if proc eq
      dw 0
      dw 0
    else
      dw proc - SIC_F_BASE
     if defined proc#.size
      dw proc#.size
     else
      dw 0
      oops
     end if

     if @order = 0
      proc#.map.index = @index
     end if
    end if

    @count = @count + 1
    @index = @count / n
    @order = @count mod n
  common
    map#.data.size = n
}

proc_map @x2_co_procs_1p, 2,\
         @@co.chs   , @@_co.int.chs   ,\
         @@co.abs   , @@_co.int.abs   ,\
         @@co.nabs  , @@_co.int.nabs  ,\
         @@co.rcopy , @@_co.int.rcopy
;        0            1

proc_map @x4_co_procs_2p, 4,\
         @@co.add      , @@_co.int.add      , @@_co.int.add.1      , @@_co.int.add.m1      ,\
         @@co.sub      , @@_co.int.sub      , @@_co.int.sub.1      , @@_co.int.sub.m1      ,\
         @@co.subr     , @@_co.int.subr     , @@_co.int.subr.1     , @@_co.int.subr.m1     ,\
         @@co.mul      , @@_co.int.mul      , @@_co.int.mul.1      , @@_co.int.mul.m1      ,\
         @@co.div      , @@_co.int.div      , @@_co.int.div.1      , @@_co.int.div.m1      ,\
         @@co.divr     , @@_co.int.divr     , @@_co.int.divr.1     , @@_co.int.divr.m1     ,\
         @@co.quo      , @@_co.int.quo      , @@_co.int.quo.1      , @@_co.int.quo.m1      ,\
         @@co.quor     , @@_co.int.quor     , @@_co.int.quor.1     , @@_co.int.quor.m1     ,\
         @@co.mod      , @@_co.int.mod      , @@_co.int.mod.1      , @@_co.int.mod.m1      ,\
         @@co.modr     , @@_co.int.modr     , @@_co.int.modr.1     , @@_co.int.modr.m1     ,\
         @@co.str.add  , @@_co.int.str.add  , @@_co.int.str.add.1  , @@_co.int.str.add.m1  ,\
         @@co.str.sub  , @@_co.int.str.sub  , @@_co.int.str.sub.1  , @@_co.int.str.sub.m1  ,\
         @@co.str.subr , @@_co.int.str.subr , @@_co.int.str.subr.1 , @@_co.int.str.subr.m1
;        0               1                    2                      3

; integer result
; integer parameters
proc_map @x4_co_iprocs_i2p, 4,\
         @@co.bor        , @@_co.bor.0    , @@_co.bor.1    , @@_co.bor.m1    ,\
         @@co.bnor       , @@_co.bnor.0   , @@_co.bnor.1   , @@_co.bnor.m1   ,\
         @@co.born       , @@_co.born.0   , @@_co.born.1   , @@_co.born.m1   ,\
         @@co.bnorn      , @@_co.bnorn.0  , @@_co.bnorn.1  , @@_co.bnorn.m1  ,\
         @@co.borc       , @@_co.borc.0   , @@_co.borc.1   , @@_co.borc.m1   ,\
         @@co.bnorc      , @@_co.bnorc.0  , @@_co.bnorc.1  , @@_co.bnorc.m1  ,\
         @@co.bcor       , @@_co.bcor.0   , @@_co.bcor.1   , @@_co.bcor.m1   ,\
         @@co.bcorn      , @@_co.bcorn.0  , @@_co.bcorn.1  , @@_co.bcorn.m1  ,\
         @@co.bxor       , @@_co.bxor.0   , @@_co.bxor.1   , @@_co.bxor.m1   ,\
         @@co.bxnor      , @@_co.bxnor.0  , @@_co.bxnor.1  , @@_co.bxnor.m1  ,\
         @@co.band       , @@_co.band.0   , @@_co.band.1   , @@_co.band.m1   ,\
         @@co.bnand      , @@_co.bnand.0  , @@_co.bnand.1  , @@_co.bnand.m1  ,\
         @@co.bandn      , @@_co.bandn.0  , @@_co.bandn.1  , @@_co.bandn.m1  ,\
         @@co.bandn.bmi  , @@_co.bandn.0  , @@_co.bandn.1  , @@_co.bandn.m1  ,\
         @@co.bnandn     , @@_co.bnandn.0 , @@_co.bnandn.1 , @@_co.bnandn.m1 ,\
         @@co.bnandn.bmi , @@_co.bnandn.0 , @@_co.bnandn.1 , @@_co.bnandn.m1 ,\
         @@co.breset     , @@_co.breset.0 , @@_co.breset.1 , @@_co.breset.m1 ,\
         @@co.bset       , @@_co.bset.0   , @@_co.bset.1   , @@_co.bset.m1   ,\
         @@co.shr        , @@_co.shr.0    , @@_co.shr.1    , @@_co.shr.m1    ,\
         @@co.shl        , @@_co.shl.0    , @@_co.shl.1    , @@_co.shl.m1    ,\
         @@co.sar        , @@_co.sar.0    , @@_co.sar.1    , @@_co.sar.m1    ,\
         @@co.sal        , @@_co.sal.0    , @@_co.sal.1    , @@_co.sal.m1    ,\
         @@co.ror        , @@_co.ror.0    , @@_co.ror.1    , @@_co.ror.m1    ,\
         @@co.rol        , @@_co.rol.0    , @@_co.rol.1    , @@_co.rol.m1
;        0                 1                2                3

; integer result
; integer parameter
proc_map @x2_iprocs_i1p, 2,\
         @@bsf       , @@bsf.enter       ,\
         @@bsr       , @@bsr.enter       ,\
         @@hammw     , @@hammw.enter     ,\
         @@hammw.cpu , @@hammw.cpu.enter ,\
         @@bnot      , @@bnot.enter      ,\
         @@bswap     , @@bswap.enter     ,\
         @@b4swap    , @@b4swap.enter    ,\
         @@b2swap    , @@b2swap.enter    ,\
         @@bitswap   , @@bitswap.enter   ,\
         @@bit32swap , @@bit32swap.enter ,\
         @@bit16swap , @@bit16swap.enter ,\
         @@bit8swap  , @@bit8swap.enter
;        0             1

; integer result
; integer parameters
proc_map @x2_iprocs_i2p, 2,\
         @@bt         , @@bt.enter         ,\
         @@hammd      , @@hammd.enter      ,\
         @@hammd.cpu  , @@hammd.cpu.enter  ,\
         @@bor        , @@bor.enter        ,\
         @@bnor       , @@bnor.enter       ,\
         @@born       , @@born.enter       ,\
         @@bnorn      , @@bnorn.enter      ,\
         @@borc       , @@borc.enter       ,\
         @@bnorc      , @@bnorc.enter      ,\
         @@bcor       , @@bcor.enter       ,\
         @@bcorn      , @@bcorn.enter      ,\
         @@bxor       , @@bxor.enter       ,\
         @@bxnor      , @@bxnor.enter      ,\
         @@band       , @@band.enter       ,\
         @@bnand      , @@bnand.enter      ,\
         @@bandn      , @@bandn.enter      ,\
         @@bandn.bmi  , @@bandn.bmi.enter  ,\
         @@bnandn     , @@bnandn.enter     ,\
         @@bnandn.bmi , @@bnandn.bmi.enter ,\
         @@breset     , @@breset.enter     ,\
         @@bset       , @@bset.enter       ,\
         @@shr        , @@shr.enter        ,\
         @@shl        , @@shl.enter        ,\
         @@sar        , @@sar.enter        ,\
         @@sal        , @@sal.enter        ,\
         @@ror        , @@ror.enter        ,\
         @@rol        , @@rol.enter        ,\
         @@igcd       , @@igcd.enter       ,\
         @@ilcm       , @@ilcm.enter
;        0              1

; integer result
; integer parameters
proc_map @x4_iprocs_i2p, 4,\
         @@btc , @@btc.enter , @@btc_ivar , @@btc_ivar.enter ,\
         @@btr , @@btr.enter , @@btr_ivar , @@btr_ivar.enter ,\
         @@bts , @@bts.enter , @@bts_ivar , @@bts_ivar.enter
;        0       1             2            3

proc_map @x2_procs_3p, 2,\
         @@fmadd132      , @@fmadd132.enter      ,\
         @@fmadd132.fma  , @@fmadd132.fma.enter  ,\
         @@fmadd213      , @@fmadd213.enter      ,\
         @@fmadd213.fma  , @@fmadd213.fma.enter  ,\
         @@fmadd231      , @@fmadd231.enter      ,\
         @@fmadd231.fma  , @@fmadd231.fma.enter  ,\
         @@fnmadd132     , @@fnmadd132.enter     ,\
         @@fnmadd132.fma , @@fnmadd132.fma.enter ,\
         @@fnmadd213     , @@fnmadd213.enter     ,\
         @@fnmadd213.fma , @@fnmadd213.fma.enter ,\
         @@fnmadd231     , @@fnmadd231.enter     ,\
         @@fnmadd231.fma , @@fnmadd231.fma.enter ,\
         @@fmsub132      , @@fmsub132.enter      ,\
         @@fmsub132.fma  , @@fmsub132.fma.enter  ,\
         @@fmsub213      , @@fmsub213.enter      ,\
         @@fmsub213.fma  , @@fmsub213.fma.enter  ,\
         @@fmsub231      , @@fmsub231.enter      ,\
         @@fmsub231.fma  , @@fmsub231.fma.enter  ,\
         @@fnmsub132     , @@fnmsub132.enter     ,\
         @@fnmsub132.fma , @@fnmsub132.fma.enter ,\
         @@fnmsub213     , @@fnmsub213.enter     ,\
         @@fnmsub213.fma , @@fnmsub213.fma.enter ,\
         @@fnmsub231     , @@fnmsub231.enter     ,\
         @@fnmsub231.fma , @@fnmsub231.fma.enter
;        0                 1

proc_map @x3_procs_1p, 3,\
         @@setz     , @@_setz_int      , @@setz.enter     ,\
         @@set1     , @@_set1_int      , @@set1.enter     ,\
         @@int      , @@_int_int       , @@int.enter      ,\
         @@frac     , @@_frac_int      , @@frac.enter     ,\
         @@round    , @@_round_int     , @@round.enter    ,\
         @@factln   , @@_factln_int    , @@factln.enter   ,\
         @@fact     , @@_fact_int      , @@fact.enter     ,\
         @@fact2    , @@_fact2_int     , @@fact2.enter    ,\
         @@bit      , @@_bit_int       , @@bit.enter      ,\
         @@nibble   , @@_nibble_int    , @@nibble.enter   ,\
         @@byte     , @@_byte_int      , @@byte.enter     ,\
         @@word     , @@_word_int      , @@word.enter     ,\
         @@dword    , @@_dword_int     , @@dword.enter    ,\
         @@qword    , @@_qword_int     , @@qword.enter    ,\
         @@nword    , @@_nword_int     , @@nword.enter    ,\
         @@tword    , @@_tword_int     , @@tword.enter    ,\
         @@xword    , @@_xword_int     , @@xword.enter    ,\
         @@oword    , @@_oword_int     , @@oword.enter    ,\
         @@yword    , @@_yword_int     , @@yword.enter    ,\
         @@zword    , @@_zword_int     , @@zword.enter    ,\
         @@kibi     , @@_kibi_int      , @@kibi.enter     ,\
         @@mebi     , @@_mebi_int      , @@mebi.enter     ,\
         @@gibi     , @@_gibi_int      , @@gibi.enter     ,\
         @@tebi     , @@_tebi_int      , @@tebi.enter     ,\
         @@pebi     , @@_pebi_int      , @@pebi.enter     ,\
         @@exbi     , @@_exbi_int      , @@exbi.enter     ,\
         @@zebi     , @@_zebi_int      , @@zebi.enter     ,\
         @@yobi     , @@_yobi_int      , @@yobi.enter     ,\
         @@kibo     , @@_kibo_int      , @@kibo.enter     ,\
         @@mebo     , @@_mebo_int      , @@mebo.enter     ,\
         @@gibo     , @@_gibo_int      , @@gibo.enter     ,\
         @@tebo     , @@_tebo_int      , @@tebo.enter     ,\
         @@pebo     , @@_pebo_int      , @@pebo.enter     ,\
         @@exbo     , @@_exbo_int      , @@exbo.enter     ,\
         @@zebo     , @@_zebo_int      , @@zebo.enter     ,\
         @@yobo     , @@_yobo_int      , @@yobo.enter     ,\
         @@deca     , @@_deca_int      , @@deca.enter     ,\
         @@hecto    , @@_hecto_int     , @@hecto.enter    ,\
         @@kilo     , @@_kilo_int      , @@kilo.enter     ,\
         @@mega     , @@_mega_int      , @@mega.enter     ,\
         @@giga     , @@_giga_int      , @@giga.enter     ,\
         @@tera     , @@_tera_int      , @@tera.enter     ,\
         @@peta     , @@_peta_int      , @@peta.enter     ,\
         @@exa      , @@_exa_int       , @@exa.enter      ,\
         @@zetta    , @@_zetta_int     , @@zetta.enter    ,\
         @@yotta    , @@_yotta_int     , @@yotta.enter    ,\
         @@deci     , @@_deci_int      , @@deci.enter     ,\
         @@centi    , @@_centi_int     , @@centi.enter    ,\
         @@milli    , @@_milli_int     , @@milli.enter    ,\
         @@micro    , @@_micro_int     , @@micro.enter    ,\
         @@nano     , @@_nano_int      , @@nano.enter     ,\
         @@pico     , @@_pico_int      , @@pico.enter     ,\
         @@femto    , @@_femto_int     , @@femto.enter    ,\
         @@atto     , @@_atto_int      , @@atto.enter     ,\
         @@zepto    , @@_zepto_int     , @@zepto.enter    ,\
         @@yocto    , @@_yocto_int     , @@yocto.enter
;        0            1                  2

proc_map @x3_procs_1p_ir, 3,\
         @@trunc    , @@trunc.enter    , @@_trunc_reg
;        0            1                  2
macro c
{
proc_map @x3_procs_1p_ir, 3,\
         @@isign    , @@isign.enter    , @@_isign_reg     ,\
         @@risign   , @@risign.enter   , @@_risign_reg    ,\
         @@trunc    , @@trunc.enter    , @@_trunc_reg
;        0            1                  2
}

proc_map @x3_procs_1p_xr, 3,\
         @@sign     , @@_sign_reg      , @@sign.enter     ,\
         @@rsign    , @@_rsign_reg     , @@rsign.enter    ,\
         @@chs      , @@_chs_reg       , @@chs.enter      ,\
         @@abs      , @@_abs_reg       , @@abs.enter      ,\
         @@nabs     , @@_nabs_reg      , @@nabs.enter     ,\
         @@inc      , @@_inc_reg       , @@inc.enter      ,\
         @@dec      , @@_dec_reg       , @@dec.enter      ,\
         @@nzero    , @@_nzero_reg     , @@nzero.enter    ,\
         @@rnzero   , @@_rnzero_reg    , @@rnzero.enter   ,\
         @@pos      , @@_pos_reg       , @@pos.enter      ,\
         @@neg      , @@_neg_reg       , @@neg.enter      ,\
         @@inv      , @@_inv_reg       , @@inv.enter      ,\
         @@ot       , @@_ot_reg        , @@ot.enter       ,\
         @@not      , @@_not_reg       , @@not.enter      ,\
         @@if.true  , @@_if.true_reg   , @@if.true.enter  ,\
         @@if.false , @@_if.false_reg  , @@if.false.enter ,\
         @@if.z     , @@_if.z_reg      , @@if.z.enter     ,\
         @@if.nz    , @@_if.nz_reg     , @@if.nz.enter    ,\
         @@if.az    , @@_if.az_reg     , @@if.az.enter    ,\
         @@if.aez   , @@_if.aez_reg    , @@if.aez.enter   ,\
         @@if.bz    , @@_if.bz_reg     , @@if.bz.enter    ,\
         @@if.bez   , @@_if.bez_reg    , @@if.bez.enter
;        0            1                  2

proc_map @x2_procs_1p_pp, 2,\
         @@inc.pre  , @@_inc.pre_int   ,\
         @@inc.post , @@_inc.post_int  ,\
         @@dec.pre  , @@_dec.pre_int   ,\
         @@dec.post , @@_dec.post_int
;        0            1

proc_map @x3_procs_1p_dm, 3,\
         @@.mul.2pi , @@_mul.2pi_int   , @@.mul.2pi.enter ,\
         @@.mul.pi  , @@_mul.pi_int    , @@.mul.pi.enter  ,\
         @@.mul.pi2 , @@_mul.pi2_int   , @@.mul.pi2.enter ,\
         @@.mul.pi4 , @@_mul.pi4_int   , @@.mul.pi4.enter ,\
         @@.div.2pi , @@_div.2pi_int   , @@.div.2pi.enter ,\
         @@.div.pi  , @@_div.pi_int    , @@.div.pi.enter  ,\
         @@.div.pi2 , @@_div.pi2_int   , @@.div.pi2.enter ,\
         @@.div.pi4 , @@_div.pi4_int   , @@.div.pi4.enter ,\
         @@.quo.2pi , @@_quo.2pi_int   , @@.quo.2pi.enter ,\
         @@.quo.pi  , @@_quo.pi_int    , @@.quo.pi.enter  ,\
         @@.quo.pi2 , @@_quo.pi2_int   , @@.quo.pi2.enter ,\
         @@.quo.pi4 , @@_quo.pi4_int   , @@.quo.pi4.enter ,\
         @@.mod.2pi , @@_mod.2pi_int   , @@.mod.2pi.enter ,\
         @@.mod.pi  , @@_mod.pi_int    , @@.mod.pi.enter  ,\
         @@.mod.pi2 , @@_mod.pi2_int   , @@.mod.pi2.enter ,\
         @@.mod.pi4 , @@_mod.pi4_int   , @@.mod.pi4.enter
;        0            1                  2

proc_map @x4_procs_2p, 4,\
         @@add      , @@_add_int       , @@add.enter      , @@_add_reg      ,\
         @@add.pos  , @@_add.pos_int   , @@add.pos.enter  , @@_add.pos_reg  ,\
         @@add.neg  , @@_add.neg_int   , @@add.neg.enter  , @@_add.neg_reg  ,\
         @@sub      , @@_sub_int       , @@sub.enter      , @@_sub_reg      ,\
         @@sub.pos  , @@_sub.pos_int   , @@sub.pos.enter  , @@_sub.pos_reg  ,\
         @@sub.neg  , @@_sub.neg_int   , @@sub.neg.enter  , @@_sub.neg_reg  ,\
         @@subr     , @@_subr_int      , @@subr.enter     , @@_subr_reg     ,\
         @@subr.pos , @@_subr.pos_int  , @@subr.pos.enter , @@_subr.pos_reg ,\
         @@subr.neg , @@_subr.neg_int  , @@subr.neg.enter , @@_subr.neg_reg ,\
         @@mul      , @@_mul_int       , @@mul.enter      , @@_mul_reg      ,\
         @@mul.pos  , @@_mul.pos_int   , @@mul.pos.enter  , @@_mul.pos_reg  ,\
         @@mul.neg  , @@_mul.neg_int   , @@mul.neg.enter  , @@_mul.neg_reg  ,\
         @@div      , @@_div_int       , @@div.enter      , @@_div_reg      ,\
         @@div.pos  , @@_div.pos_int   , @@div.pos.enter  , @@_div.pos_reg  ,\
         @@div.neg  , @@_div.neg_int   , @@div.neg.enter  , @@_div.neg_reg  ,\
         @@divr     , @@_divr_int      , @@divr.enter     , @@_divr_reg     ,\
         @@divr.pos , @@_divr.pos_int  , @@divr.pos.enter , @@_divr.pos_reg ,\
         @@divr.neg , @@_divr.neg_int  , @@divr.neg.enter , @@_divr.neg_reg ,\
         @@quo      , @@_quo_int       , @@quo.enter      , @@_quo_reg      ,\
         @@quo.pos  , @@_quo.pos_int   , @@quo.pos.enter  , @@_quo.pos_reg  ,\
         @@quo.neg  , @@_quo.neg_int   , @@quo.neg.enter  , @@_quo.neg_reg  ,\
         @@quor     , @@_quor_int      , @@quor.enter     , @@_quor_reg     ,\
         @@quor.pos , @@_quor.pos_int  , @@quor.pos.enter , @@_quor.pos_reg ,\
         @@quor.neg , @@_quor.neg_int  , @@quor.neg.enter , @@_quor.neg_reg ,\
         @@mod      , @@_mod_int       , @@mod.enter      , @@_mod_reg      ,\
         @@mod.pos  , @@_mod.pos_int   , @@mod.pos.enter  , @@_mod.pos_reg  ,\
         @@mod.neg  , @@_mod.neg_int   , @@mod.neg.enter  , @@_mod.neg_reg  ,\
         @@modr     , @@_modr_int      , @@modr.enter     , @@_modr_reg     ,\
         @@modr.pos , @@_modr.pos_int  , @@modr.pos.enter , @@_modr.pos_reg ,\
         @@modr.neg , @@_modr.neg_int  , @@modr.neg.enter , @@_modr.neg_reg ,\
         @@min      , @@_min_int       , @@min.enter      , @@_min_reg      ,\
         @@max      , @@_max_int       , @@max.enter      , @@_max_reg      ,\
         @@adev     , @@_adev_int      , @@adev.enter     , @@_adev_reg     ,\
         @@nadev    , @@_nadev_int     , @@nadev.enter    , @@_nadev_reg    ,\
         @@gcd      , @@_gcd_int       , @@gcd.enter      , @@_gcd_reg      ,\
         @@lcm      , @@_lcm_int       , @@lcm.enter      , @@_lcm_reg      ,\
         @@or       , @@_or_int        , @@or.enter       , @@_or_reg       ,\
         @@nor      , @@_nor_int       , @@nor.enter      , @@_nor_reg      ,\
         @@xor      , @@_xor_int       , @@xor.enter      , @@_xor_reg      ,\
         @@xnor     , @@_xnor_int      , @@xnor.enter     , @@_xnor_reg     ,\
         @@and      , @@_and_int       , @@and.enter      , @@_and_reg      ,\
         @@nand     , @@_nand_int      , @@nand.enter     , @@_nand_reg     ,\
         @@if.e     , @@_if.e_int      , @@if.e.enter     , @@_if.e_reg     ,\
         @@if.ne    , @@_if.ne_int     , @@if.ne.enter    , @@_if.ne_reg    ,\
         @@if.a     , @@_if.a_int      , @@if.a.enter     , @@_if.a_reg     ,\
         @@if.ae    , @@_if.ae_int     , @@if.ae.enter    , @@_if.ae_reg    ,\
         @@if.b     , @@_if.b_int      , @@if.b.enter     , @@_if.b_reg     ,\
         @@if.be    , @@_if.be_int     , @@if.be.enter    , @@_if.be_reg    ,\
         @@if.bea   , @@_if.bea_int    , @@if.bea.enter   , @@_if.bea_reg   ,\
         @@if.aeb   , @@_if.aeb_int    , @@if.aeb.enter   , @@_if.aeb_reg   ,\
         @@case.x32 , @@_case.x32_int  , @@case.x32.enter , @@_case.x32_reg ,\
         @@case.n32 , @@_case.n32_int  , @@case.n32.enter , @@_case.n32_reg ,\
         @@case.x64 , @@_case.x64_int  , @@case.x64.enter , @@_case.x64_reg ,\
         @@case.n64 , @@_case.n64_int  , @@case.n64.enter , @@_case.n64_reg
;        0            1                  2                  3

proc_map @x8_procs_2ps, 8,\
         @@pow   , @@apow.enter  , @@pow.enter   , @@fld1 , @@uplus , @@pow2  , @@pow3  , @@pow4  ,\
         @@root  , @@root.enter  , @@root.enter  ,        , @@uplus , @@root2 , @@root3 , @@root4
;        0         1               2               3        4         5         6         7

proc_map @x8_procs_2pr, 8,\
         @@powr  , @@apowr.enter , @@powr.enter  , @@set1 , @@uplus , @@pow2  , @@pow3  , @@pow4  ,\
         @@rootr , @@rootr.enter , @@rootr.enter ,        , @@uplus , @@root2 , @@root3 , @@root4
;        0         1               2               3        4         5         6         7

proc_map @x3_jump_procs_if_xz, 3,\
         @@goto.if.true  , @@goto.int.if.true  , @@goto.reg.if.true  ,\
         @@goto.if.false , @@goto.int.if.false , @@goto.reg.if.false ,\
         @@goto.if.z     , @@goto.int.if.z     , @@goto.reg.if.z     ,\
         @@goto.if.nz    , @@goto.int.if.nz    , @@goto.reg.if.nz    ,\
         @@goto.if.az    , @@goto.int.if.az    , @@goto.reg.if.az    ,\
         @@goto.if.aez   , @@goto.int.if.aez   , @@goto.reg.if.aez   ,\
         @@goto.if.bz    , @@goto.int.if.bz    , @@goto.reg.if.bz    ,\
         @@goto.if.bez   , @@goto.int.if.bez   , @@goto.reg.if.bez   ,\
         @@call.if.true  , @@call.int.if.true  , @@call.reg.if.true  ,\
         @@call.if.false , @@call.int.if.false , @@call.reg.if.false ,\
         @@call.if.z     , @@call.int.if.z     , @@call.reg.if.z     ,\
         @@call.if.nz    , @@call.int.if.nz    , @@call.reg.if.nz    ,\
         @@call.if.az    , @@call.int.if.az    , @@call.reg.if.az    ,\
         @@call.if.aez   , @@call.int.if.aez   , @@call.reg.if.aez   ,\
         @@call.if.bz    , @@call.int.if.bz    , @@call.reg.if.bz    ,\
         @@call.if.bez   , @@call.int.if.bez   , @@call.reg.if.bez
;        0                 1                     2

proc_map @x3_jump_procs_ie_xz, 3,\
         @@call.ie.true  , @@call.int.ie.true  , @@call.reg.ie.true  ,\
         @@call.ie.false , @@call.int.ie.false , @@call.reg.ie.false ,\
         @@call.ie.z     , @@call.int.ie.z     , @@call.reg.ie.z     ,\
         @@call.ie.nz    , @@call.int.ie.nz    , @@call.reg.ie.nz    ,\
         @@call.ie.az    , @@call.int.ie.az    , @@call.reg.ie.az    ,\
         @@call.ie.aez   , @@call.int.ie.aez   , @@call.reg.ie.aez   ,\
         @@call.ie.bz    , @@call.int.ie.bz    , @@call.reg.ie.bz    ,\
         @@call.ie.bez   , @@call.int.ie.bez   , @@call.reg.ie.bez
;        0                 1                     2

; ------------------------------------------------------------------------------

; ??exit.name      db '??exit',0
; ??exit.name.size = $-??exit.name-1
; ??exit.code      db '??exit:',0
; ??exit.code.size = $-??exit.code-1

sdata   ??exit.name, '??exit',\
        ??exit.code, '??exit:'

; ------------------------------------------------------------------------------

sdata   SC_SIC_OPT_FLAG_OPTIMIZATION , 'OPTIMIZATION' ,\
        SC_SIC_OPT_FLAG_STACK_FRAME  , 'STACK_FRAME'  ,\
        SC_SIC_OPT_FLAG_STACK.FRAME  , 'STACK.FRAME'  ,\
        SC_SIC_OPT_FLAG_LOCALS       , 'LOCALS'       ,\
        SC_SIC_OPT_FLAG_FP_FRAME     , 'FP_FRAME'     ,\
        SC_SIC_OPT_FLAG_FP.FRAME     , 'FP.FRAME'     ,\
        SC_SIC_OPT_FLAG_DEBUG        , 'DEBUG'        ,\
        SC_SIC_OPT_FLAG_CPUX64       , 'CPUX64'       ,\
        SC_SIC_OPT_FLAG_CPUX32       , 'CPUX32'       ,\
        SC_SIC_OPT_FLAG_CPUX         , 'CPUX'         ,\
        SC_SIC_OPT_FLAG_DALIGN       , 'DALIGN'       ,\
        SC_SIC_OPT_FLAG_NO_CALIGN    , 'NO_CALIGN'    ,\
        SC_SIC_OPT_FLAG_NO.CALIGN    , 'NO.CALIGN'    ,\
        SC_SIC_OPT_FLAG_NO_ECALC     , 'NO_ECALC'     ,\
        SC_SIC_OPT_FLAG_NO.ECALC     , 'NO.ECALC'     ,\
        SC_SIC_OPT_FLAG_COMPLEX      , 'COMPLEX'      ,\
        SC_SIC_OPT_FLAG_COMPACT      , 'COMPACT'

; ------------------------------------------------------------------------------
