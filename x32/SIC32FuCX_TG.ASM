
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number trigonometric functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex sine
; z = a + i•b
; csin(a,b)
; csin(z) = sin(a)*cosh(b) + i•cos(a)*sinh(b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' = sin(a)*cosh(b)
; b' = cos(a)*sinh(b)

macro @@csin.sse
{
$usprocf @@csin

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm3, xmm1                      ; xmm3 = b
        mov     edx, @@fsincos.enter
        call    edx                             ; xmm0 = sin(a)  | xmm1 = cos(a)
        @@.xch  xmm3, xmm0                      ; xmm0 = b       | xmm3 = sin(a)
        movapd  xmm2, xmm1                      ; xmm2 = cos(a)
        mov     edx, @@fchsh.enter
        call    edx                             ; xmm0 = cosh(b) | xmm1 = sinh(b)
        mulsd   xmm0, xmm3                      ; xmm0 = sin(a)*cosh(b)
        mulsd   xmm1, xmm2                      ; xmm1 = cos(a)*sinh(b)
   .return:
        retn
$endp

macro @@.csin.fpu
\{
$usprocf @@csin

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        mov     edx, @@shch.enter.fpu
        call    edx                             ; st0 = ch(b)  | st1 = sh(b)  | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sh(b)  | st2 = ch(b)
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(a) | st1 = sin(a) | st2 = sh(b) | st3 = ch(b)
        fmulp   st2, st0                        ; st0 = sin(a) | st1 = cos(a)sh(b) | st2 = ch(b)
        fmulp   st2, st0                        ; st0 = cos(a)sh(b) | st1 = sin(a)ch(b)
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}

$asprocf @@csin.enter.fpu
                                                ; st0 = b      | st1 = a
        mov     edx, @@shch.enter.fpu
        call    edx                             ; st0 = ch(b)  | st1 = sh(b)  | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sh(b)  | st2 = ch(b)
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(a) | st1 = sin(a) | st2 = sh(b) | st3 = ch(b)
        fmulp   st2, st0                        ; st0 = sin(a) | st1 = cos(a)sh(b) | st2 = ch(b)
        fmulp   st2, st0                        ; st0 = cos(a)sh(b) | st1 = sin(a)ch(b)
   .return:
        retn
$endp
}

macro @@csin.fpu
{
$usprocf @@csin

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        mov     edx, @@shch.enter
        call    edx                             ; st0 = ch(b)  | st1 = sh(b)  | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sh(b)  | st2 = ch(b)
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(a) | st1 = sin(a) | st2 = sh(b) | st3 = ch(b)
        fmulp   st2, st0                        ; st0 = sin(a) | st1 = cos(a)sh(b) | st2 = ch(b)
        fmulp   st2, st0                        ; st0 = cos(a)sh(b) | st1 = sin(a)ch(b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csin.sse
$else
  @@csin.fpu
$end

; ------------------------------------------------------------------------------

; complex cosine
; z = a + i•b
; ccos(a,b)
; ccos(z) = cos(a)*cosh(b) - i•sin(a)*sinh(b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' =  cos(a)*cosh(b)
; b' = -sin(a)*sinh(b)

macro @@ccos.sse
{
$usprocf @@ccos

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm3, xmm1                      ; xmm3 = b
        mov     edx, @@fsincos.enter
        call    edx                             ; xmm0 = sin(a)  | xmm1 = cos(a)
        @@.xch  xmm3, xmm0                      ; xmm0 = b       | xmm3 = sin(a)
        movapd  xmm2, xmm1                      ; xmm2 = cos(a)
        mov     edx, @@fchsh.enter
        call    edx                             ; xmm0 = cosh(b) | xmm1 = sinh(b)
        mulsd   xmm0, xmm2                      ; xmm0 = cos(a)*cosh(b)
        mulsd   xmm1, xmm3                      ; xmm1 = sin(a)*sinh(b)
        @@.chs  xmm1                            ; xmm1 = -sin(a)*sinh(b)
   .return:
        retn
$endp

macro @@.ccos.fpu
\{
$usprocf @@ccos

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        mov     edx, @@shch.enter.fpu
        call    edx                             ; st0 = ch(b)  | st1 = sh(b)  | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sh(b)  | st2 = ch(b)
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(a) | st1 = sin(a) | st2 = sh(b) | st3 = ch(b)
        fmulp   st3, st0                        ; st0 = sin(a) | st1 = sh(b)  | st2 = cos(a)ch(b)
        fchs                                    ; st0 =-sin(a) | st1 = sh(b)  | st3 = cos(a)ch(b)
        fmulp                                   ; st0 =-sin(a)sh(b) | st1 = cos(a)ch(b)
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}

$asprocf @@ccos.enter.fpu
                                                ; st0 = b      | st1 = a
        mov     edx, @@shch.enter.fpu
        call    edx                             ; st0 = ch(b)  | st1 = sh(b)  | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sh(b)  | st2 = ch(b)
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(a) | st1 = sin(a) | st2 = sh(b) | st3 = ch(b)
        fmulp   st3, st0                        ; st0 = sin(a) | st1 = sh(b)  | st2 = cos(a)ch(b)
        fchs                                    ; st0 =-sin(a) | st1 = sh(b)  | st3 = cos(a)ch(b)
        fmulp                                   ; st0 =-sin(a)sh(b) | st1 = cos(a)ch(b)
   .return:
        retn
$endp
}

macro @@ccos.fpu
{
$usprocf @@ccos

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        mov     edx, @@shch.enter
        call    edx                             ; st0 = ch(b)  | st1 = sh(b)  | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sh(b)  | st2 = ch(b)
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(a) | st1 = sin(a) | st2 = sh(b) | st3 = ch(b)
        fmulp   st3, st0                        ; st0 = sin(a) | st1 = sh(b)  | st2 = cos(a)ch(b)
        fchs                                    ; st0 =-sin(a) | st1 = sh(b)  | st3 = cos(a)ch(b)
        fmulp                                   ; st0 =-sin(a)sh(b) | st1 = cos(a)ch(b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccos.sse
$else
  @@ccos.fpu
$end

; ------------------------------------------------------------------------------

; complex secant
; z = a + i•b
; csec(a,b) = 1/ccos(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@csec.sse
{
$usprocf @@csec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     edx, @@ccos.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp

macro @@.csec.fpu
\{
$usprocf @@csec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@ccos.enter.fpu
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

macro @@csec.fpu
{
$usprocf @@csec

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@ccos.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csec.sse
$else
  @@csec.fpu
$end

; ------------------------------------------------------------------------------

; complex cosecant
; z = a + i•b
; ccosec(a,b) = 1/csin(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ccosec.sse
{
$usprocf @@ccosec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     edx, @@csin.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp

macro @@.ccosec.fpu
\{
$usprocf @@ccosec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@csin.enter.fpu
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

macro @@ccosec.fpu
{
$usprocf @@ccosec

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@csin.enter
        call    edx
        mov     edx, @@cinv.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccosec.sse
$else
  @@ccosec.fpu
$end

; ------------------------------------------------------------------------------

; complex tangent
; z = a + i•b
; ctan(a,b) = csin(a,b) / ccos(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ctan.sse
{
$usprocf @@ctan

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm6, xmm0
        movapd  xmm7, xmm1
        mov     edx, @@ccos.enter
        call    edx
        @@.xch  xmm6, xmm0
        @@.xch  xmm7, xmm1
        mov     edx, @@csin.enter
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
$usprocf @@ctan

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccos.enter.fpu
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csin.enter.fpu
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

macro @@ctan.fpu
{
$usprocf @@ctan

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccos.enter
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csin.enter
        call    edx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@cdivr.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ctan.sse
$else
  @@ctan.fpu
$end

; ------------------------------------------------------------------------------

; complex cotangent
; z = a + i•b
; ccotan(a,b) = ccos(a,b) / csin(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ccotan.sse
{
$usprocf @@ccotan

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm6, xmm0
        movapd  xmm7, xmm1
        mov     edx, @@csin.enter
        call    edx
        @@.xch  xmm6, xmm0
        @@.xch  xmm7, xmm1
        mov     edx, @@ccos.enter
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
$usprocf @@ccotan

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccos.enter.fpu
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csin.enter.fpu
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

macro @@ccotan.fpu
{
$usprocf @@ccotan

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     edx, @@ccos.enter
        call    edx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@csin.enter
        call    edx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     edx, @@cdiv.enter
        call    edx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccotan.sse
$else
  @@ccotan.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse complex sine
; z = a + i•b
; casin(z)
; -i*ln(i*(z + (z^2 - 1)^(1/2)))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@casin.sse.fpu
{
$usprocf @@casin

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
        fchs
        fxch                                    ; i*(z+(z^2-1)^(1/2))
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln(i*(z+(z^2-1)^(1/2)))
        fxch
        fchs                                    ; (-i)*ln(i*(z+(z^2-1)^(1/2)))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@casin.fpu
{
$usprocf @@casin

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
        fchs
        fxch                                    ; i*(z+(z^2-1)^(1/2))
        mov     edx, @@cln.enter
        call    edx                             ; ln(i*(z+(z^2-1)^(1/2)))
        fxch
        fchs                                    ; (-i)*ln(i*(z+(z^2-1)^(1/2)))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@casin.sse.fpu
$else
  @@casin.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex cosine
; z = a + i•b
; cacos(z)
; -i*ln(z + (z^2 - 1)^(1/2))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacos.sse.fpu
{
$usprocf @@cacos

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
        fxch
        fchs                                    ; (-i)*ln(z+(z^2-1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacos.fpu
{
$usprocf @@cacos

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
        fxch
        fchs                                    ; (-i)*ln(z+(z^2-1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacos.sse.fpu
$else
  @@cacos.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex secant
; z = a + i•b
; casec(z) = cacos(1/z)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@casec.sse.fpu
{
$usprocf @@casec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@cinv.enter.fpu
        call    edx                             ; 1/z
   .cacos:
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
        fxch
        fchs                                    ; (-i)*ln(z+(z^2-1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@casec.fpu
{
$usprocf @@casec

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@cinv.enter
        call    edx                             ; 1/z
   .cacos:
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
        fxch
        fchs                                    ; (-i)*ln(z+(z^2-1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@casec.sse.fpu
$else
  @@casec.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex cosecant
; z = a + i•b
; cacosec(z) = casin(1/z)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacosec.sse.fpu
{
$usprocf @@cacosec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     edx, @@cinv.enter.fpu
        call    edx                             ; 1/z
   .casin:
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
        fchs
        fxch                                    ; i*(z+(z^2-1)^(1/2))
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln(i*(z+(z^2-1)^(1/2)))
        fxch
        fchs                                    ; (-i)*ln(i*(z+(z^2-1)^(1/2)))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacosec.fpu
{
$usprocf @@cacosec

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     edx, @@cinv.enter
        call    edx                             ; 1/z
   .casin:
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
        fchs
        fxch                                    ; i*(z+(z^2-1)^(1/2))
        mov     edx, @@cln.enter
        call    edx                             ; ln(i*(z+(z^2-1)^(1/2)))
        fxch
        fchs                                    ; (-i)*ln(i*(z+(z^2-1)^(1/2)))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacosec.sse.fpu
$else
  @@cacosec.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex tangent
; z = a + i•b
; catan(z)
; (1/2)*(-i)*ln((1+i*z)/(1-i*z))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@catan.sse.fpu
{
$usprocf @@catan

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fchs
        fxch                                    ; i*z = (i•a-b)
                                                ; st0 = a | st1 = -b
        fld     st1
        fld     st1
        fchs                                    ; st0:st1 = ~i*z | st2:st3 = i*z
                                                ; ~i*z = (-i•a-b)
        fld1                                    ; st0 = 1 | st1:st2 = ~i*z | st3:st4 = i*z
        fadd    st4, st0
        fsubrp  st2, st0                        ; st0:st1 = 1-i*z | st2:st3 = 1+i*z
        mov     edx, @@cdiv.enter.fpu
        call    edx                             ; (1+i*z)/(1-i*z)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln((1+i*z)/(1-i*z))
        fxch
        fchs                                    ; (-i)*ln((1+i*z)/(1-i*z))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*(-i)*ln((1+i*z)/(1-i*z))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@catan.fpu
{
$usprocf @@catan

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fchs
        fxch                                    ; i*z = (i•a-b)
                                                ; st0 = a | st1 = -b
        fld     st1
        fld     st1
        fchs                                    ; st0:st1 = ~i*z | st2:st3 = i*z
                                                ; ~i*z = (-i•a-b)
        fld1                                    ; st0 = 1 | st1:st2 = ~i*z | st3:st4 = i*z
        fadd    st4, st0
        fsubrp  st2, st0                        ; st0:st1 = 1-i*z | st2:st3 = 1+i*z
        mov     edx, @@cdiv.enter
        call    edx                             ; (1+i*z)/(1-i*z)
        mov     edx, @@cln.enter
        call    edx                             ; ln((1+i*z)/(1-i*z))
        fxch
        fchs                                    ; (-i)*ln((1+i*z)/(1-i*z))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*(-i)*ln((1+i*z)/(1-i*z))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@catan.sse.fpu
$else
  @@catan.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex cotangent
; z = a + i•b
; cacotan(z)
; (1/2)*i*ln((i*z+1)/(i*z-1))
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacotan.sse.fpu
{
$usprocf @@cacotan

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fchs
        fxch                                    ; i*z = (i•a-b)
        fld     st1
        fld     st1                             ; st0:st1 = i*z | st2:st3 = i*z
        fld1                                    ; st0 = 1 | st1:st2 = i*z | st3:st4 = i*z
        fadd    st4, st0
        fsubp   st2, st0                        ; st0:st1 = i*z-1 | st2:st3 = i*z+1
        mov     edx, @@cdiv.enter.fpu
        call    edx                             ; (i*z+1)/(i*z-1)
        mov     edx, @@cln.enter.fpu
        call    edx                             ; ln((i*z+1)/(i*z-1))
        fchs
        fxch                                    ; i*ln((i*z+1)/(i*z-1))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*i*ln((i*z+1)/(i*z-1))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacotan.fpu
{
$usprocf @@cacotan

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fchs
        fxch                                    ; i*z = (i•a-b)
        fld     st1
        fld     st1                             ; st0:st1 = i*z | st2:st3 = i*z
        fld1                                    ; st0 = 1 | st1:st2 = i*z | st3:st4 = i*z
        fadd    st4, st0
        fsubp   st2, st0                        ; st0:st1 = i*z-1 | st2:st3 = i*z+1
        mov     edx, @@cdiv.enter
        call    edx                             ; (i*z+1)/(i*z-1)
        mov     edx, @@cln.enter
        call    edx                             ; ln((i*z+1)/(i*z-1))
        fchs
        fxch                                    ; i*ln((i*z+1)/(i*z-1))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*i*ln((i*z+1)/(i*z-1))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacotan.sse.fpu
$else
  @@cacotan.fpu
$end

; ------------------------------------------------------------------------------
