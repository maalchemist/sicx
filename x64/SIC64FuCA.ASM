
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

        push    rbp
        mov     rbp, rsp
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
; rcx = float argument number (one-based)

macro @@arg.getf.sse
{
$usprocf @@arg.getf

        lea     rcx, [rbp + 8*rcx + 8]
        movsd   xmm0, qword [rcx]
    .return:
        retn
$endp
}

macro @@arg.getf.fpu
{
$usprocf @@arg.getf

        lea     rcx, [rbp + 8*rcx + 8]
        fld     qword [rcx]
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
; return result in rax
; rcx = integer argument number (one-based)

$usprocf @@arg.geti

        lea     rcx, [rbp + 8*rcx + 8]
        mov     rax, [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; allocate memory for local variables
; rcx = local variable count

$usprocf @@locals.alloc

        shl     rcx, 3                          ; rcx = 8 * (local variable count)
        sub     rsp, rcx
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; get float local variable
; return result in ST0(xmm0)
; rcx = local variable number (one-based)

macro @@local.getf.sse
{
$usprocf @@local.getf

        neg     rcx
        lea     rcx, [rbp + 8*rcx]
        movsd   xmm0, qword [rcx]
    .return:
        retn
$endp
}

macro @@local.getf.fpu
{
$usprocf @@local.getf

        neg     rcx
        lea     rcx, [rbp + 8*rcx]
        fld     qword [rcx]
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
; return result in rax
; rcx = local variable number (one-based)

$usprocf @@local.geti

        neg     rcx
        lea     rcx, [rbp + 8*rcx]
        mov     rax, [rcx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; set float local variable
; return result in ST0(xmm0)
; rcx = local variable number (one-based)
; rsp = value

macro @@local.setf.sse
{
$usprocf @@local.setf

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        neg     rcx
        lea     rcx, [rbp + 8*rcx]
        movsd   qword [rcx], xmm0
        add     rsp, 8
    .return:
        retn
$endp
}

macro @@local.setf.fpu
{
$usprocf @@local.setf

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        neg     rcx
        lea     rcx, [rbp + 8*rcx]
        fst     qword [rcx]
        add     rsp, 8
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
; return result in rax
; rcx = local variable number (one-based)
; rsp = value

$usprocf @@local.seti

        neg     rcx
        lea     rcx, [rbp + 8*rcx]
        mov     rax, [rsp]
        mov     [rcx], rax
        add     rsp, 8
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
; rdx = offset of proc address

$usprocf @@call

        call    qword [rdx]
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

; xcall (proc_0, proc_1, ..., proc_n, index)
; procedure call by index

$usprocf @@xcall

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; rxcall (proc_n, ..., proc_1, proc_0, index)
; procedure call by reverse index

$usprocf @@rxcall

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
; rdx = offset of proc address

$usprocf @@call.if.x32

;       call    qword [rdx]
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
; rcx = offset of else.proc address
; rdx = offset of if.proc address

$usprocf @@call.ie.x32

        call    qword [rcx]                     ; call else.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.n32 (proc)
; conditional call
;
; call proc if DLL is not x32
;
; rdx = offset of proc address

$usprocf @@call.if.n32

        call    qword [rdx]
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
; rcx = offset of else.proc address
; rdx = offset of if.proc address

$usprocf @@call.ie.n32

        call    qword [rdx]                     ; call if.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.x64 (proc)
; conditional call
;
; call proc if DLL is x64
;
; rdx = offset of proc address

$usprocf @@call.if.x64

        call    qword [rdx]
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
; rcx = offset of else.proc address
; rdx = offset of if.proc address

$usprocf @@call.ie.x64

        call    qword [rdx]                     ; call if.proc
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.n64 (proc)
; conditional call
;
; call proc if DLL is not x64
;
; rdx = offset of proc address

$usprocf @@call.if.n64

;       call    qword [rdx]
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
; rcx = offset of else.proc address
; rdx = offset of if.proc address

$usprocf @@call.ie.n64

        call    qword [rcx]                     ; call else.proc
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
; rdx = offset of proc address
; rsp = x

macro @@call.if.true.sse
{
$usprocf @@call.if.true

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .no.call:                                   ; x = 0
        jmp    .return

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.true.fpu
{
$usprocf @@call.if.true

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.true.sse
{
$usprocf @@call.ie.true

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .else.call:                                 ; x = 0
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.true.fpu
{
$usprocf @@call.ie.true

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .if.call                         ; call if x <> 0

    .else.call:                                 ; x = 0
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.true

        cmp     qword [rax], 0                  ; compare x to 0
        jz     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.true

        cmp     qword [rax], 0                  ; compare x to 0
        jnz    .if.call                         ; call if x <> 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.true (proc, x)
; conditional call
;
; call proc if x <> 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.true

        test    rax, rax                        ; compare x to 0
        jz     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.true

        test    rax, rax                        ; compare x to 0
        jnz    .if.call                         ; call if x <> 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.false (proc, x)
; conditional call
;
; call proc if x = 0
;
; rdx = offset of proc address
; rsp = x

macro @@call.if.false.sse
{
$usprocf @@call.if.false

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .return                          ; no call if x <> 0
        jp     .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.false.fpu
{
$usprocf @@call.if.false

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.false.sse
{
$usprocf @@call.ie.false

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .else.call                       ; else call if x <> 0
        jp     .else.call                       ; else call if x <> 0
        jmp    .if.call

    .else.call:                                 ; x <> 0
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.false.fpu
{
$usprocf @@call.ie.false

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .if.call                         ; call if x = 0

    .else.call:                                 ; x <> 0
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.false

        cmp     qword [rax], 0                  ; compare x to 0
        jnz    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.false

        cmp     qword [rax], 0                  ; compare x to 0
        jz     .if.call                         ; call if x = 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.false (proc, x)
; conditional call
;
; call proc if x = 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.false

        test    rax, rax                        ; compare x to 0
        jnz    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.false

        test    rax, rax                        ; compare x to 0
        jz     .if.call                         ; call if x = 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rsp = x

macro @@call.if.z.sse
{
$usprocf @@call.if.z

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .return                          ; no call if x <> 0
        jp     .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.z.fpu
{
$usprocf @@call.if.z

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.z.sse
{
$usprocf @@call.ie.z

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .else.call                       ; else call if x <> 0
        jp     .else.call                       ; else call if x <> 0
        jmp    .if.call

    .else.call:                                 ; x <> 0
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.z.fpu
{
$usprocf @@call.ie.z

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .if.call                         ; call if x = 0

    .else.call:                                 ; x <> 0
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.z

        cmp     qword [rax], 0                  ; compare x to 0
        jne    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.z

        cmp     qword [rax], 0                  ; compare x to 0
        je     .if.call                         ; call if x = 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.z (proc, x)
; conditional call
;
; call proc if x = 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.z

        test    rax, rax                        ; compare x to 0
        jnz    .return                          ; no call if x <> 0

    .if.call:                                   ; x = 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.z

        test    rax, rax                        ; compare x to 0
        jz     .if.call                         ; call if x = 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x = 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.nz (proc, x)
; conditional call
;
; call proc if x <> 0
;
; rdx = offset of proc address
; rsp = x

macro @@call.if.nz.sse
{
$usprocf @@call.if.nz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .no.call:                                   ; x = 0
        jmp    .return

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.nz.fpu
{
$usprocf @@call.if.nz

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.nz.sse
{
$usprocf @@call.ie.nz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .if.call                         ; call if x <> 0
        jp     .if.call                         ; call if x <> 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.nz.fpu
{
$usprocf @@call.ie.nz

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .if.call                         ; call if x <> 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.nz

        cmp     qword [rax], 0                  ; compare x to 0
        je     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.nz

        cmp     qword [rax], 0                  ; compare x to 0
        jne    .if.call                         ; call if x <> 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.nz (proc, x)
; conditional call
;
; call proc if x <> 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.nz

        test    rax, rax                        ; compare x to 0
        jz     .return                          ; no call if x = 0

    .if.call:                                   ; x <> 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.nz

        test    rax, rax                        ; compare x to 0
        jnz    .if.call                         ; call if x <> 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <> 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.az (proc, x)
; conditional call
;
; call proc if x > 0
;
; rdx = offset of proc address
; rsp = x

macro @@call.if.az.sse
{
$usprocf @@call.if.az

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.az.fpu
{
$usprocf @@call.if.az

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.az.sse
{
$usprocf @@call.ie.az

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .if.call                         ; call if x > 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.az.fpu
{
$usprocf @@call.ie.az

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .if.call                         ; call if x > 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.az

        cmp     qword [rax], 0                  ; compare x to 0
        jle    .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.az

        cmp     qword [rax], 0                  ; compare x to 0
        jg     .if.call                         ; call if x > 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.az (proc, x)
; conditional call
;
; call proc if x > 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.az

        cmp     rax, 0                          ; compare x to 0
        jle    .return                          ; no call if x <= 0

    .if.call:                                   ; x > 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.az

        cmp     rax, 0                          ; compare x to 0
        jg     .if.call                         ; call if x > 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x > 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.aez (proc, x)
; conditional call
;
; call proc if x >= 0
;
; rdx = offset of proc address
; rsp = x

macro @@call.if.aez.sse
{
$usprocf @@call.if.aez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.aez.fpu
{
$usprocf @@call.if.aez

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.aez.sse
{
$usprocf @@call.ie.aez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .if.call                         ; call if x >= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.aez.fpu
{
$usprocf @@call.ie.aez

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .if.call                         ; call if x >= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.aez

        cmp     qword [rax], 0                  ; compare x to 0
        jl     .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.aez

        cmp     qword [rax], 0                  ; compare x to 0
        jge    .if.call                         ; call if x >= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.aez (proc, x)
; conditional call
;
; call proc if x >= 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.aez

        cmp     rax, 0                          ; compare x to 0
        jl     .return                          ; no call if x < 0

    .if.call:                                   ; x >= 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.aez

        cmp     rax, 0                          ; compare x to 0
        jge    .if.call                         ; call if x >= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x >= 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.bz (proc, x)
; conditional call
;
; call proc if x < 0
;
; rdx = offset of proc address
; rsp = x

macro @@call.if.bz.sse
{
$usprocf @@call.if.bz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.bz.fpu
{
$usprocf @@call.if.bz

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.bz.sse
{
$usprocf @@call.ie.bz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .if.call                         ; call if x < 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.bz.fpu
{
$usprocf @@call.ie.bz

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .if.call                         ; call if x < 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.bz

        cmp     qword [rax], 0                  ; compare x to 0
        jge    .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.bz

        cmp     qword [rax], 0                  ; compare x to 0
        jl     .if.call                         ; call if x < 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.bz (proc, x)
; conditional call
;
; call proc if x < 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.bz

        cmp     rax, 0                          ; compare x to 0
        jge    .return                          ; no call if x >= 0

    .if.call:                                   ; x < 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.bz

        cmp     rax, 0                          ; compare x to 0
        jl     .if.call                         ; call if x < 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x < 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.if.bez (proc, x)
; conditional call
;
; call proc if x <= 0
;
; rdx = offset of proc address
; rsp = x

macro @@call.if.bez.sse
{
$usprocf @@call.if.bez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.if.bez.fpu
{
$usprocf @@call.if.bez

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rsp = x

macro @@call.ie.bez.sse
{
$usprocf @@call.ie.bez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .if.call                         ; call if x <= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    qword [rdx]

    .return:
        retn
$endp
}

macro @@call.ie.bez.fpu
{
$usprocf @@call.ie.bez

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     rsp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .if.call                         ; call if x <= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    qword [rdx]

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
; rdx = offset of proc address
; rax = offset of x

$usprocf @@call.int.if.bez

        cmp     qword [rax], 0                  ; compare x to 0
        jg     .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = offset of x

$usprocf @@call.int.ie.bez

        cmp     qword [rax], 0                  ; compare x to 0
        jle    .if.call                         ; call if x <= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; call.reg.if.bez (proc, x)
; conditional call
;
; call proc if x <= 0
;
; rdx = offset of proc address
; rax = x

$usprocf @@call.reg.if.bez

        cmp     rax, 0                          ; compare x to 0
        jg     .return                          ; no call if x > 0

    .if.call:                                   ; x <= 0
        call    qword [rdx]

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
; rdx = offset of if.proc address
; rcx = offset of else.proc address
; rax = x

$usprocf @@call.reg.ie.bez

        cmp     rax, 0                          ; compare x to 0
        jle    .if.call                         ; call if x <= 0

    .else.call:
        mov     rdx, rcx                        ; set proc = else.proc

    .if.call:                                   ; x <= 0
        call    qword [rdx]

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; call.if.or (proc, x, Y1, Y2, ..., Yn)
; conditional call
; variable number of arguments
; r13 -> argument count, min=3
;
; call proc if (x = Y1) or (x = Y2) or ... or (x = Yn)
;
; r11 = offset of proc address
; rsp = x

macro @@call.if.or.sse
{
$usprocf @@call.if.or

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .no.call                         ; return if no matches
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        jmp    .if.call                         ; call if x = Y[i]

    .no.call:
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]

    .return:
        retn
$endp
}

macro @@call.if.or.fpu
{
$usprocf @@call.if.or

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .no.call                         ; return if no matches
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnje   .if.call                         ; call if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]

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
; r13 -> argument count, min=4
;
; call if.proc if (x = Y1) or (x = Y2) or ... or (x = Yn),
; call else.proc otherwise
;
; r11 = offset of if.proc address
; r10 = offset of else.proc address
; rsp = x

macro @@call.ie.or.sse
{
$usprocf @@call.ie.or

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .else.call                       ; return if no matches
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        jmp    .if.call                         ; call if x = Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.or.fpu
{
$usprocf @@call.ie.or

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .else.call                       ; return if no matches
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnje   .if.call                         ; call if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

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
; r13 -> argument count, min=3
;
; call proc if (x <> Y1) and (x <> Y2) and ... and (x <> Yn)
;
; r11 = offset of proc address
; rsp = x

macro @@call.if.nor.sse
{
$usprocf @@call.if.nor

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]

    .no.call:
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]

    .return:
        retn
$endp
}

macro @@call.if.nor.fpu
{
$usprocf @@call.if.nor

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnje   .no.call                         ; return if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]

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
; r13 -> argument count, min=4
;
; call if.proc if (x <> Y1) and (x <> Y2) and ... and (x <> Yn),
; call else.proc otherwise
;
; r11 = offset of if.proc address
; r10 = offset of else.proc address
; rsp = x

macro @@call.ie.nor.sse
{
$usprocf @@call.ie.nor

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.nor.fpu
{
$usprocf @@call.ie.nor

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnje   .else.call                       ; return if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

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
; r13 -> argument count, min=3
;
; call proc if (x = Y1) and (x = Y2) and ... and (x = Yn)
;
; r11 = offset of proc address
; rsp = x

macro @@call.if.and.sse
{
$usprocf @@call.if.and

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .no.call                         ; return if x <> Y[i]
        jp     .no.call                         ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]

    .return:
        retn
$endp
}

macro @@call.if.and.fpu
{
$usprocf @@call.if.and

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnjne  .no.call                         ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]

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
; r13 -> argument count, min=4
;
; call if.proc if (x = Y1) and (x = Y2) and ... and (x = Yn),
; call else.proc otherwise
;
; r11 = offset of if.proc address
; r10 = offset of else.proc address
; rsp = x

macro @@call.ie.and.sse
{
$usprocf @@call.ie.and

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .else.call                       ; return if x <> Y[i]
        jp     .else.call                       ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.and.fpu
{
$usprocf @@call.ie.and

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .if.call                         ; call on complete match
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnjne  .else.call                       ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

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
; r13 -> argument count, min=3
;
; call proc if (x <> Y1) or (x <> Y2) or ... or (x <> Yn)
;
; r11 = offset of proc address
; rsp = x

macro @@call.if.nand.sse
{
$usprocf @@call.if.nand

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .no.call                         ; return if no matches
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .if.call                         ; call if x <> Y[i]
        jp     .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]

    .return:
        retn
$endp
}

macro @@call.if.nand.fpu
{
$usprocf @@call.if.nand

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save proc
        lea     r13, [r13 * 8 - 8]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .no.call                         ; return if no matches
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnjne  .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .no.call:
        fstp    st0                             ; pop x
        add     rsp, r13
        jmp    .return

    .if.call:
;       mov     r11, ***                        ; restore proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]

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
; r13 -> argument count, min=4
;
; call if.proc if (x <> Y1) or (x <> Y2) or ... or (x <> Yn),
; call else.proc otherwise
;
; r11 = offset of if.proc address
; r10 = offset of else.proc address
; rsp = x

macro @@call.ie.nand.sse
{
$usprocf @@call.ie.nand

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .else.call                       ; return if no matches
        ucomisd xmm0, qword [rsp + rdx]         ; compare x to Y[i]
        jnz    .if.call                         ; call if x <> Y[i]
        jp     .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

    .return:
        retn
$endp
}

macro @@call.ie.nand.fpu
{
$usprocf @@call.ie.nand

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       mov     ***, r11                        ; save if.proc
;       mov     ***, r10                        ; save else.proc
        lea     r13, [r13 * 8 - 16]
        xor     rdx, rdx
    .next.arg:
        add     rdx, 8
        cmp     rdx, r13
        je     .else.call                       ; return if no matches
        fcom    qword [rsp + rdx]               ; compare x to Y[i]
        fnjne  .if.call                         ; call if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .else.call:
        mov     r11, r10                        ; set proc = else.proc
        jmp    .if.call.main

    .if.call:
;       mov     r11, ***                        ; restore if.proc
    .if.call.main:
        fstp    st0                             ; pop x
        add     rsp, r13
        call    qword [r11]                     ; call if.proc

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
