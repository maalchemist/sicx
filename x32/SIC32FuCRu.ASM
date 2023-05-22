
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (core functions utils)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; assign FPU control word
;
; @@.fpu.cw.assign 0x????
; ...
; @@.fpu.cw.restore

macro @@.fpu.cw.assign cw
{
        add     esp, -16
        fnstcw  word [esp + 2]                  ; save control word
        mov     word [esp], cw
        fldcw   word [esp]                      ; load control word
}

; ------------------------------------------------------------------------------

; update FPU control word

macro @@.fpu.cw.update cw
{
        mov     word [esp], cw
        fldcw   word [esp]                      ; load control word
}

; ------------------------------------------------------------------------------

; restore FPU control word and set new control word
;
; @@.fpu.cw.assign 0x????
; ...
; @@.fpu.cw.restore

macro @@.fpu.cw.restore
{
        fldcw   word [esp + 2]
        add     esp, +16
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@.stack.align16.enter reg
{
    $ifdef _X64
        push    0
        test    rsp, 0x0F
        jz      @F
        push    rsp
    $else
      $if (reg eq)
        push    0
        mov     ecx, esp
        and     ecx, 0x0F
        sub     ecx, 0x10
        test    ecx, 0x0F
        jz      @F
        add     esp, ecx
        mov     [esp], ecx
      $else
        push    0
        mov     reg, esp
        and     reg, 0x0F
        sub     reg, 0x10
        test    reg, 0x0F
        jz      @F
        add     esp, reg
        mov     [esp], reg
      $end
    $end
    @@:
}

macro @@.stack.align16.leave reg
{
    $ifdef _X64
      $if (reg eq)
        pop     rcx
        test    rcx, rcx
        jz      @F
        pop     rcx
      $else
        pop     reg
        test    reg, reg
        jz      @F
        pop     reg
      $end
    $else
      $if (reg eq)
        pop     ecx
        test    ecx, ecx
        jz      @F
        sub     esp, ecx
      $else
        pop     reg
        test    reg, reg
        jz      @F
        sub     esp, reg
      $end
    $end
    @@:
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; exchange xmma and xmmb
macro @@.xch xmma, xmmb
{
        pxor    xmma, xmmb
        pxor    xmmb, xmma
        pxor    xmma, xmmb
}

; ------------------------------------------------------------------------------

; convert xmmn to chs(xmmn)

macro @@.chs xmmn, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU pxor                        ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmmn, [r10]
    $else
        mov     reg, @var
        @pop    xmmn, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmmn, xword [@var]
    $else
        mov     reg, @var
        @pop    xmmn, [reg]
    $end
   $end
}

macro @@..chs xmmn, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU pxor                        ; operation

   $ifdef _X64
        mov     r10, @var
        @pop    xmmn, [r10]
   $else
        @pop    xmmn, xword [@var]
   $end
}

; ------------------------------------------------------------------------------

; convert xmma,xmmb to chs(xmma),chs(xmmb)

macro @@.chss xmma, xmmb, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU pxor                        ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
    $end
   $end
}

macro @@..chss xmma, xmmb, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU pxor                        ; operation

   $ifdef _X64
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
   $else
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
   $end
}

; ------------------------------------------------------------------------------

; convert xmmn to abs(xmmn)

macro @@.abs xmmn, reg
{
        local   @var, @pop

        @var    EQU ??.0x7FFFFFFFFFFFFFFF
        @pop    EQU pand                        ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmmn, [r10]
    $else
        mov     reg, @var
        @pop    xmmn, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmmn, xword [@var]
    $else
        mov     reg, @var
        @pop    xmmn, [reg]
    $end
   $end
}

macro @@..abs xmmn, reg
{
        local   @var, @pop

        @var    EQU ??.0x7FFFFFFFFFFFFFFF
        @pop    EQU pand                        ; operation

   $ifdef _X64
        mov     r10, @var
        @pop    xmmn, [r10]
   $else
        @pop    xmmn, xword [@var]
   $end
}

; ------------------------------------------------------------------------------

; convert xmma,xmmb to abs(xmma),abs(xmmb)

macro @@.abss xmma, xmmb, reg
{
        local   @var, @pop

        @var    EQU ??.0x7FFFFFFFFFFFFFFF
        @pop    EQU pand                        ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
    $end
   $end
}

macro @@..abss xmma, xmmb, reg
{
        local   @var, @pop

        @var    EQU ??.0x7FFFFFFFFFFFFFFF
        @pop    EQU pand                        ; operation

   $ifdef _X64
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
   $else
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
   $end
}

; ------------------------------------------------------------------------------

; convert xmma,xmmb,xmmc to abs(xmma),abs(xmmb),abs(xmmc)

macro @@.abs3 xmma, xmmb, xmmc, reg
{
        local   @var, @pop

        @var    EQU ??.0x7FFFFFFFFFFFFFFF
        @pop    EQU pand                        ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
        @pop    xmmc, [r10]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
        @pop    xmmc, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
        @pop    xmmc, xword [@var]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
        @pop    xmmc, [reg]
    $end
   $end
}

; ------------------------------------------------------------------------------

; convert xmmn to nabs(xmmn)

macro @@.nabs xmmn, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU por                         ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmmn, [r10]
    $else
        mov     reg, @var
        @pop    xmmn, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmmn, xword [@var]
    $else
        mov     reg, @var
        @pop    xmmn, [reg]
    $end
   $end
}

macro @@..nabs xmmn, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU por                         ; operation

   $ifdef _X64
        mov     r10, @var
        @pop    xmmn, [r10]
   $else
        @pop    xmmn, xword [@var]
   $end
}

; ------------------------------------------------------------------------------

; convert xmma,xmmb to nabs(xmma),nabs(xmmb)

macro @@.nabss xmma, xmmb, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU por                         ; operation

   $ifdef _X64
    $if (reg eq)
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
    $end
   $else
    $if (reg eq)
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
    $else
        mov     reg, @var
        @pop    xmma, [reg]
        @pop    xmmb, [reg]
    $end
   $end
}

macro @@..nabss xmma, xmmb, reg
{
        local   @var, @pop

        @var    EQU ??.0x8000000000000000
        @pop    EQU por                         ; operation

   $ifdef _X64
        mov     r10, @var
        @pop    xmma, [r10]
        @pop    xmmb, [r10]
   $else
        @pop    xmma, xword [@var]
        @pop    xmmb, xword [@var]
   $end
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy int(xmmS) to xmmD
; xmmS - source
; xmmD - destination

macro xintsd xmmD, xmmS
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSE4.1
        roundsd xmmD, xmmS, 0x3                 ; round toward zero (truncate) (_MM_FROUND_TO_ZERO = 0x3)
    $else
      $ifdef _X64
        local ..main, ..zero, ..return

        movq    r10, xmmS
        shr     r10, 32
        and     r10, 0x7FF00000
        cmp     r10, 0x43300000
       if (xmmD eq xmmS)
        jge   ..return
       else
        jl    ..main
        movsd   xmmD, xmmS
        jmp   ..return
       end if
  ..main:
        cmp     r10, 0x3FE00000
        jbe   ..zero
        cvttsd2si r10, xmmS
        cvtsi2sd  xmmD, r10
        jmp   ..return
  ..zero:
        xorpd   xmmD, xmmD
  ..return:
      $else
        movsd   qword [@mem], xmmS
        fld     qword [@mem]

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)
        @@.fpu.cw.restore                       ; restore control word

        fstp    qword [@mem]
        movsd   xmmD, qword [@mem]              ; xmmD = int(x)
      $end
    $end
}

; ------------------------------------------------------------------------------

; convert st0 to int(st0)
macro @@.int.st0
{
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)
        @@.fpu.cw.restore                       ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy frac(xmmS) to xmmD
; xmmS - source
; xmmD - destination

macro xfracsd xmmD, xmmS
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSE4.1
       if (xmmS eq xmm5)
        oops xfracsd `xmmD, `xmmS
       end if

        roundsd xmm5, xmmS, 0x3                 ; round toward zero (truncate) (_MM_FROUND_TO_ZERO = 0x3)
       if ~ (xmmD eq xmmS)                      ; xmm5 = int(xmmS)
        movsd   xmmD, xmmS
       end if
        subsd   xmmD, xmm5                      ; xmmD = xmmS - int(xmmS)
    $else
      $ifdef _X64
        local ..main, ..zero, ..return

       if (xmmS eq xmm5)
        oops xfracsd `xmmD, `xmmS
       end if

        movq    r10, xmmS
        shr     r10, 32
        and     r10, 0x7FF00000
        cmp     r10, 0x43300000
        jge   ..zero
        cmp     r10, 0x3FE00000
       if (xmmD eq xmmS)
        jbe   ..return
       else
        ja    ..main
        movsd   xmmD, xmmS
        jmp   ..return
       end if
  ..main:
        cvttsd2si r10, xmmS
        cvtsi2sd  xmm5, r10                     ; xmm5 = int(xmmS)
       if ~ (xmmD eq xmmS)
        movsd   xmmD, xmmS
       end if
        subsd   xmmD, xmm5                      ; xmmD = xmmS - int(xmmS)
        jmp   ..return
  ..zero:
        xorpd   xmmD, xmmD
  ..return:
      $else
        movsd   qword [@mem], xmmS
        fld     qword [@mem]

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)
        @@.fpu.cw.restore                       ; restore control word

        fstp    qword [@mem]                    ; [@mem] = int(x)
       if ~ (xmmD eq xmmS)
        movsd   xmmD, xmmS
       end if
        subsd   xmmD, qword [@mem]              ; xmmD = x - int(x) = frac(x)
      $end
    $end
}

; ------------------------------------------------------------------------------

; convert st0 to frac(st0)
macro @@.frac.st0
{
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0                             ; st0 = x      | st1 = x
        frndint                                 ; st0 = int(x) | st1 = x
        fsubp                                   ; st0 = x - int(x) = frac(x)

        @@.fpu.cw.restore                       ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; convert st0 to frac(st0)
; store trunc(st0) in reg

macro @@.trunc.frac.st0 reg
{
        local   @mem
        @mem    EQU esp - 64

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0                             ; st0 = x | st1 = x
        fistp   dword [@mem]                    ; [@mem] = trunc(x)
        fild    dword [@mem]                    ; st0 = trunc(x) | st1 = x
        fsubp                                   ; st0 = frac(x)
        mov     reg, dword [@mem]               ; reg = trunc(x)

        @@.fpu.cw.restore                       ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy round(xmmS) to xmmD
; xmmS - source
; xmmD - destination

macro xrndsd xmmD, xmmS
{
       if (xmmS eq xmm4)
        oops xrndsd `xmmD, `xmmS
       end if

        movsd   xmm4, xmmS                      ; xmm4 = x
        xfracsd xmm4, xmm4                      ; xmm4 = frac(x)
        addsd   xmm4, xmm4                      ; xmm4 = 2*frac(x)
        xintsd  xmmS, xmmS                      ; xmmS = int(x)
        xintsd  xmm4, xmm4                      ; xmm4 = int(2*frac(x))
       if ~ (xmmD eq xmmS)
        movsd   xmmD, xmmS
       end if
        addsd   xmmD, xmm4                      ; xmm0 = round(x)
}

; ------------------------------------------------------------------------------

; convert st0 to round(st0)
macro @@.round.st0
{
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
                                                ; -------------------------------------
                                                ; ST(0)        | ST(1)        | ST(2) |
                                                ; -------------------------------------
                                                ; x.y          | ?            | ?     |
        fld     st0                             ; x.y          | x.y          | ?     |
        fld     st0                             ; x.y          | x.y          | x.y   |
        frndint                                 ; x            | x.y          | x.y   |
        fsubp                                   ; 0.y          | x.y          | ?     |
        fld     st0                             ; 0.y          | 0.y          | x.y   |
        faddp                                   ; 2 * 0.y      | x.y          | ?     |
        frndint                                 ; int(2 * 0.y) | x.y          | ?     |
        fxch                                    ; x.y          | int(2 * 0.y) | ?     |
        frndint                                 ; int(x.y)     | int(2 * 0.y) | ?     |
        faddp                                   ; round(x.y)   | ?            | ?     |
                                                ; -------------------------------------
        @@.fpu.cw.restore                       ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@.trunc.xmm xmm, reg
{
      if reg eq
        cvttsd2si eax, xmm                      ; eax = trunc(xmm)
      else
        cvttsd2si reg, xmm                      ; reg = trunc(xmm)
      end if
}

; ------------------------------------------------------------------------------

macro @@.trunc.st0 reg
{
        local   @mem
        @mem    EQU esp - 64

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fistp   dword [@mem]                    ; [@mem] = trunc(x)
        mov     reg, dword [@mem]

        @@.fpu.cw.restore                       ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@.fld.xmm0
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        movsd   qword [@mem], xmm0
        fld     qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fld.xmm1
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        movsd   qword [@mem], xmm1
        fld     qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fld.xmm2
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        movsd   qword [@mem], xmm2
        fld     qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fld.xmm3
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        movsd   qword [@mem], xmm3
        fld     qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fld.xmmn n
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
      common
        local @n, @count

        @count = 0
      if n eq
        @n = 1
      else
        @n = n
      end if
      if @n > 8
        @n = 8
      end if

      if @n > 0
      while @count < @n
      if @count = 0
        movsd   qword [@mem], xmm0
      end if
      if @count = 1
        movsd   qword [@mem], xmm1
      end if
      if @count = 2
        movsd   qword [@mem], xmm2
      end if
      if @count = 3
        movsd   qword [@mem], xmm3
      end if
      if @count = 4
        movsd   qword [@mem], xmm4
      end if
      if @count = 5
        movsd   qword [@mem], xmm5
      end if
      if @count = 6
        movsd   qword [@mem], xmm6
      end if
      if @count = 7
        movsd   qword [@mem], xmm7
      end if
        fld     qword [@mem]
        @count = @count + 1
      end while
      end if
    $end
}

; ------------------------------------------------------------------------------

macro @@.fstp.xmm0
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        fstp    qword [@mem]
        movsd   xmm0, qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fstp.xmm1
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        fstp    qword [@mem]
        movsd   xmm1, qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fstp.xmm2
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        fstp    qword [@mem]
        movsd   xmm2, qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fstp.xmm3
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
        fstp    qword [@mem]
        movsd   xmm3, qword [@mem]
    $end
}

; ------------------------------------------------------------------------------

macro @@.fstp.xmmn n
{
        local   @mem
        @mem    EQU esp - 64

    $ifdef _SSEX
      common
        local @n, @count

      if n eq
        @n = 1
      else
        @n = n
      end if
      if @n > 8
        @n = 8
      end if

      if @n > 0
      while @n > 0
        fstp    qword [@mem]
      if @n = 1
        movsd   xmm0, qword [@mem]
      end if
      if @n = 2
        movsd   xmm1, qword [@mem]
      end if
      if @n = 3
        movsd   xmm2, qword [@mem]
      end if
      if @n = 4
        movsd   xmm3, qword [@mem]
      end if
      if @n = 5
        movsd   xmm4, qword [@mem]
      end if
      if @n = 6
        movsd   xmm5, qword [@mem]
      end if
      if @n = 7
        movsd   xmm6, qword [@mem]
      end if
      if @n = 8
        movsd   xmm7, qword [@mem]
      end if
        @n = @n - 1
      end while
      end if
    $end
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; x = xmm0
; returns: xmm0=x, x > 0
;          xmm0=0, otherwise

macro @@.xmm0.pos
{
   .test.in:
       movmskpd ecx, xmm0                       ; ecx = sign bits
        test    ecx, 1
        jz     .test.out                        ; jump if x > 0
        xorpd   xmm0, xmm0                      ; xmm0 = 0
   .test.out:
}

macro @@..xmm0.pos
{
   .test.in:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .test.out                        ; jump if x > 0
        xorpd   xmm0, xmm0                      ; xmm0 = 0
   .test.out:
}

macro @@..xmm0.pos
{
   .test.in:
        comisd  xmm0, [??.0.0]                  ; compare x to 0
        ja     .test.out                        ; jump if x > 0
        xorpd   xmm0, xmm0                      ; xmm0 = 0
   .test.out:
}

; ------------------------------------------------------------------------------

; x = xmm1
; returns: xmm1=x, x > 0
;          xmm1=0, otherwise

macro @@.xmm1.pos
{
   .test.in:
       movmskpd ecx, xmm1                       ; ecx = sign bits
        test    ecx, 1
        jz     .test.out                        ; jump if x > 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .test.out:
}

macro @@..xmm1.pos
{
   .test.in:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm1, xmm5                      ; compare x to 0
        ja     .test.out                        ; jump if x > 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .test.out:
}

macro @@..xmm1.pos
{
   .test.in:
        comisd  xmm1, [??.0.0]                  ; compare x to 0
        ja     .test.out                        ; jump if x > 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .test.out:
}

; ------------------------------------------------------------------------------

; x = st0
; returns: st0=x, x > 0
;          st0=0, otherwise

macro @@.st0.pos
{
   .test.in:
        ftst
        fnjg   .test.out                        ; return x
        fldz                                    ; return 0
        fstp    st1
   .test.out:
}

macro @@.st0.pos.unsafe
{
   .test.in:
        ftst
        fnjg   .test.out                        ; return x
        fstp    st0
        fldz                                    ; return 0
   .test.out:
        fnop                                    ; optimizer directive - don't optimize code near the label
}

; ------------------------------------------------------------------------------

; x = xmm0
; returns: xmm0=x, x < 0
;          xmm0=0, otherwise

macro @@.xmm0.neg
{
   .test.in:
       movmskpd ecx, xmm0                       ; ecx = sign bits
        test    ecx, 1
        jnz    .test.out                        ; jump if x < 0
        xorpd   xmm0, xmm0                      ; xmm0 = 0
   .test.out:
}

macro @@..xmm0.neg
{
   .test.in:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .test.out                        ; jump if x < 0
        xorpd   xmm0, xmm0                      ; xmm0 = 0
   .test.out:
}

macro @@..xmm0.neg
{
   .test.in:
        comisd  xmm0, [??.0.0]                  ; compare x to 0
        jb     .test.out                        ; jump if x < 0
        xorpd   xmm0, xmm0                      ; xmm0 = 0
   .test.out:
}

; ------------------------------------------------------------------------------

; x = xmm1
; returns: xmm1=x, x < 0
;          xmm1=0, otherwise

macro @@.xmm1.neg
{
   .test.in:
       movmskpd ecx, xmm1                       ; ecx = sign bits
        test    ecx, 1
        jnz    .test.out                        ; jump if x < 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .test.out:
}

macro @@..xmm1.neg
{
   .test.in:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm1, xmm5                      ; compare x to 0
        jb     .test.out                        ; jump if x < 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .test.out:
}

macro @@..xmm1.neg
{
   .test.in:
        comisd  xmm1, [??.0.0]                  ; compare x to 0
        jb     .test.out                        ; jump if x < 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .test.out:
}

; ------------------------------------------------------------------------------

; x = st0
; returns: st0=x, x < 0
;          st0=0, otherwise

macro @@.st0.neg
{
   .test.in:
        ftst
        fnjl   .test.out                        ; return x
        fldz                                    ; return 0
        fstp    st1
   .test.out:
}

macro @@.st0.neg.unsafe
{
   .test.in:
        ftst
        fnjl   .test.out                        ; return x
        fstp    st0
        fldz                                    ; return 0
   .test.out:
        fnop                                    ; optimizer directive - don't optimize code near the label
}

; ------------------------------------------------------------------------------
