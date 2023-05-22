
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (core functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; dummy function (for internal use)
$usprocf @@.nop

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; sizeof
$usprocf @@sizeof

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; void
$usprocf @@void

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; tcarg
; complex argument typecast for external procedure
$usprocf @@tcarg

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; int3
$usprocf @@int3

        int3
    .return:
        retn
$endp

; int 3
$usprocf @@int.3

        int 3
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; set default result value
; esp = value
$usprocf @@result.set

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; set default result double value
; double result.set.double ( double x )
; esp = value

macro @@.result.set.double.sse
{
$usprocf @@.result.set.double

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
    .return:
        retn
$endp
}

macro @@.result.set.double.fpu
{
$usprocf @@.result.set.double

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fst     qword [@@_LOCALS_32_RESULT]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.result.set.double.sse
$else
  @@.result.set.double.fpu
$end

; ------------------------------------------------------------------------------

; set default result integer value
; double result.set.int ( int x )
; esp = value

macro @@.result.set.int.sse
{
$usprocf @@.result.set.int

        cvtsi2sd xmm0, dword [esp]
        movsd    qword [@@_LOCALS_32_RESULT], xmm0
    .return:
        retn
$endp
}

macro @@.result.set.int.fpu
{
$usprocf @@.result.set.int

        fild    dword [esp]
        fst     qword [@@_LOCALS_32_RESULT]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.result.set.int.sse
$else
  @@.result.set.int.fpu
$end

; ------------------------------------------------------------------------------

; get default result value
; double result.get ()

macro @@result.get.sse
{
$usprocf @@result.get

        movsd   xmm0, qword [@@_LOCALS_32_RESULT]
    .return:
        retn
$endp
}

macro @@result.get.fpu
{
$usprocf @@result.get

        fld     qword [@@_LOCALS_32_RESULT]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@result.get.sse
$else
  @@result.get.fpu
$end

; ------------------------------------------------------------------------------

; copy result.get to dst
; co.rcopy ( pdouble dst )
; dst offset = ecx

macro @@co.rcopy.sse
{
$usprocf @@co.rcopy

        movsd   xmm0, qword [@@_LOCALS_32_RESULT]
    .copy:
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@co.rcopy.fpu
{
$usprocf @@co.rcopy

        fld     qword [@@_LOCALS_32_RESULT]
    .copy:
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.rcopy.sse
$else
  @@co.rcopy.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@co.rxcopy.sse
{
$usprocf @@co.rxcopy

        movsd   xmm0, qword [@@_LOCALS_32_RESULT]
    .copy:
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@co.rxcopy.fpu
{
$usprocf @@co.rxcopy

        fld     qword [@@_LOCALS_32_RESULT]
    .copy:
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.rxcopy.sse
$else
  @@co.rxcopy.fpu
$end

; ------------------------------------------------------------------------------

; copy result.get to dst
; co.rcopy ( pinteger dst )
; dst offset = ecx

macro @@_co.int.rcopy.sse
{
$usprocf @@_co.int.rcopy

        movsd     xmm0, qword [@@_LOCALS_32_RESULT]
    .inter:
        cvttsd2si eax, xmm0                     ; eax = trunc(xmm0)
        cvtsi2sd  xmm0, eax                     ; xmm0 = trunc(xmm0)
        mov       dword [ecx], eax
    .return:
        retn
$endp
}

macro @@_co.int.rcopy.fpu
{
$usprocf @@_co.int.rcopy

        fld     qword [@@_LOCALS_32_RESULT]
    .inter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        fistp   dword [ecx]
        fild    dword [ecx]
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.rcopy.sse
$else
  @@_co.int.rcopy.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; exit
$usprocf @@exit

        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; return
$usprocf @@return

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; return
$usprocf @@.returnv

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; return double value
; esp = double value
; edx = ??exit label offset

macro @@.return.double.sse
{
$usprocf @@.return.double

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        add     esp, 8
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@.return.double.fpu
{
$usprocf @@.return.double

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        add     esp, 8
        fstp    qword [@@_LOCALS_32_RESULT]
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.return.double.sse
$else
  @@.return.double.fpu
$end

; ------------------------------------------------------------------------------

; return integer value
; esp = integer value
; edx = ??exit label offset

macro @@.return.int.sse
{
$usprocf @@.return.int

        cvtsi2sd xmm0, dword [esp]
        add     esp, 4
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@.return.int.fpu
{
$usprocf @@.return.int

        fild    dword [esp]
        add     esp, 4
        fstp    qword [@@_LOCALS_32_RESULT]
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.return.int.sse
$else
  @@.return.int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; exit
; exit.if.true ( integer c )
; exit if c is true
;
; esp = c
; edx = ??exit label offset

$usprocf @@exit.if.true

        mov     eax, dword [esp]
        add     esp, 4
        test    eax, eax
        jz     .return
    .c.nz:
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; exit
; exit.if.false ( integer c )
; exit if c is false
;
; esp = c
; edx = ??exit label offset

$usprocf @@exit.if.false

        mov     eax, dword [esp]
        add     esp, 4
        test    eax, eax
        jnz    .return
    .c.z:
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; return
$usprocf @@return.if.true

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; return
$usprocf @@.returnv.if.true

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; return
; return.double.if.true ( double x, integer c )
; return x if c is true
;
; esp + 0 = x
; esp + 8 = c
; edx = ??exit label offset

macro @@.return.double.if.true.sse
{
$usprocf @@.return.double.if.true

        cmp     dword [esp + 8], 0
        jz     .return
    .c.nz:
        movsd   xmm0, qword [esp]
        add     esp, 12
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 12
        retn
$endp
}

macro @@.return.double.if.true.fpu
{
$usprocf @@.return.double.if.true

        cmp     dword [esp + 8], 0
        jz     .return
    .c.nz:
        fld     qword [esp]
        add     esp, 12
        fstp    qword [@@_LOCALS_32_RESULT]
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 12
        retn
$endp
}

$ifdef _SSEX
  @@.return.double.if.true.sse
$else
  @@.return.double.if.true.fpu
$end

; ------------------------------------------------------------------------------

; return
; return.int.if.true ( integer x, integer c )
; return x if c is true
;
; esp + 0 = x
; esp + 4 = c
; edx = ??exit label offset

macro @@.return.int.if.true.sse
{
$usprocf @@.return.int.if.true

        cmp     dword [esp + 4], 0
        jz     .return
    .c.nz:
        cvtsi2sd xmm0, dword [esp]
        add     esp, 08
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 08
        retn
$endp
}

macro @@.return.int.if.true.fpu
{
$usprocf @@.return.int.if.true

        cmp     dword [esp + 4], 0
        jz     .return
    .c.nz:
        fild    dword [esp]
        add     esp, 08
        fstp    qword [@@_LOCALS_32_RESULT]
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 08
        retn
$endp
}

$ifdef _SSEX
  @@.return.int.if.true.sse
$else
  @@.return.int.if.true.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; return
$usprocf @@return.if.false

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; return
$usprocf @@.returnv.if.false

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; return
; return.double.if.false ( double x, integer c )
; return x if c is false
;
; esp + 0 = x
; esp + 8 = c
; edx = ??exit label offset

macro @@.return.double.if.false.sse
{
$usprocf @@.return.double.if.false

        cmp     dword [esp + 8], 0
        jnz    .return
    .c.z:
        movsd   xmm0, qword [esp]
        add     esp, 12
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 12
        retn
$endp
}

macro @@.return.double.if.false.fpu
{
$usprocf @@.return.double.if.false

        cmp     dword [esp + 8], 0
        jnz    .return
    .c.z:
        fld     qword [esp]
        add     esp, 12
        fstp    qword [@@_LOCALS_32_RESULT]
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 12
        retn
$endp
}

$ifdef _SSEX
  @@.return.double.if.false.sse
$else
  @@.return.double.if.false.fpu
$end

; ------------------------------------------------------------------------------

; return
; return.int.if.false ( integer x, integer c )
; return x if c is false
;
; esp + 0 = x
; esp + 4 = c
; edx = ??exit label offset

macro @@.return.int.if.false.sse
{
$usprocf @@.return.int.if.false

        cmp     dword [esp + 4], 0
        jnz    .return
    .c.z:
        cvtsi2sd xmm0, dword [esp]
        add     esp, 08
        movsd   qword [@@_LOCALS_32_RESULT], xmm0
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 08
        retn
$endp
}

macro @@.return.int.if.false.fpu
{
$usprocf @@.return.int.if.false

        cmp     dword [esp + 4], 0
        jnz    .return
    .c.z:
        fild    dword [esp]
        add     esp, 08
        fstp    qword [@@_LOCALS_32_RESULT]
        mov     [@@_LOCALS_32_EXIT_LABEL], edx
        jmp     dword [edx]
    .return:
        add     esp, 08
        retn
$endp
}

$ifdef _SSEX
  @@.return.int.if.false.sse
$else
  @@.return.int.if.false.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double variable declaration (for internal use)
$usprocf @@.var.double

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; complex variable declaration (for internal use)
$usprocf @@.var.complex

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; integer variable declaration (for internal use)
$usprocf @@.var.integer

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; pointer variable declaration (for internal use)
$usprocf @@.var.pointer

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; string variable declaration (for internal use)
$usprocf @@.var.string

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; absolute
$usprocf @@absolute

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; assign
$usprocf @@assign

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; reassign
$usprocf @@reassign

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; "tvar" keyword (for internal use)
$usprocf @@tvar

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tfloat" keyword (for internal use)
$usprocf @@tfloat

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tdouble" keyword (for internal use)
$usprocf @@tdouble

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tcvar" keyword (for internal use)
$usprocf @@tcvar

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tcomplex" keyword (for internal use)
$usprocf @@tcomplex

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tint" keyword (for internal use)
$usprocf @@tint

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tinteger" keyword (for internal use)
$usprocf @@tinteger

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tint64" keyword (for internal use)
$usprocf @@tint64

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tstr" keyword (for internal use)
$usprocf @@tstr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tstring" keyword (for internal use)
$usprocf @@tstring

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tptr" keyword (for internal use)
$usprocf @@tptr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "tpointer" keyword (for internal use)
$usprocf @@tpointer

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; "var" keyword (for internal use)
$usprocf @@var

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "float" keyword (for internal use)
$usprocf @@float

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "double" keyword (for internal use)
$usprocf @@double

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "cvar" keyword (for internal use)
$usprocf @@cvar

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "complex" keyword (for internal use)
$usprocf @@complex

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "array2" keyword (for internal use)
$usprocf @@array2

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "array3" keyword (for internal use)
$usprocf @@array3

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "array4" keyword (for internal use)
$usprocf @@array4

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "integer" keyword (for internal use)
$usprocf @@integer

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "array2i" keyword (for internal use)
$usprocf @@array2i

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "array3i" keyword (for internal use)
$usprocf @@array3i

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "array4i" keyword (for internal use)
$usprocf @@array4i

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "str" keyword (for internal use)
$usprocf @@str

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "string" keyword (for internal use)
$usprocf @@string

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "ptr" keyword (for internal use)
$usprocf @@ptr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; "pointer" keyword (for internal use)
$usprocf @@pointer

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; address
$usprocf @@addr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address
$usprocf @@.addr.1P

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address
$usprocf @@.addr.2P

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address of string array
$usprocf @@saddr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; address as double variable
$usprocf @@vfloat

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as double variable
$usprocf @@vdouble

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as complex variable
$usprocf @@vcomplex

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array2 variable
$usprocf @@varray2

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array3 variable
$usprocf @@varray3

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array4 variable
$usprocf @@varray4

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as integer variable
$usprocf @@vint

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as integer variable
$usprocf @@vinteger

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array2i variable
$usprocf @@varray2i

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array3i variable
$usprocf @@varray3i

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array4i variable
$usprocf @@varray4i

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as string variable
$usprocf @@vstr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as string variable
$usprocf @@vstring

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array2s variable
$usprocf @@varray2s

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array3s variable
$usprocf @@varray3s

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; address as array4s variable
$usprocf @@varray4s

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double indirection operator
; ecx = value offset

macro @@pdouble.sse
{
$usprocf @@pdouble

        movsd   xmm0, qword [ecx]
    .return:
        retn
$endp
}

macro @@pdouble.fpu
{
$usprocf @@pdouble

        fld     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pdouble.sse
$else
  @@pdouble.fpu
$end

; ------------------------------------------------------------------------------

; complex indirection operator
; ecx = complex offset

macro @@pcomplex.sse
{
$usprocf @@pcomplex

        movsd   xmm0, qword [ecx]
        movsd   xmm1, qword [ecx + 8]
    .return:
        retn
$endp
}

macro @@pcomplex.fpu
{
$usprocf @@pcomplex

        fld     qword [ecx]
        fld     qword [ecx + 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pcomplex.sse
$else
  @@pcomplex.fpu
$end

; ------------------------------------------------------------------------------

; array2 indirection operator
; ecx = array offset

macro @@parray2.sse
{
$usprocf @@parray2

        movsd   xmm0, qword [ecx]
        movsd   xmm1, qword [ecx + 8]
    .return:
        retn
$endp
}

macro @@parray2.fpu
{
$usprocf @@parray2

        fld     qword [ecx]
        fld     qword [ecx + 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@parray2.sse
$else
  @@parray2.fpu
$end

; ------------------------------------------------------------------------------

; array3 indirection operator
; ecx = array offset

macro @@parray3.sse
{
$usprocf @@parray3

        movsd   xmm0, qword [ecx]
        movsd   xmm1, qword [ecx + 8]
        movsd   xmm2, qword [ecx + 16]
    .return:
        retn
$endp
}

macro @@parray3.fpu
{
$usprocf @@parray3

        fld     qword [ecx]
        fld     qword [ecx + 8]
        fld     qword [ecx + 16]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@parray3.sse
$else
  @@parray3.fpu
$end

; ------------------------------------------------------------------------------

; array4 indirection operator
; ecx = array offset

macro @@parray4.sse
{
$usprocf @@parray4

        movsd   xmm0, qword [ecx]
        movsd   xmm1, qword [ecx + 8]
        movsd   xmm2, qword [ecx + 16]
        movsd   xmm3, qword [ecx + 24]
    .return:
        retn
$endp
}

macro @@parray4.fpu
{
$usprocf @@parray4

        fld     qword [ecx]
        fld     qword [ecx + 8]
        fld     qword [ecx + 16]
        fld     qword [ecx + 24]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@parray4.sse
$else
  @@parray4.fpu
$end

; ------------------------------------------------------------------------------

; integer indirection operator
; x32 : 4-byte integer
; x64 : 8-byte integer
; ecx = value offset
; return result in eax

$usprocf @@pint

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; string indirection operator
; x32 : 4-byte integer
; x64 : 8-byte integer
; ecx = value offset
; return result in eax

$usprocf @@pstr

        mov     eax, dword [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; int32 indirection operator
; ecx = value offset

macro @@pint32.sse
{
$usprocf @@pint32

        cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@pint32.fpu
{
$usprocf @@pint32

        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pint32.sse
$else
  @@pint32.fpu
$end

; ------------------------------------------------------------------------------

; int64 indirection operator
; ecx = value offset

macro @@pint64.sse
{
$usprocf @@pint64

    $ifdef _X64
        cvtsi2sd xmm0, qword [rcx]
    $else
       .mem     EQU esp - 64

        fild    qword [ecx]
        fstp    qword [.mem]
        movsd   xmm0, qword [.mem]
    $endif
    .return:
        retn
$endp
}

macro @@pint64.fpu
{
$usprocf @@pint64

        fild    qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pint64.sse
$else
  @@pint64.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double type modifier

macro @@.double.sse
{
$usprocf @@.double

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

macro @@.double.fpu
{
$usprocf @@.double

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.double.sse
$else
  @@.double.fpu
$end

; ------------------------------------------------------------------------------

; integer type modifier
; x32 : 4-byte integer
; x64 : 8-byte integer

$usprocf @@.int

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; int32 type modifier
$usprocf @@.int32

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; int64 type modifier
$usprocf @@.int64

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; compile-time value
$usprocf @@covalue

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; assign compile-time value
; return value
$usprocf @@restore

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; assign compile-time value
; return void
$usprocf @@reset

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; is x32 DLL?
;
; returns 1 if DLL is x32
;         0 if DLL is not x32

$usprocf @@is.x32

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; is not x32 DLL?
;
; returns 1 if DLL is not x32
;         0 if DLL is x32

$usprocf @@is.n32

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; is x64 DLL?
;
; returns 1 if DLL is x64
;         0 if DLL is not x64

$usprocf @@is.x64

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; is not x64 DLL?
;
; returns 1 if DLL is not x64
;         0 if DLL is x64

$usprocf @@is.n64

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; DLL bitness
$usprocf @@dll.bits

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; returns whether x is a NaN (Not-A-Number) value
; return result in eax
; x = esp

; IsNan
; ((D and $7FF00000'00000000) == $7FF00000'00000000) and
; ((D and $000FFFFF'FFFFFFFF) <> $00000000'00000000)

$usprocf @@is.nan

        xor     eax, eax
        mov     dx, [esp + 6]
        and     dx, 0x7FF0
        cmp     dx, 0x7FF0
        jne    .return
    .0x7FF0:
        mov     edx, [esp + 4]
        and     edx, 0x000FFFFF
        jnz    .1
        mov     edx, [esp + 0]
        and     edx, 0xFFFFFFFF
        jz     .return
    .1:
        inc     eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; returns whether x is an infinity value (either positive infinity or negative infinity)
; return result in eax
; x = esp

; IsInfinite
; ((D and $7FF00000'00000000) == $7FF00000'00000000) and
; ((D and $000FFFFF'FFFFFFFF) == $00000000'00000000)

$usprocf @@is.inf

        xor     eax, eax
        mov     dx, [esp + 6]
        and     dx, 0x7FF0
        cmp     dx, 0x7FF0
        jne    .return
    .0x7FF0:
        mov     edx, [esp + 4]
        and     edx, 0x000FFFFF
        jnz    .return
        mov     edx, [esp + 0]
        and     edx, 0xFFFFFFFF
        jnz    .return
    .1:
        inc     eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; returns whether x is a valid value
; a valid value is any floating-point value that is neither infinite nor NaN (Not-A-Number)
; return result in eax
; x = esp

$usprocf @@is.valid

        xor     eax, eax
        mov     dx, [esp + 6]
        and     dx, 0x7FF0
        cmp     dx, 0x7FF0
        je     .return
    .1:
        inc     eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; returns whether x is an invalid value
; an invalid value is any floating-point value that is either infinite or NaN (Not-A-Number)
; return result in eax
; x = esp

$usprocf @@is.invalid

        xor     eax, eax
        mov     dx, [esp + 6]
        and     dx, 0x7FF0
        cmp     dx, 0x7FF0
        jne    .return
    .1:
        inc     eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; returns NaN (Not-A-Number) value
; 0xFFF8000000000000 = 0.0/0.0

macro @@nan.sse
{
$usprocf @@nan

        xmovsd  xmm0, ??.NaN
   .return:
        retn
$endp
}

macro @@nan.fpu
{
$usprocf @@nan

        fldq    ??.NaN
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@nan.sse
$else
  @@nan.fpu
$end

; ------------------------------------------------------------------------------

; returns NaN (Not-A-Number) value
; 0xFFFFFFFFFFFFFFFF

macro @@nanu.sse
{
$usprocf @@nanu

        xmovsd  xmm0, ??.NaNu
   .return:
        retn
$endp
}

macro @@nanu.fpu
{
$usprocf @@nanu

        fldq    ??.NaNu
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@nanu.sse
$else
  @@nanu.fpu
$end

; ------------------------------------------------------------------------------

; returns positive infinity value
; 0x7FF0000000000000 = +1.0/0.0

macro @@pinf.sse
{
$usprocf @@pinf

        xmovsd  xmm0, ??.PInf
   .return:
        retn
$endp
}

macro @@pinf.fpu
{
$usprocf @@pinf

        fldq    ??.PInf
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@pinf.sse
$else
  @@pinf.fpu
$end

; ------------------------------------------------------------------------------

; returns negative infinity value
; 0xFFF0000000000000 = -1.0/0.0

macro @@ninf.sse
{
$usprocf @@ninf

        xmovsd  xmm0, ??.NInf
   .return:
        retn
$endp
}

macro @@ninf.fpu
{
$usprocf @@ninf

        fldq    ??.NInf
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ninf.sse
$else
  @@ninf.fpu
$end

; ------------------------------------------------------------------------------

; returns positive epsilon value
; 0x0000000000000001
; 4.9406564584124654417656879286822e-324 = +(2^(-1074))

macro @@peps.sse
{
$usprocf @@peps

        xmovsd  xmm0, ??.PEpsilon
   .return:
        retn
$endp
}

macro @@peps.fpu
{
$usprocf @@peps

        fldq    ??.PEpsilon
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@peps.sse
$else
  @@peps.fpu
$end

; ------------------------------------------------------------------------------

; returns negative epsilon value
; 0x8000000000000001
; -4.9406564584124654417656879286822e-324 = -(2^(-1074))

macro @@neps.sse
{
$usprocf @@neps

        xmovsd  xmm0, ??.NEpsilon
   .return:
        retn
$endp
}

macro @@neps.fpu
{
$usprocf @@neps

        fldq    ??.NEpsilon
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@neps.sse
$else
  @@neps.fpu
$end

; ------------------------------------------------------------------------------

; returns maximum double value
; 0x7FEFFFFFFFFFFFFF
; 1.7976931348623157081452742373170e+308 = +(2^1023)*(2-2^(-52))

macro @@maxd.sse
{
$usprocf @@maxd

        xmovsd  xmm0, ??.max.Double
   .return:
        retn
$endp
}

macro @@maxd.fpu
{
$usprocf @@maxd

        fldq    ??.max.Double
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@maxd.sse
$else
  @@maxd.fpu
$end

; ------------------------------------------------------------------------------

; returns minimum double value
; 0xFFEFFFFFFFFFFFFF
; -1.7976931348623157081452742373170e+308 = -(2^1023)*(2-2^(-52))

macro @@mind.sse
{
$usprocf @@mind

        xmovsd  xmm0, ??.min.Double
   .return:
        retn
$endp
}

macro @@mind.fpu
{
$usprocf @@mind

        fldq    ??.min.Double
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mind.sse
$else
  @@mind.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; returns 0 for any x

macro @@setz.sse
{
$usprocf @@setz

    .enter:
        xorpd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@setz.fpu
{
$usprocf @@setz

    .enter:
        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@setz.sse
$else
  @@setz.fpu
$end

; ------------------------------------------------------------------------------

; returns 0 for any x

macro @@_setz_int.sse
{
$usprocf @@_setz_int

    .enter:
        xorpd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_setz_int.fpu
{
$usprocf @@_setz_int

    .enter:
        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_setz_int.sse
$else
  @@_setz_int.fpu
$end

; ------------------------------------------------------------------------------

; returns 1 for any x

macro @@set1.sse
{
$usprocf @@set1

    .enter:
        xmovsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@set1.fpu
{
$usprocf @@set1

    .enter:
        fld1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@set1.sse
$else
  @@set1.fpu
$end

; ------------------------------------------------------------------------------

; returns 1 for any x

macro @@_set1_int.sse
{
$usprocf @@_set1_int

    .enter:
        xmovsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@_set1_int.fpu
{
$usprocf @@_set1_int

    .enter:
        fld1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_set1_int.sse
$else
  @@_set1_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy the value of y to the variable x
; copy(x,y)
$usprocf @@copy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of y to the variable x
; xcopy(x,y)
$usprocf @@xcopy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of the variable x to the variable y
; copx(x,y)
$usprocf @@copx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of the variable x to the variable y
; ycopx(x,y)
$usprocf @@ycopx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; indirect copy y to px
; px = destination offset value
; pcopy(px,y)
$usprocf @@pcopy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; indirect copy y to px
; px = destination offset value
; pxcopy(px,y)
$usprocf @@pxcopy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; indirect copy x to py
; py = destination offset value
; pcopx(x,py)
$usprocf @@pcopx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; indirect copy x to py
; py = destination offset value
; pycopx(x,py)
$usprocf @@pycopx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy the int value of y to the variable x
; copy.int(x,y)
$usprocf @@copy.int

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the int value of y to the variable x
; xcopy.int(x,y)
$usprocf @@xcopy.int

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the int value of the variable x to the variable y
; copx.int(x,y)
$usprocf @@copx.int

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the int value of the variable x to the variable y
; ycopx.int(x,y)
$usprocf @@ycopx.int

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy the frac value of y to the variable x
; copy.frac(x,y)
$usprocf @@copy.frac

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the frac value of y to the variable x
; xcopy.frac(x,y)
$usprocf @@xcopy.frac

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the frac value of the variable x to the variable y
; copx.frac(x,y)
$usprocf @@copx.frac

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the frac value of the variable x to the variable y
; ycopx.frac(x,y)
$usprocf @@ycopx.frac

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy the round value of y to the variable x
; copy.round(x,y)
$usprocf @@copy.round

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the round value of y to the variable x
; xcopy.round(x,y)
$usprocf @@xcopy.round

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the round value of the variable x to the variable y
; copx.round(x,y)
$usprocf @@copx.round

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the round value of the variable x to the variable y
; ycopx.round(x,y)
$usprocf @@ycopx.round

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy the value of y to the variable x
; move(x,y)
; return nothing
$usprocf @@move

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of the variable x to the variable y
; movx(x,y)
; return nothing
$usprocf @@movx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; indirect copy y to px
; px = destination offset value
; pmove(px,y)
; return nothing
$usprocf @@pmove

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; indirect copy x to py
; py = destination offset value
; pmovx(x,py)
; return nothing
$usprocf @@pmovx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x2copy(x_1, x_2, y_1, y_2)
$usprocf @@x2copy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x2copy(x_1, x_2, y_1, y_2)
;
; eax      = x_1 offset
; edx      = x_2 offset
; esp + 00 = y_1 value
; esp + 08 = y_2 value

macro @@.x2copy.d.sse
{
$usprocf @@.x2copy.d

        movsd   xmm0, qword [esp + 08]
        movsd   qword [edx], xmm0
        movsd   xmm0, qword [esp + 00]
        movsd   qword [eax], xmm0
    .return:
        add     esp, 2*8
        retn
$endp
}

macro @@.x2copy.d.fpu
{
$usprocf @@.x2copy.d

    $ifdef _X64
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        fld     qword [rsp]
    $else
        fld     qword [esp + 08]
        fstp    qword [edx]
        fld     qword [esp + 00]
        fst     qword [eax]
    $end
    .return:
        add     esp, 2*8
        retn
$endp
}

$ifdef _SSEX
  @@.x2copy.d.sse
$else
  @@.x2copy.d.fpu
$end

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x2copy(x_1, x_2, y_1, y_2)
;
; eax      = x_1 offset
; edx      = x_2 offset
; esp + 00 = y_1 value
; esp + 04 = y_2 value

macro @@.x2copy.i.sse
{
$usprocf @@.x2copy.i

    $ifdef _X64
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        cvtsi2sd xmm0, r11
    $else
        mov     ecx, dword [esp + 04]
        mov     dword [edx], ecx
        mov     ecx, dword [esp + 00]
        mov     dword [eax], ecx
        cvtsi2sd xmm0, ecx
    $end
    .return:
        add     esp, 2*4
        retn
$endp
}

macro @@.x2copy.i.fpu
{
$usprocf @@.x2copy.i

    $ifdef _X64
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        fild    qword [rsp]
    $else
        mov     ecx, dword [esp + 04]
        mov     dword [edx], ecx
        mov     ecx, dword [esp + 00]
        mov     dword [eax], ecx
        fild    dword [esp]
    $end
    .return:
        add     esp, 2*4
        retn
$endp
}

$ifdef _SSEX
  @@.x2copy.i.sse
$else
  @@.x2copy.i.fpu
$end

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; x2copy(x_1, x_2, y_1, y_2)
;
; eax      = x_1 offset
; edx      = x_2 offset
; esp + 00 = y_1 value
; esp + 04 = y_2 value

$usprocf @@.x2copy.s

    $ifdef _X64
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
    $else
        mov     ecx, dword [esp + 04]
        mov     dword [edx], ecx
        mov     ecx, dword [esp + 00]
        mov     dword [eax], ecx
    $end
    .return:
        add     esp, 2*4
        retn
$endp

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x3copy(x_1, x_2, x_3, y_1, y_2, y_3)
$usprocf @@x3copy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x3copy(x_1, x_2, x_3, y_1, y_2, y_3)
;
; eax      = x_1 offset
; edx      = x_2 offset
; ecx      = x_3 offset
; esp + 00 = y_1 value
; esp + 08 = y_2 value
; esp + 16 = y_3 value

macro @@.x3copy.d.sse
{
$usprocf @@.x3copy.d

        movsd   xmm0, qword [esp + 16]
        movsd   qword [ecx], xmm0
        movsd   xmm0, qword [esp + 08]
        movsd   qword [edx], xmm0
        movsd   xmm0, qword [esp + 00]
        movsd   qword [eax], xmm0
    .return:
        add     esp, 3*8
        retn
$endp
}

macro @@.x3copy.d.fpu
{
$usprocf @@.x3copy.d

    $ifdef _X64
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        fld     qword [rsp]
    $else
        fld     qword [esp + 16]
        fstp    qword [ecx]
        fld     qword [esp + 08]
        fstp    qword [edx]
        fld     qword [esp + 00]
        fst     qword [eax]
    $end
    .return:
        add     esp, 3*8
        retn
$endp
}

$ifdef _SSEX
  @@.x3copy.d.sse
$else
  @@.x3copy.d.fpu
$end

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x3copy(x_1, x_2, x_3, y_1, y_2, y_3)
;
; eax      = x_1 offset
; edx      = x_2 offset
; ecx      = x_3 offset
; esp + 00 = y_1 value
; esp + 04 = y_2 value
; esp + 08 = y_3 value

macro @@.x3copy.i.sse
{
$usprocf @@.x3copy.i

    $ifdef _X64
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        cvtsi2sd xmm0, r11
    $else
        mov     ebx, dword [esp + 08]
        mov     dword [ecx], ebx
        mov     ebx, dword [esp + 04]
        mov     dword [edx], ebx
        mov     ebx, dword [esp + 00]
        mov     dword [eax], ebx
        cvtsi2sd xmm0, ebx
    $end
    .return:
        add     esp, 3*4
        retn
$endp
}

macro @@.x3copy.i.fpu
{
$usprocf @@.x3copy.i

    $ifdef _X64
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        fild    qword [rsp]
    $else
        mov     ebx, dword [esp + 08]
        mov     dword [ecx], ebx
        mov     ebx, dword [esp + 04]
        mov     dword [edx], ebx
        mov     ebx, dword [esp + 00]
        mov     dword [eax], ebx
        fild    dword [esp]
    $end
    .return:
        add     esp, 3*4
        retn
$endp
}

$ifdef _SSEX
  @@.x3copy.i.sse
$else
  @@.x3copy.i.fpu
$end

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; x3copy(x_1, x_2, x_3, y_1, y_2, y_3)
;
; eax      = x_1 offset
; edx      = x_2 offset
; ecx      = x_3 offset
; esp + 00 = y_1 value
; esp + 04 = y_2 value
; esp + 08 = y_3 value

$usprocf @@.x3copy.s

    $ifdef _X64
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
    $else
        mov     ebx, dword [esp + 08]
        mov     dword [ecx], ebx
        mov     ebx, dword [esp + 04]
        mov     dword [edx], ebx
        mov     ebx, dword [esp + 00]
        mov     dword [eax], ebx
    $end
    .return:
        add     esp, 3*4
        retn
$endp

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x4copy(x_1, x_2, x_3, x_4, y_1, y_2, y_3, y_4)
$usprocf @@x4copy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x4copy(x_1, x_2, x_3, x_4, y_1, y_2, y_3, y_4)
;
; eax      = x_1 offset
; edx      = x_2 offset
; ecx      = x_3 offset
; ebx      = x_4 offset
; esp + 00 = y_1 value
; esp + 08 = y_2 value
; esp + 16 = y_3 value
; esp + 24 = y_4 value

macro @@.x4copy.d.sse
{
$usprocf @@.x4copy.d

        movsd   xmm0, qword [esp + 24]
        movsd   qword [ebx], xmm0
        movsd   xmm0, qword [esp + 16]
        movsd   qword [ecx], xmm0
        movsd   xmm0, qword [esp + 08]
        movsd   qword [edx], xmm0
        movsd   xmm0, qword [esp + 00]
        movsd   qword [eax], xmm0
    .return:
        add     esp, 4*8
        retn
$endp
}

macro @@.x4copy.d.fpu
{
$usprocf @@.x4copy.d

    $ifdef _X64
        mov     r11, qword [rsp + 24]
        mov     qword [r10], r11
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        fld     qword [rsp]
    $else
        fld     qword [esp + 24]
        fstp    qword [ebx]
        fld     qword [esp + 16]
        fstp    qword [ecx]
        fld     qword [esp + 08]
        fstp    qword [edx]
        fld     qword [esp + 00]
        fst     qword [eax]
    $end
    .return:
        add     esp, 4*8
        retn
$endp
}

$ifdef _SSEX
  @@.x4copy.d.sse
$else
  @@.x4copy.d.fpu
$end

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; double x4copy(x_1, x_2, x_3, x_4, y_1, y_2, y_3, y_4)
;
; eax      = x_1 offset
; edx      = x_2 offset
; ecx      = x_3 offset
; ebx      = x_4 offset
; esp + 00 = y_1 value
; esp + 04 = y_2 value
; esp + 08 = y_3 value
; esp + 12 = y_4 value

macro @@.x4copy.i.sse
{
$usprocf @@.x4copy.i

    $ifdef _X64
        mov     r11, qword [rsp + 24]
        mov     qword [r10], r11
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        cvtsi2sd xmm0, r11
    $else
        mov     [esp - 4], ecx
        mov     ecx, dword [esp + 12]
        mov     dword [ebx], ecx
        mov     ecx, [esp - 4]
        mov     ebx, dword [esp + 08]
        mov     dword [ecx], ebx
        mov     ebx, dword [esp + 04]
        mov     dword [edx], ebx
        mov     ebx, dword [esp + 00]
        mov     dword [eax], ebx
        cvtsi2sd xmm0, ebx
    $end
    .return:
        add     esp, 4*4
        retn
$endp
}

macro @@.x4copy.i.fpu
{
$usprocf @@.x4copy.i

    $ifdef _X64
        mov     r11, qword [rsp + 24]
        mov     qword [r10], r11
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
        fild    qword [rsp]
    $else
        mov     [esp - 4], ecx
        mov     ecx, dword [esp + 12]
        mov     dword [ebx], ecx
        mov     ecx, [esp - 4]
        mov     ebx, dword [esp + 08]
        mov     dword [ecx], ebx
        mov     ebx, dword [esp + 04]
        mov     dword [edx], ebx
        mov     ebx, dword [esp + 00]
        mov     dword [eax], ebx
        fild    dword [esp]
    $end
    .return:
        add     esp, 4*4
        retn
$endp
}

$ifdef _SSEX
  @@.x4copy.i.sse
$else
  @@.x4copy.i.fpu
$end

; ------------------------------------------------------------------------------

; copy the value of y_i to the variable x_i
; x4copy(x_1, x_2, x_3, x_4, y_1, y_2, y_3, y_4)
;
; eax      = x_1 offset
; edx      = x_2 offset
; ecx      = x_3 offset
; ebx      = x_4 offset
; esp + 00 = y_1 value
; esp + 04 = y_2 value
; esp + 08 = y_3 value
; esp + 12 = y_4 value

$usprocf @@.x4copy.s

    $ifdef _X64
        mov     r11, qword [rsp + 24]
        mov     qword [r10], r11
        mov     r11, qword [rsp + 16]
        mov     qword [rcx], r11
        mov     r11, qword [rsp + 08]
        mov     qword [rdx], r11
        mov     r11, qword [rsp + 00]
        mov     qword [rax], r11
    $else
        mov     [esp - 4], ecx
        mov     ecx, dword [esp + 12]
        mov     dword [ebx], ecx
        mov     ecx, [esp - 4]
        mov     ebx, dword [esp + 08]
        mov     dword [ecx], ebx
        mov     ebx, dword [esp + 04]
        mov     dword [edx], ebx
        mov     ebx, dword [esp + 00]
        mov     dword [eax], ebx
    $end
    .return:
        add     esp, 4*4
        retn
$endp

; ------------------------------------------------------------------------------

; copy the value of variable y to the variables x_i
; vcopy(x_1, x_2, ..., x_n, y)
; variable number of arguments
; ecx -> argument count, min=2
;
; x_1 = esp
; x_2 = esp + 4
; ...

$usprocf @@vcopy

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy the value of variable x to the variables y_i
; vcopx(x, y_1, y_2, ..., y_n)
; variable number of arguments
; ecx -> argument count, min=2
;
; x   = esp
; y_1 = esp + 4
; ...

$usprocf @@vcopx

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap the values of the variables x and y
$usprocf @@swap

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap the int values of the variables x and y
$usprocf @@swap.int

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; swap the frac values of the variables x and y
$usprocf @@swap.frac

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; swap the round values of the variables x and y
$usprocf @@swap.round

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap the values of the variables
; shift right
; variable number of arguments
; ecx -> argument count, min=2

$usprocf @@swapr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; swap the values of the variables
; shift left
; variable number of arguments
; ecx -> argument count, min=2

$usprocf @@swapl

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; return argument #1
; x_1 = esp
; x_2 = esp + 08
; x_3 = esp + 16
; x_4 = esp + 24

macro @@.arg1.sse
{
$usprocf @@.arg1

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

macro @@.arg1.fpu
{
$usprocf @@.arg1

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

; return argument #1
; x_1 = esp
; x_2 = esp + 04
; x_3 = esp + 08
; x_4 = esp + 12

macro @@.arg1_int.sse
{
$usprocf @@.arg1_int

        cvtsi2sd xmm0, dword [esp]
    .return:
        retn
$endp
}

macro @@.arg1_int.fpu
{
$usprocf @@.arg1_int

        fild    dword [esp]
    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; return argument #2
; x_1 = esp
; x_2 = esp + 08
; x_3 = esp + 16
; x_4 = esp + 24

macro @@.arg2.sse
{
$usprocf @@.arg2

        movsd   xmm0, qword [esp + 08]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

macro @@.arg2.fpu
{
$usprocf @@.arg2

        fld     qword [esp + 08]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

; return argument #2
; x_1 = esp
; x_2 = esp + 04
; x_3 = esp + 08
; x_4 = esp + 12

macro @@.arg2_int.sse
{
$usprocf @@.arg2_int

        cvtsi2sd xmm0, dword [esp + 04]
    .return:
        retn
$endp
}

macro @@.arg2_int.fpu
{
$usprocf @@.arg2_int

        fild    dword [esp + 04]
    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; return argument #3
; x_1 = esp
; x_2 = esp + 08
; x_3 = esp + 16
; x_4 = esp + 24

macro @@.arg3.sse
{
$usprocf @@.arg3

        movsd   xmm0, qword [esp + 16]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

macro @@.arg3.fpu
{
$usprocf @@.arg3

        fld     qword [esp + 16]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

; return argument #3
; x_1 = esp
; x_2 = esp + 04
; x_3 = esp + 08
; x_4 = esp + 12

macro @@.arg3_int.sse
{
$usprocf @@.arg3_int

        cvtsi2sd xmm0, dword [esp + 08]
    .return:
        retn
$endp
}

macro @@.arg3_int.fpu
{
$usprocf @@.arg3_int

        fild    dword [esp + 08]
    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; return argument #4
; x_1 = esp
; x_2 = esp + 08
; x_3 = esp + 16
; x_4 = esp + 24

macro @@.arg4.sse
{
$usprocf @@.arg4

        movsd   xmm0, qword [esp + 24]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

macro @@.arg4.fpu
{
$usprocf @@.arg4

        fld     qword [esp + 24]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

; return argument #4
; x_1 = esp
; x_2 = esp + 04
; x_3 = esp + 08
; x_4 = esp + 12

macro @@.arg4_int.sse
{
$usprocf @@.arg4_int

        cvtsi2sd xmm0, dword [esp + 12]
    .return:
        retn
$endp
}

macro @@.arg4_int.fpu
{
$usprocf @@.arg4_int

        fild    dword [esp + 12]
    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------
