
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (bitwise functions II)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise reset
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@breset

;       mov     eax, dword [esp]                ; eax = x integer value
;       mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        xor     eax, eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.breset

;       mov     eax, dword [esp]
   .enter:
        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.breset.0

        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.breset.1

        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.breset.m1

        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise set
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bset

;       mov     eax, dword [esp]                ; eax = x integer value
;       mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        mov     eax, -1
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bset

;       mov     eax, dword [esp]
   .enter:
        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bset.0

        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bset.1

        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bset.m1

        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise or not
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@born
  @@.bopn or
$endp

; ------------------------------------------------------------------------------

; copy born(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.born

        mov     eax, dword [esp]
   .enter:
        mov     edx, dword [ecx]                ; edx = dst
        not     eax                             ; eax = not src
        or      eax, edx
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy born(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.born.0

;       mov     eax, dword [ecx]
;       mov     edx, 0
;       not     edx                             ; edx = -1
;       or      eax, edx                        ; eax = -1
;       mov     dword [ecx], eax

        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy born(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.born.1

;       mov     eax, dword [ecx]
;       mov     edx, 1
;       not     edx                             ; edx = .... FFFF FFFE
;       or      eax, edx
;       mov     qword [ecx], eax

    $ifdef _X64
        mov     rax, qword [rcx]
        mov     rdx, 0xFFFFFFFFFFFFFFFE
        or      rax, rdx
        mov     qword [rcx], rax
    $else
        mov     eax, dword [ecx]
        or      eax, 0xFFFFFFFE
        mov     dword [ecx], eax
    $end
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy born(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.born.m1

;       mov     eax, dword [ecx]
;       mov     edx, -1
;       not     edx                             ; edx = 0
;       or      eax, edx                        ; eax = eax
;       mov     dword [ecx], eax

        mov     eax, dword [ecx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not or not
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bnorn
  @@.bnopn or
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bnorn

        mov     eax, dword [esp]
   .enter:
        mov     edx, dword [ecx]                ; edx = dst
        not     eax                             ; eax = not src
        or      eax, edx
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnorn.0

;       mov     eax, dword [ecx]
;       mov     edx, 0
;       not     edx                             ; edx = -1
;       or      eax, edx                        ; eax = -1
;       not     eax                             ; eax = 0
;       mov     dword [ecx], eax

        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnorn.1

;       mov     eax, dword [ecx]
;       mov     edx, 1
;       not     edx                             ; edx = .... FFFF FFFE
;       or      eax, edx
;       not     eax
;       mov     dword [ecx], eax

    $ifdef _X64
        mov     rax, qword [rcx]
        mov     rdx, 0xFFFFFFFFFFFFFFFE
        or      rax, rdx
        not     rax
        mov     qword [rcx], rax
    $else
        mov     eax, dword [ecx]
        or      eax, 0xFFFFFFFE
        not     eax
        mov     dword [ecx], eax
    $end
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnorn.m1

;       mov     eax, dword [ecx]
;       mov     edx, -1
;       not     edx                             ; edx = 0
;       or      eax, edx                        ; eax = eax
;       not     eax                             ; eax = not eax
;       mov     dword [ecx], eax

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise and not
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bandn
  @@.bopn and
$endp

; ------------------------------------------------------------------------------

; bitwise and not
; return result in rax
; x = esp
; y = esp + 4

$usprocf @@bandn.bmi

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
    .enter:
        andn    eax, ecx, eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bandn

        mov     eax, dword [esp]
   .enter:
        mov     edx, dword [ecx]                ; edx = dst
        not     eax                             ; eax = not src
        and     eax, edx
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bandn.bmi

        mov     eax, dword [esp]
   .enter:
        mov     edx, dword [ecx]                ; edx = dst
        andn    eax, eax, edx
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bandn.0

;       mov     eax, dword [ecx]
;       mov     edx, 0
;       not     edx                             ; edx = -1
;       and     eax, edx                        ; eax = eax
;       mov     dword [ecx], eax

        mov     eax, dword [ecx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bandn.1

;       mov     eax, dword [ecx]
;       mov     edx, 1
;       not     edx                             ; edx = .... FFFF FFFE
;       and     eax, edx
;       mov     dword [ecx], eax

    $ifdef _X64
        mov     rax, qword [rcx]
        mov     rdx, 0xFFFFFFFFFFFFFFFE
        and     rax, rdx
        mov     qword [rcx], rax
    $else
        mov     eax, dword [ecx]
        and     eax, 0xFFFFFFFE
        mov     dword [ecx], eax
    $end
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bandn.m1

;       mov     eax, dword [ecx]
;       mov     edx, -1
;       not     edx                             ; edx = 0
;       and     eax, edx                        ; eax = 0
;       mov     dword [ecx], eax

        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not and not
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bnandn
  @@.bnopn and
$endp

; ------------------------------------------------------------------------------

; bitwise not and not
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bnandn.bmi

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
    .enter:
        andn    eax, ecx, eax
        not     eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bnandn

        mov     eax, dword [esp]
   .enter:
        mov     edx, dword [ecx]                ; edx = dst
        not     eax                             ; eax = not src
        and     eax, edx
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bnandn.bmi

        mov     eax, dword [esp]
   .enter:
        mov     edx, dword [ecx]                ; edx = dst
        andn    eax, eax, edx
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnandn.0

;       mov     eax, dword [ecx]
;       mov     edx, 0
;       not     edx                             ; edx = -1
;       and     eax, edx                        ; eax = eax
;       not     eax                             ; eax = not eax
;       mov     dword [ecx], eax

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnandn.1

;       mov     eax, dword [ecx]
;       mov     edx, 1
;       not     edx                             ; edx = .... FFFF FFFE
;       and     eax, edx
;       not     eax
;       mov     dword [ecx], eax

    $ifdef _X64
        mov     rax, qword [rcx]
        mov     rdx, 0xFFFFFFFFFFFFFFFE
        and     rax, rdx
        not     rax
        mov     qword [rcx], rax
    $else
        mov     eax, dword [ecx]
        and     eax, 0xFFFFFFFE
        not     eax
        mov     dword [ecx], eax
    $end
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnandn.m1

;       mov     eax, dword [ecx]
;       mov     edx, -1
;       not     edx                             ; edx = 0
;       and     eax, edx                        ; eax = 0
;       not     eax                             ; eax = -1
;       mov     dword [ecx], eax

        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise or clear
; borc(x,y) = x or (y and 0) = x
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@borc

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.borc

        mov     eax, dword [esp]
   .enter:
        mov     eax, dword [ecx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.borc.0

        mov     eax, dword [ecx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.borc.1

        mov     eax, dword [ecx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.borc.m1

        mov     eax, dword [ecx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not or clear
; bnorc(x,y) = (not x) or (y and 0) = (not x)
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bnorc

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        not     eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bnorc

        mov     eax, dword [esp]
   .enter:
        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnorc.0

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnorc.1

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnorc.m1

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise clear or
; bcor(x,y) = (x and 0) or y = y
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bcor

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        mov     eax, ecx
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bcor

        mov     eax, dword [esp]
   .enter:
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bcor.0

        xor     eax, eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bcor.1

        mov     eax, 1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bcor.m1

        mov     eax, -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise clear or not
; bcorn(x,y) = (x and 0) or (not y) = (not y)
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bcorn

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        mov     eax, ecx
        not     eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bcorn

        mov     eax, dword [esp]
   .enter:
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bcorn.0

        mov     eax, -1                         ; eax = not 0
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bcorn.1

        mov     eax, 0xFFFFFFFE                 ; eax = not 1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bcorn.m1

        xor     eax, eax                        ; eax = not -1
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; Hamming weight
; integer hammw ( integer x )
; return result in eax
; x = esp

$usprocf @@hammw

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        mov     edx, eax
        xor     eax, eax
   .bsf:
        bsf     ecx, edx
        jz     .return
        inc     eax
        inc     ecx
        shr     edx, cl
        jnz    .bsf
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; Hamming weight
; integer hammw ( integer x )
; return result in eax
; x = esp

$usprocf @@hammw.cpu

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        popcnt  eax, eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; Hamming distance
; integer hammd ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@hammd

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        mov     edx, ecx
        xor     edx, eax                        ; hammd(x,y) = hammw(x xor y)
        xor     eax, eax
   .bsf:
        bsf     ecx, edx
        jz     .return
        inc     eax
        inc     ecx
        shr     edx, cl
        jnz    .bsf
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; Hamming distance
; integer hammd ( integer x, integer y )
; return result in rax
; x = esp
; y = esp + 4

$usprocf @@hammd.cpu

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        xor     eax, ecx                        ; hammd(x,y) = hammw(x xor y)
        popcnt  eax, eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
