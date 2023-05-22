
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (call functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; begin procedure
$usprocf @@proc.begin

        push    ebp
        mov     ebp, esp
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; end procedure
$usprocf @@proc.end

        leave
        retn
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; get procedure float argument
; return result in ST0(xmm0)
; ecx = float argument number (one-based)

macro @@arg.getf.sse
{
$usprocf @@arg.getf

        lea     ecx, [ebp + 8*ecx + 0]
        movsd   xmm0, qword [ecx]
    .return:
        retn
$endp
}

macro @@arg.getf.fpu
{
$usprocf @@arg.getf

        lea     ecx, [ebp + 8*ecx + 0]
        fld     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arg.getf.sse
$else
  @@arg.getf.fpu
$end

; ------------------------------------------------------------------------------

; get procedure integer argument
; return result in eax
; ecx = integer argument number (one-based)

$usprocf @@arg.geti

        lea     ecx, [ebp + 4*ecx + 4]
        mov     eax, [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; allocate memory for local variables
; ecx = local variable count

$usprocf @@locals.alloc

        shl     ecx, 3                          ; ecx = 8 * (local variable count)
        sub     esp, ecx
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; get float local variable
; return result in ST0(xmm0)
; ecx = local variable number (one-based)

macro @@local.getf.sse
{
$usprocf @@local.getf

        neg     ecx
        lea     ecx, [ebp + 8*ecx]
        movsd   xmm0, qword [ecx]
    .return:
        retn
$endp
}

macro @@local.getf.fpu
{
$usprocf @@local.getf

        neg     ecx
        lea     ecx, [ebp + 8*ecx]
        fld     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@local.getf.sse
$else
  @@local.getf.fpu
$end

; ------------------------------------------------------------------------------

; get integer local variable
; return result in eax
; ecx = local variable number (one-based)

$usprocf @@local.geti

        neg     ecx
        lea     ecx, [ebp + 8*ecx]
        mov     eax, [ecx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; set float local variable
; return result in ST0(xmm0)
; ecx = local variable number (one-based)
; esp = value

macro @@local.setf.sse
{
$usprocf @@local.setf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        neg     ecx
        lea     ecx, [ebp + 8*ecx]
        movsd   qword [ecx], xmm0
        add     esp, 8
    .return:
        retn
$endp
}

macro @@local.setf.fpu
{
$usprocf @@local.setf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        neg     ecx
        lea     ecx, [ebp + 8*ecx]
        fst     qword [ecx]
        add     esp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@local.setf.sse
$else
  @@local.setf.fpu
$end

; ------------------------------------------------------------------------------

; set integer local variable
; return result in eax
; ecx = local variable number (one-based)
; esp = value

$usprocf @@local.seti

        neg     ecx
        lea     ecx, [ebp + 8*ecx]
        mov     eax, [esp]
        mov     [ecx], eax
        add     esp, 4
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; retn
; return from procedure

$usprocf @@retn

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; call (proc)
; procedure call
; edx = offset of proc address

$usprocf @@call

        call    dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; calls (proc_1, proc_2, ..., proc_n)
; procedure call

$usprocf @@calls

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; rcalls (proc_1, proc_2, ..., proc_n)
; reverse procedure call

$usprocf @@rcalls

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; call.if.x32 (proc)
; conditional call
;
; call proc if DLL is x32
;
; edx = offset of proc address

$usprocf @@call.if.x32

        call    dword [edx]
    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.x32 (if.proc, else.proc)
; conditional call
;
; call if.proc if DLL is x32,
; call else.proc otherwise
;
; ecx = offset of else.proc address
; edx = offset of if.proc address

$usprocf @@call.ie.x32

        call    dword [edx]                     ; call if.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.n32 (proc)
; conditional call
;
; call proc if DLL is not x32
;
; edx = offset of proc address

$usprocf @@call.if.n32

;       call    dword [edx]
    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.n32 (if.proc, else.proc)
; conditional call
;
; call if.proc if DLL is not x32,
; call else.proc otherwise
;
; ecx = offset of else.proc address
; edx = offset of if.proc address

$usprocf @@call.ie.n32

        call    dword [ecx]                     ; call else.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.x64 (proc)
; conditional call
;
; call proc if DLL is x64
;
; edx = offset of proc address

$usprocf @@call.if.x64

;       call    dword [edx]
    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.x64 (if.proc, else.proc)
; conditional call
;
; call if.proc if DLL is x64,
; call else.proc otherwise
;
; ecx = offset of else.proc address
; edx = offset of if.proc address

$usprocf @@call.ie.x64

        call    dword [ecx]                     ; call else.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.n64 (proc)
; conditional call
;
; call proc if DLL is not x64
;
; edx = offset of proc address

$usprocf @@call.if.n64

        call    dword [edx]
    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.n64 (if.proc, else.proc)
; conditional call
;
; call if.proc if DLL is not x64,
; call else.proc otherwise
;
; ecx = offset of else.proc address
; edx = offset of if.proc address

$usprocf @@call.ie.n64

        call    dword [edx]                     ; call if.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; call.if.true (proc, x)
; conditional call
;
; call proc if x <> 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.true.sse
{
$usprocf @@call.if.true

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .no.call:                                   ; x = 0
        jmp    .return

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.true.fpu
{
$usprocf @@call.if.true

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.true.sse
$else
  @@call.if.true.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.true (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <> 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.true.sse
{
$usprocf @@call.ie.true

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .else.call:                                 ; x = 0
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.true.fpu
{
$usprocf @@call.ie.true

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .if.call                         ; call if x <> 0

    .else.call:                                 ; x = 0
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.true.sse
$else
  @@call.ie.true.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.true (proc, x)
; conditional call
;
; call proc if x <> 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.true

        cmp     dword [eax], 0                  ; compare x to 0
        jz     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.true (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <> 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.true

        cmp     dword [eax], 0                  ; compare x to 0
        jnz    .if.call                         ; call if x <> 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.true (proc, x)
; conditional call
;
; call proc if x <> 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.true

        test    eax, eax                        ; compare x to 0
        jz     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.true (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <> 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.true

        test    eax, eax                        ; compare x to 0
        jnz    .if.call                         ; call if x <> 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.false (proc, x)
; conditional call
;
; call proc if x = 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.false.sse
{
$usprocf @@call.if.false

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .return                          ; no call if x <> 0
        jp     .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.false.fpu
{
$usprocf @@call.if.false

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.false.sse
$else
  @@call.if.false.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.false (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x = 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.false.sse
{
$usprocf @@call.ie.false

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .else.call                       ; else call if x <> 0
        jp     .else.call                       ; else call if x <> 0
        jmp    .if.call

    .else.call:                                 ; x <> 0
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.false.fpu
{
$usprocf @@call.ie.false

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .if.call                         ; call if x = 0

    .else.call:                                 ; x <> 0
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.false.sse
$else
  @@call.ie.false.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.false (proc, x)
; conditional call
;
; call proc if x = 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.false

        cmp     dword [eax], 0                  ; compare x to 0
        jnz    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.false (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x = 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.false

        cmp     dword [eax], 0                  ; compare x to 0
        jz     .if.call                         ; call if x = 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.false (proc, x)
; conditional call
;
; call proc if x = 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.false

        test    eax, eax                        ; compare x to 0
        jnz    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.false (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x = 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.false

        test    eax, eax                        ; compare x to 0
        jz     .if.call                         ; call if x = 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; call.if.z (proc, x)
; conditional call
;
; call proc if x = 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.z.sse
{
$usprocf @@call.if.z

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .return                          ; no call if x <> 0
        jp     .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.z.fpu
{
$usprocf @@call.if.z

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.z.sse
$else
  @@call.if.z.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.z (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x = 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.z.sse
{
$usprocf @@call.ie.z

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .else.call                       ; else call if x <> 0
        jp     .else.call                       ; else call if x <> 0
        jmp    .if.call

    .else.call:                                 ; x <> 0
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.z.fpu
{
$usprocf @@call.ie.z

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .if.call                         ; call if x = 0

    .else.call:                                 ; x <> 0
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.z.sse
$else
  @@call.ie.z.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.z (proc, x)
; conditional call
;
; call proc if x = 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.z

        cmp     dword [eax], 0                  ; compare x to 0
        jne    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.z (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x = 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.z

        cmp     dword [eax], 0                  ; compare x to 0
        je     .if.call                         ; call if x = 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.z (proc, x)
; conditional call
;
; call proc if x = 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.z

        test    eax, eax                        ; compare x to 0
        jnz    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.z (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x = 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.z

        test    eax, eax                        ; compare x to 0
        jz     .if.call                         ; call if x = 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.nz (proc, x)
; conditional call
;
; call proc if x <> 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.nz.sse
{
$usprocf @@call.if.nz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .no.call:                                   ; x = 0
        jmp    .return

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.nz.fpu
{
$usprocf @@call.if.nz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.nz.sse
$else
  @@call.if.nz.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.nz (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <> 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.nz.sse
{
$usprocf @@call.ie.nz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.nz.fpu
{
$usprocf @@call.ie.nz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .if.call                         ; call if x <> 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.nz.sse
$else
  @@call.ie.nz.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.nz (proc, x)
; conditional call
;
; call proc if x <> 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.nz

        cmp     dword [eax], 0                  ; compare x to 0
        je     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.nz (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <> 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.nz

        cmp     dword [eax], 0                  ; compare x to 0
        jne    .if.call                         ; call if x <> 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.nz (proc, x)
; conditional call
;
; call proc if x <> 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.nz

        test    eax, eax                        ; compare x to 0
        jz     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.nz (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <> 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.nz

        test    eax, eax                        ; compare x to 0
        jnz    .if.call                         ; call if x <> 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.az (proc, x)
; conditional call
;
; call proc if x > 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.az.sse
{
$usprocf @@call.if.az

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.az.fpu
{
$usprocf @@call.if.az

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.az.sse
$else
  @@call.if.az.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.az (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x > 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.az.sse
{
$usprocf @@call.ie.az

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .if.call                         ; call if x > 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.az.fpu
{
$usprocf @@call.ie.az

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .if.call                         ; call if x > 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.az.sse
$else
  @@call.ie.az.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.az (proc, x)
; conditional call
;
; call proc if x > 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.az

        cmp     dword [eax], 0                  ; compare x to 0
        jle    .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.az (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x > 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.az

        cmp     dword [eax], 0                  ; compare x to 0
        jg     .if.call                         ; call if x > 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.az (proc, x)
; conditional call
;
; call proc if x > 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.az

        cmp     eax, 0                          ; compare x to 0
        jle    .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.az (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x > 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.az

        cmp     eax, 0                          ; compare x to 0
        jg     .if.call                         ; call if x > 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.aez (proc, x)
; conditional call
;
; call proc if x >= 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.aez.sse
{
$usprocf @@call.if.aez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.aez.fpu
{
$usprocf @@call.if.aez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.aez.sse
$else
  @@call.if.aez.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.aez (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x >= 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.aez.sse
{
$usprocf @@call.ie.aez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .if.call                         ; call if x >= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.aez.fpu
{
$usprocf @@call.ie.aez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .if.call                         ; call if x >= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.aez.sse
$else
  @@call.ie.aez.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.aez (proc, x)
; conditional call
;
; call proc if x >= 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.aez

        cmp     dword [eax], 0                  ; compare x to 0
        jl     .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.aez (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x >= 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.aez

        cmp     dword [eax], 0                  ; compare x to 0
        jge    .if.call                         ; call if x >= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.aez (proc, x)
; conditional call
;
; call proc if x >= 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.aez

        cmp     eax, 0                          ; compare x to 0
        jl     .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.aez (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x >= 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.aez

        cmp     eax, 0                          ; compare x to 0
        jge    .if.call                         ; call if x >= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.bz (proc, x)
; conditional call
;
; call proc if x < 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.bz.sse
{
$usprocf @@call.if.bz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.bz.fpu
{
$usprocf @@call.if.bz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.bz.sse
$else
  @@call.if.bz.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.bz (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x < 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.bz.sse
{
$usprocf @@call.ie.bz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .if.call                         ; call if x < 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.bz.fpu
{
$usprocf @@call.ie.bz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .if.call                         ; call if x < 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.bz.sse
$else
  @@call.ie.bz.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.bz (proc, x)
; conditional call
;
; call proc if x < 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.bz

        cmp     dword [eax], 0                  ; compare x to 0
        jge    .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.bz (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x < 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.bz

        cmp     dword [eax], 0                  ; compare x to 0
        jl     .if.call                         ; call if x < 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.bz (proc, x)
; conditional call
;
; call proc if x < 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.bz

        cmp     eax, 0                          ; compare x to 0
        jge    .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.bz (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x < 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.bz

        cmp     eax, 0                          ; compare x to 0
        jl     .if.call                         ; call if x < 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.bez (proc, x)
; conditional call
;
; call proc if x <= 0
;
; edx = offset of proc address
; esp = x

macro @@call.if.bez.sse
{
$usprocf @@call.if.bez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.bez.fpu
{
$usprocf @@call.if.bez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.bez.sse
$else
  @@call.if.bez.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.bez (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <= 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; esp = x

macro @@call.ie.bez.sse
{
$usprocf @@call.ie.bez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .if.call                         ; call if x <= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.ie.bez.fpu
{
$usprocf @@call.ie.bez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .if.call                         ; call if x <= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.bez.sse
$else
  @@call.ie.bez.fpu
$end

; ------------------------------------------------------------------------------

; call.int.if.bez (proc, x)
; conditional call
;
; call proc if x <= 0
;
; edx = offset of proc address
; eax = offset of x

$usprocf @@call.int.if.bez

        cmp     dword [eax], 0                  ; compare x to 0
        jg     .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.int.ie.bez (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <= 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = offset of x

$usprocf @@call.int.ie.bez

        cmp     dword [eax], 0                  ; compare x to 0
        jle    .if.call                         ; call if x <= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.bez (proc, x)
; conditional call
;
; call proc if x <= 0
;
; edx = offset of proc address
; eax = x

$usprocf @@call.reg.if.bez

        cmp     eax, 0                          ; compare x to 0
        jg     .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.reg.ie.bez (if.proc, else.proc, x)
; conditional call
;
; call if.proc if x <= 0,
; call else.proc otherwise
;
; edx = offset of if.proc address
; ecx = offset of else.proc address
; eax = x

$usprocf @@call.reg.ie.bez

        cmp     eax, 0                          ; compare x to 0
        jle    .if.call                         ; call if x <= 0

    .else.call:
        mov     edx, ecx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    dword [edx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; call.if.or (proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=3
;
; call proc if (x = Y1) or (x = Y2) or ... or (x = Yn)
;
; edx = offset of proc address
; esp = x

macro @@call.if.or.sse
{
$usprocf @@call.if.or

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .no.call                         ; return if no matches
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        jmp    .if.call                         ; call if x = Y[i]

    .no.call:
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.or.fpu
{
$usprocf @@call.if.or

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .no.call                         ; return if no matches
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnje   .if.call                         ; call if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.or.sse
$else
  @@call.if.or.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.or (if.proc, else.proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=4
;
; call if.proc if (x = Y1) or (x = Y2) or ... or (x = Yn),
; call else.proc otherwise
;
; edx = offset of if.proc address
; eax = offset of else.proc address
; esp = x

macro @@call.ie.or.sse
{
$usprocf @@call.ie.or

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .else.call                       ; return if no matches
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        jmp    .if.call                         ; call if x = Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.or.fpu
{
$usprocf @@call.ie.or

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .else.call                       ; return if no matches
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnje   .if.call                         ; call if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.or.sse
$else
  @@call.ie.or.fpu
$end

; ------------------------------------------------------------------------------

; call.if.nor (proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=3
;
; call proc if (x <> Y1) and (x <> Y2) and ... and (x <> Yn)
;
; edx = offset of proc address
; esp = x

macro @@call.if.nor.sse
{
$usprocf @@call.if.nor

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]

    .no.call:
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.nor.fpu
{
$usprocf @@call.if.nor

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnje   .no.call                         ; return if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.nor.sse
$else
  @@call.if.nor.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.nor (if.proc, else.proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=4
;
; call if.proc if (x <> Y1) and (x <> Y2) and ... and (x <> Yn),
; call else.proc otherwise
;
; edx = offset of if.proc address
; eax = offset of else.proc address
; esp = x

macro @@call.ie.nor.sse
{
$usprocf @@call.ie.nor

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.nor.fpu
{
$usprocf @@call.ie.nor

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnje   .else.call                       ; return if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.nor.sse
$else
  @@call.ie.nor.fpu
$end

; ------------------------------------------------------------------------------

; call.if.and (proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=3
;
; call proc if (x = Y1) and (x = Y2) and ... and (x = Yn)
;
; edx = offset of proc address
; esp = x

macro @@call.if.and.sse
{
$usprocf @@call.if.and

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .no.call                         ; return if x <> Y[i]
        jp     .no.call                         ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.and.fpu
{
$usprocf @@call.if.and

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnjne  .no.call                         ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.and.sse
$else
  @@call.if.and.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.and (if.proc, else.proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=4
;
; call if.proc if (x = Y1) and (x = Y2) and ... and (x = Yn),
; call else.proc otherwise
;
; edx = offset of if.proc address
; eax = offset of else.proc address
; esp = x

macro @@call.ie.and.sse
{
$usprocf @@call.ie.and

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .else.call                       ; return if x <> Y[i]
        jp     .else.call                       ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.and.fpu
{
$usprocf @@call.ie.and

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .if.call                         ; call on complete match
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnjne  .else.call                       ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.and.sse
$else
  @@call.ie.and.fpu
$end

; ------------------------------------------------------------------------------

; call.if.nand (proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=3
;
; call proc if (x <> Y1) or (x <> Y2) or ... or (x <> Yn)
;
; edx = offset of proc address
; esp = x

macro @@call.if.nand.sse
{
$usprocf @@call.if.nand

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .no.call                         ; return if no matches
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .if.call                         ; call if x <> Y[i]
        jp     .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

macro @@call.if.nand.fpu
{
$usprocf @@call.if.nand

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save proc
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .no.call                         ; return if no matches
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnjne  .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     esp, ecx
        jmp    .return

    .if.call:
        mov     edx, [esp]                      ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.if.nand.sse
$else
  @@call.if.nand.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; call.ie.nand (if.proc, else.proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; ecx -> argument count, min=4
;
; call if.proc if (x <> Y1) or (x <> Y2) or ... or (x <> Yn),
; call else.proc otherwise
;
; edx = offset of if.proc address
; eax = offset of else.proc address
; esp = x

macro @@call.ie.nand.sse
{
$usprocf @@call.ie.nand

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .else.call                       ; return if no matches
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .if.call                         ; call if x <> Y[i]
        jp     .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.nand.fpu
{
$usprocf @@call.ie.nand

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save if.proc
        mov     [esp - 4], eax                  ; save else.proc
        lea     ecx, [ecx * 8 - 16]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .else.call                       ; return if no matches
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnjne  .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     edx, [esp - 4]                  ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
        mov     edx, [esp]                      ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     esp, ecx
        call    dword [edx]                     ; call if.proc

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@call.ie.nand.sse
$else
  @@call.ie.nand.fpu
$end

; ------------------------------------------------------------------------------
