
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
; http://www.moshier.net/double.zip/gamma.c
; Gamma function

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$align 16
??.PD_ftgamma_PQ:
v64bit  ??.PD_ftgamma_P0 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_ftgamma_Q0 , 0xBEF8487A8400D3AF ,\ ; -2.31581873324120129819E-5
        ??.PD_ftgamma_P1 , 0x3F24FCB839982153 ,\ ;  1.60119522476751861407E-4
        ??.PD_ftgamma_Q1 , 0x3F41AE8A29152573 ,\ ;  5.39605580493303397842E-4
        ??.PD_ftgamma_P2 , 0x3F5384E3E686BFAB ,\ ;  1.19135147006586384913E-3
        ??.PD_ftgamma_Q2 , 0xBF7240E4E750B44A ,\ ; -4.45641913851797240494E-3
        ??.PD_ftgamma_P3 , 0x3F8557CDE9DB14AF ,\ ;  1.04213797561761569935E-2
        ??.PD_ftgamma_Q3 , 0x3F8831ED5B1BB117 ,\ ;  1.18139785222060435552E-2
        ??.PD_ftgamma_P4 , 0x3FA863D918C423D3 ,\ ;  4.76367800457137231464E-2
        ??.PD_ftgamma_Q4 , 0x3FA25779E33FDE67 ,\ ;  3.58236398605498653373E-2
        ??.PD_ftgamma_P5 , 0x3FCA8DA9DCAE7D31 ,\ ;  2.07448227648435975150E-1
        ??.PD_ftgamma_Q5 , 0xBFCE071A9D4287C2 ,\ ; -2.34591795718243348568E-1
        ??.PD_ftgamma_P6 , 0x3FDFA1373993E312 ,\ ;  4.94214826801497100753E-1
        ??.PD_ftgamma_Q6 , 0x3FB24944C9CD3C51 ,\ ;  7.14304917030273074085E-2
        ??.PD_ftgamma_P7 , 0x3FF0000000000000 ,\ ;  9.99999999999999996796E-1
        ??.PD_ftgamma_Q7 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_ftgamma_Pn:
v64bit  ??.SD_ftgamma_P0 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_ftgamma_P1 , 0x3F24FCB839982153 ,\ ;  1.60119522476751861407E-4
        ??.SD_ftgamma_P2 , 0x3F5384E3E686BFAB ,\ ;  1.19135147006586384913E-3
        ??.SD_ftgamma_P3 , 0x3F8557CDE9DB14AF ,\ ;  1.04213797561761569935E-2
        ??.SD_ftgamma_P4 , 0x3FA863D918C423D3 ,\ ;  4.76367800457137231464E-2
        ??.SD_ftgamma_P5 , 0x3FCA8DA9DCAE7D31 ,\ ;  2.07448227648435975150E-1
        ??.SD_ftgamma_P6 , 0x3FDFA1373993E312 ,\ ;  4.94214826801497100753E-1
        ??.SD_ftgamma_P7 , 0x3FF0000000000000    ;  9.99999999999999996796E-1

$align 16
??.SD_ftgamma_Qn:
v64bit  ??.SD_ftgamma_Q0 , 0xBEF8487A8400D3AF ,\ ; -2.31581873324120129819E-5
        ??.SD_ftgamma_Q1 , 0x3F41AE8A29152573 ,\ ;  5.39605580493303397842E-4
        ??.SD_ftgamma_Q2 , 0xBF7240E4E750B44A ,\ ; -4.45641913851797240494E-3
        ??.SD_ftgamma_Q3 , 0x3F8831ED5B1BB117 ,\ ;  1.18139785222060435552E-2
        ??.SD_ftgamma_Q4 , 0x3FA25779E33FDE67 ,\ ;  3.58236398605498653373E-2
        ??.SD_ftgamma_Q5 , 0xBFCE071A9D4287C2 ,\ ; -2.34591795718243348568E-1
        ??.SD_ftgamma_Q6 , 0x3FB24944C9CD3C51 ,\ ;  7.14304917030273074085E-2
        ??.SD_ftgamma_Q7 , 0x3FF0000000000000    ;  1.0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Stirling's formula for the gamma function
;
; gamma(x) = sqrt(2*pi) * (x)^(x-0.5) * exp(-x) * (1 + 1/x * P(1/x)) 
;          = sqrt(2*pi/e) * (x/e)^(x-0.5) * (1 + 1/x * P(1/x)) 

$align 16
??.PD_fsgamma_STIRn:
v64bit  ??.PD_fsgamma_STIR0 , 0x3F49CC72592D7293 ,\ ;  7.87311395793093628397E-4
        ??.PD_fsgamma_STIR3 , 0x3F6C71C71B98C5FD ,\ ;  3.47222221605458667310E-3
        ??.PD_fsgamma_STIR1 , 0xBF2E166B27E61D7C ,\ ; -2.29549961613378126380E-4
        ??.PD_fsgamma_STIR4 , 0x3FB5555555555986 ,\ ;  8.33333333333482257126E-2
        ??.PD_fsgamma_STIR2 , 0xBF65F72607D44FD7 ,\ ; -2.68132617805781232825E-3
        ??.PD_fsgamma_STIR5 , 0x3FF0000000000000    ;  1.0

$align 16
??.PD_fsgamma_ESTIRn:
v64bit  ??.PD_fsgamma_ESTIR0 , 0x3F539C86677A8CC5 ,\ ;  1.196986440768197968717E-3
        ??.PD_fsgamma_ESTIR3 , 0x3F759F6A04645967 ,\ ;  5.278982285992084981027E-3
        ??.PD_fsgamma_ESTIR1 , 0xBF36DF2C925007B1 ,\ ; -3.489955727787831509669E-4
        ??.PD_fsgamma_ESTIR4 , 0x3FC0378F83C6FEBF ,\ ;  1.266955750888793753837E-1
        ??.PD_fsgamma_ESTIR2 , 0xBF70B2917844DE1E ,\ ; -4.076545945558089631285E-3
        ??.PD_fsgamma_ESTIR5 , 0x3FF8535745AA7957    ;  1.520346901066280805612E+0

$align 16
??.SD_fsgamma_STIRn:
v64bit  ??.SD_fsgamma_STIR0 , 0x3F49CC72592D7293 ,\ ;  7.87311395793093628397E-4
        ??.SD_fsgamma_STIR1 , 0xBF2E166B27E61D7C ,\ ; -2.29549961613378126380E-4
        ??.SD_fsgamma_STIR2 , 0xBF65F72607D44FD7 ,\ ; -2.68132617805781232825E-3
        ??.SD_fsgamma_STIR3 , 0x3F6C71C71B98C5FD ,\ ;  3.47222221605458667310E-3
        ??.SD_fsgamma_STIR4 , 0x3FB5555555555986 ,\ ;  8.33333333333482257126E-2
        ??.SD_fsgamma_STIR5 , 0x3FF0000000000000    ;  1.0

; STIRn * SQRT(2*PI/E)
$align 16
??.SD_fsgamma_ESTIRn:
v64bit  ??.SD_fsgamma_ESTIR0 , 0x3F539C86677A8CC5 ,\ ;  1.196986440768197968717E-3
        ??.SD_fsgamma_ESTIR1 , 0xBF36DF2C925007B1 ,\ ; -3.489955727787831509669E-4
        ??.SD_fsgamma_ESTIR2 , 0xBF70B2917844DE1E ,\ ; -4.076545945558089631285E-3
        ??.SD_fsgamma_ESTIR3 , 0x3F759F6A04645967 ,\ ;  5.278982285992084981027E-3
        ??.SD_fsgamma_ESTIR4 , 0x3FC0378F83C6FEBF ,\ ;  1.266955750888793753837E-1
        ??.SD_fsgamma_ESTIR5 , 0x3FF8535745AA7957    ;  1.520346901066280805612E+0

macro c
{
; STIRn * SQRT(2*PI)
$align 16
??.SD_fsgamma_FSTIRn:
v64bit  ??.SD_fsgamma_FSTIR0 , 0x3F602AB923226DA6 ,\ ;  1.973497005634167029172E-3
        ??.SD_fsgamma_FSTIR1 , 0xBF42DAC66981700A ,\ ; -5.753964242205544093448E-4
        ??.SD_fsgamma_FSTIR2 , 0xBF7B8792533DEF66 ,\ ; -6.721088011427988954072E-3
        ??.SD_fsgamma_FSTIR3 , 0x3F81D32D71365ED1 ,\ ;  8.703570382564337645006E-3
        ??.SD_fsgamma_FSTIR4 , 0x3FCABCC42A9D8E9E ,\ ;  2.088856895526207048603E-1
        ??.SD_fsgamma_FSTIR5 , 0x40040D931FF62706    ;  2.506628274631000502416E+0
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro comment 
{
$align 16
??.PD_fsgammaL_ESTIRn:
v64bit  ??.PD_fsgammaL_ESTIR0 , 0x3F51CDBF178C7081 ,\ ;  1.086651433246849265499E-3
        ??.PD_fsgammaL_ESTIR5 , 0xBF36DD2F547C3667 ,\ ; -3.488770057494594646096E-4
        ??.PD_fsgammaL_ESTIR1 , 0xBF02D79C66F48005 ,\ ; -3.593870212115216546984E-5
        ??.PD_fsgammaL_ESTIR6 , 0xBF70B291DF0E4C86 ,\ ; -4.076547441303485292075E-3
        ??.PD_fsgammaL_ESTIR2 , 0xBF4DA4B10648FE95 ,\ ; -9.046425225917748070800E-4
        ??.PD_fsgammaL_ESTIR7 , 0x3F759F6A0509852F ,\ ;  5.278982295380970019853E-3
        ??.PD_fsgammaL_ESTIR3 , 0x3F1BDB20EA77001D ,\ ;  1.062620964296105464050E-4
        ??.PD_fsgammaL_ESTIR8 , 0x3FC0378F83C6FB8E ,\ ;  1.266955750888567104967E-1
        ??.PD_fsgammaL_ESTIR4 , 0x3F53879F58377FBA ,\ ;  1.192002878148897127308E-3
        ??.PD_fsgammaL_ESTIR9 , 0x3FF8535745AA7957    ;  1.520346901066280805612E+0

; STIRn * SQRT(2*PI/E)
$align 16
??.SD_fsgammaL_ESTIRn:
v64bit  ??.SD_fsgammaL_ESTIR0 , 0x3F51CDBF178C7081 ,\ ;  1.086651433246849265499E-3
        ??.SD_fsgammaL_ESTIR1 , 0xBF02D79C66F48005 ,\ ; -3.593870212115216546984E-5
        ??.SD_fsgammaL_ESTIR2 , 0xBF4DA4B10648FE95 ,\ ; -9.046425225917748070800E-4
        ??.SD_fsgammaL_ESTIR3 , 0x3F1BDB20EA77001D ,\ ;  1.062620964296105464050E-4
        ??.SD_fsgammaL_ESTIR4 , 0x3F53879F58377FBA ,\ ;  1.192002878148897127308E-3
        ??.SD_fsgammaL_ESTIR5 , 0xBF36DD2F547C3667 ,\ ; -3.488770057494594646096E-4
        ??.SD_fsgammaL_ESTIR6 , 0xBF70B291DF0E4C86 ,\ ; -4.076547441303485292075E-3
        ??.SD_fsgammaL_ESTIR7 , 0x3F759F6A0509852F ,\ ;  5.278982295380970019853E-3
        ??.SD_fsgammaL_ESTIR8 , 0x3FC0378F83C6FB8E ,\ ;  1.266955750888567104967E-1
        ??.SD_fsgammaL_ESTIR9 , 0x3FF8535745AA7957    ;  1.520346901066280805612E+0

$align 16
??.SD_fsgammaL_STIRn:
v64bit  ??.SD_fsgammaL_STIR0 , 0x3F476BAA9C6D3EEE ,\ ;  7.147391378143610789273E-4
        ??.SD_fsgammaL_STIR1 , 0xBEF8C968886052B8 ,\ ; -2.363848809501759061727E-5
        ??.SD_fsgammaL_STIR2 , 0xBF437F6BC8EF8B37 ,\ ; -5.950237554056330156018E-4
        ??.SD_fsgammaL_STIR3 , 0x3F12527623A3472B ,\ ;  6.989332260623193171870E-5
        ??.SD_fsgammaL_STIR4 , 0x3F49B0F316434426 ,\ ;  7.840334842744753003862E-4
        ??.SD_fsgammaL_STIR5 , 0xBF2E13CD410E0478 ,\ ; -2.294719747873185405699E-4
        ??.SD_fsgammaL_STIR6 , 0xBF65F7268F0B5907 ,\ ; -2.681327161876304418288E-3
        ??.SD_fsgammaL_STIR7 , 0x3F6C71C71C720DD8 ,\ ;  3.472222222230075327854E-3
        ??.SD_fsgammaL_STIR8 , 0x3FB5555555555554 ,\ ;  8.333333333333331800504E-2
        ??.SD_fsgammaL_STIR9 , 0x3FF0000000000000    ;  1.0
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; A[]      : Stirling's formula expansion of log gamma
; T[]      : log gamma function, x > 1000
; B[], C[] : log gamma function, x between 2 and 3

$align 16
??.SD_flgamma_An:
v64bit  ??.SD_flgamma_A0 , 0x3F4A985027336661 ,\ ;  8.11614167470508450300E-4
        ??.SD_flgamma_A1 , 0xBF437FBDB580E943 ,\ ; -5.95061904284301438324E-4
        ??.SD_flgamma_A2 , 0x3F4A019F20DC5EBB ,\ ;  7.93650340457716943945E-4
        ??.SD_flgamma_A3 , 0xBF66C16C16B0A5A1 ,\ ; -2.77777777730099687205E-3
        ??.SD_flgamma_A4 , 0x3FB555555555554B    ;  8.33333333333331927722E-2

$align 16
??.SD_flgamma_Tn:
v64bit  ??.SD_flgamma_T0 , 0x3F4A01A01A01A01A ,\ ;  7.9365079365079365079365E-4 |  1/1260
        ??.SD_flgamma_T1 , 0xBF66C16C16C16C17 ,\ ; -2.7777777777777777777778E-3 | -1/360
        ??.SD_flgamma_T2 , 0x3FB5555555555555    ;  0.0833333333333333333333E+0 |  1/12

$align 16
??.SD_flgamma_4Tn:
v64bit  ??.SD_flgamma_4T0 , 0xBF43813813813814 ,\ ; -5.9523809523809523809524E-4 | -1/1680
        ??.SD_flgamma_4T1 , 0x3F4A01A01A01A01A ,\ ;  7.9365079365079365079365E-4 |  1/1260
        ??.SD_flgamma_4T2 , 0xBF66C16C16C16C17 ,\ ; -2.7777777777777777777778E-3 | -1/360
        ??.SD_flgamma_4T3 , 0x3FB5555555555555    ;  0.0833333333333333333333E+0 |  1/12

$align 16
??.SD_flgamma_8Tn:
v64bit  ??.SD_flgamma_8T0 , 0xBF9E4286CB0F5398 ,\ ; -2.9550653594771241830065E-2 | -3617/122400
        ??.SD_flgamma_8T1 , 0x3F7A41A41A41A41A ,\ ;  6.4102564102564102564103E-3 |  1/156
        ??.SD_flgamma_8T2 , 0xBF5F6AB0D9993C7D ,\ ; -1.9175269175269175269175E-3 | -691/360360
        ??.SD_flgamma_8T3 , 0x3F4B951E2B18FF23 ,\ ;  8.4175084175084175084175E-4 |  1/1188
        ??.SD_flgamma_8T4 , 0xBF43813813813814 ,\ ; -5.9523809523809523809524E-4 | -1/1680
        ??.SD_flgamma_8T5 , 0x3F4A01A01A01A01A ,\ ;  7.9365079365079365079365E-4 |  1/1260
        ??.SD_flgamma_8T6 , 0xBF66C16C16C16C17 ,\ ; -2.7777777777777777777778E-3 | -1/360
        ??.SD_flgamma_8T7 , 0x3FB5555555555555    ;  0.0833333333333333333333E+0 |  1/12

$align 16
??.PD_flgamma_BC:
v64bit  ??.PD_flgamma_B0 , 0xC09589018FF36761 ,\ ; -1.37825152569120859100E+3
        ??.PD_flgamma_C0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_flgamma_B1 , 0xC0E2F234355BB93E ,\ ; -3.88016315134637840924E+4
        ??.PD_flgamma_C1 , 0xC075FD0D1CF312B2 ,\ ; -3.51815701436523470549E+2
        ??.PD_flgamma_B2 , 0xC1143D73F89089E5 ,\ ; -3.31612992738871184744E+5
        ??.PD_flgamma_C2 , 0xC0D0AA0D7B89D757 ,\ ; -1.70642106651881159223E+4
        ??.PD_flgamma_B3 , 0xC131BC82F994DB51 ,\ ; -1.16237097492762307383E+6
        ??.PD_flgamma_C3 , 0xC10AEB84B9744C9B ,\ ; -2.20528590553854454839E+5
        ??.PD_flgamma_B4 , 0xC13A45890219F20B ,\ ; -1.72173700820839662146E+6
        ??.PD_flgamma_C4 , 0xC131628671950043 ,\ ; -1.13933444367982507207E+6
        ??.PD_flgamma_B5 , 0xC12A0C675418055E ,\ ; -8.53555664245765465627E+5
        ??.PD_flgamma_C5 , 0xC1435255892FF34C ,\ ; -2.53252307177582951285E+6
        ??.PD_flgamma_B6 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_flgamma_C6 , 0xC13ECE4B6A11E14A    ; -2.01889141433532773231E+6

$align 16
??.SD_flgamma_Bn:
v64bit  ??.SD_flgamma_B0 , 0xC09589018FF36761 ,\ ; -1.37825152569120859100E+3
        ??.SD_flgamma_B1 , 0xC0E2F234355BB93E ,\ ; -3.88016315134637840924E+4
        ??.SD_flgamma_B2 , 0xC1143D73F89089E5 ,\ ; -3.31612992738871184744E+5
        ??.SD_flgamma_B3 , 0xC131BC82F994DB51 ,\ ; -1.16237097492762307383E+6
        ??.SD_flgamma_B4 , 0xC13A45890219F20B ,\ ; -1.72173700820839662146E+6
        ??.SD_flgamma_B5 , 0xC12A0C675418055E ,\ ; -8.53555664245765465627E+5
        ??.SD_flgamma_B6 , 0x0000000000000000    ;  0.0

$align 16
??.SD_flgamma_Cn:
v64bit  ??.SD_flgamma_C0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_flgamma_C1 , 0xC075FD0D1CF312B2 ,\ ; -3.51815701436523470549E+2
        ??.SD_flgamma_C2 , 0xC0D0AA0D7B89D757 ,\ ; -1.70642106651881159223E+4
        ??.SD_flgamma_C3 , 0xC10AEB84B9744C9B ,\ ; -2.20528590553854454839E+5
        ??.SD_flgamma_C4 , 0xC131628671950043 ,\ ; -1.13933444367982507207E+6
        ??.SD_flgamma_C5 , 0xC1435255892FF34C ,\ ; -2.53252307177582951285E+6
        ??.SD_flgamma_C6 , 0xC13ECE4B6A11E14A    ; -2.01889141433532773231E+6

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_fsgamma_max_arg  , 0x406573FAE561F647 ; 171.624376956302725
;       ??.SD_fsgamma_max_arg  , 0x406573FAE561F647 ; 171.6243769563027209
;       ??.SD_fsgamma_max_arg  , 0x4065733333333333 ; 171.6
; x >= max_arg : sgamma(x) = PInf

v64bit  ??.SD_fsgamma_min_arg , 0x34322EEAFC74334A ; 2.89676253E-57
; 0 < x <= min_arg : sgamma(x) = PInf

; SSE
; sgamma (2.89676252250726662e-57) = 0x7FEFFFFFFFFFFFF4
; sgamma (2.89676252250726661e-57) = undefined

; FPU
; sgamma (2.8967625225072735e-57)  = 0x7FEFFFFFFFFFFFFF
; sgamma (2.8967625225072734e-57)  = undefined

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_ftgamma_max_arg  , 0x406573FAE561F647 ; 171.6243769563027209
;       ??.SD_ftgamma_max_arg  , 0x406573FAE561F647 ; 171.624376956302725
;       ??.SD_ftgamma_max_arg  , 0x4065733333333333 ; 171.6
; x >= max_arg : tgamma(x) = PInf
;
; tgamma(171.6243769563027208) = 0x7FEFFFFFFFFFFFFF = 1.797693134862315792688E+308
;                                                     1.7976931348623157926879559168855812764983781098142357E+308
; tgamma(171.6243769563027209) = undefined          = 1.797693134862316717132E+308
;                                                     1.7976931348623167171322472257289542374869179826141375E+308
; 171.6243769563027209   = 0x406573FAE561F647
; 171.624376956302697296 = 0x406573FAE561F647
; 171.624376956302697295 = 0x406573FAE561F646

v64bit  ??.SD_ftgamma_min_arg  , 0xC06573FAE561F647 ; -171.6243769563027209
;       ??.SD_ftgamma_min_arg  , 0xC06573FAE561F647 ; -171.624376956302725
;       ??.SD_ftgamma_min_arg  , 0xC065400000000000 ; -170.0
; x <= max_arg : tgamma(x) = +0 or -0

v64bit  ??.SD_ftgamma_STIR_max , 0x4061E083BA3443D4 ; 143.01608

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_flgamma_max_arg , 0x7F574C5DD06D2516 ; +2.556348E+305
; x >= max_arg : lgamma(x) = PInf

v64bit  ??.SD_flgamma_min_arg , 0xFF574C5DD06D2516 ; -2.556348E+305
; x <= max_arg : lgamma(x) = NInf or NaN

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_fbeta_maxgam , 0x40416C1096EC7FB0 ; 34.84425627277176174

; ------------------------------------------------------------------------------
