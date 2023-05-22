
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (inline functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; do  - double offset
; doo - double offset offset
; dv  - double value
; io  - integer offset
; ioo - integer offset offset
; iv  - integer value
; so  - string offset
; soo - string offset offset
; sv  - string value

; ------------------------------------------------------------------------------

; integer typecast
; value on stack
; x = ST0(xmm0)
; return int32 in eax

macro @@__int32.sse
{
$asprocf @@__int32

    .enter:
        cvttsd2si eax, xmm0
    .return:
        retn
$endp
}

macro @@__int32.fpu
{
$asprocf @@__int32

       .int32   EQU esp - 16

    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fistp   dword [.int32]
        mov     eax, dword [.int32]             ; save result

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@__int32.sse
$else
  @@__int32.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value on stack
; x = ST0(xmm0)
; return int64 in eax:edx

macro @@__int64.sse
{
$asprocf @@__int64

       .mem     EQU esp - 20
       .int64   EQU esp - 20
       .int64LO EQU esp - 20
       .int64HI EQU esp - 16

    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        movsd   qword [.mem], xmm0              ; load xmm0 to st0
        fld     qword [.mem]
        ;
        fistp   qword [.int64]
        mov     eax, dword [.int64LO]           ; save result
        mov     edx, dword [.int64HI]

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@__int64.fpu
{
$asprocf @@__int64

       .int64   EQU esp - 20
       .int64LO EQU esp - 20
       .int64HI EQU esp - 16

    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fistp   qword [.int64]
        mov     eax, dword [.int64LO]           ; save result
        mov     edx, dword [.int64HI]

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@__int64.sse
$else
  @@__int64.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value on stack
; x = esp

macro @@_dv.esp_as_int32.sse
{
$usprocf @@_dv.esp_as_int32

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       add     esp, 8                          ; remove x from stack
;       add     esp, -4                         ; allocate memory for dword
        add     esp, 8-4
        cvttsd2si eax, xmm0                     ; eax = int32 value
        mov     [esp], eax                      ; [esp] = int32 value
    .return:
        retn
$endp
}

macro @@_dv.esp_as_int32.fpu
{
$usprocf @@_dv.esp_as_int32

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       add     esp, 8                          ; remove x from stack
;       add     esp, -4                         ; allocate memory for dword
        add     esp, 8-4
        mov     eax, @@__int32
        call    eax                             ; eax = int32 value
        mov     [esp], eax
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dv.esp_as_int32.sse
$else
  @@_dv.esp_as_int32.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value on stack
; x = esp

macro @@_dv.esp_as_int64.sse
{
$usprocf @@_dv.esp_as_int64

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       add     esp, 8                          ; remove x from stack
;       add     esp, -8                         ; allocate memory for qword
;       add     esp, 8-8
        ;
        movsd   qword [esp], xmm0               ; load xmm0 to st0
        fld     qword [esp]
        ;
        mov     eax, @@__int64
        call    eax                             ; eax:edx = int64 value
        mov     [esp + 0], eax
        mov     [esp + 4], edx
    .return:
        retn
$endp
}

macro @@_dv.esp_as_int64.fpu
{
$usprocf @@_dv.esp_as_int64

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       add     esp, 8                          ; remove x from stack
;       add     esp, -8                         ; allocate memory for qword
;       add     esp, 8-8
        mov     eax, @@__int64
        call    eax                             ; eax:edx = int64 value
        mov     [esp + 0], eax
        mov     [esp + 4], edx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dv.esp_as_int64.sse
$else
  @@_dv.esp_as_int64.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value by reference
; ecx = offset of x

macro @@_do.ecx_as_int32.sse
{
$usprocf @@_do.ecx_as_int32

        movsd   xmm0, qword [ecx]
   .enter:
        add     esp, -4                         ; allocate memory for dword
        cvttsd2si eax, xmm0                     ; eax = int32 value
        mov     [esp], eax                      ; [esp] = int32 value
   .return:
        retn
$endp
}

macro @@_do.ecx_as_int32.fpu
{
$usprocf @@_do.ecx_as_int32

        fld     qword [ecx]
   .enter:
        add     esp, -4                         ; allocate memory for dword
        mov     eax, @@__int32
        call    eax                             ; eax = int32 value
        mov     [esp], eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_do.ecx_as_int32.sse
$else
  @@_do.ecx_as_int32.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value by reference
; ecx = offset of x

macro @@_do.ecx_as_int64.sse
{
$usprocf @@_do.ecx_as_int64

        movsd   xmm0, qword [ecx]
   .enter:
        add     esp, -8                         ; allocate memory for qword
        ;
        movsd   qword [esp], xmm0               ; load xmm0 to st0
        fld     qword [esp]
        ;
        mov     eax, @@__int64
        call    eax                             ; eax:edx = int64 value
        mov     [esp + 0], eax
        mov     [esp + 4], edx
   .return:
        retn
$endp
}

macro @@_do.ecx_as_int64.fpu
{
$usprocf @@_do.ecx_as_int64

        fld     qword [ecx]
   .enter:
        add     esp, -8                         ; allocate memory for qword
        mov     eax, @@__int64
        call    eax                             ; eax:edx = int64 value
        mov     [esp + 0], eax
        mov     [esp + 4], edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_do.ecx_as_int64.sse
$else
  @@_do.ecx_as_int64.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; load native integer x
; eax = offset of x

macro @@_io.eax_as_double.sse
{
$usprocf @@_io.eax_as_double

        cvtsi2sd xmm0, dword [eax]
        add     esp, -8
    .return:
        retn
$endp
}

macro @@_io.eax_as_double.fpu
{
$usprocf @@_io.eax_as_double

        fild    dword [eax]
        add     esp, -8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_io.eax_as_double.sse
$else
  @@_io.eax_as_double.fpu
$end

; ------------------------------------------------------------------------------

; load native integer x
; ecx = offset of x

macro @@_io.ecx_as_double.sse
{
$usprocf @@_io.ecx_as_double

        fild    dword [ecx]
        add     esp, -8
    .return:
        retn
$endp
}

macro @@_io.ecx_as_double.fpu
{
$usprocf @@_io.ecx_as_double

        fild    dword [ecx]
        add     esp, -8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_io.ecx_as_double.sse
$else
  @@_io.ecx_as_double.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy integer src to double dst
; ecx = dst offset
; esp = src value

macro @@_copy_do.ecx_iv.esp.sse
{
$usprocf @@_copy_do.ecx_iv.esp

        cvtsi2sd xmm0, dword [esp]
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_do.ecx_iv.esp.fpu
{
$usprocf @@_copy_do.ecx_iv.esp

        fild    dword [esp]
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_do.ecx_iv.esp.sse
$else
  @@_copy_do.ecx_iv.esp.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to double dst
; ecx = dst offset
; eax = src offset

macro @@_copy_do.ecx_io.eax.sse
{
$usprocf @@_copy_do.ecx_io.eax

        cvtsi2sd xmm0, dword [eax]
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_do.ecx_io.eax.fpu
{
$usprocf @@_copy_do.ecx_io.eax

        fild    dword [eax]
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_do.ecx_io.eax.sse
$else
  @@_copy_do.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; edx  = dst offset offset
; xmm0 = src value
; ST0  = src value

macro @@_copy_doo.edx_dv.xmm0.sse
{
$usprocf @@_copy_doo.edx_dv.xmm0

        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        movsd   qword [edx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_doo.edx_dv.st0.fpu
{
$usprocf @@_copy_doo.edx_dv.st0

        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        fst     qword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.edx_dv.xmm0.sse
$else
  @@_copy_doo.edx_dv.st0.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; edx = dst offset offset
; esp = src value

macro @@_copy_doo.edx_dv.esp.sse
{
$usprocf @@_copy_doo.edx_dv.esp

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        movsd   qword [edx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_doo.edx_dv.esp.fpu
{
$usprocf @@_copy_doo.edx_dv.esp

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        fst     qword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.edx_dv.esp.sse
$else
  @@_copy_doo.edx_dv.esp.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; edx = dst offset offset
; eax = src offset

macro @@_copy_doo.edx_do.eax.sse
{
$usprocf @@_copy_doo.edx_do.eax

        movsd   xmm0, qword [eax]
        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        movsd   qword [edx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_doo.edx_do.eax.fpu
{
$usprocf @@_copy_doo.edx_do.eax

        fld     qword [eax]
        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        fst     qword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.edx_do.eax.sse
$else
  @@_copy_doo.edx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; edx = dst offset offset
; ecx = src offset

macro @@_copy_doo.edx_do.ecx.sse
{
$usprocf @@_copy_doo.edx_do.ecx

        movsd   xmm0, qword [ecx]
        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        movsd   qword [edx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_doo.edx_do.ecx.fpu
{
$usprocf @@_copy_doo.edx_do.ecx

        fld     qword [ecx]
        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        fst     qword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.edx_do.ecx.sse
$else
  @@_copy_doo.edx_do.ecx.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy double src to integer dst
; ecx  = dst offset
; xmm0 = src value
; ST0  = src value

macro @@_copy_io.ecx_dv.xmm0.sse
{
$usprocf @@_copy_io.ecx_dv.xmm0

        cvttsd2si eax, xmm0                     ; eax = truncated xmm0
        mov       [ecx], eax
        cvtsi2sd  xmm0, eax
    .return:
        retn
$endp
}

macro @@_copy_io.ecx_dv.st0.fpu
{
$usprocf @@_copy_io.ecx_dv.st0

        mov     eax, @@__int32
        call    eax
    .copy:
        mov     [ecx], eax
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.ecx_dv.xmm0.sse
$else
  @@_copy_io.ecx_dv.st0.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to integer dst
; ecx = dst offset
; eax = src offset

macro @@_copy_io.ecx_do.eax.sse
{
$usprocf @@_copy_io.ecx_do.eax

        movsd   xmm0, qword [eax]
    .enter:
        cvttsd2si eax, xmm0
    .copy:
        mov     [ecx], eax
        cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_copy_io.ecx_do.eax.fpu
{
$usprocf @@_copy_io.ecx_do.eax

        fld     qword [eax]
    .enter:
        mov     eax, @@__int32
        call    eax
    .copy:
        mov     [ecx], eax
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.ecx_do.eax.sse
$else
  @@_copy_io.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; ecx = dst offset
; eax = src value

macro @@_copy_io.ecx_iv.eax.sse
{
$usprocf @@_copy_io.ecx_iv.eax

    .copy:
        mov     [ecx], eax
        cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_copy_io.ecx_iv.eax.fpu
{
$usprocf @@_copy_io.ecx_iv.eax

    .copy:
        mov     [ecx], eax
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.ecx_iv.eax.sse
$else
  @@_copy_io.ecx_iv.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; ecx = dst offset
; eax = src value

macro @@_copy_io.ecx_iv.eax_esp.sse
{
$usprocf @@_copy_io.ecx_iv.eax_esp

    .copy:
        mov     [ecx], eax
        cvtsi2sd xmm0, eax
    .return:
        add     esp, 4
        retn
$endp
}

macro @@_copy_io.ecx_iv.eax_esp.fpu
{
$usprocf @@_copy_io.ecx_iv.eax_esp

    .copy:
        mov     [ecx], eax
        fild    dword [ecx]
    .return:
        add     esp, 4
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.ecx_iv.eax_esp.sse
$else
  @@_copy_io.ecx_iv.eax_esp.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; edx = dst offset offset
; eax = src value

macro @@_copy_ioo.edx_iv.eax.sse
{
$usprocf @@_copy_ioo.edx_iv.eax

        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        mov     [edx], eax
    .return:
        cvtsi2sd xmm0, eax
        retn
$endp
}

macro @@_copy_ioo.edx_iv.eax.fpu
{
$usprocf @@_copy_ioo.edx_iv.eax

        mov     edx, [edx]
        test    edx, edx
        jnz    .copy
        mov     [esp - 4], eax
        fild    dword [esp - 4]
        jmp    .return
    .copy:
        mov     [edx], eax
        fild    dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_ioo.edx_iv.eax.sse
$else
  @@_copy_ioo.edx_iv.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; edx = dst offset offset
; eax = src value
; esp = src value

macro @@_copy_ioo.edx_iv.eax.esp.sse
{
$usprocf @@_copy_ioo.edx_iv.eax.esp

        mov     edx, [edx]
        test    edx, edx
        jnz    .copy
        cvtsi2sd xmm0, dword [esp]
        jmp    .return
    .copy:
        mov     [edx], eax
        cvtsi2sd xmm0, eax
    .return:
        add     esp, 4
        retn
$endp
}

macro @@_copy_ioo.edx_iv.eax.esp.fpu
{
$usprocf @@_copy_ioo.edx_iv.eax.esp

        mov     edx, [edx]
        test    edx, edx
        jnz    .copy
        fild    dword [esp]
        jmp    .return
    .copy:
        mov     [edx], eax
        fild    dword [edx]
    .return:
        add     esp, 4
        retn
$endp
}

$ifdef _SSEX
  @@_copy_ioo.edx_iv.eax.esp.sse
$else
  @@_copy_ioo.edx_iv.eax.esp.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; ecx = dst offset
; eax = src offset

macro @@_copy_io.ecx_io.eax.sse
{
$usprocf @@_copy_io.ecx_io.eax

        mov     eax, [eax]
    .copy:
        mov     [ecx], eax
        cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_copy_io.ecx_io.eax.fpu
{
$usprocf @@_copy_io.ecx_io.eax

        mov     eax, [eax]
    .copy:
        mov     [ecx], eax
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.ecx_io.eax.sse
$else
  @@_copy_io.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; edx = dst offset offset
; eax = src offset

macro @@_copy_ioo.edx_io.eax.sse
{
$usprocf @@_copy_ioo.edx_io.eax

        mov     edx, [edx]
        mov     eax, [eax]
        test    edx, edx
        jz     .load
    .copy:
        mov     [edx], eax
    .load:
        cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_copy_ioo.edx_io.eax.fpu
{
$usprocf @@_copy_ioo.edx_io.eax

        mov     edx, [edx]
        mov     eax, [eax]
        test    edx, edx
        jnz    .copy
        mov     [esp - 4], eax
        fild    dword [esp - 4]
        jmp    .return
    .copy:
        mov     [edx], eax
        fild    dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_ioo.edx_io.eax.sse
$else
  @@_copy_ioo.edx_io.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy string src to string dst
; edx = dst offset
; eax = src value

$usprocf @@_copy_so.edx_sv.eax

    .copy:
        mov     [edx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy string src to string dst
; edx = dst offset offset
; eax = src value

$usprocf @@_copy_soo.edx_sv.eax

        mov     edx, [edx]
        test    edx, edx
        jz     .return
    .copy:
        mov     [edx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy string src to string dst
; edx = dst offset offset
; eax = src offset

$usprocf @@_copy_soo.edx_so.eax

        mov     edx, [edx]
        mov     eax, [eax]
        test    edx, edx
        jz     .return
    .copy:
        mov     [edx], eax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy int double src to double dst
; double dst offset = ecx
; double src offset = eax

macro @@_copy.int_do.ecx_do.eax.sse
{
$usprocf @@_copy.int_do.ecx_do.eax

        movsd   xmm0, qword [eax]               ; xmm0 = src
        xintsd  xmm0, xmm0                      ; xmm0 = int(src)
        movsd   qword [ecx], xmm0               ; int(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.int_do.ecx_do.eax.fpu
{
$usprocf @@_copy.int_do.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        @@.int.st0                              ; st0 = int(src)
        fst     qword [ecx]                     ; int(src)->dst ; st0 = int(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.int_do.ecx_do.eax.sse
$else
  @@_copy.int_do.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy int double src to double dst
; double dst offset = ecx
; double src        = st0|xmm0

macro @@_copy.int_do.ecx_dv.cpu.sse
{
$usprocf @@_copy.int_do.ecx_dv.cpu

        xintsd  xmm0, xmm0                      ; xmm0 = int(src)
        movsd   qword [ecx], xmm0               ; int(src)->dst
        add     esp, 8
    .return:
        retn
$endp
}

macro @@_copy.int_do.ecx_dv.cpu.fpu
{
$usprocf @@_copy.int_do.ecx_dv.cpu

        @@.int.st0                              ; st0 = int(src)
        fst     qword [ecx]                     ; int(src)->dst ; st0 = int(src)
        add     esp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.int_do.ecx_dv.cpu.sse
$else
  @@_copy.int_do.ecx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------

; copy frac double src to double dst
; double dst offset = ecx
; double src offset = eax

macro @@_copy.frac_do.ecx_do.eax.sse
{
$usprocf @@_copy.frac_do.ecx_do.eax

        movsd   xmm0, qword [eax]               ; xmm0 = src
        xfracsd xmm0, xmm0                      ; xmm0 = frac(src)
        movsd   qword [ecx], xmm0               ; frac(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.frac_do.ecx_do.eax.fpu
{
$usprocf @@_copy.frac_do.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        @@.frac.st0                             ; st0 = frac(src)
        fst     qword [ecx]                     ; frac(src)->dst ; st0 = frac(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.frac_do.ecx_do.eax.sse
$else
  @@_copy.frac_do.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy frac double src to double dst
; double dst offset = ecx
; double src        = st0|xmm0

macro @@_copy.frac_do.ecx_dv.cpu.sse
{
$usprocf @@_copy.frac_do.ecx_dv.cpu

        xfracsd xmm0, xmm0                      ; xmm0 = frac(src)
        movsd   qword [ecx], xmm0               ; frac(src)->dst
        add     esp, 8
    .return:
        retn
$endp
}

macro @@_copy.frac_do.ecx_dv.cpu.fpu
{
$usprocf @@_copy.frac_do.ecx_dv.cpu

        @@.frac.st0                             ; st0 = frac(src)
        fst     qword [ecx]                     ; frac(src)->dst ; st0 = frac(src)
        add     esp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.frac_do.ecx_dv.cpu.sse
$else
  @@_copy.frac_do.ecx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to double dst
; double dst offset = ecx
; double src offset = eax

macro @@_copy.round_do.ecx_do.eax.sse
{
$usprocf @@_copy.round_do.ecx_do.eax

        movsd   xmm0, qword [eax]               ; xmm0 = src
        xrndsd  xmm0, xmm0                      ; xmm0 = round(src)
        movsd   qword [ecx], xmm0               ; round(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.round_do.ecx_do.eax.fpu
{
$usprocf @@_copy.round_do.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        @@.round.st0                            ; st0 = round(src)
        fst     qword [ecx]                     ; round(src)->dst ; st0 = round(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_do.ecx_do.eax.sse
$else
  @@_copy.round_do.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to double dst
; double dst offset = ecx
; double src        = st0|xmm0

macro @@_copy.round_do.ecx_dv.cpu.sse
{
$usprocf @@_copy.round_do.ecx_dv.cpu

        xrndsd  xmm0, xmm0                      ; xmm0 = round(src)
        movsd   qword [ecx], xmm0               ; round(src)->dst
        add     esp, 8
    .return:
        retn
$endp
}

macro @@_copy.round_do.ecx_dv.cpu.fpu
{
$usprocf @@_copy.round_do.ecx_dv.cpu

        @@.round.st0                            ; st0 = round(src)
        fst     qword [ecx]                     ; round(src)->dst ; st0 = round(src)
        add     esp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_do.ecx_dv.cpu.sse
$else
  @@_copy.round_do.ecx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to integer dst
; integer dst offset = ecx
; double src offset  = eax

macro @@_copy.round_io.ecx_do.eax.sse
{
$usprocf @@_copy.round_io.ecx_do.eax

        movsd     xmm0, qword [eax]             ; xmm0 = src
        xrndsd    xmm0, xmm0                    ; xmm0 = round(src)
        cvttsd2si edx, xmm0                     ; edx = round(src)
        mov       dword [ecx], edx              ; round(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.round_io.ecx_do.eax.fpu
{
$usprocf @@_copy.round_io.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        @@.round.st0                            ; st0 = round(src)
        fist    dword [ecx]                     ; round(src)->dst ; st0 = round(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_io.ecx_do.eax.sse
$else
  @@_copy.round_io.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to integer dst
; integer dst offset = ecx
; double src         = st0|xmm0

macro @@_copy.round_io.ecx_dv.cpu.sse
{
$usprocf @@_copy.round_io.ecx_dv.cpu

        xrndsd    xmm0, xmm0                    ; xmm0 = round(src)
        cvttsd2si edx, xmm0                     ; edx = round(src)
        mov       dword [ecx], edx              ; round(src)->dst
        add       esp, 8
    .return:
        retn
$endp
}

macro @@_copy.round_io.ecx_dv.cpu.fpu
{
$usprocf @@_copy.round_io.ecx_dv.cpu

        @@.round.st0                            ; st0 = round(src)
        fist    dword [ecx]                     ; round(src)->dst ; st0 = round(src)
        add     esp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_io.ecx_dv.cpu.sse
$else
  @@_copy.round_io.ecx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap double src and double dst
; double dst offset = ecx
; double src offset = eax

macro @@_swap_do.ecx_do.eax.sse
{
$usprocf @@_swap_do.ecx_do.eax

        movsd   xmm0, qword [eax]               ; xmm0 = src
        movsd   xmm1, qword [ecx]               ; xmm1 = dst
        movsd   qword [eax], xmm1               ; dst->src
        movsd   qword [ecx], xmm0               ; src->dst
    .return:
        retn
$endp
}

macro @@_swap_do.ecx_do.eax.fpu
{
$usprocf @@_swap_do.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        fld     qword [ecx]                     ; st0 = dst, st1 = src
        fstp    qword [eax]                     ; dst->src ; st0 = src
        fst     qword [ecx]                     ; src->dst ; st0 = src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_do.ecx_do.eax.sse
$else
  @@_swap_do.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; swap integer src and double dst
; double dst offset  = ecx
; integer src offset = eax

macro @@_swap_do.ecx_io.eax.sse
{
$usprocf @@_swap_do.ecx_io.eax

        cvtsi2sd  xmm0, dword [eax]             ; xmm0 = src
        movsd     xmm1, qword [ecx]             ; xmm1 = dst
        cvttsd2si edx, xmm1
        mov       dword [eax], edx              ; dst->src
        movsd     qword [ecx], xmm0             ; src->dst
    .return:
        retn
$endp
}

macro @@_swap_do.ecx_io.eax.fpu
{
$usprocf @@_swap_do.ecx_io.eax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    dword [eax]                     ; st0 = src
        fld     qword [ecx]                     ; st0 = dst, st1 = src
        fistp   dword [eax]                     ; dst->src ; st0 = src
        fst     qword [ecx]                     ; src->dst ; st0 = src

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_do.ecx_io.eax.sse
$else
  @@_swap_do.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; swap double src and integer dst
; integer dst offset = ecx
; double src offset  = eax

macro @@_swap_io.ecx_do.eax.sse
{
$usprocf @@_swap_io.ecx_do.eax

        movsd     xmm0, qword [eax]             ; xmm0 = src
        cvtsi2sd  xmm1, dword [ecx]             ; xmm1 = dst
        movsd     qword [eax], xmm1             ; dst->src
        cvttsd2si edx, xmm0
        mov       dword [ecx], edx              ; src->dst
    .return:
        retn
$endp
}

macro @@_swap_io.ecx_do.eax.fpu
{
$usprocf @@_swap_io.ecx_do.eax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    dword [ecx]                     ; st0 = dst
        fld     qword [eax]                     ; st0 = src, st1 = dst
        fistp   dword [ecx]                     ; src->dst ; st0 = dst
        fstp    qword [eax]                     ; dst->src
        fild    dword [ecx]                     ; st0 = src

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_io.ecx_do.eax.sse
$else
  @@_swap_io.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; swap integer src and integer dst
; integer dst offset = ecx
; integer src offset = eax

macro @@_swap_io.ecx_io.eax.sse
{
$usprocf @@_swap_io.ecx_io.eax

        mov     edx, [eax]                      ; edx = src
        mov     ebx, [ecx]
        mov     [eax], ebx
        mov     [ecx], edx
        cvtsi2sd xmm0, edx                      ; xmm0 = src
    .return:
        retn
$endp
}

macro @@_swap_io.ecx_io.eax.fpu
{
$usprocf @@_swap_io.ecx_io.eax

        mov     edx, [eax]                      ; edx = src
        mov     ebx, [ecx]
        mov     [eax], ebx
        mov     [ecx], edx
        fild    dword [ecx]                     ; st0 = src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_io.ecx_io.eax.sse
$else
  @@_swap_io.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap int double src and int double dst
; double dst offset = ecx
; double src offset = eax

macro @@_swap.int_do.ecx_do.eax.sse
{
$usprocf @@_swap.int_do.ecx_do.eax

        movsd   xmm0, qword [eax]               ; xmm0 = src
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        mov     edx, @@__int2p
        call    edx                             ; xmm0 = (src), xmm1 = (dst)

        movsd   qword [eax], xmm1               ; (dst)->src
        movsd   qword [ecx], xmm0               ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.int_do.ecx_do.eax.fpu
{
$usprocf @@_swap.int_do.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        fld     qword [ecx]                     ; st0 = dst, st1 = src

        mov     edx, @@__int2p
        call    edx                             ; st0 = (src), st1 = (dst)

        fstp    qword [ecx]                     ; (src)->dst ; st0 = (dst)
        fst     qword [eax]                     ; (dst)->src ; st0 = (dst)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.int_do.ecx_do.eax.sse
$else
  @@_swap.int_do.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap frac double src and frac double dst
; double dst offset = ecx
; double src offset = eax

macro @@_swap.frac_do.ecx_do.eax.sse
{
$usprocf @@_swap.frac_do.ecx_do.eax

        movsd   xmm0, qword [eax]               ; xmm0 = src
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        mov     edx, @@__frac2p
        call    edx                             ; xmm0 = (src), xmm1 = (dst)

        movsd   qword [eax], xmm1               ; (dst)->src
        movsd   qword [ecx], xmm0               ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.frac_do.ecx_do.eax.fpu
{
$usprocf @@_swap.frac_do.ecx_do.eax

        fld     qword [eax]                     ; st0 = src
        fld     qword [ecx]                     ; st0 = dst, st1 = src

        mov     edx, @@__frac2p
        call    edx                             ; st0 = (src), st1 = (dst)

        fstp    qword [ecx]                     ; (src)->dst ; st0 = (dst)
        fst     qword [eax]                     ; (dst)->src ; st0 = (dst)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.frac_do.ecx_do.eax.sse
$else
  @@_swap.frac_do.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap round double src and round double dst
; double dst offset = ecx
; double src offset = edx

macro @@_swap.round_do.ecx_do.edx.sse
{
$usprocf @@_swap.round_do.ecx_do.edx

        movsd   xmm0, qword [edx]               ; xmm0 = src
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        mov     eax, @@__round2p
        call    eax                             ; xmm0 = (src), xmm1 = (dst)

        movsd   qword [edx], xmm1               ; (dst)->src
        movsd   qword [ecx], xmm0               ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.round_do.ecx_do.edx.fpu
{
$usprocf @@_swap.round_do.ecx_do.edx

        fld     qword [edx]                     ; st0 = src
        fld     qword [ecx]                     ; st0 = dst, st1 = src

        mov     eax, @@__round2p
        call    eax                             ; st0 = (src), st1 = (dst)

        fstp    qword [ecx]                     ; (src)->dst ; st0 = (dst)
        fst     qword [edx]                     ; (dst)->src ; st0 = (dst)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.round_do.ecx_do.edx.sse
$else
  @@_swap.round_do.ecx_do.edx.fpu
$end

; ------------------------------------------------------------------------------

; swap round integer src and round double dst
; double dst offset  = ecx
; integer src offset = eax

macro @@_swap.round_do.ecx_io.eax.sse
{
$usprocf @@_swap.round_do.ecx_io.eax

        movsd     xmm0, qword [ecx]             ; xmm0 = dst

        mov       edx, @@round.enter
        call      edx                           ; xmm0 = (dst)

        cvttsd2si edx, xmm0                     ; edx = (dst)
        cvtsi2sd  xmm0, dword [eax]             ; xmm0 = (src)
        mov       dword [eax], edx              ; (dst)->src
        movsd     qword [ecx], xmm0             ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.round_do.ecx_io.eax.fpu
{
$usprocf @@_swap.round_do.ecx_io.eax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    dword [eax]                     ; st0 = (src)
        fld     qword [ecx]                     ; st0 = dst, st1 = (src)

        mov     edx, @@round.enter
        call    edx                             ; st0 = (dst), st1 = (src)

        fistp   dword [eax]                     ; (dst)->src ; st0 = (src)
        fst     qword [ecx]                     ; (src)->dst ; st0 = (src)

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.round_do.ecx_io.eax.sse
$else
  @@_swap.round_do.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; swap round double src and round integer dst
; integer dst offset = ecx
; double src offset  = eax

macro @@_swap.round_io.ecx_do.eax.sse
{
$usprocf @@_swap.round_io.ecx_do.eax

        movsd     xmm0, qword [eax]             ; xmm0 = src

        mov       edx, @@round.enter
        call      edx                           ; xmm0 = (src)

        cvtsi2sd  xmm1, dword [ecx]             ; xmm1 = (dst)
        movsd     qword [eax], xmm1             ; (dst)->src
        cvttsd2si edx, xmm0                     ; edx = (src)
        mov       dword [ecx], edx              ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.round_io.ecx_do.eax.fpu
{
$usprocf @@_swap.round_io.ecx_do.eax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    dword [ecx]                     ; st0 = (dst)
        fld     qword [eax]                     ; st0 = src, st1 = (dst)

        mov     edx, @@round.enter
        call    edx                             ; st0 = (src), st1 = (dst)

        fistp   dword [ecx]                     ; (src)->dst ; st0 = (dst)
        fstp    qword [eax]                     ; (dst)->src
        fild    dword [ecx]                     ; st0 = (src)

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.round_io.ecx_do.eax.sse
$else
  @@_swap.round_io.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; assign zero
; double offset = ecx

macro @@_assign.zero_do.ecx.sse
{
$usprocf @@_assign.zero_do.ecx

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        movsd   qword [ecx], xmm0               ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zero_do.ecx.fpu
{
$usprocf @@_assign.zero_do.ecx

        fldz                                    ; st0 = 0
        fst     qword [ecx]                     ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zero_do.ecx.sse
$else
  @@_assign.zero_do.ecx.fpu
$end

; ------------------------------------------------------------------------------

; assign zero
; integer offset = ecx

macro @@_assign.zero_io.ecx.sse
{
$usprocf @@_assign.zero_io.ecx

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     edx, edx
        mov     dword [ecx], edx                ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zero_io.ecx.fpu
{
$usprocf @@_assign.zero_io.ecx

        fldz                                    ; st0 = 0
        xor     edx, edx
        mov     dword [ecx], edx                ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zero_io.ecx.sse
$else
  @@_assign.zero_io.ecx.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; assign zeroes
; double offset  = ecx
; integer offset = eax

macro @@_assign.zeroes_do.ecx_io.eax.sse
{
$usprocf @@_assign.zeroes_do.ecx_io.eax

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     edx, edx
        mov     dword [eax], edx                ; 0->
        movsd   qword [ecx], xmm0               ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zeroes_do.ecx_io.eax.fpu
{
$usprocf @@_assign.zeroes_do.ecx_io.eax

        fldz                                    ; st0 = 0
        xor     edx, edx
        mov     dword [eax], edx                ; 0->
        fst     qword [ecx]                     ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zeroes_do.ecx_io.eax.sse
$else
  @@_assign.zeroes_do.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; assign zeroes
; integer offset = ecx
; double offset  = eax

macro @@_assign.zeroes_io.ecx_do.eax.sse
{
$usprocf @@_assign.zeroes_io.ecx_do.eax

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     edx, edx
        movsd   qword [eax], xmm0               ; 0->
        mov     dword [ecx], edx                ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zeroes_io.ecx_do.eax.fpu
{
$usprocf @@_assign.zeroes_io.ecx_do.eax

        fldz                                    ; st0 = 0
        xor     edx, edx
        fst     qword [eax]                     ; 0->
        mov     dword [ecx], edx                ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zeroes_io.ecx_do.eax.sse
$else
  @@_assign.zeroes_io.ecx_do.eax.fpu
$end

; ------------------------------------------------------------------------------

; assign zeroes
; integer offset = ecx
; integer offset = eax

macro @@_assign.zeroes_io.ecx_io.eax.sse
{
$usprocf @@_assign.zeroes_io.ecx_io.eax

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     edx, edx
        mov     dword [eax], edx                ; 0->
        mov     dword [ecx], edx                ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zeroes_io.ecx_io.eax.fpu
{
$usprocf @@_assign.zeroes_io.ecx_io.eax

        fldz                                    ; st0 = 0
        xor     edx, edx
        mov     dword [eax], edx                ; 0->
        mov     dword [ecx], edx                ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zeroes_io.ecx_io.eax.sse
$else
  @@_assign.zeroes_io.ecx_io.eax.fpu
$end

; ------------------------------------------------------------------------------
