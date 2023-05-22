
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number hyperbolic functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex hyperbolic sine
; z = a + i•b
; csinh(a,b)
; csinh(z) = sinh(a)*cos(b) + i•cosh(a)*sin(b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' = sinh(a)*cos(b)
; b' = cosh(a)*sin(b)

macro @@csinh.sse
{
$usprocf @@csinh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm3, xmm1                      ; xmm3 = b
        mov     edx, @@fshch.enter
        call    edx                             ; xmm0 = sinh(a) | xmm1 = cosh(a)
        @@.xch  xmm3, xmm0                      ; xmm0 = b       | xmm3 = sinh(a)
        movapd  xmm2, xmm1                      ; xmm2 = cosh(a)
        mov     edx, @@fcossin.enter
        call    edx                             ; xmm0 = cos(b)  | xmm1 = sin(b)
        mulsd   xmm0, xmm3                      ; xmm0 = sinh(a)*cos(b)
        mulsd   xmm1, xmm2                      ; xmm1 = cosh(a)*sin(b)
   .return:
        retn
$endp

macro @@.csinh.fpu
\{
$usprocf @@csinh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     edx, @@chsh.enter.fpu
        call    edx                             ; st0 = sh(a)  | st1 = ch(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = ch(a)  | st1 = sin(b) | st2 = sh(a)cos(b)
        fmulp                                   ; st0 = ch(a)sin(b) | st1 = sh(a)cos(b)
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}

$usprocf @@csinh.enter.fpu
                                                ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     edx, @@chsh.enter.fpu
        call    edx                             ; st0 = sh(a)  | st1 = ch(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = ch(a)  | st1 = sin(b) | st2 = sh(a)cos(b)
        fmulp                                   ; st0 = ch(a)sin(b) | st1 = sh(a)cos(b)
   .return:
        retn
$endp
}

macro @@csinh.fpu
{
$usprocf @@csinh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     edx, @@chsh.enter
        call    edx                             ; st0 = sh(a)  | st1 = ch(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = ch(a)  | st1 = sin(b) | st2 = sh(a)cos(b)
        fmulp                                   ; st0 = ch(a)sin(b) | st1 = sh(a)cos(b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csinh.sse
$else
  @@csinh.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic cosine
; z = a + i•b
; ccosh(a,b)
; ccosh(z) = cosh(a)*cos(b) + i•sinh(a)*sin(b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' = cosh(a)*cos(b)
; b' = sinh(a)*sin(b)

macro @@ccosh.sse
{
$usprocf @@ccosh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm3, xmm1                      ; xmm3 = b
        mov     edx, @@fshch.enter
        call    edx                             ; xmm0 = sinh(a) | xmm1 = cosh(a)
        @@.xch  xmm3, xmm0                      ; xmm0 = b       | xmm3 = sinh(a)
        movapd  xmm2, xmm1                      ; xmm2 = cosh(a)
        mov     edx, @@fcossin.enter
        call    edx                             ; xmm0 = cos(b)  | xmm1 = sin(b)
        mulsd   xmm0, xmm2                      ; xmm0 = cosh(a)*cos(b)
        mulsd   xmm1, xmm3                      ; xmm1 = sinh(a)*sin(b)
   .return:
        retn
$endp

macro @@.ccosh.fpu
\{
$usprocf @@ccosh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     edx, @@shch.enter.fpu
        call    edx                             ; st0 = ch(a)  | st1 = sh(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = sh(a)  | st1 = sin(b) | st2 = ch(a)cos(b)
        fmulp                                   ; st0 = sh(a)sin(b) | st1 = ch(a)cos(b)
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}

$asprocf @@ccosh.enter.fpu
                                                ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     edx, @@shch.enter.fpu
        call    edx                             ; st0 = ch(a)  | st1 = sh(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = sh(a)  | st1 = sin(b) | st2 = ch(a)cos(b)
        fmulp                                   ; st0 = sh(a)sin(b) | st1 = ch(a)cos(b)
   .return:
        retn
$endp
}

macro @@ccosh.fpu
{
$usprocf @@ccosh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     edx, @@shch.enter
        call    edx                             ; st0 = ch(a)  | st1 = sh(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = sh(a)  | st1 = sin(b) | st2 = ch(a)cos(b)
        fmulp                                   ; st0 = sh(a)sin(b) | st1 = ch(a)cos(b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccosh.sse
$else
  @@ccosh.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic secant
; z = a + i•b
; csech(a,b) = 1/ccosh(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@csech.sse
{
$usprocf @@csech

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     edx, @@ccosh.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp

macro @@.csech.fpu
\{
$usprocf @@csech

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@ccosh.enter.fpu
        call    edx
        mov     edx, @@cinv.enter.fpu
        call    edx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@csech.fpu
{
$usprocf @@csech

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@ccosh.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csech.sse
$else
  @@csech.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic cosecant
; z = a + i•b
; ccosech(a,b) = 1/csinh(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ccosech.sse
{
$usprocf @@ccosech

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     edx, @@csinh.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp

macro @@.ccosech.fpu
\{
$usprocf @@ccosech

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@csinh.enter.fpu
        call    edx
        mov     edx, @@cinv.enter.fpu
        call    edx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@ccosech.fpu
{
$usprocf @@ccosech

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@csinh.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccosech.sse
$else
  @@ccosech.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic tangent
; z = a + i•b
; ctanh(a,b) = csinh(a,b) / ccosh(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ctanh.sse
{
$usprocf @@ctanh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm6, xmm0
        movapd  xmm7, xmm1
        mov     edx, @@ccosh.enter
        call    edx
        @@.xch  xmm6, xmm0
        @@.xch  xmm7, xmm1
        mov     edx, @@csinh.enter
        call    edx
        movapd  xmm2, xmm6
        movapd  xmm3, xmm7
        mov     edx, @@cdiv.enter
        call    edx
   .return:
        retn
$endp

macro @@.ctanh.fpu
\{
$usprocf @@ctanh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccosh.enter.fpu
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csinh.enter.fpu
        call    edx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@cdivr.enter.fpu
        call    edx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@ctanh.fpu
{
$usprocf @@ctanh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccosh.enter
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csinh.enter
        call    edx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@cdivr.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ctanh.sse
$else
  @@ctanh.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic cotangent
; z = a + i•b
; ccotanh(a,b) = ccosh(a,b) / csinh(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ccotanh.sse
{
$usprocf @@ccotanh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm6, xmm0
        movapd  xmm7, xmm1
        mov     edx, @@csinh.enter
        call    edx
        @@.xch  xmm6, xmm0
        @@.xch  xmm7, xmm1
        mov     edx, @@ccosh.enter
        call    edx
        movapd  xmm2, xmm6
        movapd  xmm3, xmm7
        mov     edx, @@cdiv.enter
        call    edx
   .return:
        retn
$endp

macro @@.ccotanh.fpu
\{
$usprocf @@ccotanh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccosh.enter.fpu
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csinh.enter.fpu
        call    edx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@cdiv.enter.fpu
        call    edx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@ccotanh.fpu
{
$usprocf @@ccotanh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccosh.enter
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csinh.enter
        call    edx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@cdiv.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccotanh.sse
$else
  @@ccotanh.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse complex hyperbolic sine
; z = a + i•b
; casinh(z)
; ln(z + (z^2 + 1)^(1/2))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@casinh.sse.fpu
{
$usprocf @@casinh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter.fpu
        call    edx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     edx, @@croot2.enter.fpu
        call    edx                             ; (z^2+1)^(1/2)
        mov     edx, @@cadd.enter.fpu
        call    edx                             ; z+(z^2+1)^(1/2)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@casinh.fpu
{
$usprocf @@casinh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter
        call    edx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     edx, @@croot2.enter
        call    edx                             ; (z^2+1)^(1/2)
        mov     edx, @@cadd.enter
        call    edx                             ; z+(z^2+1)^(1/2)
        mov     edx, @@cln.enter
        call    edx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@casinh.sse.fpu
$else
  @@casinh.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic cosine
; z = a + i•b
; cacosh(z)
; ln(z + (z^2 - 1)^(1/2))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacosh.sse.fpu
{
$usprocf @@cacosh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter.fpu
        call    edx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     edx, @@croot2.enter.fpu
        call    edx                             ; (z^2-1)^(1/2)
        mov     edx, @@cadd.enter.fpu
        call    edx                             ; z+(z^2-1)^(1/2)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacosh.fpu
{
$usprocf @@cacosh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter
        call    edx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     edx, @@croot2.enter
        call    edx                             ; (z^2-1)^(1/2)
        mov     edx, @@cadd.enter
        call    edx                             ; z+(z^2-1)^(1/2)
        mov     edx, @@cln.enter
        call    edx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacosh.sse.fpu
$else
  @@cacosh.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic secant
; z = a + i•b
; casech(z) = cacosh(1/z)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@casech.sse.fpu
{
$usprocf @@casech

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@cinv.enter.fpu
        call    edx                             ; 1/z
   .cacosh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter.fpu
        call    edx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     edx, @@croot2.enter.fpu
        call    edx                             ; (z^2-1)^(1/2)
        mov     edx, @@cadd.enter.fpu
        call    edx                             ; z+(z^2-1)^(1/2)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@casech.fpu
{
$usprocf @@casech

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@cinv.enter
        call    edx                             ; 1/z
   .cacosh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter
        call    edx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     edx, @@croot2.enter
        call    edx                             ; (z^2-1)^(1/2)
        mov     edx, @@cadd.enter
        call    edx                             ; z+(z^2-1)^(1/2)
        mov     edx, @@cln.enter
        call    edx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@casech.sse.fpu
$else
  @@casech.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic cosecant
; z = a + i•b
; cacosech(z) = casinh(1/z)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacosech.sse.fpu
{
$usprocf @@cacosech

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@cinv.enter.fpu
        call    edx                             ; 1/z
   .casinh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter.fpu
        call    edx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     edx, @@croot2.enter.fpu
        call    edx                             ; (z^2+1)^(1/2)
        mov     edx, @@cadd.enter.fpu
        call    edx                             ; z+(z^2+1)^(1/2)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacosech.fpu
{
$usprocf @@cacosech

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@cinv.enter
        call    edx                             ; 1/z
   .casinh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     edx, @@cpow2.enter
        call    edx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     edx, @@croot2.enter
        call    edx                             ; (z^2+1)^(1/2)
        mov     edx, @@cadd.enter
        call    edx                             ; z+(z^2+1)^(1/2)
        mov     edx, @@cln.enter
        call    edx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacosech.sse.fpu
$else
  @@cacosech.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic tangent
; z = a + i•b
; catanh(z)
; (1/2)*ln((1+z)/(1-z))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@catanh.sse.fpu
{
$usprocf @@catanh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1
        fchs                                    ; st0:st1 = ~z | st2:st3 = z
                                                ; ~z = (-i•b+a)
        fld1                                    ; st0 = 1 | st1:st2 = ~z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = ~z | st3:st4 = 1+z
        fsubrp  st2, st0                        ; st0:st1 = 1-z | st2:st3 = 1+z
        mov     edx, @@cdiv.enter.fpu
        call    edx                             ; (1+z)/(1-z)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln((1+z)/(1-z))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((1+z)/(1-z))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@catanh.fpu
{
$usprocf @@catanh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1
        fchs                                    ; st0:st1 = ~z | st2:st3 = z
                                                ; ~z = (-i•b+a)
        fld1                                    ; st0 = 1 | st1:st2 = ~z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = ~z | st3:st4 = 1+z
        fsubrp  st2, st0                        ; st0:st1 = 1-z | st2:st3 = 1+z
        mov     edx, @@cdiv.enter
        call    edx                             ; (1+z)/(1-z)
        mov     edx, @@cln.enter
        call    edx                             ; ln((1+z)/(1-z))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((1+z)/(1-z))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@catanh.sse.fpu
$else
  @@catanh.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic cotangent
; z = a + i•b
; cacotanh(z)
; (1/2)*ln((z+1)/(z-1))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacotanh.sse.fpu
{
$usprocf @@cacotanh

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0:st1 = z | st2:st3 = z
        fld1                                    ; st0 = 1 | st1:st2 = z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = z | st3:st4 = z+1
        fsubp   st2, st0                        ; st0:st1 = z-1 | st2:st3 = z+1
        mov     edx, @@cdiv.enter.fpu
        call    edx                             ; (z+1)/(z-1)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln((z+1)/(z-1))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((z+1)/(z-1))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacotanh.fpu
{
$usprocf @@cacotanh

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1                             ; st0:st1 = z | st2:st3 = z
        fld1                                    ; st0 = 1 | st1:st2 = z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = z | st3:st4 = z+1
        fsubp   st2, st0                        ; st0:st1 = z-1 | st2:st3 = z+1
        mov     edx, @@cdiv.enter
        call    edx                             ; (z+1)/(z-1)
        mov     edx, @@cln.enter
        call    edx                             ; ln((z+1)/(z-1))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((z+1)/(z-1))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacotanh.sse.fpu
$else
  @@cacotanh.fpu
$end

; ------------------------------------------------------------------------------
