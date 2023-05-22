
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
; return result in eax
; x = esp

$usprocf @@bsf

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        bsf     eax, eax
        jnz    .return
        xor     eax, eax
        dec     eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit scan reverse
; integer bsr ( integer x )
; return result in eax
; x = esp

$usprocf @@bsr

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        bsr     eax, eax
        jnz    .return
        xor     eax, eax
        dec     eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bit test
; integer bt ( integer x, integer y )
; return the destination bit indexed by the y value in eax
; x = esp
; y = esp + 4

$usprocf @@bt

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        bt      eax, ecx
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and complement
; integer btc ( integer x, integer y )
; return the destination bit indexed by the y value in eax and complement (invert) the destination bit
; x = rsp
; y = rsp + 8

$usprocf @@btc

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        btc     eax, ecx
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and complement
; integer btc ( integer *x, integer y )
; return the destination bit indexed by the y value in eax and complement (invert) the destination bit
; *x = ecx
;  y = esp

$usprocf @@btc_ivar

        mov     eax, dword [esp]
   .enter:
        btc     dword [ecx], eax
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and reset
; integer btr ( integer x, integer y )
; return the destination bit indexed by the y value in eax and clear the destination bit
; x = rsp
; y = rsp + 8

$usprocf @@btr

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        btr     eax, ecx
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and reset
; integer btr ( integer *x, integer y )
; return the destination bit indexed by the y value in eax and clear the destination bit
; *x = ecx
;  y = esp

$usprocf @@btr_ivar

        mov     eax, dword [esp]
   .enter:
        btr     dword [ecx], eax
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and set
; integer bts ( integer x, integer y )
; return the destination bit indexed by the y value in eax and set in the destination bit
; x = rsp
; y = rsp + 8

$usprocf @@bts

        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        bts     eax, ecx
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit test and set
; integer bts ( integer *x, integer y )
; return the destination bit indexed by the y value in eax and set in the destination bit
; *x = ecx
;  y = esp

$usprocf @@bts_ivar

        mov     eax, dword [esp]
   .enter:
        bts     dword [ecx], eax
        mov     eax, 0                          ; eax = 0 ; mov instruction does not modify flags
        adc     eax, 0                          ; copy CF to rax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not
; integer bnot ( integer x )
; return result in eax
; x = esp

$usprocf @@bnot

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        not     eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnot(dst) to dst
; integer co.bnot ( integer *dst )
; return result in eax
; dst offset = ecx

$usprocf @@co.bnot

        mov     eax, dword [ecx]
   .enter:
        not     eax
        mov     dword [ecx], eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise operation
; integer bop ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4

macro @@.bop bop
{
        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        bop     eax, ecx
   .return:
        retn
}

; ------------------------------------------------------------------------------

; bitwise post not operation
; integer bnop ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4

macro @@.bnop bop
{
        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        bop     eax, ecx
        not     eax
   .return:
        retn
}

; ------------------------------------------------------------------------------

; bitwise pre not operation
; integer bopn ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4

macro @@.bopn bop
{
        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        not     ecx
        bop     eax, ecx
   .return:
        retn
}

; ------------------------------------------------------------------------------

; bitwise pre & post not operation
; integer bnopn ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4

macro @@.bnopn bop
{
        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
   .enter:
        not     ecx
        bop     eax, ecx
        not     eax
   .return:
        retn
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise or
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bor
  @@.bop or
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bor

        mov     eax, dword [esp]
    .enter:
        or      eax, dword [ecx]
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bor.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bor.1

        mov     eax, dword [ecx]
        or      eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bor(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bor.m1

;       mov     eax, dword [ecx]
;       or      eax, -1
;       mov     dword [ecx], eax

        mov     eax, -1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not or
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bnor
  @@.bnop or
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bnor

        mov     eax, dword [esp]
    .enter:
        or      eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnor.0

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnor.1

        mov     eax, dword [ecx]
        or      eax, 1
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnor(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnor.m1

;       mov     eax, dword [ecx]
;       or      eax, -1
;       not     eax                             ; eax = 0
;       mov     dword [ecx], eax

        xor     eax, eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise xor
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bxor
  @@.bop xor
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bxor

        mov     eax, dword [esp]
    .enter:
        xor     eax, dword [ecx]
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bxor.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bxor.1

        mov     eax, dword [ecx]
        xor     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxor(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bxor.m1

        mov     eax, dword [ecx]
        not     eax
;       xor     eax, -1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not xor
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bxnor
  @@.bnop xor
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bxnor

        mov     eax, dword [esp]
    .enter:
        xor     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bxnor.0

;       mov     eax, dword [ecx]
;       xor     eax, 0                          ; eax = eax
;       not     eax                             ; eax = not eax
;       mov     dword [ecx], eax

        mov     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bxnor.1

        mov     eax, dword [ecx]
        xor     eax, 1
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bxnor(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bxnor.m1

;       xor     eax, -1                         ; eax = not eax
;       not     eax                             ; eax = eax

        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise and
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@band
  @@.bop and
$endp

; ------------------------------------------------------------------------------

; copy band(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.band

        mov     eax, dword [esp]
    .enter:
        and     eax, dword [ecx]
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy band(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.band.0

        xor     eax, eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy band(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.band.1

        mov     eax, dword [ecx]
        and     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy band(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.band.m1

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bitwise not and
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@bnand
  @@.bnop and
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.bnand

        mov     eax, dword [esp]
    .enter:
        and     eax, dword [ecx]
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnand.0

        mov     eax, -1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnand.1

        mov     eax, dword [ecx]
        and     eax, 1
        not     eax
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy bnand(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.bnand.m1

;       mov     eax, dword [ecx]
;       and     eax, -1                         ; eax = eax
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

; bitwise shift
; return result in eax
; x = esp
; y = esp + 4
;
; op.pos - operation for positive values
; op.neg - operation for negative values

macro @@.shift op.pos, op.neg
{
        mov     eax, dword [esp]                ; eax = x integer value
        mov     ecx, dword [esp + 4]            ; ecx = y integer value
    .enter:
        test    ecx, ecx
;       jz     .return
        jns    .op.pos
        neg     ecx
    .op.neg:
        op.neg  eax, cl
        jmp    .return
    .op.pos:
        op.pos  eax, cl
    .return:
        retn
}

; ------------------------------------------------------------------------------

; copy shift(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp
;
; op.pos - operation for positive values
; op.neg - operation for negative values

macro @@.co.shift op.pos, op.neg
{
        mov     edx, ecx                        ; edx = dst offset
        mov     eax, [ecx]                      ; eax = dst integer value
        mov     ecx, [esp]                      ; ecx = src integer value
    .enter:
        test    ecx, ecx
;       jz     .return
        jns    .op.pos
        neg     ecx
    .op.neg:
        op.neg  eax, cl
        jmp    .return
    .op.pos:
        op.pos  eax, cl
    .return:
        mov     [edx], eax
        retn
}

; ------------------------------------------------------------------------------

; bitwise shift right
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@shr
  @@.shift shr, shl
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.shr
  @@.co.shift shr, shl
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.shr.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.shr.1

        mov     eax, dword [ecx]
        shr     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shr(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.shr.m1

        mov     eax, dword [ecx]
        shl     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise shift left
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@shl
  @@.shift shl, shr
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.shl
  @@.co.shift shl, shr
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.shl.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.shl.1

        mov     eax, dword [ecx]
        shl     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy shl(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.shl.m1

        mov     eax, dword [ecx]
        shr     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise shift arithmetic right
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@sar
  @@.shift sar, sal
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.sar
  @@.co.shift sar, sal
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.sar.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.sar.1

        mov     eax, dword [ecx]
        sar     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sar(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.sar.m1

        mov     eax, dword [ecx]
        sal     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise shift arithmetic left
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@sal
  @@.shift sal, sar
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.sal
  @@.co.shift sal, sar
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.sal.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.sal.1

        mov     eax, dword [ecx]
        sal     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy sal(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.sal.m1

        mov     eax, dword [ecx]
        sar     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise rotate right
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@ror
  @@.shift ror, rol
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.ror
  @@.co.shift ror, rol
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.ror.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.ror.1

        mov     eax, dword [ecx]
        ror     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy ror(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.ror.m1

        mov     eax, dword [ecx]
        rol     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bitwise rotate left
; return result in eax
; x = esp
; y = esp + 4

$usprocf @@rol
  @@.shift rol, ror
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,src) to dst
; return result in eax
; dst offset = ecx
; src value  = esp

$usprocf @@co.rol
  @@.co.shift rol, ror
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,0) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.rol.0

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.rol.1

        mov     eax, dword [ecx]
        rol     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy rol(dst,-1) to dst
; return result in eax
; dst offset = ecx

$usprocf @@_co.rol.m1

        mov     eax, dword [ecx]
        ror     eax, 1
        mov     dword [ecx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
