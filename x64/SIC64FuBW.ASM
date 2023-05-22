
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (bitwise functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; bit scan forward
; integer bsf ( integer x )
; return result in rax
; x = rsp

$usprocf @@bsf

        mov     rax, qword [rsp]                ; rax = x integer value
   .enter:
        bsf     rax, rax
        jnz    .return
        xor     rax, rax
        dec     rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit scan reverse
; integer bsr ( integer x )
; return result in rax
; x = rsp

$usprocf @@bsr

        mov     rax, qword [rsp]                ; rax = x integer value
   .enter:
        bsr     rax, rax
        jnz    .return
        xor     rax, rax
        dec     rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bit test
; integer bt ( integer x, integer y )
; return the destination bit indexed by the y value in rax
; x = rsp
; y = rsp + 8

$usprocf @@bt

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        bt      rax, rcx
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and complement
; integer btc ( integer x, integer y )
; return the destination bit indexed by the y value in rax and complement (invert) the destination bit
; x = rsp
; y = rsp + 8

$usprocf @@btc

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        btc     rax, rcx
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and complement
; integer btc ( integer *x, integer y )
; return the destination bit indexed by the y value in rax and complement (invert) the destination bit
; *x = rcx
;  y = rsp

$usprocf @@btc_ivar

        mov     rax, qword [rsp]
   .enter:
        btc     qword [rcx], rax
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and reset
; integer btr ( integer x, integer y )
; return the destination bit indexed by the y value in rax and clear the destination bit
; x = rsp
; y = rsp + 8

$usprocf @@btr

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        btr     rax, rcx
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and reset
; integer btr ( integer *x, integer y )
; return the destination bit indexed by the y value in rax and clear the destination bit
; *x = rcx
;  y = rsp

$usprocf @@btr_ivar

        mov     rax, qword [rsp]
   .enter:
        btr     qword [rcx], rax
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and set
; integer bts ( integer x, integer y )
; return the destination bit indexed by the y value in rax and set in the destination bit
; x = rsp
; y = rsp + 8

$usprocf @@bts

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        bts     rax, rcx
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and set
; integer bts ( integer *x, integer y )
; return the destination bit indexed by the y value in rax and set in the destination bit
; *x = rcx
;  y = rsp

$usprocf @@bts_ivar

        mov     rax, qword [rsp]
   .enter:
        bts     qword [rcx], rax
        mov     eax, 0                          ; rax = 0 ; mov instruction does not modify flags
        adc     rax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not
; integer bnot ( integer x )
; return result in rax
; x = rsp

$usprocf @@bnot

        mov     rax, qword [rsp]                ; rax = x integer value
   .enter:
        not     rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnot(dst) to dst
; integer co.bnot ( integer *dst )
; return result in rax
; dst offset = rcx

$usprocf @@co.bnot

        mov     rax, qword [rcx]
   .enter:
        not     rax
        mov     qword [rcx], rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise operation
; integer bop ( integer x, integer y )
; return result in rax
; x = rsp
; y = rsp + 8

macro @@.bop bop
{
        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        bop     rax, rcx
   .return:
        retn
}

; ------------------------------------------------------------------------------

; bitwise post not operation
; integer bnop ( integer x, integer y )
; return result in rax
; x = rsp
; y = rsp + 8

macro @@.bnop bop
{
        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        bop     rax, rcx
        not     rax
   .return:
        retn
}

; ------------------------------------------------------------------------------

; bitwise pre not operation
; integer bopn ( integer x, integer y )
; return result in rax
; x = rsp
; y = rsp + 8

macro @@.bopn bop
{
        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        not     rcx
        bop     rax, rcx
   .return:
        retn
}

; ------------------------------------------------------------------------------

; bitwise pre & post not operation
; integer bnopn ( integer x, integer y )
; return result in rax
; x = rsp
; y = rsp + 8

macro @@.bnopn bop
{
        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        not     rcx
        bop     rax, rcx
        not     rax
   .return:
        retn
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise or
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bor
  @@.bop or
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bor

        mov     rax, qword [rsp]
    .enter:
        or      rax, qword [rcx]
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bor.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bor.1

        mov     rax, qword [rcx]
        or      rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bor.m1

;       mov     rax, qword [rcx]
;       or      rax, -1
;       mov     qword [rcx], rax

        mov     rax, -1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not or
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bnor
  @@.bnop or
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bnor

        mov     rax, qword [rsp]
    .enter:
        or      rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnor.0

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnor.1

        mov     rax, qword [rcx]
        or      rax, 1
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnor.m1

;       mov     rax, qword [rcx]
;       or      rax, -1
;       not     rax                             ; rax = 0
;       mov     qword [rcx], rax

        xor     rax, rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise xor
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bxor
  @@.bop xor
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bxor

        mov     rax, qword [rsp]
    .enter:
        xor     rax, qword [rcx]
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bxor.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bxor.1

        mov     rax, qword [rcx]
        xor     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bxor.m1

        mov     rax, qword [rcx]
        not     rax
;       xor     rax, -1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not xor
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bxnor
  @@.bnop xor
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bxnor

        mov     rax, qword [rsp]
    .enter:
        xor     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bxnor.0

;       mov     rax, qword [rcx]
;       xor     rax, 0                          ; rax = rax
;       not     rax                             ; rax = not rax
;       mov     qword [rcx], rax

        mov     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bxnor.1

        mov     rax, qword [rcx]
        xor     rax, 1
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bxnor.m1

;       xor     rax, -1                         ; rax = not rax
;       not     rax                             ; rax = rax

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise and
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@band
  @@.bop and
$endp

; ------------------------------------------------------------------------------

; copy band(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.band

        mov     rax, qword [rsp]
    .enter:
        and     rax, qword [rcx]
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy band(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.band.0

        xor     rax, rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy band(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.band.1

        mov     rax, qword [rcx]
        and     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy band(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.band.m1

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not and
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@bnand
  @@.bnop and
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.bnand

        mov     rax, qword [rsp]
    .enter:
        and     rax, qword [rcx]
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnand.0

        mov     rax, -1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnand.1

        mov     rax, qword [rcx]
        and     rax, 1
        not     rax
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.bnand.m1

;       mov     rax, qword [rcx]
;       and     rax, -1                         ; rax = rax
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

; bitwise shift
; return result in rax
; x = rsp
; y = rsp + 8
;
; op.pos - operation for positive values
; op.neg - operation for negative values

macro @@.shift op.pos, op.neg
{
        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
    .enter:
        test    rcx, rcx
;       jz     .return
        jns    .op.pos
        neg     rcx
    .op.neg:
        op.neg  rax, cl
        jmp    .return
    .op.pos:
        op.pos  rax, cl
    .return:
        retn
}

; ------------------------------------------------------------------------------

; copy shift(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp
;
; op.pos - operation for positive values
; op.neg - operation for negative values

macro @@.co.shift op.pos, op.neg
{
        mov     rdx, rcx                        ; rdx = dst offset
        mov     rax, [rcx]                      ; rax = dst integer value
        mov     rcx, [rsp]                      ; rcx = src integer value
    .enter:
        test    rcx, rcx
;       jz     .return
        jns    .op.pos
        neg     rcx
    .op.neg:
        op.neg  rax, cl
        jmp    .return
    .op.pos:
        op.pos  rax, cl
    .return:
        mov     [rdx], rax
        retn
}

; ------------------------------------------------------------------------------

; bitwise shift right
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@shr
  @@.shift shr, shl
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.shr
  @@.co.shift shr, shl
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.shr.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.shr.1

        mov     rax, qword [rcx]
        shr     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.shr.m1

        mov     rax, qword [rcx]
        shl     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise shift left
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@shl
  @@.shift shl, shr
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.shl
  @@.co.shift shl, shr
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.shl.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.shl.1

        mov     rax, qword [rcx]
        shl     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.shl.m1

        mov     rax, qword [rcx]
        shr     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise shift arithmetic right
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@sar
  @@.shift sar, sal
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.sar
  @@.co.shift sar, sal
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.sar.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.sar.1

        mov     rax, qword [rcx]
        sar     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.sar.m1

        mov     rax, qword [rcx]
        sal     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise shift arithmetic left
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@sal
  @@.shift sal, sar
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.sal
  @@.co.shift sal, sar
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.sal.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.sal.1

        mov     rax, qword [rcx]
        sal     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.sal.m1

        mov     rax, qword [rcx]
        sar     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise rotate right
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@ror
  @@.shift ror, rol
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.ror
  @@.co.shift ror, rol
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.ror.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.ror.1

        mov     rax, qword [rcx]
        ror     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.ror.m1

        mov     rax, qword [rcx]
        rol     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise rotate left
; return result in rax
; x = rsp
; y = rsp + 8

$usprocf @@rol
  @@.shift rol, ror
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,src) to dst
; return result in rax
; dst offset = rcx
; src value  = rsp

$usprocf @@co.rol
  @@.co.shift rol, ror
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,0) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.rol.0

        mov     rax, qword [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.rol.1

        mov     rax, qword [rcx]
        rol     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,-1) to dst
; return result in rax
; dst offset = rcx

$usprocf @@_co.rol.m1

        mov     rax, qword [rcx]
        ror     rax, 1
        mov     qword [rcx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
