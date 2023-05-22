
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

; asinh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/asinh.c
; Inverse hyperbolic sine

; asinh(x) = x + (x^3)*P(x^2)/Q(x^2)
;          = x*(1 + (x^2)*P(x^2)/Q(x^2))
; |x| < 0.5

; x = 0.1
;  asinh(x) = 0x3FB98EB9E7E5FC3E = 9.98340788992075633273E-2
; fasinh(x) = 0x3FB98EB9E7E5FC3F
;
; x = 0.2
;  asinh(x) = 0x3FC96EAD72FE8B33 = 1.986901103492414064746E-1
; fasinh(x) = 0x3FC96EAD72FE8B33
;
; x = 0.3
;  asinh(x) = 0x3FD2EC4EA565FCC1 = 2.956730475634224391027E-1
; fasinh(x) = 0x3FD2EC4EA565FCC1
;
; x = 0.4
;  asinh(x) = 0x3FD8F656B3ACCED6 = 3.900353197707152760802E-1
; fasinh(x) = 0x3FD8F656B3ACCED7
;
; x = 0.499
;  asinh(x) = 0x3FDEBD846EDC6334 = 4.803172190309396922118E-1
; fasinh(x) = 0x3FDEBD846EDC6334

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.fasinh_range , 0x3FE0000000000000 ; 0.5

$align 16
??.PD_fasinh_PQ:
v64bit  ??.PD_fasinh_P0 , 0xBF71BEC372211168 ,\ ; -4.33231683752342103572E-3
        ??.PD_fasinh_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fasinh_P1 , 0xBFE2EF9E2405DD2A ,\ ; -5.91750212056387121207E-1
        ??.PD_fasinh_Q1 , 0x4029C05BC70A1EC5 ,\ ;  1.28757002067426453537E+1
        ??.PD_fasinh_P2 , 0xC0117EE03C0BCACC ,\ ; -4.37390226194356683570E+0
        ??.PD_fasinh_Q2 , 0x40484D5802CC8453 ,\ ;  4.86042483805291788324E+1
        ??.PD_fasinh_P3 , 0xC0222E3C80287F96 ,\ ; -9.09030533308377316566E+0
        ??.PD_fasinh_Q3 , 0x4051649FC769DAC6 ,\ ;  6.95722521337257608734E+1
        ??.PD_fasinh_P4 , 0xC016446D0EC8D6DD ,\ ; -5.56682227230859640450E+0
        ??.PD_fasinh_Q4 , 0x4040B351CB16A12E    ;  3.34009336338516356383E+1

$align 16
??.SD_fasinh_Pn:
v64bit  ??.SD_fasinh_P0 , 0xBF71BEC372211168 ,\ ; -4.33231683752342103572E-3
        ??.SD_fasinh_P1 , 0xBFE2EF9E2405DD2A ,\ ; -5.91750212056387121207E-1
        ??.SD_fasinh_P2 , 0xC0117EE03C0BCACC ,\ ; -4.37390226194356683570E+0
        ??.SD_fasinh_P3 , 0xC0222E3C80287F96 ,\ ; -9.09030533308377316566E+0
        ??.SD_fasinh_P4 , 0xC016446D0EC8D6DD    ; -5.56682227230859640450E+0

$align 16
??.SD_fasinh_Qn:
v64bit  ??.SD_fasinh_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fasinh_Q1 , 0x4029C05BC70A1EC5 ,\ ;  1.28757002067426453537E+1
        ??.SD_fasinh_Q2 , 0x40484D5802CC8453 ,\ ;  4.86042483805291788324E+1
        ??.SD_fasinh_Q3 , 0x4051649FC769DAC6 ,\ ;  6.95722521337257608734E+1
        ??.SD_fasinh_Q4 , 0x4040B351CB16A12E    ;  3.34009336338516356383E+1

; ------------------------------------------------------------------------------

; acosh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/acosh.c
; Inverse hyperbolic cosine

; acosh(1+x) = sqrt(x)*P(x)/Q(x)
; 1+x < 1.5

; x = 1.1
;  acosh(x) = 0x3FDC636C1A882F29 = 4.435682543851151891329E-1
; facosh(x) = 0x3FDC636C1A882F2C
;
; x = 1.2
;  acosh(x) = 0x3FE3EA64C4F6C5DC = 6.223625037147786678069E-1
; facosh(x) = 0x3FE3EA64C4F6C5DB
;
; x = 1.3
;  acosh(x) = 0x3FE834B2CAB7F58E = 7.564329108569595862421E-1
; facosh(x) = 0x3FE834B2CAB7F58F
;
; x = 1.4
;  acosh(x) = 0x3FEBBE95AAEDACF3 = 8.670147264905651039505E-1
; facosh(x) = 0x3FEBBE95AAEDACF3
;
; x = 1.499
;  acosh(x) = 0x3FEEC4D7CE6E4F10 = 9.615286857465168785391E-1
; facosh(x) = 0x3FEEC4D7CE6E4F12

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.facosh_range , 0x3FF8000000000000 ; 1.5

$align 16
??.PD_facosh_PQ:
v64bit  ??.PD_facosh_P0 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_facosh_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_facosh_P1 , 0x405DB345B90059A4 ,\ ;  1.18801130533544501356E+2
        ??.PD_facosh_Q1 , 0x406744A6F5B70853 ,\ ;  1.86145380837903397292E+2
        ??.PD_facosh_P2 , 0x40AED6887B4D1A18 ,\ ;  3.94726656571334401102E+3
        ??.PD_facosh_Q2 , 0x40B03986DA8C4702 ,\ ;  4.15352677227719831579E+3
        ??.PD_facosh_P3 , 0x40E0CBDE00C23CBD ,\ ;  3.43989375926195455866E+4
        ??.PD_facosh_Q3 , 0x40DD1215F44EA588 ,\ ;  2.97683430363289370382E+4
        ??.PD_facosh_P4 , 0x40FA646DFF52AB95 ,\ ;  1.08102874834699867335E+5
        ??.PD_facosh_Q4 , 0x40F441C86736E6CF ,\ ;  8.29725251988426222434E+4
        ??.PD_facosh_P5 , 0x40FB107F2804C1B4 ,\ ;  1.10855947270161294369E+5
        ??.PD_facosh_Q5 , 0x40F3232FDF6F63E7    ;  7.83869920495893927727E+4

$align 16
??.SD_facosh_Pn:
v64bit  ??.SD_facosh_P0 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_facosh_P1 , 0x405DB345B90059A4 ,\ ;  1.18801130533544501356E+2
        ??.SD_facosh_P2 , 0x40AED6887B4D1A18 ,\ ;  3.94726656571334401102E+3
        ??.SD_facosh_P3 , 0x40E0CBDE00C23CBD ,\ ;  3.43989375926195455866E+4
        ??.SD_facosh_P4 , 0x40FA646DFF52AB95 ,\ ;  1.08102874834699867335E+5
        ??.SD_facosh_P5 , 0x40FB107F2804C1B4    ;  1.10855947270161294369E+5

$align 16
??.SD_facosh_Qn:
v64bit  ??.SD_facosh_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_facosh_Q1 , 0x406744A6F5B70853 ,\ ;  1.86145380837903397292E+2
        ??.SD_facosh_Q2 , 0x40B03986DA8C4702 ,\ ;  4.15352677227719831579E+3
        ??.SD_facosh_Q3 , 0x40DD1215F44EA588 ,\ ;  2.97683430363289370382E+4
        ??.SD_facosh_Q4 , 0x40F441C86736E6CF ,\ ;  8.29725251988426222434E+4
        ??.SD_facosh_Q5 , 0x40F3232FDF6F63E7    ;  7.83869920495893927727E+4

; ------------------------------------------------------------------------------

; atanh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/atanh.c
; Inverse hyperbolic tangent

; atanh(x) = x + (x^3)*P(x^2)/Q(x^2)
;          = x*(1 + (x^2)*P(x^2)/Q(x^2))
;          = x*(1 + P'(x^2)/Q(x^2))
; |x| < 0.5

; x = 0.1
;  atanh(x) = 0x3FB9AF93CD234412 = 1.003353477310755806357E-1
; fatanh(x) = 0x3FB9AF93CD234412
;
; x = 0.2
;  atanh(x) = 0x3FC9F323ECBF984C = 2.02732554054082190989E-1
; fatanh(x) = 0x3FC9F323ECBF984C
;
; x = 0.3
;  atanh(x) = 0x3FD3CF2B50617C95 = 3.095196042031117154741E-1
; fatanh(x) = 0x3FD3CF2B50617C95
;
; x = 0.4
;  atanh(x) = 0x3FDB1D10670AAE99 = 4.236489301936018068551E-1
; fatanh(x) = 0x3FDB1D10670AAE9A
;
; x = 0.499
;  atanh(x) = 0x3FE1890023453D67 = 5.479736985088664526606E-1
; fatanh(x) = 0x3FE1890023453D67

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.fatanh_range , 0x3FE0000000000000 ; 0.5

$align 16
??.PD_fatanh_PQ:
v64bit  ??.PD_fatanh_P0 , 0xBFEB5493B17FB618 ,\ ; -8.54074331929669305196E-1
        ??.PD_fatanh_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fatanh_P1 , 0x402815DAF520E73A ,\ ;  1.20426861384072379242E+1
        ??.PD_fatanh_Q1 , 0xC033905AC366172F ,\ ; -1.95638849376911654834E+1
        ??.PD_fatanh_P2 , 0xC04710097370F62C ,\ ; -4.61252884198732692637E+1
        ??.PD_fatanh_Q2 , 0x405B3C09B3A52685 ,\ ;  1.08938092147140262656E+2
        ??.PD_fatanh_P3 , 0x40505D3A20D5E2F7 ,\ ;  6.54566728676544377376E+1
        ??.PD_fatanh_Q3 , 0xC06F3ADC602B5DD3 ,\ ; -2.49839401325893582852E+2
        ??.PD_fatanh_P4 , 0xC03EE8C4DDB7697D ,\ ; -3.09092539379866942570E+1
        ??.PD_fatanh_Q4 , 0x406F8036AFF08019 ,\ ;  2.52006675691344555838E+2
        ??.PD_fatanh_P5 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_fatanh_Q5 , 0xC0572E93A6498F20    ; -9.27277618139601130017E+1

$align 16
??.SD_fatanh_Pn:
v64bit  ??.SD_fatanh_P0 , 0xBFEB5493B17FB618 ,\ ; -8.54074331929669305196E-1
        ??.SD_fatanh_P1 , 0x402815DAF520E73A ,\ ;  1.20426861384072379242E+1
        ??.SD_fatanh_P2 , 0xC04710097370F62C ,\ ; -4.61252884198732692637E+1
        ??.SD_fatanh_P3 , 0x40505D3A20D5E2F7 ,\ ;  6.54566728676544377376E+1
        ??.SD_fatanh_P4 , 0xC03EE8C4DDB7697D ,\ ; -3.09092539379866942570E+1
        ??.SD_fatanh_P5 , 0x0000000000000000    ;  0.0

$align 16
??.SD_fatanh_Qn:
v64bit  ??.SD_fatanh_Q0 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fatanh_Q1 , 0xC033905AC366172F ,\ ; -1.95638849376911654834E+1
        ??.SD_fatanh_Q2 , 0x405B3C09B3A52685 ,\ ;  1.08938092147140262656E+2
        ??.SD_fatanh_Q3 , 0xC06F3ADC602B5DD3 ,\ ; -2.49839401325893582852E+2
        ??.SD_fatanh_Q4 , 0x406F8036AFF08019 ,\ ;  2.52006675691344555838E+2
        ??.SD_fatanh_Q5 , 0xC0572E93A6498F20    ; -9.27277618139601130017E+1

; ------------------------------------------------------------------------------

; acoth(x)

; ------------------------------------------------------------------------------
