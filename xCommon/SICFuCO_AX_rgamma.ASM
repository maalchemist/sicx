
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; function constants

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/rgamma.c
; Reciprocal gamma function

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$align 16
??.SD_frgamma_Rn:
v64bit  ??.SD_frgamma_R00 , 0x3C820D9FDFBD2E74 ,\ ;  3.13173458231230000000E-17
        ??.SD_frgamma_R01 , 0xBCC82A498888964D ,\ ; -6.70718606477908000000E-16
        ??.SD_frgamma_R02 , 0x3CE3D1C175A886DE ,\ ;  2.20039078172259550000E-15
        ??.SD_frgamma_R03 , 0x3D516E04074F9C9A ,\ ;  2.47691630348254132600E-13
        ??.SD_frgamma_R04 , 0xBD9D07C60FFFB490 ,\ ; -6.60074100411295197440E-12
        ??.SD_frgamma_R05 , 0x3DCC3FCC67F7B14D ,\ ;  5.13850186324226978840E-11
        ??.SD_frgamma_R06 , 0x3E12B8592F40B364 ,\ ;  1.08965386454418662084E-09
        ??.SD_frgamma_R07 , 0xBE61EDF99543633A ,\ ; -3.33964630686836942556E-08
        ??.SD_frgamma_R08 , 0x3E920CF8F155DAB4 ,\ ;  2.68975996440595483619E-07
        ??.SD_frgamma_R09 , 0x3EC8D493AEBDFE05 ,\ ;  2.96001177518801696639E-06
        ??.SD_frgamma_R10 , 0xBF1519042371E38C ,\ ; -8.04814124978471142852E-05
        ??.SD_frgamma_R11 , 0x3F3B4D8AA03FC192 ,\ ;  4.16609138709688864714E-04
        ??.SD_frgamma_R12 , 0x3F74BFDFF7CF7663 ,\ ;  5.06579864028608725080E-03
        ??.SD_frgamma_R13 , 0xBFB06EEC2B74B84D ,\ ; -6.41925436109158228810E-02
        ??.SD_frgamma_R14 , 0xBF746BC46592C3DE ,\ ; -4.98558728684003594785E-03
        ??.SD_frgamma_R15 , 0x3FC0536D86E42299    ;  1.27546015610523951063E-01

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_frgamma_max_arg , 0x406573FAE561F647 ; 171.6243769563027209
;       ??.SD_frgamma_max_arg , 0x406573FAE561F647 ; 171.624376956302725
;       ??.SD_frgamma_max_arg , 0x4065733333333333 ; 171.6
; x >= max_arg : rgamma(x) = 0

v64bit  ??.SD_frgamma_min_arg , 0xC06573FAE561F647 ; -171.6243769563027209
;       ??.SD_frgamma_min_arg , 0xC06573FAE561F647 ; -171.624376956302725
;       ??.SD_frgamma_min_arg , 0xC065400000000000 ; -170.0
; x <= max_arg : rgamma(x) = PInf or NInf

macro c
{
v64bit  ??.SD_frgamma_min_arg , 0xFF574C5DD06D2516 ; -2.556348E+305
; x <= max_arg : rgamma(x) = PInf or NInf
}

v64bit  ??.SD_frgamma_34.8  , 0x40416C1096EC7FB0 ;  34.84425627277176174
v64bit  ??.SD_frgamma_m34.0 , 0xC041045A1CAC0831 ; -34.034

; ------------------------------------------------------------------------------
