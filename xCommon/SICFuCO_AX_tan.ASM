
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
; http://www.moshier.net/double.zip/tan.c
; Circular tangent
; Circular cotangent

; tan(x) = x + (x^3)*P(x^2)/Q(x^2)
;        = x*(1 + (x^2)*P(x^2)/Q(x^2))
;        = x*(1 + P'(x^2)/Q(x^2))
; 0 <= x < pi/4
;
; P =      -1.79565251976484877988E+7 +
;   (x^2)*( 1.15351664838587416140E+6 +
;   (x^2)*(-1.30936939181383777646E+4 ))
;
; P' =      0.00000000000000000000E+0 +
;   (x^2)*(-1.79565251976484877988E+7 +
;   (x^2)*( 1.15351664838587416140E+6 +
;   (x^2)*(-1.30936939181383777646E+4 +
;   (x^2)*( 0.00000000000000000000E+0 ))))
;
; Q =      -5.38695755929454629881E+7 +
;   (x^2)*( 2.50083801823357915839E+7 +
;   (x^2)*(-1.32089234440210967447E+6 +
;   (x^2)*( 1.36812963470692954678E+4 +
;   (x^2)*( 1.00000000000000000000E+0 ))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$align 16
??.PD_ftan_PQ:
v64bit  ??.PD_ftan_P0 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_ftan_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_ftan_P1 , 0xC0C992D8D24F3F38 ,\ ; -1.30936939181383777646E4
        ??.PD_ftan_Q1 , 0x40CAB8A5EEB36572 ,\ ;  1.36812963470692954678E4
        ??.PD_ftan_P2 , 0x413199ECA5FC9DDD ,\ ;  1.15351664838587416140E6
        ??.PD_ftan_Q2 , 0xC13427BC582ABC96 ,\ ; -1.32089234440210967447E6
        ??.PD_ftan_P3 , 0xC1711FEAD3299176 ,\ ; -1.79565251976484877988E7
        ??.PD_ftan_Q3 , 0x4177D98FC2EAD8EF ,\ ;  2.50083801823357915839E7
        ??.PD_ftan_P4 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_ftan_Q4 , 0xC189AFE03CBE5A31    ; -5.38695755929454629881E7

$align 16
??.SD_ftan_Pn:
v64bit  ??.SD_ftan_P0 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_ftan_P1 , 0xC0C992D8D24F3F38 ,\ ; -1.30936939181383777646E4
        ??.SD_ftan_P2 , 0x413199ECA5FC9DDD ,\ ;  1.15351664838587416140E6
        ??.SD_ftan_P3 , 0xC1711FEAD3299176 ,\ ; -1.79565251976484877988E7
        ??.SD_ftan_P4 , 0x0000000000000000    ;  0.0

$align 16
??.SD_ftan_Qn:
v64bit  ??.SD_ftan_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_ftan_Q1 , 0x40CAB8A5EEB36572 ,\ ;  1.36812963470692954678E4
        ??.SD_ftan_Q2 , 0xC13427BC582ABC96 ,\ ; -1.32089234440210967447E6
        ??.SD_ftan_Q3 , 0x4177D98FC2EAD8EF ,\ ;  2.50083801823357915839E7
        ??.SD_ftan_Q4 , 0xC189AFE03CBE5A31    ; -5.38695755929454629881E7

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_ftan_max_arg , 0x43D921FB54442D18 ; 7244019458077122841.5989278935877 = (2^63-1)*PI/4
;       ??.SD_ftan_max_arg , 0x43D0000000000000 ; 2^(+62) = 4611686018427387904
vdup    ??.SD_ftan_max_arg ,\
        ??.SD_fcot_max_arg

v64bit  ??.SD_ftan_min_arg , 0xC3D921FB54442D18 ; -7244019458077122842.3843260569851 = -(2^63)*PI/4
vdup    ??.SD_ftan_min_arg ,\
        ??.SD_fcot_min_arg

v64bit  ??.SX_ftan_eps     , 0x3E50000000000000 ; 2^(-26) = 0.000000014901161193847656250
; tan(x) = x, |x| <= eps
; tan(x) = x, x.exp < -26

; ------------------------------------------------------------------------------
