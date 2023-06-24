
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; common macros

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

XFT_offset_size = 4                   ; dd
XFT_data_size   = XFT_offset_size + 3 ; dd + db + db + db
macro c 
{
XFT_offset_size = 2                   ; dw
XFT_data_size   = XFT_offset_size + 3 ; dw + db + db + db
}

; ------------------------------------------------------------------------------

; global function table
; -> fat : function table label
; -> fun : function name
; -> fuo : function offset
; -> fua : function argument count
; -> fur : function return type
; -> sys : nonupdatable system function flag

macro GFT fat, [fun, fuo, fua, fur, sys]
{
  common
    local @count
    @count = 0

    fat:
  forward
    local @ndelta, @acount, @cosize, @sys

   $if ~ ((sys eq '-s') | (sys eq 's-') | (sys eq '-'))

   $if sys eq 's'
    @sys=1
    @ndelta=2
   $else
    @sys=0
    @ndelta=1
   $end

   $if fua eq 'any'
    @acount=0x80
   $else
    @acount=fua
   $end

    @cosize=fuo#.size

    db @@#fun#.nsize                            ; function name size
    @@#fun#.fname db `fun                       ; function name
    @@#fun#.nsize = $ - @@#fun#.fname           ; function name size
    db @sys

   $if fitem.nsize < @@#fun#.nsize + @ndelta    ; check function name size
    display 'invalid function name: ',`fun,13,10
    oops
   $end

   $if XFT_offset_size = 4
    @@#fun#.fuo dd fuo - SIC_F_BASE             ; function entry offset (relative)
   $else
    @@#fun#.fuo dw fuo - SIC_F_BASE             ; function entry offset (relative)
   $end
    @@#fun#.fua db @acount                      ; function argument count
    @@#fun#.fus db @cosize                      ; function code size

   $if fur eq 'i64'                             ; function return type
   $ifdef _X64
    @@#fun#.fur db 'i'                          ; integer
   $else
    @@#fun#.fur db 1                            ; 8-byte value
   $end
   $else
    @@#fun#.fur db fur
   $end

    @count = @count + 1

   $end
  common
    fat#.data.size = XFT_data_size
    fat#.count = @count
}

; ------------------------------------------------------------------------------

; sys function table
; -> fat : function table label
; -> fun : function name
; -> fuo : function offset
; -> fui : function ident
; -> fua : function argument count
; -> fur : function return type
; -> sys : nonupdatable system function flag

macro SFT fat, [fun, fuo, fui, fua, fur, sys]
{
  common
    local @count
    @count = 0

    fat:
  forward
    local @ndelta, @acount, @cosize, @sys

   $if ~ ((sys eq '-s') | (sys eq 's-') | (sys eq '-'))

   $if sys eq 's'
    @sys=1
    @ndelta=2
   $else
    @sys=0
    @ndelta=1
   $end

   $if fua eq 'any'
    @acount=0x80
   $else
    @acount=fua
   $end

    @cosize=fuo#.size

    db fui#.nsize                               ; function name size
    fui#.fname db `fun                          ; function name
    fui#.nsize = $ - fui#.fname                 ; function name size
    db @sys

   $if fitem.nsize < fui#.nsize + @ndelta       ; check function name size
    display 'invalid function name: ',fun,13,10
    oops
   $end

   $if XFT_offset_size = 4
    fui#.fuo dd fuo - SIC_F_BASE                ; function entry offset (relative)
   $else
    fui#.fuo dw fuo - SIC_F_BASE                ; function entry offset (relative)
   $end
    fui#.fua db @acount                         ; function argument count
    fui#.fus db @cosize                         ; function code size

   $if fur eq 'i64'                             ; function return type
   $ifdef _X64
    fui#.fur db 'i'                             ; integer
   $else
    fui#.fur db 1                               ; 8-byte value
   $end
   $else
    fui#.fur db fur
   $end

    @count = @count + 1

   $end
  common
    fat#.data.size = XFT_data_size
    fat#.count = @count
}

; ------------------------------------------------------------------------------

; global constant table
; -> cot : constant table label
; -> con : constant name
; -> cov : constant value
; -> coi : constant item type

macro GCT cot, [con, cov, coi]
{
  common
    local @count
    @count = 0

    cot:
  forward
    db con#.nsize                               ; constant name size
    con#.cname db `con                          ; constant name
    con#.nsize = $ - con#.cname                 ; constant name size
    db 0

   $if citem.nsize < con#.nsize + 1             ; check constant name size
    display 'invalid constant name: ',`con,13,10
    oops
   $end

   $if (coi eq 'f')
    dfq con#.value, cov                         ; constant value
;   ; be sure value is floating point
;   virtual.float cov
;   con#.value dq cov                           ; constant value
   $else
    con#.value dq cov                           ; constant value
   $end

    con#.itype db coi                           ; constant item type

    @count = @count + 1
  common
    cot#.data.size = 8 + 1                      ; data = value + item type
    cot#.count = @count
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; compare
; pointer values
macro pcmp cptr, vptr, reg
{
  common
  $ifdef _X64
    $ifdef _COFF
     $if (reg eq)
      mov  r10, vptr
      cmp  cptr, r10
     $else
      mov  reg, vptr
      cmp  cptr, reg
     $end
    $else
      cmp  cptr, vptr
    $end
  $else
      cmp  cptr, vptr
  $end
}

; ------------------------------------------------------------------------------

; case switch
macro case byte, [char, label]
{
  forward
  $if ~ ((char eq) | (label eq))
    cmp  byte, char
    je   label
  $end
}

; ------------------------------------------------------------------------------

; case switch
; pointer values
macro pcase cptr, [vptr, label]
{
  forward
  $if ~ ((vptr eq) | (label eq))
    $ifdef _X64
     $ifdef _COFF
      mov  r10, vptr
      cmp  cptr, r10
      je   label
     $else
      cmp  cptr, vptr
      je   label
     $end
    $else
      cmp  cptr, vptr
      je   label
    $end
  $end
}

; ------------------------------------------------------------------------------

; case switch
macro xcase label, byte, [char]
{
  forward
    cmp  byte, char
    je   label
}

; ------------------------------------------------------------------------------

; reverse case switch
macro ncase byte, [char, label]
{
  forward
  $if ~ ((char eq) | (label eq))
    cmp  byte, char
    jne  label
  $end
}

; ------------------------------------------------------------------------------

; reverse case switch
; pointer values
macro npcase cptr, [vptr, label]
{
  forward
  $if ~ ((vptr eq) | (label eq))
    $ifdef _X64
     $ifdef _COFF
      mov  r10, vptr
      cmp  cptr, r10
      jne  label
     $else
      cmp  cptr, vptr
      jne  label
     $end
    $else
      cmp  cptr, vptr
      jne  label
    $end
  $end
}

; ------------------------------------------------------------------------------

; convert char to lowercase
macro ctolow reg
{
    cmp  reg, 'A'
    jb   @F
    cmp  reg, 'Z'
    ja   @F
    add  reg, 0x20
    @@:
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; char data
macro cdata [n, v]
{
  common
;   align 16
  forward
    n db v
    n#.size = $-n
}

; ------------------------------------------------------------------------------

; string data
macro sdata [n, v]
{
  common
;   align 16
  forward
    n db v
    n#.size = $-n
    db 0
}

; ------------------------------------------------------------------------------

; 32-bit data
macro data32 [n]
{
  common
;   align 16
  forward
    n dd 0
    n#.name db `n,0
    n#.name.size = $-n#.name-1
}

; ------------------------------------------------------------------------------

; 64-bit data
macro data64 [n]
{
  common
;   align 16
  forward
    n dq 0
    n#.name db `n,0
    n#.name.size = $-n#.name-1
}

; ------------------------------------------------------------------------------

; 32-bit variable (16-byte alignment)
macro v32bit [n, v]
{
  common
    align 16
  forward
    n dd v
    n#.S = v
}

; ------------------------------------------------------------------------------

; 32-bit variable (no alignment)
macro u32bit [n, v]
{
  forward
    n dd v
    n#.S = v
}

; ------------------------------------------------------------------------------

; 64-bit variable (16-byte alignment)
macro v64bit [n, v]
{
  common
    align 16
  forward
    n dq v
    n#.S = v
}

; ------------------------------------------------------------------------------

; 64-bit variable (16-byte alignment)
macro va64bit [n, v]
{
  common
    align 16
  forward
    n dq v
    n#.S = v
    dq 0x0000000000000000
}

; ------------------------------------------------------------------------------

; 64-bit variable (no alignment)
macro u64bit [n, v]
{
  forward
    n dq v
    n#.S = v
}

; ------------------------------------------------------------------------------

; 128-bit variable (16-byte alignment)
macro v128bit [n, vLO, vHI]
{
  common
    align 16
  forward
    n     dq vLO
    n#.HI dq vHI
}

; ------------------------------------------------------------------------------

; 128-bit variable (no alignment)
macro u128bit [n, vLO, vHI]
{
  forward
    n     dq vLO
    n#.HI dq vHI
}

; ------------------------------------------------------------------------------

; 8-byte float variable (16-byte alignment)
macro vfloat8 [n, v]
{
  common
    align 16
  forward
    dfq n, v
;   ; be sure value is floating point
;   virtual.float v
;   n dq v
}

; ------------------------------------------------------------------------------

; 8-byte float variable (no alignment)
macro ufloat8 [n, v]
{
  forward
    dfq n, v
;   ; be sure value is floating point
;   virtual.float v
;   n dq v
}

; ------------------------------------------------------------------------------

; variable duplicate
macro vdup base, [n]
{
  forward
    n = base
    n#.S = base#.S
}

; ------------------------------------------------------------------------------

; 8-byte float local variable
macro float8 [n, v]
{
  common
    jmp @F
;   align 16
  forward
    dfq n, v
;   ; be sure value is floating point
;   virtual.float v
;   n dq v
  common
    @@:
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; SSE move
macro xmovq xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov  r10, var
      movq xmm, qword [r10]
    $else
      mov  reg, var
      movq xmm, qword [reg]
    $end
  $else
    $if (reg eq)
      movq xmm, qword [var]
    $else
      mov  reg, var
      movq xmm, qword [reg]
    $end
  $end
}

; SSE move
; move source (xmmS) to destination(xmmD)
macro xmovx xmmD, xmmS
{
  common
  $if ~ (xmmD eq xmmS)
    if xmmS in <xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, xmm10, xmm11, xmm12, xmm13, xmm14, xmm15>
;     movaps xmmD, xmmS                         ; copy 64 bits of xmmS to xmmD
      movsd  xmmD, xmmS
    else
      movsd  xmmD, xmmS
    end if
  $end
}

; SSE move
macro xmovsd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov    r10, var
;     movaps xmm, dqword [r10]
      movsd  xmm, qword [r10]
    $else
      mov    reg, var
;     movaps xmm, dqword [reg]
      movsd  xmm, qword [reg]
    $end
  $else
    $if (reg eq)
;     movaps xmm, dqword [var]
      movsd  xmm, qword [var]
    $else
      mov    reg, var
;     movaps xmm, dqword [reg]
      movsd  xmm, qword [reg]
    $end
  $end
}

; SSE move
macro xmovpd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov    r10, var
      movapd xmm, dqword [r10]
    $else
      mov    reg, var
      movapd xmm, dqword [reg]
    $end
  $else
    $if (reg eq)
      movapd xmm, dqword [var]
    $else
      mov    reg, var
      movapd xmm, dqword [reg]
    $end
  $end
}

; SSE move
macro movxpd xmm, src
{
  common
  $ifdef _X64
      movapd xmm, src
  $else
      movupd xmm, src
  $end
}

; SSE duplicate
; xmmD = xmmS.LO:xmmS.LO
macro xddup xmmD, xmmS
{
    $ifdef _SSE3
        movddup xmmD, xmmS                      ; xmmD = xmmS.LO:xmmS.LO
    $else
        xmovx   xmmD, xmmS                      ; xmmD = xmmS.LO:?
        shufpd  xmmD, xmmS, 0                   ; xmmD = xmmS.LO:xmmS.LO
    $end
}

; FPU load
macro fldq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov r10, var
      fld qword [r10]
    $else
      mov reg, var
      fld qword [reg]
    $end
  $else
    $if (reg eq)
      fld qword [var]
    $else
      mov reg, var
      fld qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

; SSE add
macro xaddsd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      addsd xmm, qword [r10]
    $else
      mov   reg, var
      addsd xmm, qword [reg]
    $end
  $else
    $if (reg eq)
      addsd xmm, qword [var]
    $else
      mov   reg, var
      addsd xmm, qword [reg]
    $end
  $end
}

; SSE add
macro xaddpd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      addpd xmm, dqword [r10]
    $else
      mov   reg, var
      addpd xmm, dqword [reg]
    $end
  $else
    $if (reg eq)
      addpd xmm, dqword [var]
    $else
      mov   reg, var
      addpd xmm, dqword [reg]
    $end
  $end
}

; FPU add
macro faddq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov  r10, var
      fadd qword [r10]
    $else
      mov  reg, var
      fadd qword [reg]
    $end
  $else
    $if (reg eq)
      fadd qword [var]
    $else
      mov  reg, var
      fadd qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

; SSE sub
macro xsubsd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      subsd xmm, qword [r10]
    $else
      mov   reg, var
      subsd xmm, qword [reg]
    $end
  $else
    $if (reg eq)
      subsd xmm, qword [var]
    $else
      mov   reg, var
      subsd xmm, qword [reg]
    $end
  $end
}

; SSE sub
macro xsubpd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      subpd xmm, dqword [r10]
    $else
      mov   reg, var
      subpd xmm, dqword [reg]
    $end
  $else
    $if (reg eq)
      subpd xmm, dqword [var]
    $else
      mov   reg, var
      subpd xmm, dqword [reg]
    $end
  $end
}

; FPU sub
macro fsubq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov  r10, var
      fsub qword [r10]
    $else
      mov  reg, var
      fsub qword [reg]
    $end
  $else
    $if (reg eq)
      fsub qword [var]
    $else
      mov  reg, var
      fsub qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

; FPU subr
macro fsubrq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      fsubr qword [r10]
    $else
      mov   reg, var
      fsubr qword [reg]
    $end
  $else
    $if (reg eq)
      fsubr qword [var]
    $else
      mov   reg, var
      fsubr qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

; SSE mul
macro xmulsd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      mulsd xmm, qword [r10]
    $else
      mov   reg, var
      mulsd xmm, qword [reg]
    $end
  $else
    $if (reg eq)
      mulsd xmm, qword [var]
    $else
      mov   reg, var
      mulsd xmm, qword [reg]
    $end
  $end
}

; SSE mul
macro xmulpd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      mulpd xmm, dqword [r10]
    $else
      mov   reg, var
      mulpd xmm, dqword [reg]
    $end
  $else
    $if (reg eq)
      mulpd xmm, dqword [var]
    $else
      mov   reg, var
      mulpd xmm, dqword [reg]
    $end
  $end
}

; FPU mul
macro fmulq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov  r10, var
      fmul qword [r10]
    $else
      mov  reg, var
      fmul qword [reg]
    $end
  $else
    $if (reg eq)
      fmul qword [var]
    $else
      mov  reg, var
      fmul qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

; SSE div
macro xdivsd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      divsd xmm, qword [r10]
    $else
      mov   reg, var
      divsd xmm, qword [reg]
    $end
  $else
    $if (reg eq)
      divsd xmm, qword [var]
    $else
      mov   reg, var
      divsd xmm, qword [reg]
    $end
  $end
}

; SSE div
macro xdivpd xmm, var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      divpd xmm, dqword [r10]
    $else
      mov   reg, var
      divpd xmm, dqword [reg]
    $end
  $else
    $if (reg eq)
      divpd xmm, dqword [var]
    $else
      mov   reg, var
      divpd xmm, dqword [reg]
    $end
  $end
}

; FPU div
macro fdivq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov  r10, var
      fdiv qword [r10]
    $else
      mov  reg, var
      fdiv qword [reg]
    $end
  $else
    $if (reg eq)
      fdiv qword [var]
    $else
      mov  reg, var
      fdiv qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

; FPU divr
macro fdivrq var, reg
{
  common
  $ifdef _X64
    $if (reg eq)
      mov   r10, var
      fdivr qword [r10]
    $else
      mov   reg, var
      fdivr qword [reg]
    $end
  $else
    $if (reg eq)
      fdivr qword [var]
    $else
      mov   reg, var
      fdivr qword [reg]
    $end
  $end
}

; ------------------------------------------------------------------------------

macro pushsa [r] ; push [r] & 16-byte stack align for x64
{
  common
    local @count
    @count = 0

  forward
    if ~ r eq
      @count = @count + 1
    end if

  common
  $ifdef _X64
    if @count mod 2 = 1
      test rsp, 0x0F
      jnz  @F
      push rax
    else
      test rsp, 0x0F
      jz   @F
      push rax
    end if
    @@:
  $end

  forward
    if ~ r eq
      push r
    end if
}

; ------------------------------------------------------------------------------

; clear exceptions
macro xnclex
{
    $ifdef _SSEX
       .mem32   EQU xsp - 64

        stmxcsr dword [.mem32]                  ; store MXCSR register state
        and     dword [.mem32], 0xFFFFFFC0      ; 11000000 ; clear exceptions
        ldmxcsr dword [.mem32]                  ; load MXCSR register state
    $else
        fnclex
    $end
}

; clear exceptions
macro xclex
{
    $ifdef _SSEX
       .mem32   EQU xsp - 64

        stmxcsr dword [.mem32]                  ; store MXCSR register state
        and     dword [.mem32], 0xFFFFFFC0      ; 11000000 ; clear exceptions
        ldmxcsr dword [.mem32]                  ; load MXCSR register state
    $else
        fclex
    $end
}

; ------------------------------------------------------------------------------
