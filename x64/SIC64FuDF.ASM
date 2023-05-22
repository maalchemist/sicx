
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (double value flags functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; double value flags
;
; 0x0000'8000 - sign flag
; 0x0000'0001 - zero flag
; 0x0000'0002 - infinity flag
; 0x0000'0004 - nan flag
; 0x0000'0008 - denormal flag
;
; 0x7FF0'???? - 11-bit exponent

; IsNan
; ((D and $7FF00000'00000000) == $7FF00000'00000000) and
; ((D and $000FFFFF'FFFFFFFF) <> $00000000'00000000)

; IsInfinite
; ((D and $7FF00000'00000000) == $7FF00000'00000000) and
; ((D and $000FFFFF'FFFFFFFF) == $00000000'00000000)

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; return xmm value flags and exponent in ecx

macro @@.xmm.flags.exp.ecx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.flags.exp.ecx

        push    rax rdx

    $ifdef _X64
        movq    rax, xmm
        mov     rcx, rax
        shr     rcx, 32
    $else
        movsd   [@mem], xmm
        mov     eax, [@mem]
        mov     ecx, [@mem + 4]
    $end
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, ecx
        mov     edx, eax
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, ecx
        mov     edx, eax
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      ecx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      ecx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        and     edx, 0x7FF00000
        or      ecx, edx                        ; set exponent
        ;
        pop     rdx rax
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm value flags in ecx

macro @@.xmm.flags.ecx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.flags.ecx

        push    rax

    $ifdef _X64
        movq    rax, xmm
        mov     rcx, rax
        shr     rcx, 32
    $else
        movsd   [@mem], xmm
        mov     eax, [@mem]
        mov     ecx, [@mem + 4]
    $end
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, ecx
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, ecx
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      ecx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      ecx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm value exponent in ecx

macro @@.xmm.exp.ecx xmm
{
        local   @mem
        @mem    EQU esp - 64

$asproc @@..#xmm#.exp.ecx

    $ifdef _X64
        movq    rcx, xmm
        shr     rcx, 64-12
    $else
        movsd   [@mem], xmm
        mov     ecx, [@mem + 4]
        shr     ecx, 32-12
    $end
        and     ecx, 0x07FF

   .return:
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm value sign and zero flags in ecx

macro @@.xmm.sz.flags.ecx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.sz.flags.ecx

        push    rax

    $ifdef _X64
        movq    rax, xmm
        mov     rcx, rax
        shr     rcx, 32
    $else
        movsd   [@mem], xmm
        mov     eax, [@mem]
        mov     ecx, [@mem + 4]
    $end
        test    eax, eax
        jz     .????????.00000000

   .????????.FFFFFFFF:
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        jmp    .return

   .????????.00000000:
        mov     eax, ecx
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        ;
        test    eax, 0x7FFFFFFF
        jnz    .return

   .Zero:                                       ; Zero
        or      ecx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp
}

; ------------------------------------------------------------------------------

; return xmm value flags and exponent in edx

macro @@.xmm.flags.exp.edx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.flags.exp.edx

        push    rax rcx

    $ifdef _X64
        movq    rax, xmm
        mov     rdx, rax
        shr     rdx, 32
    $else
        movsd   [@mem], xmm
        mov     eax, [@mem]
        mov     edx, [@mem + 4]
    $end
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, edx
        mov     ecx, eax
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, edx
        mov     ecx, eax
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      edx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      edx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        and     ecx, 0x7FF00000
        or      edx, ecx                        ; set exponent
        ;
        pop     rcx rax
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm value flags in edx

macro @@.xmm.flags.edx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.flags.edx

        push    rax

    $ifdef _X64
        movq    rax, xmm
        mov     rdx, rax
        shr     rdx, 32
    $else
        movsd   [@mem], xmm
        mov     eax, [@mem]
        mov     edx, [@mem + 4]
    $end
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, edx
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, edx
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      edx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      edx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm value exponent in edx

macro @@.xmm.exp.edx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.exp.edx

    $ifdef _X64
        movq    rdx, xmm
        shr     rdx, 64-12
    $else
        movsd   [@mem], xmm
        mov     edx, [@mem + 4]
        shr     edx, 32-12
    $end
        and     edx, 0x07FF

   .return:
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm value sign and zero flags in edx

macro @@.xmm.sz.flags.edx xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.sz.flags.edx

        push    rax

    $ifdef _X64
        movq    rax, xmm
        mov     rdx, rax
        shr     rdx, 32
    $else
        movsd   [@mem], xmm
        mov     eax, [@mem]
        mov     edx, [@mem + 4]
    $end
        test    eax, eax
        jz     .????????.00000000

   .????????.FFFFFFFF:
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        jmp    .return

   .????????.00000000:
        mov     eax, edx
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        ;
        test    eax, 0x7FFFFFFF
        jnz    .return

   .Zero:                                       ; Zero
        or      edx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; return xmm0 value flags and exponent in ecx

macro @@.xmm0.flags.exp.ecx
{
        mov     rcx, @@..xmm0.flags.exp.ecx
        call    rcx
}

@@.xmm.flags.exp.ecx xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm0 value flags in ecx

macro @@.xmm0.flags.ecx
{
        mov     rcx, @@..xmm0.flags.ecx
        call    rcx
}

@@.xmm.flags.ecx xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm0 value exponent in ecx

macro @@.xmm0.exp.ecx
{
        mov     rcx, @@..xmm0.exp.ecx
        call    rcx
}

@@.xmm.exp.ecx xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm0 value sign and zero flags in ecx

macro @@.xmm0.sz.flags.ecx
{
        mov     rcx, @@..xmm0.sz.flags.ecx
        call    rcx
}

@@.xmm.sz.flags.ecx xmm0

; ------------------------------------------------------------------------------

; return xmm0 value flags and exponent in edx

macro @@.xmm0.flags.exp.edx
{
        mov     rdx, @@..xmm0.flags.exp.edx
        call    rdx
}

@@.xmm.flags.exp.edx xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm0 value flags in edx

macro @@.xmm0.flags.edx
{
        mov     rdx, @@..xmm0.flags.edx
        call    rdx
}

@@.xmm.flags.edx xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm0 value exponent in edx

macro @@.xmm0.exp.edx
{
        mov     rdx, @@..xmm0.exp.edx
        call    rdx
}

@@.xmm.exp.edx xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm0 value sign and zero flags in edx

macro @@.xmm0.sz.flags.edx
{
        mov     rdx, @@..xmm0.sz.flags.edx
        call    rdx
}

@@.xmm.sz.flags.edx xmm0

; ------------------------------------------------------------------------------

; return xmm1 value flags and exponent in ecx

macro @@.xmm1.flags.exp.ecx
{
        mov     rcx, @@..xmm1.flags.exp.ecx
        call    rcx
}

@@.xmm.flags.exp.ecx xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm1 value flags in ecx

macro @@.xmm1.flags.ecx
{
        mov     rcx, @@..xmm1.flags.ecx
        call    rcx
}

@@.xmm.flags.ecx xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm1 value sign and zero flags in ecx

macro @@.xmm1.sz.flags.ecx
{
        mov     rcx, @@..xmm1.sz.flags.ecx
        call    rcx
}

@@.xmm.sz.flags.ecx xmm1

; ------------------------------------------------------------------------------

; return xmm1 value flags and exponent in edx

macro @@.xmm1.flags.exp.edx
{
        mov     rdx, @@..xmm1.flags.exp.edx
        call    rdx
}

@@.xmm.flags.exp.edx xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm1 value flags in edx

macro @@.xmm1.flags.edx
{
        mov     rdx, @@..xmm1.flags.edx
        call    rdx
}

@@.xmm.flags.edx xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return xmm1 value sign and zero flags in edx

macro @@.xmm1.sz.flags.edx
{
        mov     rdx, @@..xmm1.sz.flags.edx
        call    rdx
}

@@.xmm.sz.flags.edx xmm1

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; return st0 value flags and exponent in ecx

macro @@.st0.flags.exp.ecx
{
        mov     rcx, @@..st0.flags.exp.ecx
        call    rcx
}

$asproc @@..st0.flags.exp.ecx

       .mem     EQU rsp - 64

        push    rax rdx

        fst     qword [.mem]
        mov     eax, [.mem]
        mov     ecx, [.mem + 4]
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, ecx
        mov     edx, eax
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, ecx
        mov     edx, eax
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      ecx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      ecx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        and     edx, 0x7FF00000
        or      ecx, edx                        ; set exponent
        ;
        pop     rdx rax
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return st0 value flags in ecx

macro @@.st0.flags.ecx
{
        mov     rcx, @@..st0.flags.ecx
        call    rcx
}

$asproc @@..st0.flags.ecx

       .mem     EQU rsp - 64

        push    rax

        fst     qword [.mem]
        mov     eax, [.mem]
        mov     ecx, [.mem + 4]
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, ecx
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, ecx
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      ecx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      ecx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      ecx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return st0 value exponent in ecx

macro @@.st0.exp.ecx
{
        mov     rcx, @@..st0.exp.ecx
        call    rcx
}

$asproc @@..st0.exp.ecx

       .mem     EQU rsp - 64

        fst     qword [.mem]
        mov     ecx, [.mem + 4]
        shr     ecx, 32-12
        and     ecx, 0x07FF

   .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return st0 value sign and zero flags in ecx

macro @@.st0.sz.flags.ecx
{
        mov     rcx, @@..st0.sz.flags.ecx
        call    rcx
}

$asproc @@..st0.sz.flags.ecx

       .mem     EQU rsp - 64

        push    rax

        fst     qword [.mem]
        mov     eax, [.mem]
        mov     ecx, [.mem + 4]
        test    eax, eax
        jz     .????????.00000000

   .????????.FFFFFFFF:
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        jmp    .return

   .????????.00000000:
        mov     eax, ecx
        and     ecx, 0x80000000                 ; set sign flag
        shr     ecx, 16
        ;
        test    eax, 0x7FFFFFFF
        jnz    .return

   .Zero:                                       ; Zero
        or      ecx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp

; ------------------------------------------------------------------------------

; return st0 value flags and exponent in edx

macro @@.st0.flags.exp.edx
{
        mov     rdx, @@..st0.flags.exp.edx
        call    rdx
}

$asproc @@..st0.flags.exp.edx

       .mem     EQU rsp - 64

        push    rax rcx

        fst     qword [.mem]
        mov     eax, [.mem]
        mov     edx, [.mem + 4]
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, edx
        mov     ecx, eax
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, edx
        mov     ecx, eax
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      edx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      edx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        and     ecx, 0x7FF00000
        or      edx, ecx                        ; set exponent
        ;
        pop     rcx rax
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return st0 value flags in edx

macro @@.st0.flags.edx
{
        mov     rdx, @@..st0.flags.edx
        call    rdx
}

$asproc @@..st0.flags.edx

       .mem     EQU rsp - 64

        push    rax

        fst     qword [.mem]
        mov     eax, [.mem]
        mov     edx, [.mem + 4]
        test    eax, eax
        jnz    .????????.FFFFFFFF

   .????????.00000000:
        mov     eax, edx
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        ;
        test    eax, 0x7FFFFFFF
        jz     .Zero
        test    eax, 0x000FFFFF
        jnz    .???FFFFF.00000000

   .???00000.00000000:                          ; (D and $000FFFFF'FFFFFFFF) == $00000000'00000000
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .Inf:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000002                 ; set infinity flag
        jmp    .return

   .????????.FFFFFFFF:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        mov     eax, edx
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
   .???FFFFF.00000000:                          ; (D and $000FFFFF'FFFFFFFF) <> $00000000'00000000
        test    eax, 0x7FF00000
        jz     .Denorm
        and     eax, 0x7FF00000
        cmp     eax, 0x7FF00000
        jne    .return
   .NaN:                                        ; (D and $7FF00000'00000000) == $7FF00000'00000000
        or      edx, 0x00000004                 ; set nan flag
        jmp    .return

   .Denorm:
        or      edx, 0x00000008                 ; set denormal flag
        jmp    .return

   .Zero:                                       ; Zero
        or      edx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return st0 value exponent in edx

macro @@.st0.exp.edx
{
        mov     rcx, @@..st0.exp.edx
        call    rcx
}

$asproc @@..st0.exp.edx

       .mem     EQU rsp - 64

        fst     qword [.mem]
        mov     edx, [.mem + 4]
        shr     edx, 32-12
        and     edx, 0x07FF

   .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return st0 value sign and zero flags in edx

macro @@.st0.sz.flags.edx
{
        mov     rdx, @@..st0.sz.flags.edx
        call    rdx
}

$asproc @@..st0.sz.flags.edx

       .mem     EQU rsp - 64

        push    rax

        fst     qword [.mem]
        mov     eax, [.mem]
        mov     edx, [.mem + 4]
        test    eax, eax
        jz     .????????.00000000

   .????????.FFFFFFFF:
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        jmp    .return

   .????????.00000000:
        mov     eax, edx
        and     edx, 0x80000000                 ; set sign flag
        shr     edx, 16
        ;
        test    eax, 0x7FFFFFFF
        jnz    .return

   .Zero:                                       ; Zero
        or      edx, 0x00000001                 ; set zero flag
;       jmp    .return

   .return:
        pop     rax
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double value integer flags
;
; 0x0000'0001 - odd flag
; 0x0000'0002 - integer flag
; 0x0000'0004 - zero flag
; 0x0000'0008 - N.5 flag (D = N + 0.5)
; 0x0000'0010 - integer in-range flag
; 0x0000'8000 - sign flag

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; D = B*2^(p) + B*2^(p-1) + ... + B*2^(0) + B*2^(-1) + ... + B*2^(-n), B = 0|1
; <- rax - smallest power of 2 = (-n)
; <- edi - int flags

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm.int.flags.edi xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.int.flags.edi

    $ifdef _X64
        movq    rax, xmm
        mov     rdi, rax
        shr     rdi, 64-16
        and     rdi, 0x8000                     ; set sign flag
        mov     rdx, rax
        shr     rax, 52
        and     rax, 0x07FF
        jnz    .E
   .Denorm:
        inc     rax
   .E:
        cmp     rax, 1023+63
        jae    .E.main
   .In.Range:                                   ; |x| < 2^63
        or      rdi, 0x0010                     ; set integer in-range flag
   .E.main:
        sub     rax, 1023                       ; rax = exponent

   .D:
        mov     r10, 0x000FFFFFFFFFFFFF
        and     rdx, r10                        ; rdx = mantissa
        bsf     rdx, rdx
        jz     .R
        sub     rdx, 52
   .R:
        add     rax, rdx
        cmp     rax, -1023                      ; rax = -1023 -> Zero
        jne    .Not.Zero
   .Zero:
        xor     rax, rax
        or      rdi, 0x0006                     ; set zero and integer flags
        jmp    .return
   .Not.Zero:
        cmp     rax, 0                          ; rax >= 0 -> int
        jge    .Int
   .Not.Int:
        and     rdi, 0xFFEF                     ; clear integer in-range flag
        cmp     rax, -1
        jne    .return
   .Not.Int.5:
        or      rdi, 0x0008                     ; set N.5 flag
        jmp    .return
   .Int:
        or      rdi, 0x0002                     ; set integer flag
        test    rax, rax                        ; rax = 0 -> odd
        jnz    .return
   .Int.Odd:
        or      rdi, 0x0001                     ; set odd flag
    $else
      $ifdef _SSE4.1
        pextrd  eax, xmm, 1                     ; eax = D.HI
      $else
        movsd   qword [@mem], xmm
        mov     eax, [@mem + 4]                 ; eax = D.HI
      $end
        mov     edi, eax
        shr     edi, 16
        and     edi, 0x8000                     ; set sign flag
        shr     eax, 20
        and     eax, 0x07FF
        jnz    .E
   .Denorm:
        inc     eax
   .E:
        cmp     eax, 1023+31
        jae    .E.main
   .In.Range:                                   ; |x| < 2^31
        or      edi, 0x0010                     ; set integer in-range flag
   .E.main:
        sub     eax, 1023                       ; eax = exponent

   .D:
   .D_LO:
      $ifdef _SSE4.1
        pextrd  edx, xmm, 0                     ; edx = mantissa.LO
      $else
        mov     edx, [@mem]                     ; edx = mantissa.LO
      $end
        bsf     edx, edx
        jz     .D_HI
        sub     edx, 52
        jmp    .R

   .D_HI:
      $ifdef _SSE4.1
        pextrd  edx, xmm, 1
      $else
        mov     edx, [@mem + 4]
      $end
        and     edx, 0x000FFFFF                 ; edx = mantissa.HI
        bsf     edx, edx
        jz     .R
        sub     edx, 20
   .R:
        add     eax, edx
        cmp     eax, -1023                      ; eax = -1023 -> Zero
        jne    .Not.Zero
   .Zero:
        xor     eax, eax
        or      edi, 0x0006                     ; set zero and integer flags
        jmp    .return
   .Not.Zero:
        cmp     eax, 0                          ; eax >= 0 -> int
        jge    .Int
   .Not.Int:
        and     edi, 0xFFEF                     ; clear integer in-range flag
        cmp     eax, -1
        jne    .return
   .Not.Int.5:
        or      edi, 0x0008                     ; set N.5 flag
        jmp    .return
   .Int:
        or      edi, 0x0002                     ; set integer flag
        test    eax, eax                        ; eax = 0 -> odd
        jnz    .return
   .Int.Odd:
        or      edi, 0x0001                     ; set odd flag
    $end

   .return:
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm0.int.flags.edi
{
        mov     rdi, @@..xmm0.int.flags.edi
        call    rdi
}

@@.xmm.int.flags.edi xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm1.int.flags.edi
{
        mov     rdi, @@..xmm1.int.flags.edi
        call    rdi
}

@@.xmm.int.flags.edi xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm2.int.flags.edi
{
        mov     rdi, @@..xmm2.int.flags.edi
        call    rdi
}

@@.xmm.int.flags.edi xmm2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm4.int.flags.edi
{
        mov     rdi, @@..xmm4.int.flags.edi
        call    rdi
}

@@.xmm.int.flags.edi xmm4

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; <- edi - sign and odd flags

macro @@.xmm.so.flags.edi xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.so.flags.edi

    $ifdef _X64
        movq    rax, xmm
        mov     rdi, rax
        shr     rdi, 64-16
        and     rdi, 0x8000                     ; set sign flag
        mov     rdx, rax
        shr     rax, 52
        and     rax, 0x07FF                     ; rax = 0 -> zero or denorm
        jz     .return
   .E:
        sub     rax, 1023                       ; rax = exponent

   .D:
        mov     r10, 0x000FFFFFFFFFFFFF
        and     rdx, r10                        ; rdx = mantissa
        bsf     rdx, rdx
        jz     .R
        sub     rdx, 52
   .R:
        add     rax, rdx                        ; rax <> 0 -> not int or not odd
        jnz    .return
   .Int.Odd:
        or      rdi, 0x0001                     ; set odd flag
    $else
      $ifdef _SSE4.1
        pextrd  eax, xmm, 1                     ; eax = D.HI
      $else
        movsd   qword [@mem], xmm
        mov     eax, [@mem + 4]                 ; eax = D.HI
      $end
        mov     edi, eax
        shr     edi, 16
        and     edi, 0x8000                     ; set sign flag
        shr     eax, 20
        and     eax, 0x07FF                     ; eax = 0 -> zero or denorm
        jz     .return
   .E:
        sub     eax, 1023                       ; eax = exponent

   .D:
   .D_LO:
      $ifdef _SSE4.1
        pextrd  edx, xmm, 0                     ; edx = mantissa.LO
      $else
        mov     edx, [@mem]                     ; edx = mantissa.LO
      $end
        bsf     edx, edx
        jz     .D_HI
        sub     edx, 52
        jmp    .R

   .D_HI:
      $ifdef _SSE4.1
        pextrd  edx, xmm, 1
      $else
        mov     edx, [@mem + 4]
      $end
        and     edx, 0x000FFFFF                 ; edx = mantissa.HI
        bsf     edx, edx
        jz     .R
        sub     edx, 20
   .R:
        add     eax, edx                        ; eax <> 0 -> not int or not odd
        jnz    .return
   .Int.Odd:
        or      edi, 0x0001                     ; set odd flag
    $end

   .return:
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm0.so.flags.edi
{
        mov     rdi, @@..xmm0.so.flags.edi
        call    rdi
}

; @@.xmm.so.flags.edi xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm1.so.flags.edi
{
        mov     rdi, @@..xmm1.so.flags.edi
        call    rdi
}

; @@.xmm.so.flags.edi xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm2.so.flags.edi
{
        mov     rdi, @@..xmm2.so.flags.edi
        call    rdi
}

; @@.xmm.so.flags.edi xmm2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm4.so.flags.edi
{
        mov     rdi, @@..xmm4.so.flags.edi
        call    rdi
}

@@.xmm.so.flags.edi xmm4

; ------------------------------------------------------------------------------

macro @@.st0.int.flags.edi
{
        mov     rdi, @@..st0.int.flags.edi
        call    rdi
}

$asproc @@..st0.int.flags.edi

       .mem     EQU rsp - 64

        fst     qword [.mem]
    $ifdef _X64
        mov     rax, [.mem]
        mov     rdi, rax
        shr     rdi, 64-16
        and     rdi, 0x8000                     ; set sign flag
        mov     rdx, rax
        shr     rax, 52
        and     rax, 0x07FF
        jnz    .E
   .Denorm:
        inc     rax
   .E:
        cmp     rax, 1023+63
        jae    .E.main
   .In.Range:                                   ; |x| < 2^63
        or      rdi, 0x0010                     ; set integer in-range flag
   .E.main:
        sub     rax, 1023                       ; rax = exponent

   .D:
        mov     r10, 0x000FFFFFFFFFFFFF
        and     rdx, r10                        ; rdx = mantissa
        bsf     rdx, rdx
        jz     .R
        sub     rdx, 52
   .R:
        add     rax, rdx
        cmp     rax, -1023                      ; rax = -1023 -> Zero
        jne    .Not.Zero
   .Zero:
        xor     rax, rax
        or      rdi, 0x0006                     ; set zero and integer flags
        jmp    .return
   .Not.Zero:
        cmp     rax, 0                          ; rax >= 0 -> int
        jge    .Int
   .Not.Int:
        and     rdi, 0xFFEF                     ; clear integer in-range flag
        cmp     rax, -1
        jne    .return
   .Not.Int.5:
        or      rdi, 0x0008                     ; set N.5 flag
        jmp    .return
   .Int:
        or      rdi, 0x0002                     ; set integer flag
        test    rax, rax                        ; rax = 0 -> odd
        jnz    .return
   .Int.Odd:
        or      rdi, 0x0001                     ; set odd flag
    $else
        mov     eax, [.mem + 4]                 ; eax = D.HI
        mov     edi, eax
        shr     edi, 16
        and     edi, 0x8000                     ; set sign flag
        shr     eax, 20
        and     eax, 0x07FF
        jnz    .E
   .Denorm:
        inc     eax
   .E:
        cmp     eax, 1023+31
        jae    .E.main
   .In.Range:                                   ; |x| < 2^31
        or      edi, 0x0010                     ; set integer in-range flag
   .E.main:
        sub     eax, 1023                       ; eax = exponent

   .D:
   .D_LO:
        mov     edx, [.mem]                     ; edx = mantissa.LO
        bsf     edx, edx
        jz     .D_HI
        sub     edx, 52
        jmp    .R

   .D_HI:
        mov     edx, [.mem + 4]
        and     edx, 0x000FFFFF                 ; edx = mantissa.HI
        bsf     edx, edx
        jz     .R
        sub     edx, 20
   .R:
        add     eax, edx
        cmp     eax, -1023                      ; eax = -1023 -> Zero
        jne    .Not.Zero
   .Zero:
        xor     eax, eax
        or      edi, 0x0006                     ; set zero and integer flags
        jmp    .return
   .Not.Zero:
        cmp     eax, 0                          ; eax >= 0 -> int
        jge    .Int
   .Not.Int:
        and     edi, 0xFFEF                     ; clear integer in-range flag
        cmp     eax, -1
        jne    .return
   .Not.Int.5:
        or      edi, 0x0008                     ; set N.5 flag
        jmp    .return
   .Int:
        or      edi, 0x0002                     ; set integer flag
        test    eax, eax                        ; eax = 0 -> odd
        jnz    .return
   .Int.Odd:
        or      edi, 0x0001                     ; set odd flag
    $end

   .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; <- edi - sign and odd flags

macro @@.st0.so.flags.edi
{
        mov     rdi, @@..st0.so.flags.edi
        call    rdi
}

$asproc @@..st0.so.flags.edi

       .mem     EQU rsp - 64

        fst     qword [.mem]
    $ifdef _X64
        mov     rax, [.mem]
        mov     rdi, rax
        shr     rdi, 64-16
        and     rdi, 0x8000                     ; set sign flag
        mov     rdx, rax
        shr     rax, 52
        and     rax, 0x07FF                     ; rax = 0 -> zero or denorm
        jz     .return
   .E:
        sub     rax, 1023                       ; rax = exponent

   .D:
        mov     r10, 0x000FFFFFFFFFFFFF
        and     rdx, r10                        ; rdx = mantissa
        bsf     rdx, rdx
        jz     .R
        sub     rdx, 52
   .R:
        add     rax, rdx                        ; rax <> 0 -> not int or not odd
        jnz    .return
   .Int.Odd:
        or      rdi, 0x0001                     ; set odd flag
    $else
        mov     eax, [.mem + 4]                 ; eax = D.HI
        mov     edi, eax
        shr     edi, 16
        and     edi, 0x8000                     ; set sign flag
        shr     eax, 20
        and     eax, 0x07FF                     ; eax = 0 -> zero or denorm
        jz     .return
   .E:
        sub     eax, 1023                       ; eax = exponent

   .D:
   .D_LO:
        mov     edx, [.mem]                     ; edx = mantissa.LO
        bsf     edx, edx
        jz     .D_HI
        sub     edx, 52
        jmp    .R

   .D_HI:
        mov     edx, [.mem + 4]
        and     edx, 0x000FFFFF                 ; edx = mantissa.HI
        bsf     edx, edx
        jz     .R
        sub     edx, 20
   .R:
        add     eax, edx                        ; eax <> 0 -> not int or not odd
        jnz    .return
   .Int.Odd:
        or      edi, 0x0001                     ; set odd flag
    $end

   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double value sign flag
;
; 0x0000'8000 - sign flag

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; <- edi - sign flag

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm.sign.flag.edi xmm
{
        local   @mem
        @mem    EQU rsp - 64

$asproc @@..#xmm#.sign.flag.edi

    $ifdef _X64
        movq    rdi, xmm
        shr     rdi, 64-16
        and     rdi, 0x8000                     ; set sign flag
    $else
      $ifdef _SSE4.1
        pextrd  edi, xmm, 1                     ; edi = D.HI
      $else
        movsd   qword [@mem], xmm
        mov     edi, [@mem + 4]                 ; edi = D.HI
      $end
        shr     edi, 16
        and     edi, 0x8000                     ; set sign flag
    $end

   .return:
        retn
$endp
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm0.sign.flag.edi
{
        mov     rdi, @@..xmm0.sign.flag.edi
        call    rdi
}

; @@.xmm.sign.flag.edi xmm0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm1.sign.flag.edi
{
        mov     rdi, @@..xmm1.sign.flag.edi
        call    rdi
}

; @@.xmm.sign.flag.edi xmm1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm2.sign.flag.edi
{
        mov     rdi, @@..xmm2.sign.flag.edi
        call    rdi
}

; @@.xmm.sign.flag.edi xmm2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.xmm4.sign.flag.edi
{
        mov     rdi, @@..xmm4.sign.flag.edi
        call    rdi
}

; @@.xmm.sign.flag.edi xmm4

; ------------------------------------------------------------------------------

macro @@.st0.sign.flag.edi
{
        mov     rdi, @@..st0.sign.flag.edi
        call    rdi
}

macro c
{
$asproc @@..st0.sign.flag.edi

       .mem     EQU rsp - 64

        fst     qword [.mem]
    $ifdef _X64
        mov     rdi, [.mem]
        shr     rdi, 64-16
        and     rdi, 0x8000                     ; set sign flag
    $else
        mov     edi, [.mem + 4]                 ; edi = D.HI
        shr     edi, 16
        and     edi, 0x8000                     ; set sign flag
    $end

   .return:
        retn
$endp
}

; ------------------------------------------------------------------------------
