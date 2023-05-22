
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; export functions

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_EX:

include 'SICEX.INC'

; ------------------------------------------------------------------------------

; normal distribution function
@@.sic_export.DV sic_cdfnorm, @@fndtr.enter

; error function
@@.sic_export.DV sic_erf, @@ferf.enter

; complementary error function
@@.sic_export.DV sic_erfc, @@ferfc.enter

; inverse of normal distribution function
@@.sic_export.DV sic_cdfnorminv, @@fndtri.enter

; inverse error function
@@.sic_export.DV sic_erfinv, @@ferfi.enter

; inverse complementary error function
@@.sic_export.DV sic_erfcinv, @@ferfci.enter

; gamma function
@@.sic_export.DV sic_tgamma, @@ftgamma.enter

; natural logarithm of the absolute value of gamma function
@@.sic_export.DV sic_lgamma, @@flgamma.enter

; natural logarithm of the absolute value and the sign of gamma function
@@.sic_export.DV.IO sic_lgammas, @@flgamma.enter, xdi

; reciprocal gamma function
@@.sic_export.DV sic_rgamma, @@frgamma.enter

; reciprocal gamma function
@@.sic_export.DV sic_rtgamma, @@frtgamma.enter

; beta function
@@.sic_export.DV.DV sic_beta, @@fbeta.enter

; ------------------------------------------------------------------------------

macro comment
{
; sine
@@.sic_export.DV sic_sin, @@fsin.enter

; cosine
@@.sic_export.DV sic_cos, @@fcos.enter

; atan2
@@.sic_export.DV.DV sic_atan2, @@fatan2.enter
}

; ------------------------------------------------------------------------------
