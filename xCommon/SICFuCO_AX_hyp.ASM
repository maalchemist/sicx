
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

; sinh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Pade approximation sinh(x) order 18,17
; https://www.wolframalpha.com/input/?i=Pade+approximation+sinh(x)+order+18,17
; https://keisan.casio.com/calculator

; sinh(x) = x*P(x^2)/Q(x^2)
; |x| < 5.0 (5.92)

; x = -5.92
;  sinh(x) = 0xC067468B61A7291A = -1.862045143380026387643E+2
; fsinh(x) = 0xC067468B61A7291A
;
; x = 5.91
;  sinh(x) = 0x40670B414DAE3198 =  1.843517216112347864968E+2
; fsinh(x) = 0x40670B414DAE3198
;
; x = 5.92
;  sinh(x) = 0x4067468B61A7291A =  1.862045143380026387643E+2
; fsinh(x) = 0x4067468B61A7291A
;
; x = 5.93
;  sinh(x) = 0x4067826DFFDE2D61 =  1.880759276713752371465E+2
; fsinh(x) = 0x4067826DFFDE2D5C
;
; x = 5.94
;  sinh(x) = 0x4067BEEAB0CAD1C5 =  1.899661487542454352125E+2
; fsinh(x) = 0x4067BEEAB0CAD1C9

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.fsinh_range , 0x4014000000000000 ; 5.0
;       ??.fsinh_range , 0x4017AE147AE147AE ; 5.92
vdup    ??.fsinh_range ,\
        ??.fsinhcosh_range

$align 16
??.PD_fsinh_PQ:
v64bit  ??.PD_fsinh_P0 , 0x3C7372660B49918B ,\ ;  1.686747058803103075268E-17
        ??.PD_fsinh_Q0 , 0x3B86CD8BA51ACF94 ,\ ;  6.035880565762389306844E-22
        ??.PD_fsinh_P1 , 0x3D1D41B06EDB9FFA ,\ ;  2.598507933672896367899E-14
        ??.PD_fsinh_Q1 , 0xBC35262FD5D3D747 ,\ ; -1.146498662511412889392E-18
        ??.PD_fsinh_P2 , 0x3DB27CF7211DE143 ,\ ;  1.681487073693340649965E-11
        ??.PD_fsinh_Q2 , 0x3CD539DBBCC3A42B ,\ ;  1.178280205406622840989E-15
        ??.PD_fsinh_P3 , 0x3E38E75E4423C3C6 ,\ ;  5.798363624516605937684E-09
        ??.PD_fsinh_Q3 , 0xBD6D913F13FFB230 ,\ ; -8.403551631128341290391E-13
        ??.PD_fsinh_P4 , 0x3EB2E96E8082E516 ,\ ;  1.127233646909459922189E-06
        ??.PD_fsinh_Q4 , 0x3DFEC975A09A3F49 ,\ ;  4.480091025612921547842E-10
        ??.PD_fsinh_P5 , 0x3F1FD05F30FDF392 ,\ ;  1.213605976299727033688E-04
        ??.PD_fsinh_Q5 , 0xBE8837E3762F1BA2 ,\ ; -1.804405043977010571367E-07
        ??.PD_fsinh_P6 , 0x3F7B54500F7904A6 ,\ ;  6.672203765959816037425E-03
        ??.PD_fsinh_Q6 , 0x3F0BCB3F698E3146 ,\ ;  5.301272648869591305360E-05
        ??.PD_fsinh_P7 , 0x3FC40451BA0E0A7C ,\ ;  1.563818129034933874129E-01
        ??.PD_fsinh_Q7 , 0xBF851039B474AD9D ,\ ; -1.028485376317327925378E-02
        ??.PD_fsinh_P8 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fsinh_Q8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_fsinh_Pn:
v64bit  ??.SD_fsinh_P0 , 0x3C7372660B49918B ,\ ;  1.686747058803103075268E-17
        ??.SD_fsinh_P1 , 0x3D1D41B06EDB9FFA ,\ ;  2.598507933672896367899E-14
        ??.SD_fsinh_P2 , 0x3DB27CF7211DE143 ,\ ;  1.681487073693340649965E-11
        ??.SD_fsinh_P3 , 0x3E38E75E4423C3C6 ,\ ;  5.798363624516605937684E-09
        ??.SD_fsinh_P4 , 0x3EB2E96E8082E516 ,\ ;  1.127233646909459922189E-06
        ??.SD_fsinh_P5 , 0x3F1FD05F30FDF392 ,\ ;  1.213605976299727033688E-04
        ??.SD_fsinh_P6 , 0x3F7B54500F7904A6 ,\ ;  6.672203765959816037425E-03
        ??.SD_fsinh_P7 , 0x3FC40451BA0E0A7C ,\ ;  1.563818129034933874129E-01
        ??.SD_fsinh_P8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_fsinh_Qn:
v64bit  ??.SD_fsinh_Q0 , 0x3B86CD8BA51ACF94 ,\ ;  6.035880565762389306844E-22
        ??.SD_fsinh_Q1 , 0xBC35262FD5D3D747 ,\ ; -1.146498662511412889392E-18
        ??.SD_fsinh_Q2 , 0x3CD539DBBCC3A42B ,\ ;  1.178280205406622840989E-15
        ??.SD_fsinh_Q3 , 0xBD6D913F13FFB230 ,\ ; -8.403551631128341290391E-13
        ??.SD_fsinh_Q4 , 0x3DFEC975A09A3F49 ,\ ;  4.480091025612921547842E-10
        ??.SD_fsinh_Q5 , 0xBE8837E3762F1BA2 ,\ ; -1.804405043977010571367E-07
        ??.SD_fsinh_Q6 , 0x3F0BCB3F698E3146 ,\ ;  5.301272648869591305360E-05
        ??.SD_fsinh_Q7 , 0xBF851039B474AD9D ,\ ; -1.028485376317327925378E-02
        ??.SD_fsinh_Q8 , 0x3FF0000000000000    ;  1.0

; ------------------------------------------------------------------------------

; cosh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Pade approximation cosh(x) order 17,17
; https://www.wolframalpha.com/input/?i=Pade+approximation+cosh(x)+order+17,17
; https://keisan.casio.com/calculator

; cosh(x) = P(x^2)/Q(x^2)
; |x| < 5.0 (5.1)

; x = -5.1
;  cosh(x) = 0x405480E568BDF771 = 8.201400202323362979063E+1
; fcosh(x) = 0x405480E568BDF771
;
; x = 5.0
;  cosh(x) = 0x40528D6FCBEFF3AA = 7.420994852478784444411E+1
; fcosh(x) = 0x40528D6FCBEFF3AA
;
; x = 5.09
;  cosh(x) = 0x40544CAC3249F6C0 = 8.119801003668817222033E+1
; fcosh(x) = 0x40544CAC3249F6BF
;
; x = 5.1
;  cosh(x) = 0x405480E568BDF771 = 8.201400202323362979063E+1
; fcosh(x) = 0x405480E568BDF771
;
; x = 5.2
;  cosh(x) = 0x4056A8E365AAC4C9 = 9.06388792197859700712E+1
; fcosh(x) = 0x4056A8E365AAC4CB
;
; x = 5.3
;  cosh(x) = 0x40590AF009D7E906 = 1.001709007843492975257E+2
; fcosh(x) = 0x40590AF009D7E904
;
; x = 5.4
;  cosh(x) = 0x405BAD265C831F8F = 1.107054663925648498465E+2
; fcosh(x) = 0x405BAD265C831F90
;
; x = 5.5
;  cosh(x) = 0x405E9645C9B6718B = 1.223480095178294259911E+2
; fcosh(x) = 0x405E9645C9B67188
;
; x = 5.6
;  cosh(x) = 0x4060E6E1B6159D31 = 1.352150526449345555419E+2
; fcosh(x) = 0x4060E6E1B6159D2D

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.fcosh_range , 0x4014000000000000 ; 5.0
;       ??.fcosh_range , 0x4014666666666666 ; 5.1
vdup    ??.fcosh_range ,\
        ??.fcoshsinh_range

$align 16
??.PD_fcosh_PQ:
v64bit  ??.PD_fcosh_P0 , 0x3CBB4CFBBBD70FDC ,\ ;  3.788735457615526469918E-16
        ??.PD_fcosh_Q0 , 0x3B99767EBE34D7E2 ,\ ;  1.347993190330225747981E-21
        ??.PD_fcosh_P1 , 0x3D619F7B48AD33B1 ,\ ;  5.008750722741929716151E-13
        ??.PD_fcosh_Q1 , 0xBC44B7416F604F09 ,\ ; -2.246016112876270736422E-18
        ??.PD_fcosh_P2 , 0x3DF2BC46400B0FB2 ,\ ;  2.726366355274083967037E-10
        ??.PD_fcosh_Q2 , 0x3CE272F0A97897F5 ,\ ;  2.048248760670762005856E-15
        ??.PD_fcosh_P3 , 0x3E74AED8AC9FE19E ,\ ;  7.705015572779503759854E-08
        ??.PD_fcosh_Q3 , 0xBD7706D9023A9D8D ,\ ; -1.308919126477310407174E-12
        ??.PD_fcosh_P4 , 0x3EE8D785BCF59A86 ,\ ;  1.184553357687119333880E-05
        ??.PD_fcosh_Q4 , 0x3E05A9C162C5D7CA ,\ ;  6.304793957273984070366E-10
        ??.PD_fcosh_P5 , 0x3F4F5A1B8FDBE4CF ,\ ;  9.567865924672516457559E-04
        ??.PD_fcosh_Q5 , 0xBE8F046ADD66CC84 ,\ ; -2.310965629533071149148E-07
        ??.PD_fcosh_P6 , 0x3FA2854E78D4FDBC ,\ ;  3.617329812049826961222E-02
        ??.PD_fcosh_Q6 , 0x3F104D04E0A744DF ,\ ;  6.218282957283796444595E-05
        ??.PD_fcosh_P7 , 0x3FDF49F4A843D531 ,\ ;  4.888888972485175299622E-01
        ??.PD_fcosh_Q7 , 0xBF86C16AF78559DF ,\ ; -1.111110275148247003778E-02
        ??.PD_fcosh_P8 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fcosh_Q8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_fcosh_Pn:
v64bit  ??.SD_fcosh_P0 , 0x3CBB4CFBBBD70FDC ,\ ;  3.788735457615526469918E-16
        ??.SD_fcosh_P1 , 0x3D619F7B48AD33B1 ,\ ;  5.008750722741929716151E-13
        ??.SD_fcosh_P2 , 0x3DF2BC46400B0FB2 ,\ ;  2.726366355274083967037E-10
        ??.SD_fcosh_P3 , 0x3E74AED8AC9FE19E ,\ ;  7.705015572779503759854E-08
        ??.SD_fcosh_P4 , 0x3EE8D785BCF59A86 ,\ ;  1.184553357687119333880E-05
        ??.SD_fcosh_P5 , 0x3F4F5A1B8FDBE4CF ,\ ;  9.567865924672516457559E-04
        ??.SD_fcosh_P6 , 0x3FA2854E78D4FDBC ,\ ;  3.617329812049826961222E-02
        ??.SD_fcosh_P7 , 0x3FDF49F4A843D531 ,\ ;  4.888888972485175299622E-01
        ??.SD_fcosh_P8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_fcosh_Qn:
v64bit  ??.SD_fcosh_Q0 , 0x3B99767EBE34D7E2 ,\ ;  1.347993190330225747981E-21
        ??.SD_fcosh_Q1 , 0xBC44B7416F604F09 ,\ ; -2.246016112876270736422E-18
        ??.SD_fcosh_Q2 , 0x3CE272F0A97897F5 ,\ ;  2.048248760670762005856E-15
        ??.SD_fcosh_Q3 , 0xBD7706D9023A9D8D ,\ ; -1.308919126477310407174E-12
        ??.SD_fcosh_Q4 , 0x3E05A9C162C5D7CA ,\ ;  6.304793957273984070366E-10
        ??.SD_fcosh_Q5 , 0xBE8F046ADD66CC84 ,\ ; -2.310965629533071149148E-07
        ??.SD_fcosh_Q6 , 0x3F104D04E0A744DF ,\ ;  6.218282957283796444595E-05
        ??.SD_fcosh_Q7 , 0xBF86C16AF78559DF ,\ ; -1.111110275148247003778E-02
        ??.SD_fcosh_Q8 , 0x3FF0000000000000    ;  1.0

; ------------------------------------------------------------------------------

; tanh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Pade approximation tanh(x) order 18,17
; https://www.wolframalpha.com/input/?i=Pade+approximation+tanh(x)+order+18,17
; https://keisan.casio.com/calculator

; tanh(x) = x*P(x^2)/Q(x^2)
; |x| < 5.0 (5.3)

; x = -5.3
;  tanh(x) = 0xBFEFFF977F4E09A2 = -9.999501692221211401656E-1
; ftanh(x) = 0xBFEFFF977F4E09A2
;
; x = 5.1
;  tanh(x) = 0x3FEFFF641A285DA7 =  9.999256621257942211202E-1
; ftanh(x) = 0x3FEFFF641A285DA7
;
; x = 5.2
;  tanh(x) = 0x3FEFFF805C5D5589 =  9.999391368861988693184E-1
; ftanh(x) = 0x3FEFFF805C5D558A
;
; x = 5.3
;  tanh(x) = 0x3FEFFF977F4E09A2 =  9.999501692221211401656E-1
; ftanh(x) = 0x3FEFFF977F4E09A2
;
; x = 5.4
;  tanh(x) = 0x3FEFFFAA70A595BE =  9.999592018254401572303E-1
; ftanh(x) = 0x3FEFFFAA70A595BC
;
; x = 5.5
;  tanh(x) = 0x3FEFFFB9F2FC1E91 =  9.999665971563038096385E-1
; ftanh(x) = 0x3FEFFFB9F2FC1E94

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.ftanh_range , 0x4014000000000000 ; 5.0
;       ??.ftanh_range , 0x4015333333333333 ; 5.3

$align 16
??.PD_ftanh_PQ:
v64bit  ??.PD_ftanh_P0 , 0x3C074DBA97B8BE52 ,\ ;  1.579115285532518410386E-19
        ??.PD_ftanh_Q0 , 0x3C7BDAE9095AD37E ,\ ;  2.416046386864753167890E-17
        ??.PD_ftanh_P1 , 0x3CE089FA5D8DED93 ,\ ;  1.836195254017212407596E-15
        ??.PD_ftanh_Q1 , 0x3D39D797322DC336 ,\ ;  9.180976270086062037981E-14
        ??.PD_ftanh_P2 , 0x3D8DAD97A3A08E30 ,\ ;  3.374008779256627798958E-12
        ??.PD_ftanh_Q2 , 0x3DDA865920A44BE1 ,\ ;  9.649665108673955505020E-11
        ??.PD_ftanh_P3 , 0x3E2310900F76168A ,\ ;  2.219422974995009766155E-09
        ??.PD_ftanh_Q3 , 0x3E6678177FEFBF22 ,\ ;  4.185197609990589844749E-08
        ??.PD_ftanh_P4 , 0x3EA5F146F2F020A7 ,\ ;  6.539371265610296632420E-07
        ??.PD_ftanh_Q4 , 0x3EE1D409A5631A88 ,\ ;  8.501182645293385622146E-06
        ??.PD_ftanh_P5 , 0x3F1811736C129704 ,\ ;  9.181277256916856471918E-05
        ??.PD_ftanh_Q5 , 0x3F4ACD9DA114B3D1 ,\ ;  8.179683374344108493163E-04
        ??.PD_ftanh_P6 , 0x3F784A56D9FAC2F5 ,\ ;  5.930270446399478657543E-03
        ??.PD_ftanh_Q6 , 0x3FA1846118461184 ,\ ;  3.421309872922776148583E-02
        ??.PD_ftanh_P7 , 0x3FC364D9364D9365 ,\ ;  1.515151515151515151515E-01
        ??.PD_ftanh_Q7 , 0x3FDF07C1F07C1F08 ,\ ;  4.848484848484848484849E-01
        ??.PD_ftanh_P8 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_ftanh_Q8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_ftanh_Pn:
v64bit  ??.SD_ftanh_P0 , 0x3C074DBA97B8BE52 ,\ ;  1.579115285532518410386E-19
        ??.SD_ftanh_P1 , 0x3CE089FA5D8DED93 ,\ ;  1.836195254017212407596E-15
        ??.SD_ftanh_P2 , 0x3D8DAD97A3A08E30 ,\ ;  3.374008779256627798958E-12
        ??.SD_ftanh_P3 , 0x3E2310900F76168A ,\ ;  2.219422974995009766155E-09
        ??.SD_ftanh_P4 , 0x3EA5F146F2F020A7 ,\ ;  6.539371265610296632420E-07
        ??.SD_ftanh_P5 , 0x3F1811736C129704 ,\ ;  9.181277256916856471918E-05
        ??.SD_ftanh_P6 , 0x3F784A56D9FAC2F5 ,\ ;  5.930270446399478657543E-03
        ??.SD_ftanh_P7 , 0x3FC364D9364D9365 ,\ ;  1.515151515151515151515E-01
        ??.SD_ftanh_P8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_ftanh_Qn:
v64bit  ??.SD_ftanh_Q0 , 0x3C7BDAE9095AD37E ,\ ;  2.416046386864753167890E-17
        ??.SD_ftanh_Q1 , 0x3D39D797322DC336 ,\ ;  9.180976270086062037981E-14
        ??.SD_ftanh_Q2 , 0x3DDA865920A44BE1 ,\ ;  9.649665108673955505020E-11
        ??.SD_ftanh_Q3 , 0x3E6678177FEFBF22 ,\ ;  4.185197609990589844749E-08
        ??.SD_ftanh_Q4 , 0x3EE1D409A5631A88 ,\ ;  8.501182645293385622146E-06
        ??.SD_ftanh_Q5 , 0x3F4ACD9DA114B3D1 ,\ ;  8.179683374344108493163E-04
        ??.SD_ftanh_Q6 , 0x3FA1846118461184 ,\ ;  3.421309872922776148583E-02
        ??.SD_ftanh_Q7 , 0x3FDF07C1F07C1F08 ,\ ;  4.848484848484848484849E-01
        ??.SD_ftanh_Q8 , 0x3FF0000000000000    ;  1.0

; ------------------------------------------------------------------------------

; coth(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Pade approximation cotanh(x)-1/x order 18,17
; https://www.wolframalpha.com/input/?i=Pade+approximation+cotanh(x)-1/x+order+18,17
; https://keisan.casio.com/calculator

; coth(x) = 1/x + x*P(x^2)/Q(x^2)
; |x| < 7.0 (7.3)

; x = -7.3
; 1/tanh(x) = 0xBFF00000F500A84E = -1.000000912705690096447E+0
;  fcoth(x) = 0xBFF00000F500A84F
;
; x = 7.1
; 1/tanh(x) = 0x3FF000016D803F2F =  1.000001361597195768098E+0
;  fcoth(x) = 0x3FF000016D803F30
;
; x = 7.2
; 1/tanh(x) = 0x3FF000012B3F3115 =  1.000001114781359907314E+0
;  fcoth(x) = 0x3FF000012B3F3116
;
; x = 7.3
; 1/tanh(x) = 0x3FF00000F500A84E =  1.000000912705690096447E+0
;  fcoth(x) = 0x3FF00000F500A84F
;
; x = 7.4
; 1/tanh(x) = 0x3FF00000C89753AC =  1.000000747260155175818E+0
;  fcoth(x) = 0x3FF00000C89753AF
;
; x = 7.5
; 1/tanh(x) = 0x3FF00000A43AE85C =  1.000000611804828156168E+0
;  fcoth(x) = 0x3FF00000A43AE85F
;
; x = 7.6
; 1/tanh(x) = 0x3FF000008675D1CD =  1.000000500903399917601E+0
;  fcoth(x) = 0x3FF000008675D1D1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.fcoth_range , 0x401C000000000000 ; 7.0
;       ??.fcoth_range , 0x401D333333333333 ; 7.3

$align 16
??.PD_fcoth_PQ:
v64bit  ??.PD_fcoth_P0 , 0x3BB54E6174C62A5A ,\ ;  4.511757958664338315387E-21
        ??.PD_fcoth_Q0 , 0x3C2C76B63200BC94 ,\ ;  7.715106109316018519312E-19
        ??.PD_fcoth_P1 , 0x3C92ADE790D07BC1 ,\ ;  6.480689131825455556222E-17
        ??.PD_fcoth_Q1 , 0x3CF089FA5D8DED93 ,\ ;  3.672390508034424815193E-15
        ??.PD_fcoth_P2 , 0x3D44CD8CE9AC84D3 ,\ ;  1.478137179483855988115E-13
        ??.PD_fcoth_Q2 , 0x3D9573F950F9E8F9 ,\ ;  4.877852692296724760780E-12
        ??.PD_fcoth_P3 , 0x3DE0C29AC7433E03 ,\ ;  1.219463173074181190195E-10
        ??.PD_fcoth_Q3 , 0x3E27583303423AF2 ,\ ;  2.717660785708175223863E-09
        ??.PD_fcoth_P4 , 0x3E689F05CD6FDA2B ,\ ;  4.586052575882545690269E-08
        ??.PD_fcoth_Q4 , 0x3EA873406DC9BDFC ,\ ;  7.286727981680044818982E-07
        ??.PD_fcoth_P5 , 0x3EE1B9F51C65768A ,\ ;  8.452604458748851990019E-06
        ??.PD_fcoth_Q5 , 0x3F196187AE7A0100 ,\ ;  9.682074198203230461295E-05
        ??.PD_fcoth_P6 , 0x3F48967B710630F8 ,\ ;  7.503607503607503607504E-04
        ??.PD_fcoth_Q6 , 0x3F78D3018D3018D3 ,\ ;  6.060606060606060606061E-03
        ??.PD_fcoth_P7 , 0x3F9D41D41D41D41D ,\ ;  2.857142857142857142857E-02
        ??.PD_fcoth_Q7 , 0x3FC3813813813814 ,\ ;  1.523809523809523809524E-01
        ??.PD_fcoth_P8 , 0x3FD5555555555555 ,\ ;  3.333333333333333333333E-01
        ??.PD_fcoth_Q8 , 0x3FF0000000000000    ;  1.0

$align 16
??.SD_fcoth_Pn:
v64bit  ??.SD_fcoth_P0 , 0x3BB54E6174C62A5A ,\ ;  4.511757958664338315387E-21
        ??.SD_fcoth_P1 , 0x3C92ADE790D07BC1 ,\ ;  6.480689131825455556222E-17
        ??.SD_fcoth_P2 , 0x3D44CD8CE9AC84D3 ,\ ;  1.478137179483855988115E-13
        ??.SD_fcoth_P3 , 0x3DE0C29AC7433E03 ,\ ;  1.219463173074181190195E-10
        ??.SD_fcoth_P4 , 0x3E689F05CD6FDA2B ,\ ;  4.586052575882545690269E-08
        ??.SD_fcoth_P5 , 0x3EE1B9F51C65768A ,\ ;  8.452604458748851990019E-06
        ??.SD_fcoth_P6 , 0x3F48967B710630F8 ,\ ;  7.503607503607503607504E-04
        ??.SD_fcoth_P7 , 0x3F9D41D41D41D41D ,\ ;  2.857142857142857142857E-02
        ??.SD_fcoth_P8 , 0x3FD5555555555555    ;  3.333333333333333333333E-01

$align 16
??.SD_fcoth_Qn:
v64bit  ??.SD_fcoth_Q0 , 0x3C2C76B63200BC94 ,\ ;  7.715106109316018519312E-19
        ??.SD_fcoth_Q1 , 0x3CF089FA5D8DED93 ,\ ;  3.672390508034424815193E-15
        ??.SD_fcoth_Q2 , 0x3D9573F950F9E8F9 ,\ ;  4.877852692296724760780E-12
        ??.SD_fcoth_Q3 , 0x3E27583303423AF2 ,\ ;  2.717660785708175223863E-09
        ??.SD_fcoth_Q4 , 0x3EA873406DC9BDFC ,\ ;  7.286727981680044818982E-07
        ??.SD_fcoth_Q5 , 0x3F196187AE7A0100 ,\ ;  9.682074198203230461295E-05
        ??.SD_fcoth_Q6 , 0x3F78D3018D3018D3 ,\ ;  6.060606060606060606061E-03
        ??.SD_fcoth_Q7 , 0x3FC3813813813814 ,\ ;  1.523809523809523809524E-01
        ??.SD_fcoth_Q8 , 0x3FF0000000000000    ;  1.0

; ------------------------------------------------------------------------------

; exp(x)/2 = exp2(z)
; z = x*log2(e)-1
;
; z:max_arg = x:max_arg*log2(e)-1 = +1024
; x:max_arg = +1025*Ln(2)

v64bit  ??.SD_fsinh_max_arg , 0x408633CE8FB9F87E ;  710.47586007394394215266292449463 = +1025*Ln(2)
vdup    ??.SD_fsinh_max_arg ,\
        ??.SD_fcosh_max_arg ,\
        ??.SD_fsech_max_arg ,\
        ??.SD_fcosech_max_arg ,\
        ??.SD_fsinhcosh_max_arg ,\
        ??.SD_fcoshsinh_max_arg

v64bit  ??.SD_fsinh_min_arg , 0xC08633CE8FB9F87E ; -710.47586007394394215266292449463 = -1025*Ln(2)
vdup    ??.SD_fsinh_min_arg ,\
        ??.SD_fcosh_min_arg ,\
        ??.SD_fsech_min_arg ,\
        ??.SD_fcosech_min_arg ,\
        ??.SD_fsinhcosh_min_arg ,\
        ??.SD_fcoshsinh_min_arg

v64bit  ??.SD_ftanh_max_arg , 0x40862E42FEFA39EF ;  709.78271289338399684324569237317 = +1024*Ln(2)
vdup    ??.SD_ftanh_max_arg ,\
        ??.SD_fcotanh_max_arg

v64bit  ??.SD_ftanh_min_arg , 0xC0862E42FEFA39EF ; -709.78271289338399684324569237317 = -1024*Ln(2)
vdup    ??.SD_ftanh_min_arg ,\
        ??.SD_fcotanh_min_arg

; ------------------------------------------------------------------------------
