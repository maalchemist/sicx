
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; function constants

; Copyright � 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/asin.c
; Inverse circular sine
; Inverse circular cosine

; asin(x) = x + (x^3)*P(x^2)/Q(x^2)
;         = x*(1 + (x^2)*P(x^2)/Q(x^2))
;         = x*(1 + P'(x^2)/Q(x^2))
; |x| <= 0.5
;
; asin(x) = pi/2 - 2*asin(sqrt((1-x)/2))
; |x| > 0.5
;
; P =      -8.198089802484824371615E+0 +
;   (x^2)*( 1.956261983317594739197E+1 +
;   (x^2)*(-1.626247967210700244449E+1 +
;   (x^2)*( 5.444622390564711410273E+0 +
;   (x^2)*(-6.019598008014123785661E-1 +
;   (x^2)*( 4.253011369004428248960E-3 )...)
;
; Q =      -4.918853881490881290097E+1 +
;   (x^2)*( 1.395105614657485689735E+2 +
;   (x^2)*(-1.471791292232726029859E+2 +
;   (x^2)*( 7.049610280856842141659E+1 +
;   (x^2)*(-1.474091372988853791896E+1 +
;   (x^2)*( 1.000000000000000000000E+0 )...)

; asin(x) = pi/2 - sqrt(2*z)*(1 + z*R(z)/S(z))
;         = pi/2 - sqrt(2*z)*(1 + R'(z)/S(z))
; z = 1-x
; |x| > 0.625
;
; R =     2.853665548261061424989E+1 +
;   (x)*(-2.556901049652824852289E+1 +
;   (x)*( 6.968710824104713396794E+0 +
;   (x)*(-5.634242780008963776856E-1 +
;   (x)*( 2.967721961301243206100E-3 )...)
;
; S =     3.424398657913078477438E+2 +
;   (x)*(-3.838770957603691357202E+2 +
;   (x)*( 1.470656354026814941758E+2 +
;   (x)*(-2.194779531642920639778E+1 +
;   (x)*( 1.000000000000000000000E+0 )...)

; acos(x) = pi/2 - asin(x)
; |x| <= 0.5
;
; acos(x) = 2*asin(sqrt((1-x)/2))
; x > 0.5
;
; acos(x) = pi - 2*asin(sqrt((1+x)/2))
; x < -0.5

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$align 16
??.PD_fasin_PQ:
v64bit  ??.PD_fasin_P0 , 0x3F716B9B0BD48AD3 ,\ ;  4.253011369004428248960E-3
        ??.PD_fasin_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fasin_P1 , 0xBFE34341333E5C16 ,\ ; -6.019598008014123785661E-1
        ??.PD_fasin_Q1 , 0xC02D7B590B5E0EAB ,\ ; -1.474091372988853791896E+1
        ??.PD_fasin_P2 , 0x4015C74B178A2DD9 ,\ ;  5.444622390564711410273E+0
        ??.PD_fasin_Q2 , 0x40519FC025FE9054 ,\ ;  7.049610280856842141659E+1
        ??.PD_fasin_P3 , 0xC0304331DE27907B ,\ ; -1.626247967210700244449E+1
        ??.PD_fasin_Q3 , 0xC06265BB6D3576D7 ,\ ; -1.471791292232726029859E+2
        ??.PD_fasin_P4 , 0x40339007DA779259 ,\ ;  1.956261983317594739197E+1
        ??.PD_fasin_Q4 , 0x4061705684FFBF9D ,\ ;  1.395105614657485689735E+2
        ??.PD_fasin_P5 , 0xC020656C06CEAFD5 ,\ ; -8.198089802484824371615E+0
        ??.PD_fasin_Q5 , 0xC04898220A3607AC    ; -4.918853881490881290097E+1

$align 16
??.SD_fasin_Pn:
v64bit  ??.SD_fasin_P0 , 0x3F716B9B0BD48AD3 ,\ ;  4.253011369004428248960E-3
        ??.SD_fasin_P1 , 0xBFE34341333E5C16 ,\ ; -6.019598008014123785661E-1
        ??.SD_fasin_P2 , 0x4015C74B178A2DD9 ,\ ;  5.444622390564711410273E+0
        ??.SD_fasin_P3 , 0xC0304331DE27907B ,\ ; -1.626247967210700244449E+1
        ??.SD_fasin_P4 , 0x40339007DA779259 ,\ ;  1.956261983317594739197E+1
        ??.SD_fasin_P5 , 0xC020656C06CEAFD5    ; -8.198089802484824371615E+0

$align 16
??.SD_fasin_Qn:
v64bit  ??.SD_fasin_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fasin_Q1 , 0xC02D7B590B5E0EAB ,\ ; -1.474091372988853791896E+1
        ??.SD_fasin_Q2 , 0x40519FC025FE9054 ,\ ;  7.049610280856842141659E+1
        ??.SD_fasin_Q3 , 0xC06265BB6D3576D7 ,\ ; -1.471791292232726029859E+2
        ??.SD_fasin_Q4 , 0x4061705684FFBF9D ,\ ;  1.395105614657485689735E+2
        ??.SD_fasin_Q5 , 0xC04898220A3607AC    ; -4.918853881490881290097E+1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$align 16
??.PD_fasin_RS:
v64bit  ??.PD_fasin_R0 , 0x3F684FC3988E9F08 ,\ ;  2.967721961301243206100E-3
        ??.PD_fasin_S0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fasin_R1 , 0xBFE2079259F9290F ,\ ; -5.634242780008963776856E-1
        ??.PD_fasin_S1 , 0xC035F2A2B6BF5D8C ,\ ; -2.194779531642920639778E+1
        ??.PD_fasin_R2 , 0x401BDFF5BAF33E6A ,\ ;  6.968710824104713396794E+0
        ??.PD_fasin_S2 , 0x40626219AF6A7F42 ,\ ;  1.470656354026814941758E+2
        ??.PD_fasin_R3 , 0xC03991AAAC01AB68 ,\ ; -2.556901049652824852289E+1
        ??.PD_fasin_S3 , 0xC077FE08959063EE ,\ ; -3.838770957603691357202E+2
        ??.PD_fasin_R4 , 0x403C896240F3081D ,\ ;  2.853665548261061424989E+1
        ??.PD_fasin_S4 , 0x40756709B0B644BE    ;  3.424398657913078477438E+2

$align 16
??.SD_fasin_Rn:
v64bit  ??.SD_fasin_R0 , 0x3F684FC3988E9F08 ,\ ;  2.967721961301243206100E-3
        ??.SD_fasin_R1 , 0xBFE2079259F9290F ,\ ; -5.634242780008963776856E-1
        ??.SD_fasin_R2 , 0x401BDFF5BAF33E6A ,\ ;  6.968710824104713396794E+0
        ??.SD_fasin_R3 , 0xC03991AAAC01AB68 ,\ ; -2.556901049652824852289E+1
        ??.SD_fasin_R4 , 0x403C896240F3081D    ;  2.853665548261061424989E+1

$align 16
??.SD_fasin_Sn:
v64bit  ??.SD_fasin_S0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fasin_S1 , 0xC035F2A2B6BF5D8C ,\ ; -2.194779531642920639778E+1
        ??.SD_fasin_S2 , 0x40626219AF6A7F42 ,\ ;  1.470656354026814941758E+2
        ??.SD_fasin_S3 , 0xC077FE08959063EE ,\ ; -3.838770957603691357202E+2
        ??.SD_fasin_S4 , 0x40756709B0B644BE    ;  3.424398657913078477438E+2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; pi/2 = PIO2 + MOREBITS

v64bit  ??.SD_fasin_more.bits   , 0x3C91A62633145C07 ; 6.123233995736765886130E-17
v64bit  ??.SD_fasin_more.bits.2 , 0x3C81A62633145C07 ; 3.061616997868382943065E-17 | more.bits / 2
v64bit  ??.SD_fasin_2.more.bits , 0x3CA1A62633145C07 ; 1.224646799147353177226E-16 | 2 * more.bits

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SX_fasin_eps , 0x3E50000000000000 ; 2^(-26) = 0.000000014901161193847656250
; asin(x) = x, |x| <= eps
; asin(x) = x, x.exp < -26

v64bit  ??.SX_facos_eps , 0x3CA0000000000000 ; 2^(-53) = 1.1102230246251565404236316680908e-16
; acos(x) = pi/2, |x| <= eps
; acos(x) = pi/2, x.exp < -53

; ------------------------------------------------------------------------------
