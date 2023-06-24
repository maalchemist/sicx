
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (units functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; bit data modifier
; double bit ( double v )
; v = rsp
; v:bit = v/8

macro @@bit.sse
{
$usprocf @@bit

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.0.125
    .return:
        retn
$endp
}

macro @@bit.fpu
{
$usprocf @@bit

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.0.125
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@bit.sse
$else
  @@bit.fpu
$end

; ------------------------------------------------------------------------------

; bit data modifier
; double bit ( integer v )
; v = rsp
; v:bit = v/8

macro @@_bit_int.sse
{
$usprocf @@_bit_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.0.125
    .return:
        retn
$endp
}

macro @@_bit_int.fpu
{
$usprocf @@_bit_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.0.125
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_bit_int.sse
$else
  @@_bit_int.fpu
$end

; ------------------------------------------------------------------------------

; nibble data modifier
; double nibble ( double v )
; v = rsp
; v:nibble = v/2

macro @@nibble.sse
{
$usprocf @@nibble

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.0.5
    .return:
        retn
$endp
}

macro @@nibble.fpu
{
$usprocf @@nibble

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nibble.sse
$else
  @@nibble.fpu
$end

; ------------------------------------------------------------------------------

; nibble data modifier
; double nibble ( integer v )
; v = rsp
; v:nibble = v/2

macro @@_nibble_int.sse
{
$usprocf @@_nibble_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.0.5
    .return:
        retn
$endp
}

macro @@_nibble_int.fpu
{
$usprocf @@_nibble_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nibble_int.sse
$else
  @@_nibble_int.fpu
$end

; ------------------------------------------------------------------------------

; byte data modifier
; double byte ( double v )
; v = rsp
; v:byte = v*1

macro @@byte.sse
{
$usprocf @@byte

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
    .return:
        retn
$endp
}

macro @@byte.fpu
{
$usprocf @@byte

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@byte.sse
$else
  @@byte.fpu
$end

; ------------------------------------------------------------------------------

; byte data modifier
; double byte ( integer v )
; v = rsp
; v:byte = v*1

macro @@_byte_int.sse
{
$usprocf @@_byte_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
    .return:
        retn
$endp
}

macro @@_byte_int.fpu
{
$usprocf @@_byte_int

        fild    qword [rsp]
    .enter:
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_byte_int.sse
$else
  @@_byte_int.fpu
$end

; ------------------------------------------------------------------------------

; word data modifier
; double word ( double v )
; v = rsp
; v:word = v*2

macro @@word.sse
{
$usprocf @@word

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.2.0
    .return:
        retn
$endp
}

macro @@word.fpu
{
$usprocf @@word

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.2.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@word.sse
$else
  @@word.fpu
$end

; ------------------------------------------------------------------------------

; word data modifier
; double word ( integer v )
; v = rsp
; v:word = v*2

macro @@_word_int.sse
{
$usprocf @@_word_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.2.0
    .return:
        retn
$endp
}

macro @@_word_int.fpu
{
$usprocf @@_word_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.2.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_word_int.sse
$else
  @@_word_int.fpu
$end

; ------------------------------------------------------------------------------

; dword data modifier
; double dword ( double v )
; v = rsp
; v:dword = v*4

macro @@dword.sse
{
$usprocf @@dword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.4.0
    .return:
        retn
$endp
}

macro @@dword.fpu
{
$usprocf @@dword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.4.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@dword.sse
$else
  @@dword.fpu
$end

; ------------------------------------------------------------------------------

; dword data modifier
; double dword ( integer v )
; v = rsp
; v:dword = v*4

macro @@_dword_int.sse
{
$usprocf @@_dword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.4.0
    .return:
        retn
$endp
}

macro @@_dword_int.fpu
{
$usprocf @@_dword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.4.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dword_int.sse
$else
  @@_dword_int.fpu
$end

; ------------------------------------------------------------------------------

; qword data modifier
; double qword ( double v )
; v = rsp
; v:qword = v*8

macro @@qword.sse
{
$usprocf @@qword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.8.0
    .return:
        retn
$endp
}

macro @@qword.fpu
{
$usprocf @@qword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.8.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@qword.sse
$else
  @@qword.fpu
$end

; ------------------------------------------------------------------------------

; qword data modifier
; double qword ( integer v )
; v = rsp
; v:qword = v*8

macro @@_qword_int.sse
{
$usprocf @@_qword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.8.0
    .return:
        retn
$endp
}

macro @@_qword_int.fpu
{
$usprocf @@_qword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.8.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_qword_int.sse
$else
  @@_qword_int.fpu
$end

; ------------------------------------------------------------------------------

; nword data modifier
; native integer word
; double nword ( double v )
; v = rsp
; v:nword = v*8 (x64) | v*4 (x32)

macro @@nword.sse
{
$usprocf @@nword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
    $ifdef _X64
        xmulsd  xmm0, ??.8.0
    $else
        xmulsd  xmm0, ??.4.0
    $end
    .return:
        retn
$endp
}

macro @@nword.fpu
{
$usprocf @@nword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
    $ifdef _X64
        fmulq   ??.8.0
    $else
        fmulq   ??.4.0
    $end
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nword.sse
$else
  @@nword.fpu
$end

; ------------------------------------------------------------------------------

; nword data modifier
; double nword ( integer v )
; v = rsp
; v:nword = v*8 (x64) | v*4 (x32)

macro @@_nword_int.sse
{
$usprocf @@_nword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
    $ifdef _X64
        xmulsd  xmm0, ??.8.0
    $else
        xmulsd  xmm0, ??.4.0
    $end
    .return:
        retn
$endp
}

macro @@_nword_int.fpu
{
$usprocf @@_nword_int

        fild    qword [rsp]
    .enter:
    $ifdef _X64
        fmulq   ??.8.0
    $else
        fmulq   ??.4.0
    $end
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nword_int.sse
$else
  @@_nword_int.fpu
$end

; ------------------------------------------------------------------------------

; tword data modifier
; double tword ( double v )
; v = rsp
; v:tword = v*10

macro @@tword.sse
{
$usprocf @@tword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.10.0
    .return:
        retn
$endp
}

macro @@tword.fpu
{
$usprocf @@tword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.10.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@tword.sse
$else
  @@tword.fpu
$end

; ------------------------------------------------------------------------------

; tword data modifier
; double tword ( integer v )
; v = rsp
; v:tword = v*10

macro @@_tword_int.sse
{
$usprocf @@_tword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.10.0
    .return:
        retn
$endp
}

macro @@_tword_int.fpu
{
$usprocf @@_tword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.10.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_tword_int.sse
$else
  @@_tword_int.fpu
$end

; ------------------------------------------------------------------------------

; xword data modifier
; double xword ( double v )
; v = rsp
; v:xword = v*16

macro @@xword.sse
{
$usprocf @@xword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.16.0
    .return:
        retn
$endp
}

macro @@xword.fpu
{
$usprocf @@xword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.16.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@xword.sse
$else
  @@xword.fpu
$end

; ------------------------------------------------------------------------------

; xword data modifier
; double xword ( integer v )
; v = rsp
; v:xword = v*16

macro @@_xword_int.sse
{
$usprocf @@_xword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.16.0
    .return:
        retn
$endp
}

macro @@_xword_int.fpu
{
$usprocf @@_xword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.16.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_xword_int.sse
$else
  @@_xword_int.fpu
$end

; ------------------------------------------------------------------------------

; oword data modifier
; double oword ( double v )
; v = rsp
; v:oword = v*16

macro @@oword.sse
{
$usprocf @@oword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.16.0
    .return:
        retn
$endp
}

macro @@oword.fpu
{
$usprocf @@oword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.16.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@oword.sse
$else
  @@oword.fpu
$end

; ------------------------------------------------------------------------------

; oword data modifier
; double oword ( integer v )
; v = rsp
; v:oword = v*16

macro @@_oword_int.sse
{
$usprocf @@_oword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.16.0
    .return:
        retn
$endp
}

macro @@_oword_int.fpu
{
$usprocf @@_oword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.16.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_oword_int.sse
$else
  @@_oword_int.fpu
$end

; ------------------------------------------------------------------------------

; yword data modifier
; double yword ( double v )
; v = rsp
; v:yword = v*32

macro @@yword.sse
{
$usprocf @@yword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.32.0
    .return:
        retn
$endp
}

macro @@yword.fpu
{
$usprocf @@yword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.32.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@yword.sse
$else
  @@yword.fpu
$end

; ------------------------------------------------------------------------------

; yword data modifier
; double yword ( integer v )
; v = rsp
; v:yword = v*32

macro @@_yword_int.sse
{
$usprocf @@_yword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.32.0
    .return:
        retn
$endp
}

macro @@_yword_int.fpu
{
$usprocf @@_yword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.32.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_yword_int.sse
$else
  @@_yword_int.fpu
$end

; ------------------------------------------------------------------------------

; zword data modifier
; double zword ( double v )
; v = rsp
; v:zword = v*64

macro @@zword.sse
{
$usprocf @@zword

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.64.0
    .return:
        retn
$endp
}

macro @@zword.fpu
{
$usprocf @@zword

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.64.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@zword.sse
$else
  @@zword.fpu
$end

; ------------------------------------------------------------------------------

; zword data modifier
; double zword ( integer v )
; v = rsp
; v:zword = v*64

macro @@_zword_int.sse
{
$usprocf @@_zword_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.64.0
    .return:
        retn
$endp
}

macro @@_zword_int.fpu
{
$usprocf @@_zword_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.64.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_zword_int.sse
$else
  @@_zword_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; kibi data modifier (Ki)
; double kibi ( double v )
; v = rsp
; v:kibi = v*(2^10)

macro @@kibi.sse
{
$usprocf @@kibi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.kibi
    .return:
        retn
$endp
}

macro @@kibi.fpu
{
$usprocf @@kibi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.10.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kibi.sse
$else
  @@kibi.fpu
$end

; ------------------------------------------------------------------------------

; kibi data modifier (Ki)
; double kibi ( integer v )
; v = rsp
; v:kibi = v*(2^10)

macro @@_kibi_int.sse
{
$usprocf @@_kibi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.kibi
    .return:
        retn
$endp
}

macro @@_kibi_int.fpu
{
$usprocf @@_kibi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.10.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_kibi_int.sse
$else
  @@_kibi_int.fpu
$end

; ------------------------------------------------------------------------------

; mebi data modifier (Mi)
; double mebi ( double v )
; v = rsp
; v:mebi = v*(2^20)

macro @@mebi.sse
{
$usprocf @@mebi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.mebi
    .return:
        retn
$endp
}

macro @@mebi.fpu
{
$usprocf @@mebi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.20.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mebi.sse
$else
  @@mebi.fpu
$end

; ------------------------------------------------------------------------------

; mebi data modifier (Mi)
; double mebi ( integer v )
; v = rsp
; v:mebi = v*(2^20)

macro @@_mebi_int.sse
{
$usprocf @@_mebi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.mebi
    .return:
        retn
$endp
}

macro @@_mebi_int.fpu
{
$usprocf @@_mebi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.20.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mebi_int.sse
$else
  @@_mebi_int.fpu
$end

; ------------------------------------------------------------------------------

; gibi data modifier (Gi)
; double gibi ( double v )
; v = rsp
; v:gibi = v*(2^30)

macro @@gibi.sse
{
$usprocf @@gibi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.gibi
    .return:
        retn
$endp
}

macro @@gibi.fpu
{
$usprocf @@gibi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.30.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@gibi.sse
$else
  @@gibi.fpu
$end

; ------------------------------------------------------------------------------

; gibi data modifier (Gi)
; double gibi ( integer v )
; v = rsp
; v:gibi = v*(2^30)

macro @@_gibi_int.sse
{
$usprocf @@_gibi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.gibi
    .return:
        retn
$endp
}

macro @@_gibi_int.fpu
{
$usprocf @@_gibi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.30.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_gibi_int.sse
$else
  @@_gibi_int.fpu
$end

; ------------------------------------------------------------------------------

; tebi data modifier (Ti)
; double tebi ( double v )
; v = rsp
; v:tebi = v*(2^40)

macro @@tebi.sse
{
$usprocf @@tebi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.tebi
    .return:
        retn
$endp
}

macro @@tebi.fpu
{
$usprocf @@tebi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.40.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@tebi.sse
$else
  @@tebi.fpu
$end

; ------------------------------------------------------------------------------

; tebi data modifier (Ti)
; double tebi ( integer v )
; v = rsp
; v:tebi = v*(2^40)

macro @@_tebi_int.sse
{
$usprocf @@_tebi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.tebi
    .return:
        retn
$endp
}

macro @@_tebi_int.fpu
{
$usprocf @@_tebi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.40.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_tebi_int.sse
$else
  @@_tebi_int.fpu
$end

; ------------------------------------------------------------------------------

; pebi data modifier (Pi)
; double pebi ( double v )
; v = rsp
; v:pebi = v*(2^50)

macro @@pebi.sse
{
$usprocf @@pebi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.pebi
    .return:
        retn
$endp
}

macro @@pebi.fpu
{
$usprocf @@pebi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.50.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pebi.sse
$else
  @@pebi.fpu
$end

; ------------------------------------------------------------------------------

; pebi data modifier (Pi)
; double pebi ( integer v )
; v = rsp
; v:pebi = v*(2^50)

macro @@_pebi_int.sse
{
$usprocf @@_pebi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.pebi
    .return:
        retn
$endp
}

macro @@_pebi_int.fpu
{
$usprocf @@_pebi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.50.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_pebi_int.sse
$else
  @@_pebi_int.fpu
$end

; ------------------------------------------------------------------------------

; exbi data modifier (Ei)
; double exbi ( double v )
; v = rsp
; v:exbi = v*(2^60)

macro @@exbi.sse
{
$usprocf @@exbi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.exbi
    .return:
        retn
$endp
}

macro @@exbi.fpu
{
$usprocf @@exbi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.60.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exbi.sse
$else
  @@exbi.fpu
$end

; ------------------------------------------------------------------------------

; exbi data modifier (Ei)
; double exbi ( integer v )
; v = rsp
; v:exbi = v*(2^60)

macro @@_exbi_int.sse
{
$usprocf @@_exbi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.exbi
    .return:
        retn
$endp
}

macro @@_exbi_int.fpu
{
$usprocf @@_exbi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.60.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_exbi_int.sse
$else
  @@_exbi_int.fpu
$end

; ------------------------------------------------------------------------------

; zebi data modifier (Zi)
; double zebi ( double v )
; v = rsp
; v:zebi = v*(2^70)

macro @@zebi.sse
{
$usprocf @@zebi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.zebi
    .return:
        retn
$endp
}

macro @@zebi.fpu
{
$usprocf @@zebi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.70.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@zebi.sse
$else
  @@zebi.fpu
$end

; ------------------------------------------------------------------------------

; zebi data modifier (Zi)
; double zebi ( integer v )
; v = rsp
; v:zebi = v*(2^70)

macro @@_zebi_int.sse
{
$usprocf @@_zebi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.zebi
    .return:
        retn
$endp
}

macro @@_zebi_int.fpu
{
$usprocf @@_zebi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.70.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_zebi_int.sse
$else
  @@_zebi_int.fpu
$end

; ------------------------------------------------------------------------------

; yobi data modifier (Yi)
; double yobi ( double v )
; v = rsp
; v:yobi = v*(2^80)

macro @@yobi.sse
{
$usprocf @@yobi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.yobi
    .return:
        retn
$endp
}

macro @@yobi.fpu
{
$usprocf @@yobi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.80.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@yobi.sse
$else
  @@yobi.fpu
$end

; ------------------------------------------------------------------------------

; yobi data modifier (Yi)
; double yobi ( integer v )
; v = rsp
; v:yobi = v*(2^80)

macro @@_yobi_int.sse
{
$usprocf @@_yobi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.yobi
    .return:
        retn
$endp
}

macro @@_yobi_int.fpu
{
$usprocf @@_yobi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.80.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_yobi_int.sse
$else
  @@_yobi_int.fpu
$end

; ------------------------------------------------------------------------------

; robi data modifier (Ri)
; double robi ( double v )
; v = rsp
; v:robi = v*(2^90)

macro @@robi.sse
{
$usprocf @@robi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.robi
    .return:
        retn
$endp
}

macro @@robi.fpu
{
$usprocf @@robi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.90.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@robi.sse
$else
  @@robi.fpu
$end

; ------------------------------------------------------------------------------

; robi data modifier (Ri)
; double robi ( integer v )
; v = rsp
; v:robi = v*(2^90)

macro @@_robi_int.sse
{
$usprocf @@_robi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.robi
    .return:
        retn
$endp
}

macro @@_robi_int.fpu
{
$usprocf @@_robi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.90.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_robi_int.sse
$else
  @@_robi_int.fpu
$end

; ------------------------------------------------------------------------------

; quebi data modifier (Qi)
; double quebi ( double v )
; v = rsp
; v:quebi = v*(2^100)

macro @@quebi.sse
{
$usprocf @@quebi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.quebi
    .return:
        retn
$endp
}

macro @@quebi.fpu
{
$usprocf @@quebi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.100.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quebi.sse
$else
  @@quebi.fpu
$end

; ------------------------------------------------------------------------------

; quebi data modifier (Qi)
; double quebi ( integer v )
; v = rsp
; v:quebi = v*(2^100)

macro @@_quebi_int.sse
{
$usprocf @@_quebi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.quebi
    .return:
        retn
$endp
}

macro @@_quebi_int.fpu
{
$usprocf @@_quebi_int

        fild    qword [rsp]
    .enter:
        fldq    ??.100.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quebi_int.sse
$else
  @@_quebi_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; kibo data modifier
; double kibo ( double v )
; v = rsp
; v:kibo = v*(2^-10)

macro @@kibo.sse
{
$usprocf @@kibo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.kibo
    .return:
        retn
$endp
}

macro @@kibo.fpu
{
$usprocf @@kibo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m10.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kibo.sse
$else
  @@kibo.fpu
$end

; ------------------------------------------------------------------------------

; kibo data modifier
; double kibo ( integer v )
; v = rsp
; v:kibo = v*(2^-10)

macro @@_kibo_int.sse
{
$usprocf @@_kibo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.kibo
    .return:
        retn
$endp
}

macro @@_kibo_int.fpu
{
$usprocf @@_kibo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m10.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_kibo_int.sse
$else
  @@_kibo_int.fpu
$end

; ------------------------------------------------------------------------------

; mebo data modifier
; double mebo ( double v )
; v = rsp
; v:mebo = v*(2^-20)

macro @@mebo.sse
{
$usprocf @@mebo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.mebo
    .return:
        retn
$endp
}

macro @@mebo.fpu
{
$usprocf @@mebo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m20.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mebo.sse
$else
  @@mebo.fpu
$end

; ------------------------------------------------------------------------------

; mebo data modifier
; double mebo ( integer v )
; v = rsp
; v:mebo = v*(2^-20)

macro @@_mebo_int.sse
{
$usprocf @@_mebo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.mebo
    .return:
        retn
$endp
}

macro @@_mebo_int.fpu
{
$usprocf @@_mebo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m20.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mebo_int.sse
$else
  @@_mebo_int.fpu
$end

; ------------------------------------------------------------------------------

; gibo data modifier
; double gibo ( double v )
; v = rsp
; v:gibo = v*(2^-30)

macro @@gibo.sse
{
$usprocf @@gibo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.gibo
    .return:
        retn
$endp
}

macro @@gibo.fpu
{
$usprocf @@gibo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m30.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@gibo.sse
$else
  @@gibo.fpu
$end

; ------------------------------------------------------------------------------

; gibo data modifier
; double gibo ( integer v )
; v = rsp
; v:gibo = v*(2^-30)

macro @@_gibo_int.sse
{
$usprocf @@_gibo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.gibo
    .return:
        retn
$endp
}

macro @@_gibo_int.fpu
{
$usprocf @@_gibo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m30.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_gibo_int.sse
$else
  @@_gibo_int.fpu
$end

; ------------------------------------------------------------------------------

; tebo data modifier
; double tebo ( double v )
; v = rsp
; v:tebo = v*(2^-40)

macro @@tebo.sse
{
$usprocf @@tebo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.tebo
    .return:
        retn
$endp
}

macro @@tebo.fpu
{
$usprocf @@tebo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m40.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@tebo.sse
$else
  @@tebo.fpu
$end

; ------------------------------------------------------------------------------

; tebo data modifier
; double tebo ( integer v )
; v = rsp
; v:tebo = v*(2^-40)

macro @@_tebo_int.sse
{
$usprocf @@_tebo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.tebo
    .return:
        retn
$endp
}

macro @@_tebo_int.fpu
{
$usprocf @@_tebo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m40.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_tebo_int.sse
$else
  @@_tebo_int.fpu
$end

; ------------------------------------------------------------------------------

; pebo data modifier
; double pebo ( double v )
; v = rsp
; v:pebo = v*(2^-50)

macro @@pebo.sse
{
$usprocf @@pebo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.pebo
    .return:
        retn
$endp
}

macro @@pebo.fpu
{
$usprocf @@pebo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m50.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pebo.sse
$else
  @@pebo.fpu
$end

; ------------------------------------------------------------------------------

; pebo data modifier
; double pebo ( integer v )
; v = rsp
; v:pebo = v*(2^-50)

macro @@_pebo_int.sse
{
$usprocf @@_pebo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.pebo
    .return:
        retn
$endp
}

macro @@_pebo_int.fpu
{
$usprocf @@_pebo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m50.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_pebo_int.sse
$else
  @@_pebo_int.fpu
$end

; ------------------------------------------------------------------------------

; exbo data modifier
; double exbo ( double v )
; v = rsp
; v:exbo = v*(2^-60)

macro @@exbo.sse
{
$usprocf @@exbo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.exbo
    .return:
        retn
$endp
}

macro @@exbo.fpu
{
$usprocf @@exbo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m60.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exbo.sse
$else
  @@exbo.fpu
$end

; ------------------------------------------------------------------------------

; exbo data modifier
; double exbo ( integer v )
; v = rsp
; v:exbo = v*(2^-60)

macro @@_exbo_int.sse
{
$usprocf @@_exbo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.exbo
    .return:
        retn
$endp
}

macro @@_exbo_int.fpu
{
$usprocf @@_exbo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m60.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_exbo_int.sse
$else
  @@_exbo_int.fpu
$end

; ------------------------------------------------------------------------------

; zebo data modifier
; double zebo ( double v )
; v = rsp
; v:zebo = v*(2^-70)

macro @@zebo.sse
{
$usprocf @@zebo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.zebo
    .return:
        retn
$endp
}

macro @@zebo.fpu
{
$usprocf @@zebo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m70.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@zebo.sse
$else
  @@zebo.fpu
$end

; ------------------------------------------------------------------------------

; zebo data modifier
; double zebo ( integer v )
; v = rsp
; v:zebo = v*(2^-70)

macro @@_zebo_int.sse
{
$usprocf @@_zebo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.zebo
    .return:
        retn
$endp
}

macro @@_zebo_int.fpu
{
$usprocf @@_zebo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m70.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_zebo_int.sse
$else
  @@_zebo_int.fpu
$end

; ------------------------------------------------------------------------------

; yobo data modifier
; double yobo ( double v )
; v = rsp
; v:yobo = v*(2^-80)

macro @@yobo.sse
{
$usprocf @@yobo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.yobo
    .return:
        retn
$endp
}

macro @@yobo.fpu
{
$usprocf @@yobo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m80.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@yobo.sse
$else
  @@yobo.fpu
$end

; ------------------------------------------------------------------------------

; yobo data modifier
; double yobo ( integer v )
; v = rsp
; v:yobo = v*(2^-80)

macro @@_yobo_int.sse
{
$usprocf @@_yobo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.yobo
    .return:
        retn
$endp
}

macro @@_yobo_int.fpu
{
$usprocf @@_yobo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m80.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_yobo_int.sse
$else
  @@_yobo_int.fpu
$end

; ------------------------------------------------------------------------------

; robo data modifier
; double robo ( double v )
; v = rsp
; v:robo = v*(2^-90)

macro @@robo.sse
{
$usprocf @@robo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.robo
    .return:
        retn
$endp
}

macro @@robo.fpu
{
$usprocf @@robo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m90.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@robo.sse
$else
  @@robo.fpu
$end

; ------------------------------------------------------------------------------

; robo data modifier
; double robo ( integer v )
; v = rsp
; v:robo = v*(2^-90)

macro @@_robo_int.sse
{
$usprocf @@_robo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.robo
    .return:
        retn
$endp
}

macro @@_robo_int.fpu
{
$usprocf @@_robo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m90.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_robo_int.sse
$else
  @@_robo_int.fpu
$end

; ------------------------------------------------------------------------------

; quebo data modifier
; double quebo ( double v )
; v = rsp
; v:quebo = v*(2^-100)

macro @@quebo.sse
{
$usprocf @@quebo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.quebo
    .return:
        retn
$endp
}

macro @@quebo.fpu
{
$usprocf @@quebo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldq    ??.m100.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quebo.sse
$else
  @@quebo.fpu
$end

; ------------------------------------------------------------------------------

; quebo data modifier
; double quebo ( integer v )
; v = rsp
; v:quebo = v*(2^-100)

macro @@_quebo_int.sse
{
$usprocf @@_quebo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.quebo
    .return:
        retn
$endp
}

macro @@_quebo_int.fpu
{
$usprocf @@_quebo_int

        fild    qword [rsp]
    .enter:
        fldq    ??.m100.0
        fxch
        fscale
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quebo_int.sse
$else
  @@_quebo_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; deca data modifier (da)
; double deca ( double v )
; v = rsp
; v:deca = v*1.0E+01

macro @@deca.sse
{
$usprocf @@deca

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.deca
    .return:
        retn
$endp
}

macro @@deca.fpu
{
$usprocf @@deca

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.deca
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deca.sse
$else
  @@deca.fpu
$end

; ------------------------------------------------------------------------------

; deca data modifier (da)
; double deca ( integer v )
; v = rsp
; v:deca = v*1.0E+01

macro @@_deca_int.sse
{
$usprocf @@_deca_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.deca
    .return:
        retn
$endp
}

macro @@_deca_int.fpu
{
$usprocf @@_deca_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.deca
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_deca_int.sse
$else
  @@_deca_int.fpu
$end

; ------------------------------------------------------------------------------

; hecto data modifier (h)
; double hecto ( double v )
; v = rsp
; v:hecto = v*1.0E+02

macro @@hecto.sse
{
$usprocf @@hecto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.hecto
    .return:
        retn
$endp
}

macro @@hecto.fpu
{
$usprocf @@hecto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.hecto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@hecto.sse
$else
  @@hecto.fpu
$end

; ------------------------------------------------------------------------------

; hecto data modifier (h)
; double hecto ( integer v )
; v = rsp
; v:hecto = v*1.0E+02

macro @@_hecto_int.sse
{
$usprocf @@_hecto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.hecto
    .return:
        retn
$endp
}

macro @@_hecto_int.fpu
{
$usprocf @@_hecto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.hecto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_hecto_int.sse
$else
  @@_hecto_int.fpu
$end

; ------------------------------------------------------------------------------

; kilo data modifier (k)
; double kilo ( double v )
; v = rsp
; v:kilo = v*1.0E+03

macro @@kilo.sse
{
$usprocf @@kilo

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.kilo
    .return:
        retn
$endp
}

macro @@kilo.fpu
{
$usprocf @@kilo

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.kilo
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kilo.sse
$else
  @@kilo.fpu
$end

; ------------------------------------------------------------------------------

; kilo data modifier (k)
; double kilo ( integer v )
; v = rsp
; v:kilo = v*1.0E+03

macro @@_kilo_int.sse
{
$usprocf @@_kilo_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.kilo
    .return:
        retn
$endp
}

macro @@_kilo_int.fpu
{
$usprocf @@_kilo_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.kilo
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_kilo_int.sse
$else
  @@_kilo_int.fpu
$end

; ------------------------------------------------------------------------------

; mega data modifier (M)
; double mega ( double v )
; v = rsp
; v:mega = v*1.0E+06

macro @@mega.sse
{
$usprocf @@mega

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.mega
    .return:
        retn
$endp
}

macro @@mega.fpu
{
$usprocf @@mega

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.mega
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mega.sse
$else
  @@mega.fpu
$end

; ------------------------------------------------------------------------------

; mega data modifier (M)
; double mega ( integer v )
; v = rsp
; v:mega = v*1.0E+06

macro @@_mega_int.sse
{
$usprocf @@_mega_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.mega
    .return:
        retn
$endp
}

macro @@_mega_int.fpu
{
$usprocf @@_mega_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.mega
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mega_int.sse
$else
  @@_mega_int.fpu
$end

; ------------------------------------------------------------------------------

; giga data modifier (G)
; double giga ( double v )
; v = rsp
; v:giga = v*1.0E+09

macro @@giga.sse
{
$usprocf @@giga

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.giga
    .return:
        retn
$endp
}

macro @@giga.fpu
{
$usprocf @@giga

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.giga
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@giga.sse
$else
  @@giga.fpu
$end

; ------------------------------------------------------------------------------

; giga data modifier (G)
; double giga ( integer v )
; v = rsp
; v:giga = v*1.0E+09

macro @@_giga_int.sse
{
$usprocf @@_giga_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.giga
    .return:
        retn
$endp
}

macro @@_giga_int.fpu
{
$usprocf @@_giga_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.giga
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_giga_int.sse
$else
  @@_giga_int.fpu
$end

; ------------------------------------------------------------------------------

; tera data modifier (T)
; double tera ( double v )
; v = rsp
; v:tera = v*1.0E+12

macro @@tera.sse
{
$usprocf @@tera

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.tera
    .return:
        retn
$endp
}

macro @@tera.fpu
{
$usprocf @@tera

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.tera
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@tera.sse
$else
  @@tera.fpu
$end

; ------------------------------------------------------------------------------

; tera data modifier (T)
; double tera ( integer v )
; v = rsp
; v:tera = v*1.0E+12

macro @@_tera_int.sse
{
$usprocf @@_tera_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.tera
    .return:
        retn
$endp
}

macro @@_tera_int.fpu
{
$usprocf @@_tera_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.tera
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_tera_int.sse
$else
  @@_tera_int.fpu
$end

; ------------------------------------------------------------------------------

; peta data modifier (P)
; double peta ( double v )
; v = rsp
; v:peta = v*1.0E+15

macro @@peta.sse
{
$usprocf @@peta

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.peta
    .return:
        retn
$endp
}

macro @@peta.fpu
{
$usprocf @@peta

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.peta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@peta.sse
$else
  @@peta.fpu
$end

; ------------------------------------------------------------------------------

; peta data modifier (P)
; double peta ( integer v )
; v = rsp
; v:peta = v*1.0E+15

macro @@_peta_int.sse
{
$usprocf @@_peta_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.peta
    .return:
        retn
$endp
}

macro @@_peta_int.fpu
{
$usprocf @@_peta_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.peta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_peta_int.sse
$else
  @@_peta_int.fpu
$end

; ------------------------------------------------------------------------------

; exa data modifier (E)
; double exa ( double v )
; v = rsp
; v:exa = v*1.0E+18

macro @@exa.sse
{
$usprocf @@exa

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.exa
    .return:
        retn
$endp
}

macro @@exa.fpu
{
$usprocf @@exa

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.exa
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exa.sse
$else
  @@exa.fpu
$end

; ------------------------------------------------------------------------------

; exa data modifier (E)
; double exa ( integer v )
; v = rsp
; v:exa = v*1.0E+18

macro @@_exa_int.sse
{
$usprocf @@_exa_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.exa
    .return:
        retn
$endp
}

macro @@_exa_int.fpu
{
$usprocf @@_exa_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.exa
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_exa_int.sse
$else
  @@_exa_int.fpu
$end

; ------------------------------------------------------------------------------

; zetta data modifier (Z)
; double zetta ( double v )
; v = rsp
; v:zetta = v*1.0E+21

macro @@zetta.sse
{
$usprocf @@zetta

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.zetta
    .return:
        retn
$endp
}

macro @@zetta.fpu
{
$usprocf @@zetta

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.zetta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@zetta.sse
$else
  @@zetta.fpu
$end

; ------------------------------------------------------------------------------

; zetta data modifier (Z)
; double zetta ( integer v )
; v = rsp
; v:zetta = v*1.0E+21

macro @@_zetta_int.sse
{
$usprocf @@_zetta_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.zetta
    .return:
        retn
$endp
}

macro @@_zetta_int.fpu
{
$usprocf @@_zetta_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.zetta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_zetta_int.sse
$else
  @@_zetta_int.fpu
$end

; ------------------------------------------------------------------------------

; yotta data modifier (Y)
; double yotta ( double v )
; v = rsp
; v:yotta = v*1.0E+24

macro @@yotta.sse
{
$usprocf @@yotta

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.yotta
    .return:
        retn
$endp
}

macro @@yotta.fpu
{
$usprocf @@yotta

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.yotta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@yotta.sse
$else
  @@yotta.fpu
$end

; ------------------------------------------------------------------------------

; yotta data modifier (Y)
; double yotta ( integer v )
; v = rsp
; v:yotta = v*1.0E+24

macro @@_yotta_int.sse
{
$usprocf @@_yotta_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.yotta
    .return:
        retn
$endp
}

macro @@_yotta_int.fpu
{
$usprocf @@_yotta_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.yotta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_yotta_int.sse
$else
  @@_yotta_int.fpu
$end

; ------------------------------------------------------------------------------

; ronna data modifier (R)
; double ronna ( double v )
; v = rsp
; v:ronna = v*1.0E+27

macro @@ronna.sse
{
$usprocf @@ronna

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.ronna
    .return:
        retn
$endp
}

macro @@ronna.fpu
{
$usprocf @@ronna

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.ronna
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ronna.sse
$else
  @@ronna.fpu
$end

; ------------------------------------------------------------------------------

; ronna data modifier (R)
; double ronna ( integer v )
; v = rsp
; v:ronna = v*1.0E+27

macro @@_ronna_int.sse
{
$usprocf @@_ronna_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.ronna
    .return:
        retn
$endp
}

macro @@_ronna_int.fpu
{
$usprocf @@_ronna_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.ronna
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_ronna_int.sse
$else
  @@_ronna_int.fpu
$end

; ------------------------------------------------------------------------------

; quetta data modifier (Q)
; double quetta ( double v )
; v = rsp
; v:quetta = v*1.0E+30

macro @@quetta.sse
{
$usprocf @@quetta

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.quetta
    .return:
        retn
$endp
}

macro @@quetta.fpu
{
$usprocf @@quetta

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.quetta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quetta.sse
$else
  @@quetta.fpu
$end

; ------------------------------------------------------------------------------

; quetta data modifier (Q)
; double quetta ( integer v )
; v = rsp
; v:quetta = v*1.0E+30

macro @@_quetta_int.sse
{
$usprocf @@_quetta_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.quetta
    .return:
        retn
$endp
}

macro @@_quetta_int.fpu
{
$usprocf @@_quetta_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.quetta
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quetta_int.sse
$else
  @@_quetta_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; deci data modifier (d)
; double deci ( double v )
; v = rsp
; v:deci = v*1.0E-01

macro @@deci.sse
{
$usprocf @@deci

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.deci
    .return:
        retn
$endp
}

macro @@deci.fpu
{
$usprocf @@deci

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.deci
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deci.sse
$else
  @@deci.fpu
$end

; ------------------------------------------------------------------------------

; deci data modifier (d)
; double deci ( integer v )
; v = rsp
; v:deci = v*1.0E-01

macro @@_deci_int.sse
{
$usprocf @@_deci_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.deci
    .return:
        retn
$endp
}

macro @@_deci_int.fpu
{
$usprocf @@_deci_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.deci
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_deci_int.sse
$else
  @@_deci_int.fpu
$end

; ------------------------------------------------------------------------------

; centi data modifier (c)
; double centi ( double v )
; v = rsp
; v:centi = v*1.0E-02

macro @@centi.sse
{
$usprocf @@centi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.centi
    .return:
        retn
$endp
}

macro @@centi.fpu
{
$usprocf @@centi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.centi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@centi.sse
$else
  @@centi.fpu
$end

; ------------------------------------------------------------------------------

; centi data modifier (c)
; double centi ( integer v )
; v = rsp
; v:centi = v*1.0E-02

macro @@_centi_int.sse
{
$usprocf @@_centi_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.centi
    .return:
        retn
$endp
}

macro @@_centi_int.fpu
{
$usprocf @@_centi_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.centi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_centi_int.sse
$else
  @@_centi_int.fpu
$end

; ------------------------------------------------------------------------------

; milli data modifier (m)
; double milli ( double v )
; v = rsp
; v:milli = v*1.0E-03

macro @@milli.sse
{
$usprocf @@milli

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.milli
    .return:
        retn
$endp
}

macro @@milli.fpu
{
$usprocf @@milli

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.milli
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@milli.sse
$else
  @@milli.fpu
$end

; ------------------------------------------------------------------------------

; milli data modifier (m)
; double milli ( integer v )
; v = rsp
; v:milli = v*1.0E-03

macro @@_milli_int.sse
{
$usprocf @@_milli_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.milli
    .return:
        retn
$endp
}

macro @@_milli_int.fpu
{
$usprocf @@_milli_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.milli
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_milli_int.sse
$else
  @@_milli_int.fpu
$end

; ------------------------------------------------------------------------------

; micro data modifier (u)
; double micro ( double v )
; v = rsp
; v:micro = v*1.0E-06

macro @@micro.sse
{
$usprocf @@micro

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.micro
    .return:
        retn
$endp
}

macro @@micro.fpu
{
$usprocf @@micro

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.micro
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@micro.sse
$else
  @@micro.fpu
$end

; ------------------------------------------------------------------------------

; micro data modifier (u)
; double micro ( integer v )
; v = rsp
; v:micro = v*1.0E-06

macro @@_micro_int.sse
{
$usprocf @@_micro_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.micro
    .return:
        retn
$endp
}

macro @@_micro_int.fpu
{
$usprocf @@_micro_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.micro
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_micro_int.sse
$else
  @@_micro_int.fpu
$end

; ------------------------------------------------------------------------------

; nano data modifier (n)
; double nano ( double v )
; v = rsp
; v:nano = v*1.0E-09

macro @@nano.sse
{
$usprocf @@nano

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.nano
    .return:
        retn
$endp
}

macro @@nano.fpu
{
$usprocf @@nano

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.nano
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nano.sse
$else
  @@nano.fpu
$end

; ------------------------------------------------------------------------------

; nano data modifier (n)
; double nano ( integer v )
; v = rsp
; v:nano = v*1.0E-09

macro @@_nano_int.sse
{
$usprocf @@_nano_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.nano
    .return:
        retn
$endp
}

macro @@_nano_int.fpu
{
$usprocf @@_nano_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.nano
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nano_int.sse
$else
  @@_nano_int.fpu
$end

; ------------------------------------------------------------------------------

; pico data modifier (p)
; double pico ( double v )
; v = rsp
; v:pico = v*1.0E-12

macro @@pico.sse
{
$usprocf @@pico

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.pico
    .return:
        retn
$endp
}

macro @@pico.fpu
{
$usprocf @@pico

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.pico
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pico.sse
$else
  @@pico.fpu
$end

; ------------------------------------------------------------------------------

; pico data modifier (p)
; double pico ( integer v )
; v = rsp
; v:pico = v*1.0E-12

macro @@_pico_int.sse
{
$usprocf @@_pico_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.pico
    .return:
        retn
$endp
}

macro @@_pico_int.fpu
{
$usprocf @@_pico_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.pico
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_pico_int.sse
$else
  @@_pico_int.fpu
$end

; ------------------------------------------------------------------------------

; femto data modifier (f)
; double femto ( double v )
; v = rsp
; v:femto = v*1.0E-15

macro @@femto.sse
{
$usprocf @@femto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.femto
    .return:
        retn
$endp
}

macro @@femto.fpu
{
$usprocf @@femto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.femto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@femto.sse
$else
  @@femto.fpu
$end

; ------------------------------------------------------------------------------

; femto data modifier (f)
; double femto ( integer v )
; v = rsp
; v:femto = v*1.0E-15

macro @@_femto_int.sse
{
$usprocf @@_femto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.femto
    .return:
        retn
$endp
}

macro @@_femto_int.fpu
{
$usprocf @@_femto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.femto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_femto_int.sse
$else
  @@_femto_int.fpu
$end

; ------------------------------------------------------------------------------

; atto data modifier (a)
; double atto ( double v )
; v = rsp
; v:atto = v*1.0E-18

macro @@atto.sse
{
$usprocf @@atto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.atto
    .return:
        retn
$endp
}

macro @@atto.fpu
{
$usprocf @@atto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.atto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@atto.sse
$else
  @@atto.fpu
$end

; ------------------------------------------------------------------------------

; atto data modifier (a)
; double atto ( integer v )
; v = rsp
; v:atto = v*1.0E-18

macro @@_atto_int.sse
{
$usprocf @@_atto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.atto
    .return:
        retn
$endp
}

macro @@_atto_int.fpu
{
$usprocf @@_atto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.atto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_atto_int.sse
$else
  @@_atto_int.fpu
$end

; ------------------------------------------------------------------------------

; zepto data modifier (z)
; double zepto ( double v )
; v = rsp
; v:zepto = v*1.0E-21

macro @@zepto.sse
{
$usprocf @@zepto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.zepto
    .return:
        retn
$endp
}

macro @@zepto.fpu
{
$usprocf @@zepto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.zepto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@zepto.sse
$else
  @@zepto.fpu
$end

; ------------------------------------------------------------------------------

; zepto data modifier (z)
; double zepto ( integer v )
; v = rsp
; v:zepto = v*1.0E-21

macro @@_zepto_int.sse
{
$usprocf @@_zepto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.zepto
    .return:
        retn
$endp
}

macro @@_zepto_int.fpu
{
$usprocf @@_zepto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.zepto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_zepto_int.sse
$else
  @@_zepto_int.fpu
$end

; ------------------------------------------------------------------------------

; yocto data modifier (y)
; double yocto ( double v )
; v = rsp
; v:yocto = v*1.0E-24

macro @@yocto.sse
{
$usprocf @@yocto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.yocto
    .return:
        retn
$endp
}

macro @@yocto.fpu
{
$usprocf @@yocto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.yocto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@yocto.sse
$else
  @@yocto.fpu
$end

; ------------------------------------------------------------------------------

; yocto data modifier (y)
; double yocto ( integer v )
; v = rsp
; v:yocto = v*1.0E-24

macro @@_yocto_int.sse
{
$usprocf @@_yocto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.yocto
    .return:
        retn
$endp
}

macro @@_yocto_int.fpu
{
$usprocf @@_yocto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.yocto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_yocto_int.sse
$else
  @@_yocto_int.fpu
$end

; ------------------------------------------------------------------------------

; ronto data modifier (r)
; double ronto ( double v )
; v = rsp
; v:ronto = v*1.0E-27

macro @@ronto.sse
{
$usprocf @@ronto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.ronto
    .return:
        retn
$endp
}

macro @@ronto.fpu
{
$usprocf @@ronto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.ronto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ronto.sse
$else
  @@ronto.fpu
$end

; ------------------------------------------------------------------------------

; ronto data modifier (r)
; double ronto ( integer v )
; v = rsp
; v:ronto = v*1.0E-27

macro @@_ronto_int.sse
{
$usprocf @@_ronto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.ronto
    .return:
        retn
$endp
}

macro @@_ronto_int.fpu
{
$usprocf @@_ronto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.ronto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_ronto_int.sse
$else
  @@_ronto_int.fpu
$end

; ------------------------------------------------------------------------------

; quecto data modifier (q)
; double quecto ( double v )
; v = rsp
; v:quecto = v*1.0E-30

macro @@quecto.sse
{
$usprocf @@quecto

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.quecto
    .return:
        retn
$endp
}

macro @@quecto.fpu
{
$usprocf @@quecto

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.quecto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quecto.sse
$else
  @@quecto.fpu
$end

; ------------------------------------------------------------------------------

; quecto data modifier (q)
; double quecto ( integer v )
; v = rsp
; v:quecto = v*1.0E-30

macro @@_quecto_int.sse
{
$usprocf @@_quecto_int

       cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.quecto
    .return:
        retn
$endp
}

macro @@_quecto_int.fpu
{
$usprocf @@_quecto_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.quecto
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quecto_int.sse
$else
  @@_quecto_int.fpu
$end

; ------------------------------------------------------------------------------
