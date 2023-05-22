
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (variable number of arguments)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

$ifdef _SSEX

macro @@.vcount.leave.sse
{
    $ifdef _X64
        cvtsi2sd xmm0, rdx
    $else
        cvtsi2sd xmm0, edx
    $end
}

$else

macro @@.vcount.leave.fpu
{
    $ifdef _X64
        push    rdx
        fild    qword [rsp]
        add     rsp, 8
    $else
        push    edx
        fild    dword [esp]
        add     esp, 4
    $end
}

$end

; ------------------------------------------------------------------------------

macro @@.varg.enter
{
    $ifdef _X64
        mov     rdx, r13                        ; !!! don't use rax, macro fnj... use ax register
        xor     r13, r13

        mov     r10, rsp                        ; r10 = destination
        mov     r11, r10                        ; r11 = source
    $else
        mov     edx, ecx                        ; !!! don't use eax, macro fnj... use ax register
        xor     ecx, ecx

        push    edi esi ebx                     ; save registers
        lea     edi, [esp + 12]                 ; edi = destination
        mov     esi, edi                        ; esi = source
    $end
}

macro @@.varg.leave
{
    $ifdef _X64
    $else
        pop     ebx esi edi                     ; restore registers
    $end
}

macro @@.varg.accept
{
    $ifdef _X64
        inc     r13
        cmp     r10, r11
        je      @F

        mov     r9, [r11]
        mov     [r10], r9
    @@:
        add     r10, 8
    $else
        inc     ecx
        cmp     edi, esi
        je      @F

        mov     ebx, [esi]
        mov     [edi], ebx
        mov     ebx, [esi + 4]
        mov     [edi + 4], ebx
    @@:
        add     edi, 8
    $end
}

macro @@.varg.next
{
    $ifdef _X64
        add     r11, 8
        dec     rdx
        jnz    .arg
    $else
        add     esi, 8
        dec     edx
        jnz    .arg
    $end
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; argument count
; double vcount (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=0

$usprocf @@vcount

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; argument count : x[i] = 0
; double vcount.z (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@vcount.z.sse
{
$usprocf @@vcount.z

        xor     edx, edx
        xorpd   xmm5, xmm5
    .arg:
        ucomisd xmm5, qword [esp + ecx * 8 - 8] ; compare 0 to x
        jnz    .next                            ; bypass if x != 0
        jp     .next                            ; bypass if x != 0
        inc     edx                             ; accept if x = 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.z.fpu
{
$usprocf @@vcount.z

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjnzp .next                            ; bypass if x != 0
        inc     edx                             ; accept if x = 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.z.sse
$else
  @@vcount.z.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] != 0
; double vcount.nz (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@vcount.nz.sse
{
$usprocf @@vcount.nz

        xor     edx, edx
        xorpd   xmm5, xmm5
    .arg:
        ucomisd xmm5, qword [esp + ecx * 8 - 8] ; compare 0 to x
        jnz    .accept                          ; accept if x != 0
        jp     .accept                          ; accept if x != 0
        jmp    .next                            ; bypass if x = 0
    .accept:
        inc     edx
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.nz.fpu
{
$usprocf @@vcount.nz

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjzp  .next                            ; bypass if x = 0
        inc     edx                             ; accept if x != 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.nz.sse
$else
  @@vcount.nz.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] > 0
; double vcount.az (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@vcount.az.sse
{
$usprocf @@vcount.az

        xor     edx, edx
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esp + ecx * 8 - 8] ; compare 0 to x
        jae    .next                            ; bypass if x <= 0 (0 >= x)
        inc     edx                             ; accept if x > 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.az.fpu
{
$usprocf @@vcount.az

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjlep .next                            ; bypass if x <= 0
        inc     edx                             ; accept if x > 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.az.sse
$else
  @@vcount.az.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] >= 0
; double vcount.aez (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@vcount.aez.sse
{
$usprocf @@vcount.aez

        xor     edx, edx
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esp + ecx * 8 - 8] ; compare 0 to x
        ja     .next                            ; bypass if x < 0 (0 > x)
        inc     edx                             ; accept if x >= 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.aez.fpu
{
$usprocf @@vcount.aez

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjlp  .next                            ; bypass if x < 0
        inc     edx                             ; accept if x >= 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.aez.sse
$else
  @@vcount.aez.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] < 0
; double vcount.bz (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@vcount.bz.sse
{
$usprocf @@vcount.bz

        xor     edx, edx
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esp + ecx * 8 - 8] ; compare 0 to x
        jbe    .next                            ; bypass if x >= 0 (0 <= x)
        inc     edx                             ; accept if x < 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.bz.fpu
{
$usprocf @@vcount.bz

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjgep .next                            ; bypass if x >= 0
        inc     edx                             ; accept if x < 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.bz.sse
$else
  @@vcount.bz.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] <= 0
; double vcount.bez (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@vcount.bez.sse
{
$usprocf @@vcount.bez

        xor     edx, edx
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esp + ecx * 8 - 8] ; compare 0 to x
        jb     .next                            ; bypass if x > 0 (0 < x)
        inc     edx                             ; accept if x <= 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.bez.fpu
{
$usprocf @@vcount.bez

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjgp  .next                            ; bypass if x > 0
        inc     edx                             ; accept if x <= 0
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.bez.sse
$else
  @@vcount.bez.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] = a
; double vcount.e (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@vcount.e.sse
{
$usprocf @@vcount.e

        xor     edx, edx
        dec     ecx
        movsd   xmm0, qword [esp + ecx * 8]     ; xmm0 = a
    .arg:
        ucomisd xmm0, qword [esp + ecx * 8 - 8] ; compare a to x
        jnz    .next                            ; bypass if x != a
        jp     .next                            ; bypass if x != a
        inc     edx                             ; accept if x = a
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.e.fpu
{
$usprocf @@vcount.e

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
        dec     ecx
        fld     qword [esp + ecx * 8]           ; st0 = a
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjne  .next                            ; bypass if x != a
        inc     edx                             ; accept if x = a
    .next:
        dec     ecx
        jnz    .arg
        fstp    st0
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.e.sse
$else
  @@vcount.e.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] != a
; double vcount.ne (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@vcount.ne.sse
{
$usprocf @@vcount.ne

        xor     edx, edx
        dec     ecx
        movsd   xmm0, qword [esp + ecx * 8]     ; xmm0 = a
    .arg:
        ucomisd xmm0, qword [esp + ecx * 8 - 8] ; compare a to x
        jnz    .accept                          ; accept if x != a
        jp     .accept                          ; accept if x != a
        jmp    .next                            ; bypass if x = a
    .accept:
        inc     edx
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.ne.fpu
{
$usprocf @@vcount.ne

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
        dec     ecx
        fld     qword [esp + ecx * 8]           ; st0 = a
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnje   .next                            ; bypass if x = a
        inc     edx                             ; accept if x != a
    .next:
        dec     ecx
        jnz    .arg
        fstp    st0
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.ne.sse
$else
  @@vcount.ne.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] > a
; double vcount.a (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@vcount.a.sse
{
$usprocf @@vcount.a

        xor     edx, edx
        dec     ecx
        movsd   xmm0, qword [esp + ecx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esp + ecx * 8 - 8] ; compare a to x
        jae    .next                            ; bypass if x <= a (a >= x)
        inc     edx                             ; accept if x > a
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.a.fpu
{
$usprocf @@vcount.a

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
        dec     ecx
        fld     qword [esp + ecx * 8]           ; st0 = a
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjle  .next                            ; bypass if x <= a
        inc     edx                             ; accept if x > a
    .next:
        dec     ecx
        jnz    .arg
        fstp    st0
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.a.sse
$else
  @@vcount.a.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] >= a
; double vcount.ae (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@vcount.ae.sse
{
$usprocf @@vcount.ae

        xor     edx, edx
        dec     ecx
        movsd   xmm0, qword [esp + ecx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esp + ecx * 8 - 8] ; compare a to x
        ja     .next                            ; bypass if x < a (a > x)
        inc     edx                             ; accept if x >= a
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.ae.fpu
{
$usprocf @@vcount.ae

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
        dec     ecx
        fld     qword [esp + ecx * 8]           ; st0 = a
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjl   .next                            ; bypass if x < a
        inc     edx                             ; accept if x >= a
    .next:
        dec     ecx
        jnz    .arg
        fstp    st0
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.ae.sse
$else
  @@vcount.ae.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] < a
; double vcount.b (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@vcount.b.sse
{
$usprocf @@vcount.b

        xor     edx, edx
        dec     ecx
        movsd   xmm0, qword [esp + ecx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esp + ecx * 8 - 8] ; compare a to x
        jbe    .next                            ; bypass if x >= a (a <= x)
        inc     edx                             ; accept if x < a
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.b.fpu
{
$usprocf @@vcount.b

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
        dec     ecx
        fld     qword [esp + ecx * 8]           ; st0 = a
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjge  .next                            ; bypass if x >= a
        inc     edx                             ; accept if x < a
    .next:
        dec     ecx
        jnz    .arg
        fstp    st0
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.b.sse
$else
  @@vcount.b.fpu
$end

; ------------------------------------------------------------------------------

; argument count : x[i] <= a
; double vcount.be (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@vcount.be.sse
{
$usprocf @@vcount.be

        xor     edx, edx
        dec     ecx
        movsd   xmm0, qword [esp + ecx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esp + ecx * 8 - 8] ; compare a to x
        jb     .next                            ; bypass if x > a (a < x)
        inc     edx                             ; accept if x <= a
    .next:
        dec     ecx
        jnz    .arg
        @@.vcount.leave.sse

    .return:
        retn
$endp
}

macro @@vcount.be.fpu
{
$usprocf @@vcount.be

        xor     edx, edx                        ; !!! don't use eax, macro fnj... use ax register
        dec     ecx
        fld     qword [esp + ecx * 8]           ; st0 = a
    .arg:
        fld     qword [esp + ecx * 8 - 8]       ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjg   .next                            ; bypass if x > a
        inc     edx                             ; accept if x <= a
    .next:
        dec     ecx
        jnz    .arg
        fstp    st0
        @@.vcount.leave.fpu

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vcount.be.sse
$else
  @@vcount.be.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; argument filter : x[i] = 0
; double varg.z (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@varg.z.sse
{
$usprocf @@varg.z

        @@.varg.enter
        xorpd   xmm5, xmm5
    .arg:
        ucomisd xmm5, qword [esi]               ; compare 0 to x
        jnz    .next                            ; bypass if x != 0
        jp     .next                            ; bypass if x != 0
        @@.varg.accept                          ; accept if x = 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.z.fpu
{
$usprocf @@varg.z

        @@.varg.enter
    .arg:
        fld     qword [esi]                     ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjnzp .next                            ; bypass if x != 0
        @@.varg.accept                          ; accept if x = 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.z.sse
$else
  @@varg.z.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] != 0
; double varg.nz (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@varg.nz.sse
{
$usprocf @@varg.nz

        @@.varg.enter
        xorpd   xmm5, xmm5
    .arg:
        ucomisd xmm5, qword [esi]               ; compare 0 to x
        jnz    .accept                          ; accept if x != 0
        jp     .accept                          ; accept if x != 0
        jmp    .next                            ; bypass if x = 0
    .accept:
        @@.varg.accept
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.nz.fpu
{
$usprocf @@varg.nz

        @@.varg.enter
    .arg:
        fld     qword [esi]                     ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjzp  .next                            ; bypass if x = 0
        @@.varg.accept                          ; accept if x != 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.nz.sse
$else
  @@varg.nz.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] > 0
; double varg.az (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@varg.az.sse
{
$usprocf @@varg.az

        @@.varg.enter
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esi]               ; compare 0 to x
        jae    .next                            ; bypass if x <= 0 (0 >= x)
        @@.varg.accept                          ; accept if x > 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.az.fpu
{
$usprocf @@varg.az

        @@.varg.enter
    .arg:
        fld     qword [esi]                     ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjlep .next                            ; bypass if x <= 0
        @@.varg.accept                          ; accept if x > 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.az.sse
$else
  @@varg.az.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] >= 0
; double varg.aez (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@varg.aez.sse
{
$usprocf @@varg.aez

        @@.varg.enter
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esi]               ; compare 0 to x
        ja     .next                            ; bypass if x < 0 (0 > x)
        @@.varg.accept                          ; accept if x >= 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.aez.fpu
{
$usprocf @@varg.aez

        @@.varg.enter
    .arg:
        fld     qword [esi]                     ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjlp  .next                            ; bypass if x < 0
        @@.varg.accept                          ; accept if x >= 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.aez.sse
$else
  @@varg.aez.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] < 0
; double varg.bz (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@varg.bz.sse
{
$usprocf @@varg.bz

        @@.varg.enter
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esi]               ; compare 0 to x
        jbe    .next                            ; bypass if x >= 0 (0 <= x)
        @@.varg.accept                          ; accept if x < 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.bz.fpu
{
$usprocf @@varg.bz

        @@.varg.enter
    .arg:
        fld     qword [esi]                     ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjgep .next                            ; bypass if x >= 0
        @@.varg.accept                          ; accept if x < 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.bz.sse
$else
  @@varg.bz.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] <= 0
; double varg.bez (x[1], x[2], ... , x[N])
; variable number of arguments
; ecx -> argument count, min=1

macro @@varg.bez.sse
{
$usprocf @@varg.bez

        @@.varg.enter
        xorpd   xmm5, xmm5
    .arg:
        comisd  xmm5, qword [esi]               ; compare 0 to x
        jb     .next                            ; bypass if x > 0 (0 < x)
        @@.varg.accept                          ; accept if x <= 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.bez.fpu
{
$usprocf @@varg.bez

        @@.varg.enter
    .arg:
        fld     qword [esi]                     ; st0 = x[i]
        ftst                                    ; compare x to 0
        fnjgp  .next                            ; bypass if x > 0
        @@.varg.accept                          ; accept if x <= 0
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.bez.sse
$else
  @@varg.bez.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] = a
; double varg.e (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@varg.e.sse
{
$usprocf @@varg.e

        @@.varg.enter
        dec     edx
        movsd   xmm0, qword [esi + edx * 8]     ; xmm0 = a
    .arg:
        ucomisd xmm0, qword [esi]               ; compare a to x
        jnz    .next                            ; bypass if x != a
        jp     .next                            ; bypass if x != a
        @@.varg.accept                          ; accept if x = a
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.e.fpu
{
$usprocf @@varg.e

        @@.varg.enter
        dec     edx
        fld     qword [esi + edx * 8]           ; st0 = a
    .arg:
        fld     qword [esi]                     ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjne  .next                            ; bypass if x != a
        @@.varg.accept                          ; accept if x = a
    .next:
        @@.varg.next
        fstp    st0
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.e.sse
$else
  @@varg.e.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] != a
; double varg.ne (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@varg.ne.sse
{
$usprocf @@varg.ne

        @@.varg.enter
        dec     edx
        movsd   xmm0, qword [esi + edx * 8]     ; xmm0 = a
    .arg:
        ucomisd xmm0, qword [esi]               ; compare a to x
        jnz    .accept                          ; accept if x != a
        jp     .accept                          ; accept if x != a
        jmp    .next                            ; bypass if x = a
    .accept:
        @@.varg.accept
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.ne.fpu
{
$usprocf @@varg.ne

        @@.varg.enter
        dec     edx
        fld     qword [esi + edx * 8]           ; st0 = a
    .arg:
        fld     qword [esi]                     ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnje   .next                            ; bypass if x = a
        @@.varg.accept                          ; accept if x != a
    .next:
        @@.varg.next
        fstp    st0
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.ne.sse
$else
  @@varg.ne.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] > a
; double varg.a (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@varg.a.sse
{
$usprocf @@varg.a

        @@.varg.enter
        dec     edx
        movsd   xmm0, qword [esi + edx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esi]               ; compare a to x
        jae    .next                            ; bypass if x <= a (a >= x)
        @@.varg.accept                          ; accept if x > a
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.a.fpu
{
$usprocf @@varg.a

        @@.varg.enter
        dec     edx
        fld     qword [esi + edx * 8]           ; st0 = a
    .arg:
        fld     qword [esi]                     ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjle  .next                            ; bypass if x <= a
        @@.varg.accept                          ; accept if x > a
    .next:
        @@.varg.next
        fstp    st0
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.a.sse
$else
  @@varg.a.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] >= a
; double varg.ae (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@varg.ae.sse
{
$usprocf @@varg.ae

        @@.varg.enter
        dec     edx
        movsd   xmm0, qword [esi + edx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esi]               ; compare a to x
        ja     .next                            ; bypass if x < a (a > x)
        @@.varg.accept                          ; accept if x >= a
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.ae.fpu
{
$usprocf @@varg.ae

        @@.varg.enter
        dec     edx
        fld     qword [esi + edx * 8]           ; st0 = a
    .arg:
        fld     qword [esi]                     ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjl   .next                            ; bypass if x < a
        @@.varg.accept                          ; accept if x >= a
    .next:
        @@.varg.next
        fstp    st0
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.ae.sse
$else
  @@varg.ae.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] < a
; double varg.b (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@varg.b.sse
{
$usprocf @@varg.b

        @@.varg.enter
        dec     edx
        movsd   xmm0, qword [esi + edx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esi]               ; compare a to x
        jbe    .next                            ; bypass if x >= a (a <= x)
        @@.varg.accept                          ; accept if x < a
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.b.fpu
{
$usprocf @@varg.b

        @@.varg.enter
        dec     edx
        fld     qword [esi + edx * 8]           ; st0 = a
    .arg:
        fld     qword [esi]                     ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjge  .next                            ; bypass if x >= a
        @@.varg.accept                          ; accept if x < a
    .next:
        @@.varg.next
        fstp    st0
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.b.sse
$else
  @@varg.b.fpu
$end

; ------------------------------------------------------------------------------

; argument filter : x[i] <= a
; double varg.be (x[1], x[2], ... , x[N], a)
; variable number of arguments
; ecx -> argument count, min=2

macro @@varg.be.sse
{
$usprocf @@varg.be

        @@.varg.enter
        dec     edx
        movsd   xmm0, qword [esi + edx * 8]     ; xmm0 = a
    .arg:
        comisd  xmm0, qword [esi]               ; compare a to x
        jb     .next                            ; bypass if x > a (a < x)
        @@.varg.accept                          ; accept if x <= a
    .next:
        @@.varg.next
        @@.varg.leave

    .return:
        retn
$endp
}

macro @@varg.be.fpu
{
$usprocf @@varg.be

        @@.varg.enter
        dec     edx
        fld     qword [esi + edx * 8]           ; st0 = a
    .arg:
        fld     qword [esi]                     ; st0 = x[i] | st1 = a
        fcomp                                   ; compare x to a
        fnjg   .next                            ; bypass if x > a
        @@.varg.accept                          ; accept if x <= a
    .next:
        @@.varg.next
        fstp    st0
        @@.varg.leave

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@varg.be.sse
$else
  @@varg.be.fpu
$end

; ------------------------------------------------------------------------------
