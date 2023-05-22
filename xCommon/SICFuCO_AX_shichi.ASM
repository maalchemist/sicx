
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
; http://www.moshier.net/double.zip/shichi.c
; Hyperbolic sine and cosine integrals

; DESCRIPTION:
;
; Approximates the integrals
;
;                            x
;                            —
;                           | |  cosh t - 1
;   Chi(x) = eul + ln x +   |    ——————————  dt,
;                         | |         t
;                          —
;                          0
;
;               x
;               —
;              | |  sinh t
;   Shi(x) =   |    ——————  dt
;            | |       t
;             —
;             0
;
; where eul = 0.57721566490153286061 is Euler's constant.
; The integrals are evaluated by power series for x < 8
; and by Chebyshev expansions for x between 8 and 88.
; For large x, both functions approach exp(x)/2x.
; Arguments greater than 88 in magnitude return MAXNUM.

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; x exp(-x) shi(x), inverted interval 8 to 18

$align 16
??.SD_fshichi_S1:
v64bit  ??.SD_fsici_S1_00 , 0x3C753373BD4A01B0 ,\ ;  1.83889230173399459482E-17
        ??.SD_fsici_S1_01 , 0xBC9B8A3D2418B05E ,\ ; -9.55485532279655569575E-17
        ??.SD_fsici_S1_02 , 0x3CAD724D82487FE6 ,\ ;  2.04326105980879882648E-16
        ??.SD_fsici_S1_03 , 0x3CD3CC1A2C157515 ,\ ;  1.09896949074905343022E-15
        ??.SD_fsici_S1_04 , 0xBD0D91B5BAAABDA0 ,\ ; -1.31313534344092599234E-14
        ??.SD_fsici_S1_05 , 0x3D30B80CBE40D1AE ,\ ;  5.93976226264314278932E-14
        ??.SD_fsici_S1_06 , 0xBD238BA2E110BF82 ,\ ; -3.47197010497749154755E-14
        ??.SD_fsici_S1_07 , 0xBD78A3BB25413725 ,\ ; -1.40059764613117131000E-12
        ??.SD_fsici_S1_08 , 0x3DA4DEA572B09394 ,\ ;  9.49044626224223543299E-12
        ??.SD_fsici_S1_09 , 0xBDB1C48733B017F7 ,\ ; -1.61596181145435454033E-11
        ??.SD_fsici_S1_10 , 0xBDE8734ACE488AAC ,\ ; -1.77899784436430310321E-10
        ??.SD_fsici_S1_11 , 0x3E17456502073862 ,\ ;  1.35455469767246947469E-09
        ??.SD_fsici_S1_12 , 0xBE11BD4BD68BFFFC ,\ ; -1.03257121792819495123E-09
        ??.SD_fsici_S1_13 , 0xBE6326712F23DF61 ,\ ; -3.56699611114982536845E-08
        ??.SD_fsici_S1_14 , 0x3E836FF0511CAC08 ,\ ;  1.44818877384267342057E-07
        ??.SD_fsici_S1_15 , 0x3EAA3D7C3DCFFEA3 ,\ ;  7.82018215184051295296E-07
        ??.SD_fsici_S1_16 , 0xBED6A5565F3224B1 ,\ ; -5.39919118403805073710E-06
        ??.SD_fsici_S1_17 , 0xBF0061BE352ED961 ,\ ; -3.12458202168959833422E-05
        ??.SD_fsici_S1_18 , 0x3F17559B473BF3BD ,\ ;  8.90136741950727517826E-05
        ??.SD_fsici_S1_19 , 0x3F6097F587DB567F ,\ ;  2.02558474743846862168E-03
        ??.SD_fsici_S1_20 , 0x3F9E5126D464B51B ,\ ;  2.96064440855633256972E-02
        ??.SD_fsici_S1_21 , 0x3FF1E548AC8CA8B4    ;  1.11847751047257036625E+00

; x exp(-x) shi(x), inverted interval 18 to 88

$align 16
??.SD_fshichi_S2:
v64bit  ??.SD_fsici_S2_00 , 0xBC68487F83852B4C ,\ ; -1.05311574154850938805E-17
        ??.SD_fsici_S2_01 , 0x3C7E420AA1F5237F ,\ ;  2.62446095596355225821E-17
        ??.SD_fsici_S2_02 , 0x3C996CAD2812EE75 ,\ ;  8.82090135625368160657E-17
        ??.SD_fsici_S2_03 , 0xBCB8637B457B39AF ,\ ; -3.38459811878103047136E-16
        ??.SD_fsici_S2_04 , 0xBCCDED01C086EDF9 ,\ ; -8.30608026366935789136E-16
        ??.SD_fsici_S2_05 , 0x3CF1B791969F9513 ,\ ;  3.93397875437050071776E-15
        ??.SD_fsici_S2_06 , 0x3D06EA62AE46CD11 ,\ ;  1.01765565969729044505E-14
        ??.SD_fsici_S2_07 , 0xBD27B518B74A650F ,\ ; -4.21128170307640802703E-14
        ??.SD_fsici_S2_08 , 0xBD46A216216E0713 ,\ ; -1.60818204519802480035E-13
        ??.SD_fsici_S2_09 , 0x3D578DB0463A9F2E ,\ ;  3.34714954175994481761E-13
        ??.SD_fsici_S2_10 , 0x3D87FA6A0A690DD5 ,\ ;  2.72600352129153073807E-12
        ??.SD_fsici_S2_11 , 0x3D7D5C47D2CD9397 ,\ ;  1.66894954752839083608E-12
        ??.SD_fsici_S2_12 , 0xBDC333A71FE6B5D8 ,\ ; -3.49278141024730899554E-11
        ??.SD_fsici_S2_13 , 0xBDE5CB8F9E19A2DA ,\ ; -1.58580661666482709598E-10
        ??.SD_fsici_S2_14 , 0xBDE8A42FAF5AE7B9 ,\ ; -1.79289437183355633342E-10
        ??.SD_fsici_S2_15 , 0x3E1E48F2B2C4D544 ,\ ;  1.76281629144264523277E-09
        ??.SD_fsici_S2_16 , 0x3E5226D13B1D8488 ,\ ;  1.69050228879421288846E-08
        ??.SD_fsici_S2_17 , 0x3E80D46DAF17084C ,\ ;  1.25391771228487041649E-07
        ??.SD_fsici_S2_18 , 0x3EB38009C8713EFC ,\ ;  1.16229947068677338732E-06
        ??.SD_fsici_S2_19 , 0x3EF0E2D67F39B36E ,\ ;  1.61038260117376323993E-05
        ??.SD_fsici_S2_20 , 0x3F36ECD81F7D73D7 ,\ ;  3.49810375601053973070E-04
        ??.SD_fsici_S2_21 , 0x3F8A4FF366D5B790 ,\ ;  1.28478065259647610779E-02
        ??.SD_fsici_S2_22 , 0x3FF09625E3259D96    ;  1.03665722588798326712E+00

; x exp(-x) chin(x), inverted interval 8 to 18

$align 16
??.SD_fshichi_C1:
v64bit  ??.SD_fsici_C1_00 , 0xBC62BBC5A4784463 ,\ ; -8.12435385225864036372E-18
        ??.SD_fsici_C1_01 , 0x3C79160474D6A49C ,\ ;  2.17586413290339214377E-17
        ??.SD_fsici_C1_02 , 0x3C8E209323FCC2C4 ,\ ;  5.22624394924072204667E-17
        ??.SD_fsici_C1_03 , 0xBCD1179FA09D4527 ,\ ; -9.48812110591690559363E-16
        ??.SD_fsici_C1_04 , 0x3CF81E6DB8580025 ,\ ;  5.35546311647465209166E-15
        ??.SD_fsici_C1_05 , 0xBD0B3FBFF5910772 ,\ ; -1.21009970113732918701E-14
        ??.SD_fsici_C1_06 , 0xBD30E9B09DFE0FCB ,\ ; -6.00865178553447437951E-14
        ??.SD_fsici_C1_07 , 0x3D693436C5B0CD0C ,\ ;  7.16339649156028587775E-13
        ??.SD_fsici_C1_08 , 0xBD89D0F1AB0AE164 ,\ ; -2.93496072607599856104E-12
        ??.SD_fsici_C1_09 , 0xBD78B13A2561A10C ,\ ; -1.40359438136491256904E-12
        ??.SD_fsici_C1_10 , 0x3DD8166DDD3ABBED ,\ ;  8.76302288609054966081E-11
        ??.SD_fsici_C1_11 , 0xBDFE3E304FD78B61 ,\ ; -4.40092476213282340617E-10
        ??.SD_fsici_C1_12 , 0xBDE9D662156743D3 ,\ ; -1.87992075640569295479E-10
        ??.SD_fsici_C1_13 , 0x3E4C3AFCFFD94B98 ,\ ;  1.31458150989474594064E-08
        ??.SD_fsici_C1_14 , 0xBE698769E86CA8CD ,\ ; -4.75513930924765465590E-08
        ??.SD_fsici_C1_15 , 0xBE8DC421B2049EA4 ,\ ; -2.21775018801848880741E-07
        ??.SD_fsici_C1_16 , 0x3EC053C4264D421F ,\ ;  1.94635531373272490962E-06
        ??.SD_fsici_C1_17 , 0x3ED22EBBEA34E2FA ,\ ;  4.33505889257316408893E-06
        ??.SD_fsici_C1_18 , 0xBF10145ED8010CD7 ,\ ; -6.13387001076494349496E-05
        ??.SD_fsici_C1_19 , 0xBF3484B3E2FDC93C ,\ ; -3.13085477492997465138E-04
        ??.SD_fsici_C1_20 , 0x3F404A8541AA68EF ,\ ;  4.97164789823116062801E-04
        ??.SD_fsici_C1_21 , 0x3F9B11B60417FC8D ,\ ;  2.64347496031374526641E-02
        ??.SD_fsici_C1_22 , 0x3FF1D4D5974CE17B    ;  1.11446150876699213025E+00

; x exp(-x) chin(x), inverted interval 18 to 88

$align 16
??.SD_fshichi_C2:
v64bit  ??.SD_fsici_C2_00 , 0x3C629B2D11193916 ,\ ;  8.06913408255155572081E-18
        ??.SD_fsici_C2_01 , 0xBC77FD43F6E47B70 ,\ ; -2.08074168180148170312E-17
        ??.SD_fsici_C2_02 , 0xBC913D485BC56B55 ,\ ; -5.98111329658272336816E-17
        ??.SD_fsici_C2_03 , 0x3CB35993BAE932D2 ,\ ;  2.68533951085945765591E-16
        ??.SD_fsici_C2_04 , 0x3CC04BDC19588227 ,\ ;  4.52313941698904694774E-16
        ??.SD_fsici_C2_05 , 0xBCEBFD0F32C73000 ,\ ; -3.10734917335299464535E-15
        ??.SD_fsici_C2_06 , 0xBCF3F1676B8B0482 ,\ ; -4.42823207332531972288E-15
        ??.SD_fsici_C2_07 , 0x3D23AED6CBBCDD23 ,\ ;  3.49639695410806959872E-14
        ??.SD_fsici_C2_08 , 0x3D32AC596B701D61 ,\ ;  6.63406731718911586609E-14
        ??.SD_fsici_C2_09 , 0xBD5A2B9951F16A52 ,\ ; -3.71902448093119218395E-13
        ??.SD_fsici_C2_10 , 0xBD765DAB935BCDB5 ,\ ; -1.27135418132338309016E-12
        ??.SD_fsici_C2_11 , 0x3D882D18F5E44D6F ,\ ;  2.74851141935315395333E-12
        ??.SD_fsici_C2_12 , 0x3DB9B45FB882095E ,\ ;  2.33781843985453438400E-11
        ??.SD_fsici_C2_13 , 0x3DBDD83E8E3429AF ,\ ;  2.71436006377612442764E-11
        ??.SD_fsici_C2_14 , 0xBDF1A228799BBFFC ,\ ; -2.56600180000355990529E-10
        ??.SD_fsici_C2_15 , 0xBE1BA9CB8351BCF7 ,\ ; -1.61021375163803438552E-09
        ??.SD_fsici_C2_16 , 0xBE344BAA7B57CA05 ,\ ; -4.72543064876271773512E-09
        ??.SD_fsici_C2_17 , 0xBE29C729AA38FCE9 ,\ ; -3.00095178028681682282E-09
        ??.SD_fsici_C2_18 , 0x3E74EBE8F1ECA681 ,\ ;  7.79387474390914922337E-08
        ??.SD_fsici_C2_19 , 0x3EB1F1282478C545 ,\ ;  1.06942765566401507066E-06
        ??.SD_fsici_C2_20 , 0x3EF0B9A166FCCFAE ,\ ;  1.59503164802313196374E-05
        ??.SD_fsici_C2_21 , 0x3F36E930AD5DA0BF ,\ ;  3.49592575153777996871E-04
        ??.SD_fsici_C2_22 , 0x3F8A4FCF7639DE19 ,\ ;  1.28475387530065247392E-02
        ??.SD_fsici_C2_23 , 0x3FF09625962F25D7    ;  1.03665693917934275131E+00

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_fshichi_max_arg , 0x4056000000000000 ; +88.0
v64bit  ??.SD_fshichi_min_arg , 0xC056000000000000 ; -88.0

v64bit  ??.SD_fshichi_DP1 , 0x4020000000000000 ; +8.0  | domain point #1
v64bit  ??.SD_fshichi_DP2 , 0x4032000000000000 ; +18.0 | domain point #2
v64bit  ??.SD_fshichi_DP3 , 0x4056000000000000 ; +88.0 | domain point #3

; ------------------------------------------------------------------------------
