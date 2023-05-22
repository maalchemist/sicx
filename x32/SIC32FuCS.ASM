
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (case functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; case switch
; double case.e ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x=P[i] or
;         V|x  if no match
; scan from P1 to Pn

macro @@case.e.sse
{
$usprocf @@case.e

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        ucomisd xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jnz    .next.arg                        ; bypass : x != P[i]
        jp     .next.arg                        ; bypass : x != P[i]
    .V:
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@case.e.fpu
{
$usprocf @@case.e

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjne  .next.arg                        ; bypass : x != P[i]
        fstp    st0                             ; accept : x = P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.e.sse
$else
  @@case.e.fpu
$end

; ------------------------------------------------------------------------------

; reverse case switch
; double rcase.e ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x=P[i] or
;         V|x  if no match
; scan from Pn to P1

macro @@rcase.e.sse
{
$usprocf @@rcase.e

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        ucomisd xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jnz    .next.arg                        ; bypass : x != P[i]
        jp     .next.arg                        ; bypass : x != P[i]
    .V:
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@rcase.e.fpu
{
$usprocf @@rcase.e

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjne  .next.arg                        ; bypass : x != P[i]
        fstp    st0                             ; accept : x = P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rcase.e.sse
$else
  @@rcase.e.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.ne ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x!=P[i] or
;         V|x  if no match
; scan from P1 to Pn

macro @@case.ne.sse
{
$usprocf @@case.ne

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        ucomisd xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jnz    .V                               ; accept : x != P[i]
        jp     .V                               ; accept : x != P[i]
        jmp    .next.arg                        ; bypass : x = P[i]
    .V:
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@case.ne.fpu
{
$usprocf @@case.ne

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnje   .next.arg                        ; bypass : x = P[i]
        fstp    st0                             ; accept : x != P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.ne.sse
$else
  @@case.ne.fpu
$end

; ------------------------------------------------------------------------------

; reverse case switch
; double rcase.ne ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x!=P[i] or
;         V|x  if no match
; scan from Pn to P1

macro @@rcase.ne.sse
{
$usprocf @@rcase.ne

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        ucomisd xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jnz    .V                               ; accept : x != P[i]
        jp     .V                               ; accept : x != P[i]
        jmp    .next.arg                        ; bypass : x = P[i]
    .V:
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@rcase.ne.fpu
{
$usprocf @@rcase.ne

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnje   .next.arg                        ; bypass : x = P[i]
        fstp    st0                             ; accept : x != P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rcase.ne.sse
$else
  @@rcase.ne.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.a ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x>P[i] or
;         V|x  if no match
; scan from P1 to Pn

macro @@case.a.sse
{
$usprocf @@case.a

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jbe    .next.arg                        ; bypass : x <= P[i]
    .V:                                         ; accept : x > P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@case.a.fpu
{
$usprocf @@case.a

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjle  .next.arg                        ; bypass : x <= P[i]
        fstp    st0                             ; accept : x > P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.a.sse
$else
  @@case.a.fpu
$end

; ------------------------------------------------------------------------------

; reverse case switch
; double rcase.a ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x>P[i] or
;         V|x  if no match
; scan from Pn to P1

macro @@rcase.a.sse
{
$usprocf @@rcase.a

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jbe    .next.arg                        ; bypass : x <= P[i]
    .V:                                         ; accept : x > P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@rcase.a.fpu
{
$usprocf @@rcase.a

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjle  .next.arg                        ; bypass : x <= P[i]
        fstp    st0                             ; accept : x > P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rcase.a.sse
$else
  @@rcase.a.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.ae ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x>=P[i] or
;         V|x  if no match
; scan from P1 to Pn

macro @@case.ae.sse
{
$usprocf @@case.ae

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jb     .next.arg                        ; bypass : x < P[i]
    .V:                                         ; accept : x >= P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@case.ae.fpu
{
$usprocf @@case.ae

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjl   .next.arg                        ; bypass : x < P[i]
        fstp    st0                             ; accept : x >= P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.ae.sse
$else
  @@case.ae.fpu
$end

; ------------------------------------------------------------------------------

; reverse case switch
; double rcase.ae ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x>=P[i] or
;         V|x  if no match
; scan from Pn to P1

macro @@rcase.ae.sse
{
$usprocf @@rcase.ae

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jb     .next.arg                        ; bypass : x < P[i]
    .V:                                         ; accept : x >= P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@rcase.ae.fpu
{
$usprocf @@rcase.ae

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjl   .next.arg                        ; bypass : x < P[i]
        fstp    st0                             ; accept : x >= P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rcase.ae.sse
$else
  @@rcase.ae.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.b ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x<P[i] or
;         V|x  if no match
; scan from P1 to Pn

macro @@case.b.sse
{
$usprocf @@case.b

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jae    .next.arg                        ; bypass : x >= P[i]
    .V:                                         ; accept : x < P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@case.b.fpu
{
$usprocf @@case.b

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjge  .next.arg                        ; bypass : x >= P[i]
        fstp    st0                             ; accept : x < P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.b.sse
$else
  @@case.b.fpu
$end

; ------------------------------------------------------------------------------

; reverse case switch
; double rcase.b ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x<P[i] or
;         V|x  if no match
; scan from Pn to P1

macro @@rcase.b.sse
{
$usprocf @@rcase.b

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        jae    .next.arg                        ; bypass : x >= P[i]
    .V:                                         ; accept : x < P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@rcase.b.fpu
{
$usprocf @@rcase.b

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjge  .next.arg                        ; bypass : x >= P[i]
        fstp    st0                             ; accept : x < P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rcase.b.sse
$else
  @@rcase.b.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.be ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x<=P[i] or
;         V|x  if no match
; scan from P1 to Pn

macro @@case.be.sse
{
$usprocf @@case.be

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        ja     .next.arg                        ; bypass : x > P[i]
    .V:                                         ; accept : x <= P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@case.be.fpu
{
$usprocf @@case.be

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        add     edx, 2
        cmp     edx, ecx
        jg     .return                          ; return x
        jne    .compare
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjg   .next.arg                        ; bypass : x > P[i]
        fstp    st0                             ; accept : x <= P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.be.sse
$else
  @@case.be.fpu
$end

; ------------------------------------------------------------------------------

; reverse case switch
; double rcase.be ( x, P1, V1, P2, V2, ..., Pn, Vn, [V] )
; variable number of arguments
; ecx -> argument count, min=2
;
; returns V[i] if x<=P[i] or
;         V|x  if no match
; scan from Pn to P1

macro @@rcase.be.sse
{
$usprocf @@rcase.be

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        movsd   xmm0, qword [esp + ecx * 8 - 8] ; load default value
        jmp    .return
    .compare:
        comisd  xmm0, qword [esp + edx * 8 - 8] ; compare x to P[i]
        ja     .next.arg                        ; bypass : x > P[i]
    .V:                                         ; accept : x <= P[i]
        movsd   xmm0, qword [esp + edx * 8]     ; load V[i]

    .return:
        retn
$endp
}

macro @@rcase.be.fpu
{
$usprocf @@rcase.be

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        test    ecx, 1
        jz     .case                            ; jump if argument count is even
    .odd:                                       ; argument count is odd
        lea     edx, [ecx + 1]                  ; edx = argument count
        jmp    .next.arg
    .case:                                      ; st0 = x
        mov     edx, ecx                        ; edx = argument count
    .next.arg:
        sub     edx, 2
        jnz    .compare
        test    ecx, 1
        jnz    .return                          ; return x
        fstp    st0
        fld     qword [esp + ecx * 8 - 8]       ; load default value
        jmp    .return
    .compare:
        fcom    qword [esp + edx * 8 - 8]       ; compare x to P[i]
        fnjg   .next.arg                        ; bypass : x > P[i]
        fstp    st0                             ; accept : x <= P[i]
        fld     qword [esp + edx * 8]           ; load V[i]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rcase.be.sse
$else
  @@rcase.be.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; case switch
; double case.x32 ( double x, double y )
; x = esp
; y = esp + 8
;
; returns x if DLL is x32
;         y if DLL is not x32

macro @@case.x32.sse
{
$usprocf @@case.x32

        movsd   xmm0, qword [esp + 0]           ; xmm0 = x
    .return:
        retn
$endp
}

macro @@case.x32.fpu
{
$usprocf @@case.x32

        fld     qword [esp + 0]                 ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.x32.sse
$else
  @@case.x32.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@case.x32.enter.sse
{
$usprocf @@case.x32.enter

;       movsd   xmm0, qword [esp + 0]           ; xmm0 = x
;       movsd   xmm1, qword [esp + 8]           ; xmm1 = y
;   .enter:
;       movsd   xmm0, xmm0                      ; xmm0 = x
    .return:
        retn
$endp
}

macro @@case.x32.enter.fpu
{
$usprocf @@case.x32.enter

;       fld     qword [esp + 0]                 ; st0 = x
;       fld     qword [esp + 8]                 ; st0 = y | st1 = x
;   .enter:
        fstp    st0                             ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.x32.enter.sse
$else
  @@case.x32.enter.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.x32 ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns x if DLL is x32
;         y if DLL is not x32

macro @@_case.x32_int.sse
{
$usprocf @@_case.x32_int

        cvtsi2sd xmm0, dword [esp + 0]          ; xmm0 = x
    .return:
        retn
$endp
}

macro @@_case.x32_int.fpu
{
$usprocf @@_case.x32_int

        fild    dword [esp + 0]                 ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.x32_int.sse
$else
  @@_case.x32_int.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.x32 ( integer x, integer y )
; x = eax
; y = ecx
;
; returns x if DLL is x32
;         y if DLL is not x32

macro @@_case.x32_reg.sse
{
$usprocf @@_case.x32_reg

        cvtsi2sd xmm0, eax                      ; xmm0 = x
    .return:
        retn
$endp
}

macro @@_case.x32_reg.fpu
{
$usprocf @@_case.x32_reg

        mov     [esp - 4], eax
        fild    dword [esp - 4]                 ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.x32_reg.sse
$else
  @@_case.x32_reg.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.n32 ( double x, double y )
; x = esp
; y = esp + 8
;
; returns x if DLL is not x32
;         y if DLL is x32

macro @@case.n32.sse
{
$usprocf @@case.n32

        movsd   xmm0, qword [esp + 8]           ; xmm0 = y
    .return:
        retn
$endp
}

macro @@case.n32.fpu
{
$usprocf @@case.n32

        fld     qword [esp + 8]                 ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.n32.sse
$else
  @@case.n32.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@case.n32.enter.sse
{
$usprocf @@case.n32.enter

;       movsd   xmm0, qword [esp + 0]           ; xmm0 = x
;       movsd   xmm1, qword [esp + 8]           ; xmm1 = y
;   .enter:
        movsd   xmm0, xmm1                      ; xmm0 = y
    .return:
        retn
$endp
}

macro @@case.n32.enter.fpu
{
$usprocf @@case.n32.enter

;       fld     qword [esp + 0]                 ; st0 = x
;       fld     qword [esp + 8]                 ; st0 = y | st1 = x
;   .enter:
        fstp    st1                             ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.n32.enter.sse
$else
  @@case.n32.enter.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.n32 ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns x if DLL is not x32
;         y if DLL is x32

macro @@_case.n32_int.sse
{
$usprocf @@_case.n32_int

        cvtsi2sd xmm0, dword [esp + 4]          ; xmm0 = y
    .return:
        retn
$endp
}

macro @@_case.n32_int.fpu
{
$usprocf @@_case.n32_int

        fild    dword [esp + 4]                 ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.n32_int.sse
$else
  @@_case.n32_int.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.n32 ( integer x, integer y )
; x = eax
; y = ecx
;
; returns x if DLL is not x32
;         y if DLL is x32

macro @@_case.n32_reg.sse
{
$usprocf @@_case.n32_reg

        cvtsi2sd xmm0, ecx                      ; xmm0 = y
    .return:
        retn
$endp
}

macro @@_case.n32_reg.fpu
{
$usprocf @@_case.n32_reg

        mov     [esp - 4], ecx
        fild    dword [esp - 4]                 ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.n32_reg.sse
$else
  @@_case.n32_reg.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.x64 ( double x, double y )
; x = esp
; y = esp + 8
;
; returns x if DLL is x64
;         y if DLL is not x64

macro @@case.x64.sse
{
$usprocf @@case.x64

        movsd   xmm0, qword [esp + 8]           ; xmm0 = y
    .return:
        retn
$endp
}

macro @@case.x64.fpu
{
$usprocf @@case.x64

        fld     qword [esp + 8]                 ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.x64.sse
$else
  @@case.x64.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@case.x64.enter.sse
{
$usprocf @@case.x64.enter

;       movsd   xmm0, qword [esp + 0]           ; xmm0 = x
;       movsd   xmm1, qword [esp + 8]           ; xmm1 = y
;   .enter:
        movsd   xmm0, xmm1                      ; xmm0 = y
    .return:
        retn
$endp
}

macro @@case.x64.enter.fpu
{
$usprocf @@case.x64.enter

;       fld     qword [esp + 0]                 ; st0 = x
;       fld     qword [esp + 8]                 ; st0 = y | st1 = x
;   .enter:
        fstp    st1                             ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.x64.enter.sse
$else
  @@case.x64.enter.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.x64 ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns x if DLL is x64
;         y if DLL is not x64

macro @@_case.x64_int.sse
{
$usprocf @@_case.x64_int

        cvtsi2sd xmm0, dword [esp + 4]          ; xmm0 = y
    .return:
        retn
$endp
}

macro @@_case.x64_int.fpu
{
$usprocf @@_case.x64_int

        fild    dword [esp + 4]                 ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.x64_int.sse
$else
  @@_case.x64_int.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.x64 ( integer x, integer y )
; x = eax
; y = ecx
;
; returns x if DLL is x64
;         y if DLL is not x64

macro @@_case.x64_reg.sse
{
$usprocf @@_case.x64_reg

        cvtsi2sd xmm0, ecx                      ; xmm0 = y
    .return:
        retn
$endp
}

macro @@_case.x64_reg.fpu
{
$usprocf @@_case.x64_reg

        mov     [esp - 4], ecx
        fild    dword [esp - 4]                 ; st0 = y
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.x64_reg.sse
$else
  @@_case.x64_reg.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.n64 ( double x, double y )
; x = esp
; y = esp + 8
;
; returns x if DLL is not x64
;         y if DLL is x64

macro @@case.n64.sse
{
$usprocf @@case.n64

        movsd   xmm0, qword [esp + 0]           ; xmm0 = x
    .return:
        retn
$endp
}

macro @@case.n64.fpu
{
$usprocf @@case.n64

        fld     qword [esp + 0]                 ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.n64.sse
$else
  @@case.n64.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@case.n64.enter.sse
{
$usprocf @@case.n64.enter

;       movsd   xmm0, qword [esp + 0]           ; xmm0 = x
;       movsd   xmm1, qword [esp + 8]           ; xmm1 = y
;   .enter:
;       movsd   xmm0, xmm0                      ; xmm0 = x
    .return:
        retn
$endp
}

macro @@case.n64.enter.fpu
{
$usprocf @@case.n64.enter

;       fld     qword [esp + 0]                 ; st0 = x
;       fld     qword [esp + 8]                 ; st0 = y | st1 = x
;   .enter:
        fstp    st0                             ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@case.n64.enter.sse
$else
  @@case.n64.enter.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.n64 ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns x if DLL is not x64
;         y if DLL is x64

macro @@_case.n64_int.sse
{
$usprocf @@_case.n64_int

        cvtsi2sd xmm0, dword [esp + 0]          ; xmm0 = x
    .return:
        retn
$endp
}

macro @@_case.n64_int.fpu
{
$usprocf @@_case.n64_int

        fild    dword [esp + 0]                 ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.n64_int.sse
$else
  @@_case.n64_int.fpu
$end

; ------------------------------------------------------------------------------

; case switch
; double case.n64 ( integer x, integer y )
; x = eax
; y = ecx
;
; returns x if DLL is not x64
;         y if DLL is x64

macro @@_case.n64_reg.sse
{
$usprocf @@_case.n64_reg

        cvtsi2sd xmm0, eax                      ; xmm0 = x
    .return:
        retn
$endp
}

macro @@_case.n64_reg.fpu
{
$usprocf @@_case.n64_reg

        mov     [esp - 4], eax
        fild    dword [esp - 4]                 ; st0 = x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_case.n64_reg.sse
$else
  @@_case.n64_reg.fpu
$end

; ------------------------------------------------------------------------------
