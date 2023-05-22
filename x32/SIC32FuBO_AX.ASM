
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate boolean functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

@@.aif.exp0 = -46

; eps  = 2^(exp0)
; eps' = 2^(exp0 + D)
; D    = max(0,min(x.exponent,y.exponent))

; 2^(-30) = 9.3132257461547851562500000000000e-10
; 2^(-31) = 4.6566128730773925781250000000000e-10
; 2^(-32) = 2.3283064365386962890625000000000e-10
; 2^(-33) = 1.1641532182693481445312500000000e-10
; 2^(-34) = 5.8207660913467407226562500000000e-11
; 2^(-35) = 2.9103830456733703613281250000000e-11
; 2^(-36) = 1.4551915228366851806640625000000e-11
; 2^(-37) = 7.2759576141834259033203125000000e-12
; 2^(-38) = 3.6379788070917129516601562500000e-12
; 2^(-39) = 1.8189894035458564758300781250000e-12
; 2^(-40) = 9.0949470177292823791503906250000e-13
; 2^(-41) = 4.5474735088646411895751953125000e-13
; 2^(-42) = 2.2737367544323205947875976562500e-13
; 2^(-43) = 1.1368683772161602973937988281250e-13
; 2^(-44) = 5.6843418860808014869689941406250e-14
; 2^(-45) = 2.8421709430404007434844970703125e-14
; 2^(-46) = 1.4210854715202003717422485351563e-14 *
; 2^(-47) = 7.1054273576010018587112426757813e-15
; 2^(-48) = 3.5527136788005009293556213378906e-15
; 2^(-49) = 1.7763568394002504646778106689453e-15
; 2^(-50) = 8.8817841970012523233890533447266e-16
; 2^(-51) = 4.4408920985006261616945266723633e-16
; 2^(-52) = 2.2204460492503130808472633361816e-16

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; -> xmm0 = x
; -> xmm1 = y
; <- rbx  = exp' = exp0 + D
;    D    = max(0,min(x.exponent,y.exponent))

macro @@.aif.exp.sse.64
{
$asprocf @@.aif.exp

        movq    rdx, xmm0
        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent

        movq    rbx, xmm1
        shr     rbx, 64-12
        and     ebx, 0x07FF                     ; ebx = y.exponent

        cmp     ebx, edx
        jbe     @F
        mov     ebx, edx                        ; rbx = min(x.exponent,y.exponent)
    @@: sub     rbx, 1023
        jns     @F
        xor     rbx, rbx                        ; rbx = D = max(0,min(x.exponent,y.exponent))
    @@: add     rbx, 1023+@@.aif.exp0           ; rbx = exp' = exp0 + D

   .return:
        retn
$endp
}

macro @@.aif.exp.sse.32
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@.aif.exp

      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = x.HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = x.HI
      $end
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent

      $ifdef _SSE4.1
        pextrd  ebx, xmm1, 1                    ; ebx = y.HI
      $else
        movsd   [@mem], xmm1
        mov     ebx, [@mem + 4]                 ; ebx = y.HI
      $end
        shr     ebx, 32-12
        and     ebx, 0x07FF                     ; ebx = y.exponent

        cmp     ebx, edx
        jbe     @F
        mov     ebx, edx                        ; ebx = min(x.exponent,y.exponent)
    @@: sub     ebx, 1023
        jns     @F
        xor     ebx, ebx                        ; ebx = D = max(0,min(x.exponent,y.exponent))
    @@: add     ebx, 1023+@@.aif.exp0           ; ebx = exp' = exp0 + D

   .return:
        retn
$endp
}

; -> st0 = y
; -> st1 = x
; <- rbx = exp' = exp0 + D
;    D   = max(0,min(x.exponent,y.exponent))

macro  @@.aif.exp.fpu
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@.aif.exp

        fxch
        fst     qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent

        fxch
        fst     qword [@mem]
        mov     ebx, [@mem + 4]                 ; ebx = y.HI
        shr     ebx, 32-12
        and     ebx, 0x07FF                     ; ebx = y.exponent

        cmp     ebx, edx
        jbe     @F
        mov     ebx, edx                        ; ebx = min(x.exponent,y.exponent)
    @@: sub     ebx, 1023
        jns     @F
        xor     ebx, ebx                        ; ebx = D = max(0,min(x.exponent,y.exponent))
    @@: add     ebx, 1023+@@.aif.exp0           ; ebx = exp' = exp0 + D

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@.aif.exp.sse.64
$else
  @@.aif.exp.sse.32
$end
$else
  @@.aif.exp.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; approximately zero
;
; integer aif.z ( double x )
; return result in eax
; x = esp
;
; returns: 1, |x| <  eps
;          0, |x| >= eps

macro @@aif.z.sse.64
{
$usprocf @@aif.z

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     rax, rax                        ; rax = 0

        movq    rdx, xmm0
        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .1:  inc     rax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.z.sse4.1.32
{
$usprocf @@aif.z

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax                        ; eax = 0

        pextrd  edx, xmm0, 1                    ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.z.sse.32
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.z

;       movsd   xmm0, qword [esp]               ; xmm0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        xor     eax, eax                        ; eax = 0

        mov     edx, [@mem + 4]                 ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.z.fpu
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.z

;       fld     qword [esp]                     ; st0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        xor     eax, eax                        ; eax = 0

        mov     edx, [@mem + 4]                 ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@aif.z.sse.64
$else
$ifdef _SSE4.1
  @@aif.z.sse4.1.32
$else
  @@aif.z.sse.32
$end
$end
$else
  @@aif.z.fpu
$end

; ------------------------------------------------------------------------------

; approximately not zero
;
; integer aif.nz ( double x )
; return result in eax
; x = esp
;
; returns: 1, |x| >= eps
;          0, |x| <  eps

macro @@aif.nz.sse.64
{
$usprocf @@aif.nz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rax, 1                          ; rax = 1

        movq    rdx, xmm0
        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .0:  xor     rax, rax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.nz.sse4.1.32
{
$usprocf @@aif.nz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, 1                          ; eax = 1

        pextrd  edx, xmm0, 1                    ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.nz.sse.32
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.nz

;       movsd   xmm0, qword [esp]               ; xmm0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        mov     eax, 1                          ; eax = 1

        mov     edx, [@mem + 4]                 ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.nz.fpu
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.nz

;       fld     qword [esp]                     ; st0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        mov     eax, 1                          ; eax = 1

        mov     edx, [@mem + 4]                 ; edx = x.HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jae    .return                          ; jump if |x| >= eps

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@aif.nz.sse.64
$else
$ifdef _SSE4.1
  @@aif.nz.sse4.1.32
$else
  @@aif.nz.sse.32
$end
$end
$else
  @@aif.nz.fpu
$end

; ------------------------------------------------------------------------------

; approximately above zero
;
; integer aif.az ( double x )
; return result in eax
; x = esp
;
; returns: 1, x >= eps
;          0, x <  eps

macro @@aif.az.sse.64
{
$usprocf @@aif.az

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     rax, rax                        ; rax = 0

        movq    rdx, xmm0
        test    rdx, rdx
        js     .return                          ; jump if x < 0

        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .1:  inc     rax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.az.sse4.1.32
{
$usprocf @@aif.az

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax                        ; eax = 0

        pextrd  edx, xmm0, 1                    ; edx = x.HI
        test    edx, edx
        js     .return                          ; jump if x < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.az.sse.32
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.az

;       movsd   xmm0, qword [esp]               ; xmm0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        xor     eax, eax                        ; eax = 0

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        js     .return                          ; jump if x < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.az.fpu
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.az

;       fld     qword [esp]                     ; st0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        xor     eax, eax                        ; eax = 0

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        js     .return                          ; jump if x < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@aif.az.sse.64
$else
$ifdef _SSE4.1
  @@aif.az.sse4.1.32
$else
  @@aif.az.sse.32
$end
$end
$else
  @@aif.az.fpu
$end

; ------------------------------------------------------------------------------

; approximately above or equal zero
;
; integer aif.aez ( double x )
; return result in eax
; x = esp
;
; returns: 1, x >  -eps
;          0, x <= -eps

macro @@aif.aez.sse.64
{
$usprocf @@aif.aez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rax, 1                          ; rax = 1

        movq    rdx, xmm0
        test    rdx, rdx
        jns    .return                          ; jump if x >= 0

        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .0:  xor     rax, rax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.aez.sse4.1.32
{
$usprocf @@aif.aez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, 1                          ; eax = 1

        pextrd  edx, xmm0, 1                    ; edx = x.HI
        test    edx, edx
        jns    .return                          ; jump if x >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.aez.sse.32
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.aez

;       movsd   xmm0, qword [esp]               ; xmm0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        mov     eax, 1                          ; eax = 1

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        jns    .return                          ; jump if x >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.aez.fpu
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.aez

;       fld     qword [esp]                     ; st0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        mov     eax, 1                          ; eax = 1

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        jns    .return                          ; jump if x >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@aif.aez.sse.64
$else
$ifdef _SSE4.1
  @@aif.aez.sse4.1.32
$else
  @@aif.aez.sse.32
$end
$end
$else
  @@aif.aez.fpu
$end

; ------------------------------------------------------------------------------

; approximately below zero
;
; integer aif.bz ( double x )
; return result in eax
; x = esp
;
; returns: 1, x <= -eps
;          0, x >  -eps

macro @@aif.bz.sse.64
{
$usprocf @@aif.bz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     rax, rax                        ; rax = 0

        movq    rdx, xmm0
        test    rdx, rdx
        jns    .return                          ; jump if x >= 0

        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .1:  inc     rax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.bz.sse4.1.32
{
$usprocf @@aif.bz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax                        ; eax = 0

        pextrd  edx, xmm0, 1                    ; edx = x.HI
        test    edx, edx
        jns    .return                          ; jump if x >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.bz.sse.32
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.bz

;       movsd   xmm0, qword [esp]               ; xmm0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        xor     eax, eax                        ; eax = 0

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        jns    .return                          ; jump if x >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.bz.fpu
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.bz

;       fld     qword [esp]                     ; st0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        xor     eax, eax                        ; eax = 0

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        jns    .return                          ; jump if x >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | -eps < x < 0

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@aif.bz.sse.64
$else
$ifdef _SSE4.1
  @@aif.bz.sse4.1.32
$else
  @@aif.bz.sse.32
$end
$end
$else
  @@aif.bz.fpu
$end

; ------------------------------------------------------------------------------

; approximately below or equal zero
;
; integer aif.bez ( double x )
; return result in eax
; x = esp
;
; returns: 1, x <  eps
;          0, x >= eps

macro @@aif.bez.sse.64
{
$usprocf @@aif.bez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rax, 1                          ; rax = 1

        movq    rdx, xmm0
        test    rdx, rdx
        js     .return                          ; jump if x < 0

        shr     rdx, 64-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .0:  xor     rax, rax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.bez.sse4.1.32
{
$usprocf @@aif.bez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, 1                          ; eax = 1

        pextrd  edx, xmm0, 1                    ; edx = x.HI
        test    edx, edx
        js     .return                          ; jump if x < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.bez.sse.32
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.bez

;       movsd   xmm0, qword [esp]               ; xmm0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        mov     eax, 1                          ; eax = 1

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        js     .return                          ; jump if x < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.bez.fpu
{
        local   @mem
        @mem    EQU esp

$usprocf @@aif.bez

;       fld     qword [esp]                     ; st0 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
;  .enter:
        mov     eax, 1                          ; eax = 1

        mov     edx, [@mem + 4]                 ; edx = x.HI
        test    edx, edx
        js     .return                          ; jump if x < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = x.exponent
        cmp     edx, 1023+@@.aif.exp0
        jb     .return                          ; jump if |x| < eps | 0 <= x < eps

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@aif.bez.sse.64
$else
$ifdef _SSE4.1
  @@aif.bez.sse4.1.32
$else
  @@aif.bez.sse.32
$end
$end
$else
  @@aif.bez.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; approximately equal
;
; integer aif.e ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, |x-y| <  eps'
;          0, |x-y| >= eps'

macro @@aif.e.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.e

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jae    .return                          ; jump if |x-y| >= eps'

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.e.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.e

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jae    .return                          ; jump if |x-y| >= eps'

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.e.sse
$else
  @@aif.e.fpu
$end

; ------------------------------------------------------------------------------

; approximately not equal
;
; integer aif.ne ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, |x-y| >= eps'
;          0, |x-y| <  eps'

macro @@aif.ne.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.ne

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        mov     eax, 1                          ; eax = 1

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jae    .return                          ; jump if |x-y| >= eps'

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.ne.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.ne

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        mov     eax, 1                          ; eax = 1

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jae    .return                          ; jump if |x-y| >= eps'

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.ne.sse
$else
  @@aif.ne.fpu
$end

; ------------------------------------------------------------------------------

; approximately above (greater)
;
; integer aif.a ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x-y >= eps'
;          0, x-y <  eps'

macro @@aif.a.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.a

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        test    rdx, rdx
        js     .return                          ; jump if x-y < 0
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        test    edx, edx
        js     .return                          ; jump if x-y < 0
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | 0 <= x-y < eps'

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.a.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.a

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        test    edx, edx
        js     .return                          ; jump if x-y < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | 0 <= x-y < eps'

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.a.sse
$else
  @@aif.a.fpu
$end

; ------------------------------------------------------------------------------

; approximately above or equal (greater or equal)
;
; integer aif.ae ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x-y >  -eps'
;          0, x-y <= -eps'

macro @@aif.ae.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.ae

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        mov     eax, 1                          ; eax = 1

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        test    rdx, rdx
        jns    .return                          ; jump if x-y >= 0
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        test    edx, edx
        jns    .return                          ; jump if x-y >= 0
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | -eps' < x-y < 0

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.ae.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.ae

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        mov     eax, 1                          ; eax = 1

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        test    edx, edx
        jns    .return                          ; jump if x-y >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | -eps' < x-y < 0

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.ae.sse
$else
  @@aif.ae.fpu
$end

; ------------------------------------------------------------------------------

; approximately below (less)
;
; integer aif.b ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x-y <= -eps'
;          0, x-y >  -eps'

macro @@aif.b.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.b

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        test    rdx, rdx
        jns    .return                          ; jump if x-y >= 0
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        test    edx, edx
        jns    .return                          ; jump if x-y >= 0
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | -eps' < x-y < 0

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

macro @@aif.b.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.b

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        test    edx, edx
        jns    .return                          ; jump if x-y >= 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | -eps' < x-y < 0

   .1:  inc     eax                             ; return 1

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.b.sse
$else
  @@aif.b.fpu
$end

; ------------------------------------------------------------------------------

; approximately below or equal (less or equal)
;
; integer aif.be ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x-y <  eps'
;          0, x-y >= eps'

macro @@aif.be.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.be

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        mov     eax, 1                          ; eax = 1

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        test    rdx, rdx
        js     .return                          ; jump if x-y < 0
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        test    edx, edx
        js     .return                          ; jump if x-y < 0
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | 0 <= x-y < eps'

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

macro @@aif.be.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.be

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        mov     eax, 1                          ; eax = 1

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        test    edx, edx
        js     .return                          ; jump if x-y < 0

        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps' | 0 <= x-y < eps'

   .0:  xor     eax, eax                        ; return 0

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.be.sse
$else
  @@aif.be.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; three-way approximate comparison
;
; integer aif.bea ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns -1 if (x-y) <= -eps'
;          0 if |x-y| <   eps'
;         +1 if (x-y) >=  eps'

macro @@aif.bea.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.bea

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        mov     rcx, rdx
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        mov     ecx, edx                        ; ecx = (x-y).HI
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps'

    $ifdef _X64
        test    rcx, rcx
    $else
        test    ecx, ecx
    $end
        jns    .p1                              ; jump if x-y >= 0 | x-y >= eps'

   .m1: dec     eax                             ; return -1
        jmp    .return

   .p1: inc     eax                             ; return +1

   .return:
        retn
$endp
}

macro @@aif.bea.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.bea

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        mov     ecx, edx                        ; ecx = (x-y).HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps'

        test    ecx, ecx
        jns    .p1                              ; jump if x-y >= 0 | x-y >= eps'

   .m1: dec     eax                             ; return -1
        jmp    .return

   .p1: inc     eax                             ; return +1

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.bea.sse
$else
  @@aif.bea.fpu
$end

; ------------------------------------------------------------------------------

; three-way approximate comparison
;
; integer aif.aeb ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns -1 if (x-y) >=  eps'
;          0 if |x-y| <   eps'
;         +1 if (x-y) <= -eps'

macro @@aif.aeb.sse
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.aeb

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        subsd   xmm0, xmm1
    $ifdef _X64
        movq    rdx, xmm0
        mov     rcx, rdx
        shr     rdx, 64-12
    $else
      $ifdef _SSE4.1
        pextrd  edx, xmm0, 1                    ; edx = (x-y).HI
      $else
        movsd   [@mem], xmm0
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
      $end
        mov     ecx, edx                        ; ecx = (x-y).HI
        shr     edx, 32-12
    $end
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps'

    $ifdef _X64
        test    rcx, rcx
    $else
        test    ecx, ecx
    $end
        js     .p1                              ; jump if x-y < 0 | x-y <= -eps'

   .m1: dec     eax                             ; return -1
        jmp    .return

   .p1: inc     eax                             ; return +1

   .return:
        retn
$endp
}

macro @@aif.aeb.fpu
{
        local   @mem
        @mem    EQU esp - 64

$usprocf @@aif.aeb

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@.aif.exp
        call    ebx                             ; ebx = exp'

        xor     eax, eax                        ; eax = 0

        fsubp
        fstp    qword [@mem]
        mov     edx, [@mem + 4]                 ; edx = (x-y).HI
        mov     ecx, edx                        ; ecx = (x-y).HI
        shr     edx, 32-12
        and     edx, 0x07FF                     ; edx = (x-y).exponent
        cmp     edx, ebx
        jb     .return                          ; jump if |x-y| < eps'

        test    ecx, ecx
        js     .p1                              ; jump if x-y < 0 | x-y <= -eps'

   .m1: dec     eax                             ; return -1
        jmp    .return

   .p1: inc     eax                             ; return +1

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@aif.aeb.sse
$else
  @@aif.aeb.fpu
$end

; ------------------------------------------------------------------------------
