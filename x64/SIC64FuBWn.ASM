
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
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@breset

;       mov     rax, qword [rsp]                ; rax = x integer value
;       mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        xor     rax, rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.breset

;       mov     rax, qword [rsp]
   .enter:
        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.breset.0

        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.breset.1

        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy breset(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.breset.m1

        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise set
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bset

;       mov     rax, qword [rsp]                ; rax = x integer value
;       mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        mov     rax, -1
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bset

;       mov     rax, qword [rsp]
   .enter:
        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bset.0

        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bset.1

        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bset(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bset.m1

        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise or not
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@born
  @@.bopn or
$endp

; ------------------------------------------------------------------------------

; copy born(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.born

        mov     rax, qword [rsp]
   .enter:
        mov     rdx, qword [rcx]                ; rdx = dst
        not     rax                             ; rax = not src
        or      rax, rdx
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy born(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.born.0

;       mov     rax, qword [rcx]
;       mov     rdx, 0
;       not     rdx                             ; rdx = -1
;       or      rax, rdx                        ; rax = -1
;       mov     qword [rcx], rax

        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy born(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.born.1

;       mov     rax, qword [rcx]
;       mov     rdx, 1
;       not     rdx                             ; rdx = .... FFFF FFFE
;       or      rax, rdx
;       mov     qword [rcx], rax

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
; return result in rax
; dst offset = rcx

$usprocf @@_co.born.m1

;       mov     rax, qword [rcx]
;       mov     rdx, -1
;       not     rdx                             ; rdx = 0
;       or      rax, rdx                        ; rax = rax
;       mov     qword [rcx], rax

        mov     rax, qword [rcx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not or not
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bnorn
  @@.bnopn or
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bnorn

        mov     rax, qword [rsp]
   .enter:
        mov     rdx, qword [rcx]                ; rdx = dst
        not     rax                             ; rax = not src
        or      rax, rdx
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnorn.0

;       mov     rax, qword [rcx]
;       mov     rdx, 0
;       not     rdx                             ; rdx = -1
;       or      rax, rdx                        ; rax = -1
;       not     rax                             ; rax = 0
;       mov     qword [rcx], rax

        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorn(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnorn.1

;       mov     rax, qword [rcx]
;       mov     rdx, 1
;       not     rdx                             ; rdx = .... FFFF FFFE
;       or      rax, rdx
;       not     rax
;       mov     qword [rcx], rax

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
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnorn.m1

;       mov     rax, qword [rcx]
;       mov     rdx, -1
;       not     rdx                             ; rdx = 0
;       or      rax, rdx                        ; rax = rax
;       not     rax                             ; rax = not rax
;       mov     qword [rcx], rax

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise and not
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bandn
  @@.bopn and
$endp

; ------------------------------------------------------------------------------

; bitwise and not
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bandn.bmi

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
    .enter:
        andn    rax, rcx, rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bandn

        mov     rax, qword [rsp]
   .enter:
        mov     rdx, qword [rcx]                ; rdx = dst
        not     rax                             ; rax = not src
        and     rax, rdx
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bandn.bmi

        mov     rax, qword [rsp]
   .enter:
        mov     rdx, qword [rcx]                ; rdx = dst
        andn    rax, rax, rdx
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bandn.0

;       mov     rax, qword [rcx]
;       mov     rdx, 0
;       not     rdx                             ; rdx = -1
;       and     rax, rdx                        ; rax = rax
;       mov     qword [rcx], rax

        mov     rax, qword [rcx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bandn(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bandn.1

;       mov     rax, qword [rcx]
;       mov     rdx, 1
;       not     rdx                             ; rdx = .... FFFF FFFE
;       and     rax, rdx
;       mov     qword [rcx], rax

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
; return result in rax
; dst offset = rcx

$usprocf @@_co.bandn.m1

;       mov     rax, qword [rcx]
;       mov     rdx, -1
;       not     rdx                             ; rdx = 0
;       and     rax, rdx                        ; rax = 0
;       mov     qword [rcx], rax

        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not and not
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bnandn
  @@.bnopn and
$endp

; ------------------------------------------------------------------------------

; bitwise not and not
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bnandn.bmi

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
    .enter:
        andn    rax, rcx, rax
        not     rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bnandn

        mov     rax, qword [rsp]
   .enter:
        mov     rdx, qword [rcx]                ; rdx = dst
        not     rax                             ; rax = not src
        and     rax, rdx
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bnandn.bmi

        mov     rax, qword [rsp]
   .enter:
        mov     rdx, qword [rcx]                ; rdx = dst
        andn    rax, rax, rdx
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnandn.0

;       mov     rax, qword [rcx]
;       mov     rdx, 0
;       not     rdx                             ; rdx = -1
;       and     rax, rdx                        ; rax = rax
;       not     rax                             ; rax = not rax
;       mov     qword [rcx], rax

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnandn(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnandn.1

;       mov     rax, qword [rcx]
;       mov     rdx, 1
;       not     rdx                             ; rdx = .... FFFF FFFE
;       and     rax, rdx
;       not     rax
;       mov     qword [rcx], rax

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
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnandn.m1

;       mov     rax, qword [rcx]
;       mov     rdx, -1
;       not     rdx                             ; rdx = 0
;       and     rax, rdx                        ; rax = 0
;       not     rax                             ; rax = -1
;       mov     qword [rcx], rax

        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise or clear
; borc(x,y) = x or (y and 0) = x
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@borc

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
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

        mov     rax, qword [rsp]
   .enter:
        mov     rax, qword [rcx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.borc.0

        mov     rax, qword [rcx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.borc.1

        mov     rax, qword [rcx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy borc(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.borc.m1

        mov     rax, qword [rcx]
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not or clear
; bnorc(x,y) = (not x) or (y and 0) = (not x)
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bnorc

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        not     rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bnorc

        mov     rax, qword [rsp]
   .enter:
        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnorc.0

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnorc.1

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnorc(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnorc.m1

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise clear or
; bcor(x,y) = (x and 0) or y = y
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bcor

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        mov     rax, rcx
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bcor

        mov     rax, qword [rsp]
   .enter:
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bcor.0

        xor     rax, rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bcor.1

        mov     rax, 1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcor(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bcor.m1

        mov     rax, -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise clear or not
; bcorn(x,y) = (x and 0) or (not y) = (not y)
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bcorn

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        mov     rax, rcx
        not     rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bcorn

        mov     rax, qword [rsp]
   .enter:
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bcorn.0

        mov     rax, -1                         ; rax = not 0
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bcorn.1

        mov     rax, 0xFFFFFFFFFFFFFFFE         ; rax = not 1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bcorn(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bcorn.m1

        xor     rax, rax                        ; rax = not -1
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; Hamming weight
; integer hammw ( integer x )
; return result in rax
; x = rsp

$usprocf @@hammw

        mov     rax, qword [rsp]                ; rax = x integer value
   .enter:
        mov     rdx, rax
        xor     rax, rax
   .bsf:
        bsf     rcx, rdx
        jz     .return
        inc     rax
        inc     rcx
        shr     rdx, cl
        jnz    .bsf
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; Hamming weight
; integer hammw ( integer x )
; return result in rax
; x = rsp

$usprocf @@hammw.cpu

        mov     rax, qword [rsp]                ; rax = x integer value
   .enter:
        popcnt  rax, rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; Hamming distance
; integer hammd ( integer x, integer y )
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@hammd

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        mov     rdx, rcx
        xor     rdx, rax                        ; hammd(x,y) = hammw(x xor y)
        xor     rax, rax
   .bsf:
        bsf     rcx, rdx
        jz     .return
        inc     rax
        inc     rcx
        shr     rdx, cl
        jnz    .bsf
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; Hamming distance
; integer hammd ( integer x, integer y )
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@hammd.cpu

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        xor     rax, rcx                        ; hammd(x,y) = hammw(x xor y)
        popcnt  rax, rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
