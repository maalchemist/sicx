
; FASM SOURCE FILE
; http://flatassembler.net

; FPU conditional jump macros
; version 1.04

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; NOTE: jump macros modify EAX register

; ------------------------------------------------------------------------------

; f[n]stsw ax
; ah                        al
; 07 06 05 04 03 02 01 00   07 06 05 04 03 02 01 00
; ?? C3 ?? ?? ?? C2 C1 C0   ?? ?? PE UE OE ZE DE IE
; sahf
; SF ZF ?? AF ?? PF ?? CF
;
; ------------------------------------------------------------------------------

; f[n]stcw m2b
; mh                        ml
; 07 06 05 04 03 02 01 00   07 06 05 04 03 02 01 00
; ?? ?? ?? IC RC RC PC PC   ?? ?? PE UE OE ZE DE IE
;
; ------------------------------------------------------------------------------
;
; fcom[p] {ftst}
; C3 C2 C1 C0  meaning                      f[n]stsw ax      test $01  $40  $41
; 0  0  ?  0   ST > source {0}              ? 0 ? ? ? 0 ? 0        z    z    z
; 0  0  ?  1   ST < source {0}              ? 0 ? ? ? 0 ? 1        nz   z    nz
; 1  0  ?  0   ST = source {0}              ? 1 ? ? ? 0 ? 0        z    nz   nz
;
; 1  1  ?  1   ST not comparable to source  ? 1 ? ? ? 1 ? 1        nz   nz   nz
;
;                                      $01  0 0 0 0 0 0 0 1  $01
;                                      $40  0 1 0 0 0 0 0 0  $40
;                                      $41  0 1 0 0 0 0 0 1  $41
;
;                                    FLAGS  S Z ? A ? P ? C  FLAGS
;
; ------------------------------------------------------------------------------
;
;               fld     a               fld     a
;               fcom    source          fcom    source
;               fnstsw  ax              fnstsw  ax
;
; ST  > source  test    ah, $41         sahf    CF=0 & ZF=0
;               jz      .......         ja      .......
;
; ST >= source  test    ah, $01         sahf    CF=0
;               jz      .......         jae     .......
;
; ST  < source  test    ah, $01         sahf    CF=1
;               jnz     .......         jb      .......
;
; ST <= source  test    ah, $41         sahf    CF=1 | ZF=1
;               jnz     .......         jbe     .......
;
; ST == source  test    ah, $40         sahf    ZF=1
;               jnz     .......         je      .......
;
; ST <> source  test    ah, $40         sahf    ZF=0
;               jz      .......         jne     .......

; ------------------------------------------------------------------------------

; Jump if ST > source

macro   fjg     a
{
        fstsw   ax
        fajg    a
}
macro   fjgp    a
{
        fstsw   ax
        fajgp   a
}
macro   fnjg    a
{
        fnstsw  ax
        fajg    a
}
macro   fnjgp   a
{
        fnstsw  ax
        fajgp   a
}
macro   fajg    a
{
        sahf
        ja      a
;       test    ah, $41                         ; 0100 0001
;       jz      a
}
macro   fajgp   a
{
        fstp    st0
        fajg    a
}

fjnle   fix     fjg                             ; Jump if Not Less or Equal
fjnlep  fix     fjgp                            ; Jump if Not Less or Equal
fnjnle  fix     fnjg                            ; Jump if Not Less or Equal
fnjnlep fix     fnjgp                           ; Jump if Not Less or Equal
fajnle  fix     fajg                            ; Jump if Not Less or Equal
fajnlep fix     fajgp                           ; Jump if Not Less or Equal

fja     fix     fjg                             ; Jump if Above
fjap    fix     fjgp                            ; Jump if Above
fnja    fix     fnjg                            ; Jump if Above
fnjap   fix     fnjgp                           ; Jump if Above
faja    fix     fajg                            ; Jump if Above
fajap   fix     fajgp                           ; Jump if Above

fjnbe   fix     fjg                             ; Jump if Not Below or Equal
fjnbep  fix     fjgp                            ; Jump if Not Below or Equal
fnjnbe  fix     fnjg                            ; Jump if Not Below or Equal
fnjnbep fix     fnjgp                           ; Jump if Not Below or Equal
fajnbe  fix     fajg                            ; Jump if Not Below or Equal
fajnbep fix     fajgp                           ; Jump if Not Below or Equal

; ------------------------------------------------------------------------------

; Jump if ST >= source

macro   fjge    a
{
        fstsw   ax
        fajge   a
}
macro   fjgep   a
{
        fstsw   ax
        fajgep  a
}
macro   fnjge   a
{
        fnstsw  ax
        fajge   a
}
macro   fnjgep  a
{
        fnstsw  ax
        fajgep  a
}
macro   fajge   a
{
        sahf
        jae     a
;       test    ah, $01                         ; 0000 0001
;       jz      a
}
macro   fajgep  a
{
        fstp    st0
        fajge   a
}

fjnl    fix     fjge                            ; Jump if Not Less
fjnlp   fix     fjgep                           ; Jump if Not Less
fnjnl   fix     fnjge                           ; Jump if Not Less
fnjnlp  fix     fnjgep                          ; Jump if Not Less
fajnl   fix     fajge                           ; Jump if Not Less
fajnlp  fix     fajgep                          ; Jump if Not Less

fjae    fix     fjge                            ; Jump if Above or Equal
fjaep   fix     fjgep                           ; Jump if Above or Equal
fnjae   fix     fnjge                           ; Jump if Not Less
fnjaep  fix     fnjgep                          ; Jump if Not Less
fajae   fix     fajge                           ; Jump if Not Less
fajaep  fix     fajgep                          ; Jump if Not Less

fjnb    fix     fjge                            ; Jump if Not Below
fjnbp   fix     fjgep                           ; Jump if Not Below
fnjnb   fix     fnjge                           ; Jump if Not Less
fnjnbp  fix     fnjgep                          ; Jump if Not Less
fajnb   fix     fajge                           ; Jump if Not Less
fajnbp  fix     fajgep                          ; Jump if Not Less

; ------------------------------------------------------------------------------

; Jump if ST < source

macro   fjl     a
{
        fstsw   ax
        fajl    a
}
macro   fjlp    a
{
        fstsw   ax
        fajlp   a
}
macro   fnjl    a
{
        fnstsw  ax
        fajl    a
}
macro   fnjlp   a
{
        fnstsw  ax
        fajlp   a
}
macro   fajl    a
{
        sahf
        jb      a
;       test    ah, $01                         ; 0000 0001
;       jnz     a
}
macro   fajlp   a
{
        fstp    st0
        fajl    a
}

fjnge   fix     fjl                             ; Jump if Not Greater or Equal
fjngep  fix     fjlp                            ; Jump if Not Greater or Equal
fnjnge  fix     fnjl                            ; Jump if Not Greater or Equal
fnjngep fix     fnjlp                           ; Jump if Not Greater or Equal
fajnge  fix     fajl                            ; Jump if Not Greater or Equal
fajngep fix     fajlp                           ; Jump if Not Greater or Equal

fjb     fix     fjl                             ; Jump if Below
fjbp    fix     fjlp                            ; Jump if Below
fnjb    fix     fnjl                            ; Jump if Below
fnjbp   fix     fnjlp                           ; Jump if Below
fajb    fix     fajl                            ; Jump if Below
fajbp   fix     fajlp                           ; Jump if Below

fjnae   fix     fjl                             ; Jump if Not Above or Equal
fjnaep  fix     fjlp                            ; Jump if Not Above or Equal
fnjnae  fix     fnjl                            ; Jump if Not Above or Equal
fnjnaep fix     fnjlp                           ; Jump if Not Above or Equal
fajnae  fix     fajl                            ; Jump if Not Above or Equal
fajnaep fix     fajlp                           ; Jump if Not Above or Equal

; ------------------------------------------------------------------------------

; Jump if ST <= source

macro   fjle    a
{
        fstsw   ax
        fajle   a
}
macro   fjlep   a
{
        fstsw   ax
        fajlep  a
}
macro   fnjle   a
{
        fnstsw  ax
        fajle   a
}
macro   fnjlep  a
{
        fnstsw  ax
        fajlep  a
}
macro   fajle   a
{
        sahf
        jbe     a
;       test    ah, $41                         ; 0100 0001
;       jnz     a
}
macro   fajlep  a
{
        fstp    st0
        fajle   a
}

fjng    fix     fjle                            ; Jump if Not Greater
fjngp   fix     fjlep                           ; Jump if Not Greater
fnjng   fix     fnjle                           ; Jump if Not Greater
fnjngp  fix     fnjlep                          ; Jump if Not Greater
fajng   fix     fajle                           ; Jump if Not Greater
fajngp  fix     fajlep                          ; Jump if Not Greater

fjbe    fix     fjle                            ; Jump if Below or Equal
fjbep   fix     fjlep                           ; Jump if Below or Equal
fnjbe   fix     fnjle                           ; Jump if Below or Equal
fnjbep  fix     fnjlep                          ; Jump if Below or Equal
fajbe   fix     fajle                           ; Jump if Below or Equal
fajbep  fix     fajlep                          ; Jump if Below or Equal

fjna    fix     fjle                            ; Jump if Not Above
fjnap   fix     fjlep                           ; Jump if Not Above
fnjna   fix     fnjle                           ; Jump if Not Above
fnjnap  fix     fnjlep                          ; Jump if Not Above
fajna   fix     fajle                           ; Jump if Not Above
fajnap  fix     fajlep                          ; Jump if Not Above

; ------------------------------------------------------------------------------

; Jump if ST = source

macro   fje     a
{
        fstsw   ax
        faje    a
}
macro   fjep    a
{
        fstsw   ax
        fajep   a
}
macro   fnje    a
{
        fnstsw  ax
        faje    a
}
macro   fnjep   a
{
        fnstsw  ax
        fajep   a
}
macro   faje    a
{
        sahf
        je      a
;       test    ah, $40                         ; 0100 0000
;       jnz     a
}
macro   fajep   a
{
        fstp    st0
        faje    a
}

fjz     fix     fje                             ; Jump if Zero
fjzp    fix     fjep                            ; Jump if Zero
fnjz    fix     fnje                            ; Jump if Zero
fnjzp   fix     fnjep                           ; Jump if Zero
fajz    fix     faje                            ; Jump if Zero
fajzp   fix     fajep                           ; Jump if Zero

; ------------------------------------------------------------------------------

; Jump if ST <> source

macro   fjne    a
{
        fstsw   ax
        fajne   a
}
macro   fjnep   a
{
        fstsw   ax
        fajnep  a
}
macro   fnjne   a
{
        fnstsw  ax
        fajne   a
}
macro   fnjnep  a
{
        fnstsw  ax
        fajnep  a
}
macro   fajne   a
{
        sahf
        jne     a
;       test    ah, $40                         ; 0100 0000
;       jz      a
}
macro   fajnep  a
{
        fstp    st0
        fajne   a
}

fjnz    fix     fjne                            ; Jump if Not Zero
fjnzp   fix     fjnep                           ; Jump if Not Zero
fnjnz   fix     fnjne                           ; Jump if Not Zero
fnjnzp  fix     fnjnep                          ; Jump if Not Zero
fajnz   fix     fajne                           ; Jump if Not Zero
fajnzp  fix     fajnep                          ; Jump if Not Zero

; ------------------------------------------------------------------------------

; Jump if C0 flag = 1

macro   fjC0    a
{
        fstsw   ax
        fajC0   a
}
macro   fjC0p   a
{
        fstsw   ax
        fajC0p  a
}
macro   fnjC0   a
{
        fnstsw  ax
        fajC0   a
}
macro   fnjC0p  a
{
        fnstsw  ax
        fajC0p  a
}
macro   fajC0   a
{
        sahf
        jc      a
;       test    ah, $01                         ; 0000 0001
;       jnz     a
}
macro   fajC0p  a
{
        fstp    st0
        fajC0   a
}

; ------------------------------------------------------------------------------

; Jump if C0 flag = 0

macro   fjnC0   a
{
        fstsw   ax
        fajnC0  a
}
macro   fjnC0p  a
{
        fstsw   ax
        fajnC0p a
}
macro   fnjnC0  a
{
        fnstsw  ax
        fajnC0  a
}
macro   fnjnC0p a
{
        fnstsw  ax
        fajnC0p a
}
macro   fajnC0  a
{
        sahf
        jnc     a
;       test    ah, $01                         ; 0000 0001
;       jz      a
}
macro   fajnC0p a
{
        fstp    st0
        fajnC0  a
}

; ------------------------------------------------------------------------------

; Jump if C1 flag = 1

macro   fjC1    a
{
        fstsw   ax
        fajC1   a
}
macro   fjC1p   a
{
        fstsw   ax
        fajC1p  a
}
macro   fnjC1   a
{
        fnstsw  ax
        fajC1   a
}
macro   fnjC1p  a
{
        fnstsw  ax
        fajC1p  a
}
macro   fajC1   a
{
        test    ah, $02                         ; 0000 0010
        jnz     a
}
macro   fajC1p  a
{
        fstp    st0
        fajC1   a
}

; ------------------------------------------------------------------------------

; Jump if C1 flag = 0

macro   fjnC1   a
{
        fstsw   ax
        fajnC1  a
}
macro   fjnC1p  a
{
        fstsw   ax
        fajnC1p a
}
macro   fnjnC1  a
{
        fnstsw  ax
        fajnC1  a
}
macro   fnjnC1p a
{
        fnstsw  ax
        fajnC1p a
}
macro   fajnC1  a
{
        test    ah, $02                         ; 0000 0010
        jz      a
}
macro   fajnC1p a
{
        fstp    st0
        fajnC1  a
}

; ------------------------------------------------------------------------------

; Jump if C2 flag = 1

macro   fjC2    a
{
        fstsw   ax
        fajC2   a
}
macro   fjC2p   a
{
        fstsw   ax
        fajC2p  a
}
macro   fnjC2   a
{
        fnstsw  ax
        fajC2   a
}
macro   fnjC2p  a
{
        fnstsw  ax
        fajC2p  a
}
macro   fajC2   a
{
        sahf
        jp      a
;       test    ah, $04                         ; 0000 0100
;       jnz     a
}
macro   fajC2p  a
{
        fstp    st0
        fajC2   a
}

; ------------------------------------------------------------------------------

; Jump if C2 flag = 0

macro   fjnC2   a
{
        fstsw   ax
        fajnC2  a
}
macro   fjnC2p  a
{
        fstsw   ax
        fajnC2p a
}
macro   fnjnC2  a
{
        fnstsw  ax
        fajnC2  a
}
macro   fnjnC2p a
{
        fnstsw  ax
        fajnC2p a
}
macro   fajnC2  a
{
        sahf
        jnp     a
;       test    ah, $04                         ; 0000 0100
;       jz      a
}
macro   fajnC2p a
{
        fstp    st0
        fajnC2  a
}

; ------------------------------------------------------------------------------

; Jump if C3 flag = 1

macro   fjC3    a
{
        fstsw   ax
        fajC3   a
}
macro   fjC3p   a
{
        fstsw   ax
        fajC3p  a
}
macro   fnjC3   a
{
        fnstsw  ax
        fajC3   a
}
macro   fnjC3p  a
{
        fnstsw  ax
        fajC3p  a
}
macro   fajC3   a
{
        sahf
        jz      a
;       test    ah, $40                         ; 0100 0000
;       jnz     a
}
macro   fajC3p  a
{
        fstp    st0
        fajC3   a
}

; ------------------------------------------------------------------------------

; Jump if C3 flag = 0

macro   fjnC3   a
{
        fstsw   ax
        fajnC3  a
}
macro   fjnC3p  a
{
        fstsw   ax
        fajnC3p a
}
macro   fnjnC3  a
{
        fnstsw  ax
        fajnC3  a
}
macro   fnjnC3p a
{
        fnstsw  ax
        fajnC3p a
}
macro   fajnC3  a
{
        sahf
        jnz     a
;       test    ah, $40                         ; 0100 0000
;       jz      a
}
macro   fajnC3p a
{
        fstp    st0
        fajnC3  a
}

; ------------------------------------------------------------------------------

; Jump if IE flag = 1

macro   fjIE    a
{
        fstsw   ax
        fajIE   a
}
macro   fjIEp   a
{
        fstsw   ax
        fajIEp  a
}
macro   fnjIE   a
{
        fnstsw  ax
        fajIE   a
}
macro   fnjIEp  a
{
        fnstsw  ax
        fajIEp  a
}
macro   fajIE   a
{
        test    al, $01                         ; 0000 0001
        jnz     a
}
macro   fajIEp  a
{
        fstp    st0
        fajIE   a
}

; ------------------------------------------------------------------------------

; Jump if IE flag = 0

macro   fjnIE   a
{
        fstsw   ax
        fajnIE  a
}
macro   fjnIEp  a
{
        fstsw   ax
        fajnIEp a
}
macro   fnjnIE  a
{
        fnstsw  ax
        fajnIE  a
}
macro   fnjnIEp a
{
        fnstsw  ax
        fajnIEp a
}
macro   fajnIE  a
{
        test    al, $01                         ; 0000 0001
        jz      a
}
macro   fajnIEp a
{
        fstp    st0
        fajnIE  a
}

; ------------------------------------------------------------------------------

; Jump if DE flag = 1

macro   fjDE    a
{
        fstsw   ax
        fajDE   a
}
macro   fjDEp   a
{
        fstsw   ax
        fajDEp  a
}
macro   fnjDE   a
{
        fnstsw  ax
        fajDE   a
}
macro   fnjDEp  a
{
        fnstsw  ax
        fajDEp  a
}
macro   fajDE   a
{
        test    al, $02                         ; 0000 0010
        jnz     a
}
macro   fajDEp  a
{
        fstp    st0
        fajDE   a
}

; ------------------------------------------------------------------------------

; Jump if DE flag = 0

macro   fjnDE   a
{
        fstsw   ax
        fajnDE  a
}
macro   fjnDEp  a
{
        fstsw   ax
        fajnDEp a
}
macro   fnjnDE  a
{
        fnstsw  ax
        fajnDE  a
}
macro   fnjnDEp a
{
        fnstsw  ax
        fajnDEp a
}
macro   fajnDE  a
{
        test    al, $02                         ; 0000 0010
        jz      a
}
macro   fajnDEp a
{
        fstp    st0
        fajnDE  a
}

; ------------------------------------------------------------------------------

; Jump if ZE flag = 1

macro   fjZE    a
{
        fstsw   ax
        fajZE   a
}
macro   fjZEp   a
{
        fstsw   ax
        fajZEp  a
}
macro   fnjZE   a
{
        fnstsw  ax
        fajZE   a
}
macro   fnjZEp  a
{
        fnstsw  ax
        fajZEp  a
}
macro   fajZE   a
{
        test    al, $04                         ; 0000 0100
        jnz     a
}
macro   fajZEp  a
{
        fstp    st0
        fajZE   a
}

; ------------------------------------------------------------------------------

; Jump if ZE flag = 0

macro   fjnZE   a
{
        fstsw   ax
        fajnZE  a
}
macro   fjnZEp  a
{
        fstsw   ax
        fajnZEp a
}
macro   fnjnZE  a
{
        fnstsw  ax
        fajnZE  a
}
macro   fnjnZEp a
{
        fnstsw  ax
        fajnZEp a
}
macro   fajnZE  a
{
        test    al, $04                         ; 0000 0100
        jz      a
}
macro   fajnZEp a
{
        fstp    st0
        fajnZE  a
}

; ------------------------------------------------------------------------------

; Jump if OE flag = 1

macro   fjOE    a
{
        fstsw   ax
        fajOE   a
}
macro   fjOEp   a
{
        fstsw   ax
        fajOEp  a
}
macro   fnjOE   a
{
        fnstsw  ax
        fajOE   a
}
macro   fnjOEp  a
{
        fnstsw  ax
        fajOEp  a
}
macro   fajOE   a
{
        test    al, $08                         ; 0000 1000
        jnz     a
}
macro   fajOEp  a
{
        fstp    st0
        fajOE   a
}

; ------------------------------------------------------------------------------

; Jump if OE flag = 0

macro   fjnOE   a
{
        fstsw   ax
        fajnOE  a
}
macro   fjnOEp  a
{
        fstsw   ax
        fajnOEp a
}
macro   fnjnOE  a
{
        fnstsw  ax
        fajnOE  a
}
macro   fnjnOEp a
{
        fnstsw  ax
        fajnOEp a
}
macro   fajnOE  a
{
        test    al, $08                         ; 0000 1000
        jz      a
}
macro   fajnOEp a
{
        fstp    st0
        fajnOE  a
}

; ------------------------------------------------------------------------------

; Jump if UE flag = 1

macro   fjUE    a
{
        fstsw   ax
        fajUE   a
}
macro   fjUEp   a
{
        fstsw   ax
        fajUEp  a
}
macro   fnjUE   a
{
        fnstsw  ax
        fajUE   a
}
macro   fnjUEp  a
{
        fnstsw  ax
        fajUEp  a
}
macro   fajUE   a
{
        test    al, $10                         ; 0001 0000
        jnz     a
}
macro   fajUEp  a
{
        fstp    st0
        fajUE   a
}

; ------------------------------------------------------------------------------

; Jump if UE flag = 0

macro   fjnUE   a
{
        fstsw   ax
        fajnUE  a
}
macro   fjnUEp  a
{
        fstsw   ax
        fajnUEp a
}
macro   fnjnUE  a
{
        fnstsw  ax
        fajnUE  a
}
macro   fnjnUEp a
{
        fnstsw  ax
        fajnUEp a
}
macro   fajnUE  a
{
        test    al, $10                         ; 0001 0000
        jz      a
}
macro   fajnUEp a
{
        fstp    st0
        fajnUE  a
}

; ------------------------------------------------------------------------------

; Jump if PE flag = 1

macro   fjPE    a
{
        fstsw   ax
        fajPE   a
}
macro   fjPEp   a
{
        fstsw   ax
        fajPEp  a
}
macro   fnjPE   a
{
        fnstsw  ax
        fajPE   a
}
macro   fnjPEp  a
{
        fnstsw  ax
        fajPEp  a
}
macro   fajPE   a
{
        test    al, $20                         ; 0010 0000
        jnz     a
}
macro   fajPEp  a
{
        fstp    st0
        fajPE   a
}

; ------------------------------------------------------------------------------

; Jump if PE flag = 0

macro   fjnPE   a
{
        fstsw   ax
        fajnPE  a
}
macro   fjnPEp  a
{
        fstsw   ax
        fajnPEp a
}
macro   fnjnPE  a
{
        fnstsw  ax
        fajnPE  a
}
macro   fnjnPEp a
{
        fnstsw  ax
        fajnPEp a
}
macro   fajnPE  a
{
        test    al, $20                         ; 0010 0000
        jz      a
}
macro   fajnPEp a
{
        fstp    st0
        fajnPE  a
}

; ------------------------------------------------------------------------------
