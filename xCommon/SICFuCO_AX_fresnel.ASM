
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
; http://www.moshier.net/double.zip/fresnl.c
; Fresnel integrals

; DESCRIPTION:
;
; Evaluates the Fresnel integrals
;
;           x
;           —
;          | |
; C(x) =   |   cos(pi/2 t**2) dt,
;        | |
;         —
;          0
;
;           x
;           —
;          | |
; S(x) =   |   sin(pi/2 t**2) dt.
;        | |
;         —
;          0
;
;
; The integrals are evaluated by a power series for x < 1.
; For x >= 1 auxiliary functions f(x) and g(x) are employed
; such that
;
; C(x) = 0.5 + f(x) sin( pi/2 x**2 ) - g(x) cos( pi/2 x**2 )
; S(x) = 0.5 - f(x) cos( pi/2 x**2 ) - g(x) sin( pi/2 x**2 )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; S(x) for small x

$align 16
??.PD_fresnl_snd:
v64bit  ??.PD_fsici_sn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_fsici_sd_00 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fsici_sn_01 , 0xC0A75FA36D65B5C3 ,\ ; -2.99181919401019853726E+03
        ??.PD_fsici_sd_01 , 0x4071960532871072 ,\ ;  2.81376268889994315696E+02
        ??.PD_fsici_sn_02 , 0x4125A1D0172C05B6 ,\ ;  7.08840045257738576863E+05
        ??.PD_fsici_sd_02 , 0x40E64218FE9CDAA9 ,\ ;  4.55847810806532581675E+04
        ??.PD_fsici_sn_03 , 0xC18E074624F6F5ED ,\ ; -6.29741486205862506537E+07
        ??.PD_fsici_sd_03 , 0x4153BC2FB8D017B4 ,\ ;  5.17343888770096400730E+06
        ??.PD_fsici_sn_04 , 0x41E2FDA860B77AFE ,\ ;  2.54890880573376359104E+09
        ??.PD_fsici_sd_04 , 0x41B8FE51B5E5EA9E ,\ ;  4.19320245898111231129E+08
        ??.PD_fsici_sn_05 , 0xC224A0BA347BF087 ,\ ; -4.42979518059697779103E+10
        ??.PD_fsici_sd_05 , 0x4214E664E6B222E9 ,\ ;  2.24411795645340920940E+10
        ??.PD_fsici_sn_06 , 0x425282CFE6E52457 ,\ ;  3.18016297876567817986E+11
        ??.PD_fsici_sd_06 , 0x4261AD3B73DE42B5    ;  6.07366389490084639049E+11

$align 16
??.SD_fresnl_sn:
v64bit  ??.SD_fsici_sn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_fsici_sn_01 , 0xC0A75FA36D65B5C3 ,\ ; -2.99181919401019853726E+03
        ??.SD_fsici_sn_02 , 0x4125A1D0172C05B6 ,\ ;  7.08840045257738576863E+05
        ??.SD_fsici_sn_03 , 0xC18E074624F6F5ED ,\ ; -6.29741486205862506537E+07
        ??.SD_fsici_sn_04 , 0x41E2FDA860B77AFE ,\ ;  2.54890880573376359104E+09
        ??.SD_fsici_sn_05 , 0xC224A0BA347BF087 ,\ ; -4.42979518059697779103E+10
        ??.SD_fsici_sn_06 , 0x425282CFE6E52457    ;  3.18016297876567817986E+11

$align 16
??.SD_fresnl_sd:
v64bit  ??.SD_fsici_sd_00 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fsici_sd_01 , 0x4071960532871072 ,\ ;  2.81376268889994315696E+02
        ??.SD_fsici_sd_02 , 0x40E64218FE9CDAA9 ,\ ;  4.55847810806532581675E+04
        ??.SD_fsici_sd_03 , 0x4153BC2FB8D017B4 ,\ ;  5.17343888770096400730E+06
        ??.SD_fsici_sd_04 , 0x41B8FE51B5E5EA9E ,\ ;  4.19320245898111231129E+08
        ??.SD_fsici_sd_05 , 0x4214E664E6B222E9 ,\ ;  2.24411795645340920940E+10
        ??.SD_fsici_sd_06 , 0x4261AD3B73DE42B5    ;  6.07366389490084639049E+11

; C(x) for small x

$align 16
??.PD_fresnl_cnd:
v64bit  ??.PD_fsici_cn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_fsici_cd_00 , 0x3D9197686A7FC6B3 ,\ ;  3.99982968972495980367E-12
        ??.PD_fsici_cn_01 , 0xBE6AC80C2CFB62D3 ,\ ; -4.98843114573573548651E-08
        ??.PD_fsici_cd_01 , 0x3E0F7449DB0375B9 ,\ ;  9.15439215774657478799E-10
        ??.PD_fsici_cn_02 , 0x3EE3EE9262100F74 ,\ ;  9.50428062829859605134E-06
        ??.PD_fsici_cd_02 , 0x3E80C70802A45191 ,\ ;  1.25001862479598821474E-07
        ??.PD_fsici_cn_03 , 0xBF4524420ED68786 ,\ ; -6.45191435683965050962E-04
        ??.PD_fsici_cd_03 , 0x3EE9A3EEFA2A1D32 ,\ ;  1.22262789024179030997E-05
        ??.PD_fsici_cn_04 , 0x3F93566A1059CC13 ,\ ;  1.88843319396703850064E-02
        ??.PD_fsici_cd_04 , 0x3F4C718F3FDBD99D ,\ ;  8.68029542941784300606E-04
        ??.PD_fsici_cn_05 , 0xBFCA4EAC378A9690 ,\ ; -2.05525900955013891793E-01
        ??.PD_fsici_cd_05 , 0x3FA51A076030FE74 ,\ ;  4.12142090722199792936E-02
        ??.PD_fsici_cn_06 , 0x3FF0000000000000 ,\ ;  9.99999999999999998822E-01
        ??.PD_fsici_cd_06 , 0x3FF0000000000000    ;  1.00000000000000000118E+00

$align 16
??.SD_fresnl_cn:
v64bit  ??.SD_fsici_cn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_fsici_cn_01 , 0xBE6AC80C2CFB62D3 ,\ ; -4.98843114573573548651E-08
        ??.SD_fsici_cn_02 , 0x3EE3EE9262100F74 ,\ ;  9.50428062829859605134E-06
        ??.SD_fsici_cn_03 , 0xBF4524420ED68786 ,\ ; -6.45191435683965050962E-04
        ??.SD_fsici_cn_04 , 0x3F93566A1059CC13 ,\ ;  1.88843319396703850064E-02
        ??.SD_fsici_cn_05 , 0xBFCA4EAC378A9690 ,\ ; -2.05525900955013891793E-01
        ??.SD_fsici_cn_06 , 0x3FF0000000000000    ;  9.99999999999999998822E-01

$align 16
??.SD_fresnl_cd:
v64bit  ??.SD_fsici_cd_00 , 0x3D9197686A7FC6B3 ,\ ;  3.99982968972495980367E-12
        ??.SD_fsici_cd_01 , 0x3E0F7449DB0375B9 ,\ ;  9.15439215774657478799E-10
        ??.SD_fsici_cd_02 , 0x3E80C70802A45191 ,\ ;  1.25001862479598821474E-07
        ??.SD_fsici_cd_03 , 0x3EE9A3EEFA2A1D32 ,\ ;  1.22262789024179030997E-05
        ??.SD_fsici_cd_04 , 0x3F4C718F3FDBD99D ,\ ;  8.68029542941784300606E-04
        ??.SD_fsici_cd_05 , 0x3FA51A076030FE74 ,\ ;  4.12142090722199792936E-02
        ??.SD_fsici_cd_06 , 0x3FF0000000000000    ;  1.00000000000000000118E+00

; Auxiliary function f(x)

$align 16
??.PD_fresnl_fnd:
v64bit  ??.PD_fsici_fn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_fsici_fd_00 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fsici_fn_01 , 0x3FDAFA91D1B02391 ,\ ;  4.21543555043677546506E-01
        ??.PD_fsici_fd_01 , 0x3FE80CFEEB217A65 ,\ ;  7.51586398353378947175E-01
        ??.PD_fsici_fn_02 , 0x3FC25B30D2B90E5E ,\ ;  1.43407919780758885261E-01
        ??.PD_fsici_fd_02 , 0x3FBDEC6EC1D46D7D ,\ ;  1.16888925859191382142E-01
        ??.PD_fsici_fn_03 , 0x3F8798E57B157DAD ,\ ;  1.15220955073585758835E-02
        ??.PD_fsici_fd_03 , 0x3F7A615EA6ED56F3 ,\ ;  6.44051526508858611005E-03
        ??.PD_fsici_fn_04 , 0x3F369C70C4950EFC ,\ ;  3.45017939782574027900E-04
        ??.PD_fsici_fd_04 , 0x3F24704A6017BD60 ,\ ;  1.55934409164153020873E-04
        ??.PD_fsici_fn_05 , 0x3ED37203C5357795 ,\ ;  4.63613749287867322088E-06
        ??.PD_fsici_fd_05 , 0x3EBEF9B1923264F5 ,\ ;  1.84627567348930545870E-06
        ??.PD_fsici_fn_06 , 0x3E6067B5484E87A1 ,\ ;  3.05568983790257605827E-08
        ??.PD_fsici_fd_06 , 0x3E4833B495525916 ,\ ;  1.12699224763999035261E-08
        ??.PD_fsici_fn_07 , 0x3DDC1F0A4998A7BB ,\ ;  1.02304514164907233465E-10
        ??.PD_fsici_fd_07 , 0x3DC3CC8533D3A061 ,\ ;  3.60140029589371370404E-11
        ??.PD_fsici_fn_08 , 0x3D4835571459FDF7 ,\ ;  1.72010743268161828879E-13
        ??.PD_fsici_fd_08 , 0x3D30926C6B9F0790 ,\ ;  5.88754533621578410010E-14
        ??.PD_fsici_fn_09 , 0x3CA35A2DAF8FA9E4 ,\ ;  1.34283276233062758925E-16
        ??.PD_fsici_fd_09 , 0x3C8A0E5D2352F48D ,\ ;  4.52001434074129701496E-17
        ??.PD_fsici_fn_10 , 0x3BE636EF0E0B05F6 ,\ ;  3.76329711269987889006E-20
        ??.PD_fsici_fd_10 , 0x3BCD9E9412B96141    ;  1.25443237090011264384E-20

$align 16
??.SD_fresnl_fn:
v64bit  ??.SD_fsici_fn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_fsici_fn_01 , 0x3FDAFA91D1B02391 ,\ ;  4.21543555043677546506E-01
        ??.SD_fsici_fn_02 , 0x3FC25B30D2B90E5E ,\ ;  1.43407919780758885261E-01
        ??.SD_fsici_fn_03 , 0x3F8798E57B157DAD ,\ ;  1.15220955073585758835E-02
        ??.SD_fsici_fn_04 , 0x3F369C70C4950EFC ,\ ;  3.45017939782574027900E-04
        ??.SD_fsici_fn_05 , 0x3ED37203C5357795 ,\ ;  4.63613749287867322088E-06
        ??.SD_fsici_fn_06 , 0x3E6067B5484E87A1 ,\ ;  3.05568983790257605827E-08
        ??.SD_fsici_fn_07 , 0x3DDC1F0A4998A7BB ,\ ;  1.02304514164907233465E-10
        ??.SD_fsici_fn_08 , 0x3D4835571459FDF7 ,\ ;  1.72010743268161828879E-13
        ??.SD_fsici_fn_09 , 0x3CA35A2DAF8FA9E4 ,\ ;  1.34283276233062758925E-16
        ??.SD_fsici_fn_10 , 0x3BE636EF0E0B05F6    ;  3.76329711269987889006E-20

$align 16
??.SD_fresnl_fd:
v64bit  ??.SD_fsici_fd_00 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fsici_fd_01 , 0x3FE80CFEEB217A65 ,\ ;  7.51586398353378947175E-01
        ??.SD_fsici_fd_02 , 0x3FBDEC6EC1D46D7D ,\ ;  1.16888925859191382142E-01
        ??.SD_fsici_fd_03 , 0x3F7A615EA6ED56F3 ,\ ;  6.44051526508858611005E-03
        ??.SD_fsici_fd_04 , 0x3F24704A6017BD60 ,\ ;  1.55934409164153020873E-04
        ??.SD_fsici_fd_05 , 0x3EBEF9B1923264F5 ,\ ;  1.84627567348930545870E-06
        ??.SD_fsici_fd_06 , 0x3E4833B495525916 ,\ ;  1.12699224763999035261E-08
        ??.SD_fsici_fd_07 , 0x3DC3CC8533D3A061 ,\ ;  3.60140029589371370404E-11
        ??.SD_fsici_fd_08 , 0x3D30926C6B9F0790 ,\ ;  5.88754533621578410010E-14
        ??.SD_fsici_fd_09 , 0x3C8A0E5D2352F48D ,\ ;  4.52001434074129701496E-17
        ??.SD_fsici_fd_10 , 0x3BCD9E9412B96141    ;  1.25443237090011264384E-20

; Auxiliary function g(x)

$align 16
??.PD_fresnl_gnd:
v64bit  ??.PD_fsici_gn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.PD_fsici_gd_00 , 0x3FF0000000000000 ,\ ;  1.0
        ??.PD_fsici_gn_01 , 0x3FE02463B420CACA ,\ ;  5.04442073643383265887E-01
        ??.PD_fsici_gd_01 , 0x3FF7996D23BC55C1 ,\ ;  1.47495759925128324529E+00
        ??.PD_fsici_gn_02 , 0x3FC93AAA67F87481 ,\ ;  1.97102833525523411709E-01
        ??.PD_fsici_gd_02 , 0x3FD59DADEFA1C34F ,\ ;  3.37748989120019970451E-01
        ??.PD_fsici_gn_03 , 0x3F93371854BA3214 ,\ ;  1.87648584092575249293E-02
        ??.PD_fsici_gd_03 , 0x3F99F811E637AA09 ,\ ;  2.53603741420338795122E-02
        ??.PD_fsici_gn_04 , 0x3F466A7948D1B33B ,\ ;  6.84079380915393090172E-04
        ??.PD_fsici_gd_04 , 0x3F4AB2060FA0AE28 ,\ ;  8.14679107184306179049E-04
        ??.PD_fsici_gn_05 , 0x3EE82577F9FAABF3 ,\ ;  1.15138826111884280931E-05
        ??.PD_fsici_gd_05 , 0x3EEABF862C0A067B ,\ ;  1.27545075667729118702E-05
        ??.PD_fsici_gn_06 , 0x3E7A621C4DEA6091 ,\ ;  9.82852443688422223854E-08
        ??.PD_fsici_gd_06 , 0x3E7C0071AB1C7428 ,\ ;  1.04314589657571990585E-07
        ??.PD_fsici_gn_07 , 0x3DFE9A94F200EB09 ,\ ;  4.45344415861750144738E-10
        ??.PD_fsici_gd_07 , 0x3DFFA8618E3CF1C6 ,\ ;  4.60680728146520428211E-10
        ??.PD_fsici_gn_08 , 0x3D730BF5876689CB ,\ ;  1.08268041139020870318E-12
        ??.PD_fsici_gd_08 , 0x3D7366439C3DEF2B ,\ ;  1.10273215066240270757E-12
        ??.PD_fsici_gn_09 , 0x3CD8C7A03DF8A964 ,\ ;  1.37555460633261799868E-15
        ??.PD_fsici_gd_09 , 0x3CD900DC37C81936 ,\ ;  1.38796531259578871258E-15
        ??.PD_fsici_gn_10 , 0x3C2EDB24F17358A6 ,\ ;  8.36354435630677421531E-19
        ??.PD_fsici_gd_10 , 0x3C2EF5A184FF8364 ,\ ;  8.39158816283118707363E-19
        ??.PD_fsici_gn_11 , 0x3B6C409D624FBE2B ,\ ;  1.86958710162783235106E-22
        ??.PD_fsici_gd_11 , 0x3B6C409D624FBE2B    ;  1.86958710162783236342E-22

$align 16
??.SD_fresnl_gn:
v64bit  ??.SD_fsici_gn_00 , 0x0000000000000000 ,\ ;  0.0
        ??.SD_fsici_gn_01 , 0x3FE02463B420CACA ,\ ;  5.04442073643383265887E-01
        ??.SD_fsici_gn_02 , 0x3FC93AAA67F87481 ,\ ;  1.97102833525523411709E-01
        ??.SD_fsici_gn_03 , 0x3F93371854BA3214 ,\ ;  1.87648584092575249293E-02
        ??.SD_fsici_gn_04 , 0x3F466A7948D1B33B ,\ ;  6.84079380915393090172E-04
        ??.SD_fsici_gn_05 , 0x3EE82577F9FAABF3 ,\ ;  1.15138826111884280931E-05
        ??.SD_fsici_gn_06 , 0x3E7A621C4DEA6091 ,\ ;  9.82852443688422223854E-08
        ??.SD_fsici_gn_07 , 0x3DFE9A94F200EB09 ,\ ;  4.45344415861750144738E-10
        ??.SD_fsici_gn_08 , 0x3D730BF5876689CB ,\ ;  1.08268041139020870318E-12
        ??.SD_fsici_gn_09 , 0x3CD8C7A03DF8A964 ,\ ;  1.37555460633261799868E-15
        ??.SD_fsici_gn_10 , 0x3C2EDB24F17358A6 ,\ ;  8.36354435630677421531E-19
        ??.SD_fsici_gn_11 , 0x3B6C409D624FBE2B    ;  1.86958710162783235106E-22

$align 16
??.SD_fresnl_gd:
v64bit  ??.SD_fsici_gd_00 , 0x3FF0000000000000 ,\ ;  1.0
        ??.SD_fsici_gd_01 , 0x3FF7996D23BC55C1 ,\ ;  1.47495759925128324529E+00
        ??.SD_fsici_gd_02 , 0x3FD59DADEFA1C34F ,\ ;  3.37748989120019970451E-01
        ??.SD_fsici_gd_03 , 0x3F99F811E637AA09 ,\ ;  2.53603741420338795122E-02
        ??.SD_fsici_gd_04 , 0x3F4AB2060FA0AE28 ,\ ;  8.14679107184306179049E-04
        ??.SD_fsici_gd_05 , 0x3EEABF862C0A067B ,\ ;  1.27545075667729118702E-05
        ??.SD_fsici_gd_06 , 0x3E7C0071AB1C7428 ,\ ;  1.04314589657571990585E-07
        ??.SD_fsici_gd_07 , 0x3DFFA8618E3CF1C6 ,\ ;  4.60680728146520428211E-10
        ??.SD_fsici_gd_08 , 0x3D7366439C3DEF2B ,\ ;  1.10273215066240270757E-12
        ??.SD_fsici_gd_09 , 0x3CD900DC37C81936 ,\ ;  1.38796531259578871258E-15
        ??.SD_fsici_gd_10 , 0x3C2EF5A184FF8364 ,\ ;  8.39158816283118707363E-19
        ??.SD_fsici_gd_11 , 0x3B6C409D624FBE2B    ;  1.86958710162783236342E-22

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

v64bit  ??.SD_ffresnel_max_arg , 0x40E20DC000000000 ; +36974.0
v64bit  ??.SD_ffresnel_min_arg , 0xC0E20DC000000000 ; -36974.0

v64bit  ??.SD_ffresnel_DP1 , 0x4004800000000000 ; +2.5625  | domain point #1
v64bit  ??.SD_ffresnel_DP2 , 0x40E20DC000000000 ; +36974.0 | domain point #2

; ------------------------------------------------------------------------------
