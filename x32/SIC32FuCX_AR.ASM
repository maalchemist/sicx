
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number arithmetic functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex addition
; z1 = a + i•b
; z2 = c + i•d
; cadd(a,b,c,d) = (a + c) + i•(b + d)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a' = a + c
; return_2 = st0 = b' = b + d

macro @@cadd.sse
{
$usprocf @@cadd

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        addsd   xmm0, xmm2                      ; xmm0 = a+c
        addsd   xmm1, xmm3                      ; xmm1 = b+d
   .return:
        retn
$endp
}

macro @@cadd.sse.V2
{
$usprocf @@cadd

        movupd  xmm0, dqword [esp]              ; xmm0 = a : b
        movupd  xmm1, dqword [esp + 16]         ; xmm1 = c : d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        addpd   xmm0, xmm1                      ; xmm0 = a+c : b+d
        movapd  xmm1, xmm0                      ; xmm1 = a+c : b+d
;       psrldq  xmm1, 8                         ; xmm1 = b+d : 0
        shufpd  xmm1, xmm1, 1                   ; xmm1 = b+d : a+c
   .return:
        retn
$endp
}

macro @@cadd.sse.fpu
{
$asprocf @@cadd.enter.fpu
                                                ; st0 = d   | st1 = c   | st2 = b | st3 = a
        faddp   st2, st0                        ; st0 = c   | st1 = b+d | st2 = a
        faddp   st2, st0                        ; st0 = b+d | st1 = a+c
   .return:
        retn
$endp
}

macro @@cadd.fpu
{
$usprocf @@cadd

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d   | st1 = c   | st2 = b | st3 = a
        faddp   st2, st0                        ; st0 = c   | st1 = b+d | st2 = a
        faddp   st2, st0                        ; st0 = b+d | st1 = a+c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cadd.sse
  @@cadd.sse.fpu
$else
  @@cadd.fpu
$end

; ------------------------------------------------------------------------------

; complex addition of real number
; z = a + i•b
; cradd(a,b,c) = (a + i•b) + c = (a + c) + i•b
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = a + c
; return_2 = st0 = b' = b

macro @@cradd.sse
{
$usprocf @@cradd

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        addsd   xmm0, xmm2                      ; xmm0 = a+c
   .return:
        retn
$endp
}

macro @@cradd.fpu
{
$usprocf @@cradd

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c | st1 = b | st2 = a
        faddp   st2, st0                        ; st0 = b | st1 = a+c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cradd.sse
$else
  @@cradd.fpu
$end

; ------------------------------------------------------------------------------

; complex addition of imaginary number
; z = a + i•b
; ciadd(a,b,c) = (a + i•b) + i•c = a + i•(b + c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = b + c

macro @@ciadd.sse
{
$usprocf @@ciadd

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        addsd   xmm1, xmm2                      ; xmm1 = b+c
   .return:
        retn
$endp
}

macro @@ciadd.fpu
{
$usprocf @@ciadd

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        faddp   st1, st0                        ; st0 = b+c | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ciadd.sse
$else
  @@ciadd.fpu
$end

; ------------------------------------------------------------------------------

; complex addition of 1
; z = a + i•b
; cinc(a,b) = (a + i•b) + 1 = (a + 1) + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = a + 1
; return_2 = st0 = b' = b

macro @@cinc.sse
{
$usprocf @@cinc

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xaddsd  xmm0, ??.1.0                    ; xmm0 = a+1
   .return:
        retn
$endp
}

macro @@cinc.fpu
{
$usprocf @@cinc

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld1                                    ; st0 = 1 | st1 = b   | st2 = a
        faddp   st2, st0                        ; st0 = b | st1 = a+1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cinc.sse
$else
  @@cinc.fpu
$end

; ------------------------------------------------------------------------------

; complex addition of i
; z = a + i•b
; caddi(a,b) = (a + i•b) + i = a + i•(b + 1)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = b + 1

macro @@caddi.sse
{
$usprocf @@caddi

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xaddsd  xmm1, ??.1.0                    ; xmm1 = b+1
   .return:
        retn
$endp
}

macro @@caddi.fpu
{
$usprocf @@caddi

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld1
        faddp                                   ; st0 = b+1 | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@caddi.sse
$else
  @@caddi.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex subtraction
; z1 = a + i•b
; z2 = c + i•d
; csub(a,b,c,d) = (a - c) + i•(b - d)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a' = a - c
; return_2 = st0 = b' = b - d

macro @@csub.sse
{
$usprocf @@csub

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        subsd   xmm0, xmm2                      ; xmm0 = a-c
        subsd   xmm1, xmm3                      ; xmm1 = b-d
   .return:
        retn
$endp
}

macro @@csub.sse.V2
{
$usprocf @@csub

        movupd  xmm0, dqword [esp]              ; xmm0 = a : b
        movupd  xmm1, dqword [esp + 16]         ; xmm1 = c : d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        subpd   xmm0, xmm1                      ; xmm0 = a-c : b-d
        movapd  xmm1, xmm0                      ; xmm1 = a-c : b-d
;       psrldq  xmm1, 8                         ; xmm1 = b-d : 0
        shufpd  xmm1, xmm1, 1                   ; xmm1 = b-d : a-c
   .return:
        retn
$endp
}

macro @@csub.fpu
{
$usprocf @@csub

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d   | st1 = c   | st2 = b | st3 = a
        fsubp   st2, st0                        ; st0 = c   | st1 = b-d | st2 = a
        fsubp   st2, st0                        ; st0 = b-d | st1 = a-c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csub.sse
$else
  @@csub.fpu
$end

; ------------------------------------------------------------------------------

; complex subtraction of real number
; z = a + i•b
; crsub(a,b,c) = (a + i•b) - c = (a - c) + i•b
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = a - c
; return_2 = st0 = b' = b

macro @@crsub.sse
{
$usprocf @@crsub

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        subsd   xmm0, xmm2                      ; xmm0 = a-c
   .return:
        retn
$endp
}

macro @@crsub.fpu
{
$usprocf @@crsub

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c | st1 = b | st2 = a
        fsubp   st2, st0                        ; st0 = b | st1 = a-c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crsub.sse
$else
  @@crsub.fpu
$end

; ------------------------------------------------------------------------------

; complex subtraction of imaginary number
; z = a + i•b
; cisub(a,b,c) = (a + i•b) - i•c = a + i•(b - c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = b - c

macro @@cisub.sse
{
$usprocf @@cisub

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        subsd   xmm1, xmm2                      ; xmm1 = b-c
   .return:
        retn
$endp
}

macro @@cisub.fpu
{
$usprocf @@cisub

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        fsubp   st1, st0                        ; st0 = b-c | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cisub.sse
$else
  @@cisub.fpu
$end

; ------------------------------------------------------------------------------

; complex subtraction of 1
; z = a + i•b
; cdec(a,b) = (a + i•b) - 1 = (a - 1) + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = a - 1
; return_2 = st0 = b' = b

macro @@cdec.sse
{
$usprocf @@cdec

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xsubsd  xmm0, ??.1.0                    ; xmm0 = a-1
   .return:
        retn
$endp
}

macro @@cdec.fpu
{
$usprocf @@cdec

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld1                                    ; st0 = 1 | st1 = b   | st2 = a
        fsubp   st2, st0                        ; st0 = b | st1 = a-1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cdec.sse
$else
  @@cdec.fpu
$end

; ------------------------------------------------------------------------------

; complex subtraction of i
; z = a + i•b
; csubi(a,b) = (a + i•b) - i = a + i•(b - 1)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = b - 1

macro @@csubi.sse
{
$usprocf @@csubi

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xsubsd  xmm1, ??.1.0                    ; xmm1 = b-1
   .return:
        retn
$endp
}

macro @@csubi.fpu
{
$usprocf @@csubi

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld1
        fsubp                                   ; st0 = b-1 | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csubi.sse
$else
  @@csubi.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reverse complex subtraction
; z1 = a + i•b
; z2 = c + i•d
; csubr(a,b,c,d) = (c - a) + i•(d - b)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a' = c - a
; return_2 = st0 = b' = d - b

macro @@csubr.sse
{
$usprocf @@csubr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        subsd   xmm2, xmm0
        subsd   xmm3, xmm1
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@csubr.sse.V2
{
$usprocf @@csubr

        movupd  xmm0, dqword [esp]              ; xmm0 = a : b
        movupd  xmm1, dqword [esp + 16]         ; xmm1 = c : d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        subpd   xmm1, xmm0                      ; xmm1 = c-a : d-b
        movapd  xmm0, xmm1                      ; xmm0 = c-a : d-b
;       psrldq  xmm1, 8                         ; xmm1 = d-b : 0
        shufpd  xmm1, xmm1, 1                   ; xmm1 = d-b : c-a
   .return:
        retn
$endp
}

macro @@csubr.fpu
{
$usprocf @@csubr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d   | st1 = c   | st2 = b | st3 = a
        fsubrp  st2, st0                        ; st0 = c   | st1 = d-b | st2 = a
        fsubrp  st2, st0                        ; st0 = d-b | st1 = c-a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csubr.sse
$else
  @@csubr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex subtraction of real number
; z = a + i•b
; crsubr(a,b,c) = c - (a + i•b) = (c - a) + i•(-b)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = c - a
; return_2 = st0 = b' = -b

macro @@crsubr.sse
{
$usprocf @@crsubr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        xorpd   xmm3, xmm3
        subsd   xmm2, xmm0
        subsd   xmm3, xmm1
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@crsubr.fpu
{
$usprocf @@crsubr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c  | st1 = b | st2 = a
        fsubrp  st2, st0                        ; st0 = b  | st1 = c-a
        fchs                                    ; st0 = -b | st1 = c-a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crsubr.sse
$else
  @@crsubr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex subtraction of imaginary number
; z = a + i•b
; cisubr(a,b,c) = i•c - (a + i•b) = (-a) + i•(c - b)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = -a
; return_2 = st0 = b' = c - b

macro @@cisubr.sse
{
$usprocf @@cisubr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        xorpd   xmm3, xmm3
        subsd   xmm3, xmm0
        subsd   xmm2, xmm1
        movsd   xmm0, xmm3
        movsd   xmm1, xmm2
   .return:
        retn
$endp
}

macro @@cisubr.fpu
{
$usprocf @@cisubr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        fsubrp  st1, st0                        ; st0 = c-b | st1 = a
        fxch                                    ; st0 = a   | st1 = c-b
        fchs                                    ; st0 = -a  | st1 = c-b
        fxch                                    ; st0 = c-b | st1 = -a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cisubr.sse
$else
  @@cisubr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex subtraction of 1
; z = a + i•b
; cdecr(a,b) = 1 - (a + i•b) = (1 - a) + i•(-b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = 1 - a
; return_2 = st0 = b' = -b

macro @@cdecr.sse
{
$usprocf @@cdecr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm2, ??.1.0
        xorpd   xmm3, xmm3
        subsd   xmm2, xmm0
        subsd   xmm3, xmm1
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@cdecr.fpu
{
$usprocf @@cdecr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b  | st1 = a
        fld1                                    ; st0 = 1  | st1 = b   | st2 = a
        fsubrp  st2, st0                        ; st0 = b  | st1 = 1-a
        fchs                                    ; st0 = -b | st1 = 1-a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cdecr.sse
$else
  @@cdecr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex subtraction of i
; z = a + i•b
; csubri(a,b) = i - (a + i•b) = (-a) + i•(1 - b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = -a
; return_2 = st0 = b' = 1 - b

macro @@csubri.sse
{
$usprocf @@csubri

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm2, xmm2
        xmovsd  xmm3, ??.1.0
        subsd   xmm2, xmm0
        subsd   xmm3, xmm1
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@csubri.fpu
{
$usprocf @@csubri

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fxch                                    ; st0 = a   | st1 = b
        fchs                                    ; st0 = -a  | st1 = b
        fxch                                    ; st0 = b   | st1 = -a
        fld1
        fsubrp                                  ; st0 = 1-b | st1 = -a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csubri.sse
$else
  @@csubri.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex multiplication
; z1 = a + i•b
; z2 = c + i•d
; cmul(a,b,c,d) = (a*c - b*d) + i•(a*d + b*c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a' = (a*c - b*d)
; return_2 = st0 = b' = (a*d + b*c)

macro @@cmul.sse
{
$usprocf @@cmul

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        movsd   xmm4, xmm0                      ; xmm4 = a
        movsd   xmm5, xmm1                      ; xmm5 = b
        mulsd   xmm0, xmm2                      ; xmm0 = a*c
        mulsd   xmm1, xmm2                      ; xmm1 = b*c
        mulsd   xmm4, xmm3                      ; xmm4 = a*d
        mulsd   xmm5, xmm3                      ; xmm5 = b*d
        subsd   xmm0, xmm5                      ; xmm0 = a*c-b*d
        addsd   xmm1, xmm4                      ; xmm1 = a*d+b*c
   .return:
        retn
$endp
}

macro @@cmul.sse.V2
{
$usprocf @@cmul

        movupd  xmm0, dqword [esp]              ; xmm0 = a : b
        movupd  xmm1, dqword [esp + 16]         ; xmm1 = c : d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm2, xmm1                      ; xmm2 = c : d
        shufpd  xmm1, xmm1, 1                   ; xmm1 = d : c
        mulpd   xmm1, xmm0                      ; xmm1 = a*d : b*c
        mulpd   xmm0, xmm2                      ; xmm0 = a*c : b*d
    $ifdef _SSE3
        hsubpd  xmm0, xmm0                      ; xmm0 = a*c - b*d
        haddpd  xmm1, xmm1                      ; xmm1 = a*d + b*c
    $else
        oops haddpd hsubpd
    $end
   .return:
        retn
$endp
}

macro @@cmul.sse.fpu
{
$asprocf @@cmul.enter.fpu
                                                ; st0 = d   | st1 = c   | st2 = b   | st3 = a
        fld     st3                             ; st0 = a   | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st2                             ; st0 = c   | st1 = a   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fmulp                                   ; st0 = a*c | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st3                             ; st0 = b   | st1 = a*c | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st2                             ; st0 = d   | st1 = b   | st2 = a*c | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fmulp                                   ; st0 = b*d | st1 = a*c | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fsubp                                   ; st0 = a'  | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fxch    st4                             ; st0 = a   | st1 = d   | st2 = c   | st3 = b   | st4 = a'
        fmulp                                   ; st0 = a*d | st1 = c   | st2 = b   | st3 = a'
        fxch    st2                             ; st0 = b   | st1 = c   | st2 = a*d | st3 = a'
        fmulp                                   ; st0 = b*c | st1 = a*d | st2 = a'
        faddp                                   ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

macro @@cmul.fpu
{
$usprocf @@cmul

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d   | st1 = c   | st2 = b   | st3 = a
        fld     st3                             ; st0 = a   | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st2                             ; st0 = c   | st1 = a   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fmulp                                   ; st0 = a*c | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st3                             ; st0 = b   | st1 = a*c | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st2                             ; st0 = d   | st1 = b   | st2 = a*c | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fmulp                                   ; st0 = b*d | st1 = a*c | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fsubp                                   ; st0 = a'  | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fxch    st4                             ; st0 = a   | st1 = d   | st2 = c   | st3 = b   | st4 = a'
        fmulp                                   ; st0 = a*d | st1 = c   | st2 = b   | st3 = a'
        fxch    st2                             ; st0 = b   | st1 = c   | st2 = a*d | st3 = a'
        fmulp                                   ; st0 = b*c | st1 = a*d | st2 = a'
        faddp                                   ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cmul.sse
  @@cmul.sse.fpu
$else
  @@cmul.fpu
$end

; ------------------------------------------------------------------------------

; complex multiplication by real number
; z = a + i•b
; crmul(a,b,c) = (a + i•b)*c = (a*c) + i•(b*c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = a*c
; return_2 = st0 = b' = b*c

macro @@crmul.sse
{
$usprocf @@crmul

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        mulsd   xmm0, xmm2
        mulsd   xmm1, xmm2
   .return:
        retn
$endp
}

macro @@crmul.fpu
{
$usprocf @@crmul

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        fmul    st2, st0                        ; st0 = c   | st1 = b | st2 = a*c
        fmulp                                   ; st0 = b*c | st1 = a*c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crmul.sse
$else
  @@crmul.fpu
$end

; ------------------------------------------------------------------------------

; complex multiplication by imaginary number
; z = a + i•b
; cimul(a,b,c) = i•c*(a + i•b) = (-b*c) + i•(a*c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = -b*c
; return_2 = st0 = b' = a*c

macro @@cimul.sse
{
$usprocf @@cimul

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        mulsd   xmm1, xmm2                      ; xmm1 = b*c
        mulsd   xmm2, xmm0                      ; xmm2 = a*c
        xorpd   xmm0, xmm0
        subsd   xmm0, xmm1                      ; xmm0 = -b*c
        movsd   xmm1, xmm2                      ; xmm1 = a*c
   .return:
        retn
$endp
}

macro @@cimul.fpu
{
$usprocf @@cimul

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c    | st1 = b | st2 = a
        fmul    st2, st0                        ; st0 = c    | st1 = b | st2 = a*c
        fchs                                    ; st0 = -c   | st1 = b | st2 = a*c
        fmulp                                   ; st0 = -b*c | st1 = a*c
        fxch                                    ; st0 = a*c  | st1 = -b*c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cimul.sse
$else
  @@cimul.fpu
$end

; ------------------------------------------------------------------------------

; complex multiplication by i
; z = a + i•b
; cmuli(a,b) = (a + i•b)*i = -b + i•a
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = -b
; return_2 = st0 = b' = a

macro @@cmuli.sse
{
$usprocf @@cmuli

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        xorpd   xmm0, xmm0
        subsd   xmm0, xmm1
        movsd   xmm1, xmm2
   .return:
        retn
$endp
}

macro @@cmuli.fpu
{
$usprocf @@cmuli

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b  | st1 = a
        fchs                                    ; st0 = -b | st1 = a
        fxch                                    ; st0 = a  | st1 = -b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cmuli.sse
$else
  @@cmuli.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex division
; z1 = a + i•b
; z2 = c + i•d
; cdiv(a,b,c,d) = (a*c + b*d)/n + i•(b*c - a*d)/n
; n = c^2 + d^2
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a' = a''/n = (a*c + b*d)/n
; return_2 = st0 = b' = b''/n = (b*c - a*d)/n

macro @@cdiv.sse
{
$usprocf @@cdiv

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        movsd   xmm4, xmm2
        movsd   xmm5, xmm3
        mulsd   xmm4, xmm4
        mulsd   xmm5, xmm5
        addsd   xmm4, xmm5                      ; xmm4 = n
        movsd   xmm5, xmm0                      ; xmm5 = a
        movsd   xmm6, xmm1                      ; xmm6 = b
        mulsd   xmm0, xmm2                      ; xmm0 = a*c
        mulsd   xmm1, xmm2                      ; xmm1 = b*c
        mulsd   xmm5, xmm3                      ; xmm5 = a*d
        mulsd   xmm6, xmm3                      ; xmm6 = b*d
        addsd   xmm0, xmm6                      ; xmm0 = a*c+b*d
        subsd   xmm1, xmm5                      ; xmm1 = b*c-a*d
        xmovsd  xmm2, ??.1.0                    ; xmm2 = 1
        divsd   xmm2, xmm4                      ; xmm2 = 1/n
        mulsd   xmm0, xmm2
        mulsd   xmm1, xmm2
   .return:
        retn
$endp

$asprocf @@cdiv.enter.fpu
                                                ; st0 = d   | st1 = c   | st2 = b   | st3 = a
        fld     st0
        fmul    st0, st0                        ; st0 = d^2 | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st2
        fmul    st0, st0                        ; st0 = c^2 | st1 = d^2 | st2 = d   | st3 = c   | st4 = b   | st5 = a
        faddp                                   ; st0 = n   | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st4                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st3                             ; st0 = c   | st1 = a   | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fmulp                                   ; st0 = a*c | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st4                             ; st0 = b   | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fld     st3                             ; st0 = d   | st1 = b   | st2 = a*c | st3 = n   | st4 = d   | st5 = c   | st6 = b   | st7 = a
        fmulp                                   ; st0 = b*d | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        faddp                                   ; st0 = a'' | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fdiv    st0, st1                        ; st0 = a'  | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fxch    st5                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a'
        fmulp   st2, st0                        ; st0 = n   | st1 = a*d | st2 = c   | st3 = b   | st4 = a'
        fxch    st3                             ; st0 = b   | st1 = a*d | st2 = c   | st3 = n   | st4 = a'
        fmulp   st2, st0                        ; st0 = a*d | st1 = b*c | st2 = n   | st3 = a'
        fsubp                                   ; st0 = b'' | st1 = n   | st2 = a'
        fdivrp                                  ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

macro @@cdiv.fpu
{
$usprocf @@cdiv

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d   | st1 = c   | st2 = b   | st3 = a
        fld     st0
        fmul    st0, st0                        ; st0 = d^2 | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st2
        fmul    st0, st0                        ; st0 = c^2 | st1 = d^2 | st2 = d   | st3 = c   | st4 = b   | st5 = a
        faddp                                   ; st0 = n   | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st4                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st3                             ; st0 = c   | st1 = a   | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fmulp                                   ; st0 = a*c | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st4                             ; st0 = b   | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fld     st3                             ; st0 = d   | st1 = b   | st2 = a*c | st3 = n   | st4 = d   | st5 = c   | st6 = b   | st7 = a
        fmulp                                   ; st0 = b*d | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        faddp                                   ; st0 = a'' | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fdiv    st0, st1                        ; st0 = a'  | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fxch    st5                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a'
        fmulp   st2, st0                        ; st0 = n   | st1 = a*d | st2 = c   | st3 = b   | st4 = a'
        fxch    st3                             ; st0 = b   | st1 = a*d | st2 = c   | st3 = n   | st4 = a'
        fmulp   st2, st0                        ; st0 = a*d | st1 = b*c | st2 = n   | st3 = a'
        fsubp                                   ; st0 = b'' | st1 = n   | st2 = a'
        fdivrp                                  ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cdiv.sse
$else
  @@cdiv.fpu
$end

; ------------------------------------------------------------------------------

; complex division by real number
; z = a + i•b
; crdiv(a,b,c) = (a + i•b)/c = (a/c) + i•(b/c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = a/c
; return_2 = st0 = b' = b/c

macro @@crdiv.sse
{
$usprocf @@crdiv

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        xmovsd  xmm3, ??.1.0
        divsd   xmm3, xmm2                      ; xmm3 = 1/c
        mulsd   xmm0, xmm3
        mulsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@crdiv.fpu
{
$usprocf @@crdiv

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        fld1
        fdivrp                                  ; st0 = 1/c | st1 = b | st2 = a
        fmul    st2, st0                        ; st0 = 1/c | st1 = b | st2 = a/c
        fmulp                                   ; st0 = b/c | st1 = a/c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crdiv.sse
$else
  @@crdiv.fpu
$end

; ------------------------------------------------------------------------------

; complex division by imaginary number
; z = a + i•b
; cidiv(a,b,c) = (a + i•b)/(i•c) = (b/c) + i•(-a/c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = b/c
; return_2 = st0 = b' = -a/c

macro @@cidiv.sse
{
$usprocf @@cidiv

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        xmovsd  xmm3, ??.1.0
        divsd   xmm3, xmm2                      ; xmm3 = 1/c
        movsd   xmm2, xmm0
        movsd   xmm0, xmm1                      ; xmm0 = b
        xorpd   xmm1, xmm1
        subsd   xmm1, xmm2                      ; xmm1 = -a
        mulsd   xmm0, xmm3
        mulsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@cidiv.fpu
{
$usprocf @@cidiv

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c    | st1 = b | st2 = a
        fld1
        fdivrp                                  ; st0 = 1/c  | st1 = b | st2 = a
        fmul    st2, st0                        ; st0 = 1/c  | st1 = b | st2 = a/c
        fmulp                                   ; st0 = b/c  | st1 = a/c
        fxch                                    ; st0 = a/c  | st1 = b/c
        fchs                                    ; st0 = -a/c | st1 = b/c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cidiv.sse
$else
  @@cidiv.fpu
$end

; ------------------------------------------------------------------------------

; complex division by i
; z = a + i•b
; cdivi(a,b) = (a + i•b)/i = (a + i•b)*(-i) = b + i•(-a)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = b
; return_2 = st0 = b' = -a

macro @@cdivi.sse
{
$usprocf @@cdivi

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        movsd   xmm0, xmm1
        xorpd   xmm1, xmm1
        subsd   xmm1, xmm2
   .return:
        retn
$endp
}

macro @@cdivi.fpu
{
$usprocf @@cdivi

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b  | st1 = a
        fxch                                    ; st0 = a  | st1 = b
        fchs                                    ; st0 = -a | st1 = b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cdivi.sse
$else
  @@cdivi.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reverse complex division
; z1 = a + i•b
; z2 = c + i•d
; cdivr(a,b,c,d) = (a*c + b*d)/n + i•(a*d - b*c)/n
; n = a^2 + b^2
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a' = a''/n = (a*c + b*d)/n
; return_2 = st0 = b' = b''/n = (a*d - b*c)/n

macro @@cdivr.sse
{
$usprocf @@cdivr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        movsd   xmm4, xmm0
        movsd   xmm5, xmm1
        mulsd   xmm4, xmm4
        mulsd   xmm5, xmm5
        addsd   xmm4, xmm5                      ; xmm4 = n
        xmovsd  xmm6, ??.1.0
        divsd   xmm6, xmm4                      ; xmm6 = 1/n
        movsd   xmm4, xmm0                      ; xmm4 = a
        movsd   xmm5, xmm1                      ; xmm5 = b
        mulsd   xmm0, xmm2                      ; xmm0 = a*c
        mulsd   xmm2, xmm1                      ; xmm2 = b*c
        xorpd   xmm1, xmm1
        subsd   xmm1, xmm2                      ; xmm1 = -b*c
        mulsd   xmm4, xmm3                      ; xmm4 = a*d
        mulsd   xmm5, xmm3                      ; xmm5 = b*d
        addsd   xmm0, xmm5                      ; xmm0 = a*c+b*d
        addsd   xmm1, xmm4                      ; xmm1 = a*d-b*c
        mulsd   xmm0, xmm6
        mulsd   xmm1, xmm6
   .return:
        retn
$endp

$asprocf @@cdivr.enter.fpu
                                                ; st0 = d   | st1 = c   | st2 = b   | st3 = a
        fld     st3
        fmul    st0, st0                        ; st0 = a^2 | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st3
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = d   | st3 = c   | st4 = b   | st5 = a
        faddp                                   ; st0 = n   | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st4                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st3                             ; st0 = c   | st1 = a   | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fmulp                                   ; st0 = a*c | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st4                             ; st0 = b   | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fld     st3                             ; st0 = d   | st1 = b   | st2 = a*c | st3 = n   | st4 = d   | st5 = c   | st6 = b   | st7 = a
        fmulp                                   ; st0 = b*d | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        faddp                                   ; st0 = a'' | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fdiv    st0, st1                        ; st0 = a'  | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fxch    st5                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a'
        fmulp   st2, st0                        ; st0 = n   | st1 = a*d | st2 = c   | st3 = b   | st4 = a'
        fxch    st3                             ; st0 = b   | st1 = a*d | st2 = c   | st3 = n   | st4 = a'
        fmulp   st2, st0                        ; st0 = a*d | st1 = b*c | st2 = n   | st3 = a'
        fsubrp                                  ; st0 = b'' | st1 = n   | st2 = a'
        fdivrp                                  ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

macro @@cdivr.fpu
{
$usprocf @@cdivr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d   | st1 = c   | st2 = b   | st3 = a
        fld     st3
        fmul    st0, st0                        ; st0 = a^2 | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st3
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = d   | st3 = c   | st4 = b   | st5 = a
        faddp                                   ; st0 = n   | st1 = d   | st2 = c   | st3 = b   | st4 = a
        fld     st4                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st3                             ; st0 = c   | st1 = a   | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fmulp                                   ; st0 = a*c | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fld     st4                             ; st0 = b   | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        fld     st3                             ; st0 = d   | st1 = b   | st2 = a*c | st3 = n   | st4 = d   | st5 = c   | st6 = b   | st7 = a
        fmulp                                   ; st0 = b*d | st1 = a*c | st2 = n   | st3 = d   | st4 = c   | st5 = b   | st6 = a
        faddp                                   ; st0 = a'' | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fdiv    st0, st1                        ; st0 = a'  | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a
        fxch    st5                             ; st0 = a   | st1 = n   | st2 = d   | st3 = c   | st4 = b   | st5 = a'
        fmulp   st2, st0                        ; st0 = n   | st1 = a*d | st2 = c   | st3 = b   | st4 = a'
        fxch    st3                             ; st0 = b   | st1 = a*d | st2 = c   | st3 = n   | st4 = a'
        fmulp   st2, st0                        ; st0 = a*d | st1 = b*c | st2 = n   | st3 = a'
        fsubrp                                  ; st0 = b'' | st1 = n   | st2 = a'
        fdivrp                                  ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cdivr.sse
$else
  @@cdivr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex division by real number
; z = a + i•b
; crdivr(a,b,c) = c/(a + i•b) = (a*c)/n + i•(-b*c)/n
; n = a^2 + b^2
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = (a*c)/n
; return_2 = st0 = b' = (-b*c)/n

macro @@crdivr.sse
{
$usprocf @@crdivr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        movsd   xmm4, xmm0
        movsd   xmm5, xmm1
        mulsd   xmm4, xmm4
        mulsd   xmm5, xmm5
        addsd   xmm4, xmm5                      ; xmm4 = n
        divsd   xmm2, xmm4                      ; xmm2 = c/n
        mulsd   xmm0, xmm2
        mulsd   xmm1, xmm2
        @@.chs  xmm1
   .return:
        retn
$endp
}

macro @@crdivr.fpu
{
$usprocf @@crdivr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        fld     st2
        fmul    st0, st0
        fld     st2
        fmul    st0, st0
        faddp                                   ; st0 = n   | st1 = c | st2 = b | st3 = a
        fdivp                                   ; st0 = c/n | st1 = b | st2 = a
        fmul    st2, st0                        ; st0 = c/n | st1 = b | st2 = a'
        fmulp                                   ; st0 = -b' | st2 = a'
        fchs                                    ; st0 = b'  | st2 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crdivr.sse
$else
  @@crdivr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex division by imaginary number
; z = a + i•b
; cidivr(a,b,c) = (i•c)/(a + i•b) = (b*c)/n + i•(a*c)/n
; n = a^2 + b^2
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
;
; return_1 = st1 = a' = (b*c)/n
; return_2 = st0 = b' = (a*c)/n

macro @@cidivr.sse
{
$usprocf @@cidivr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        movsd   xmm4, xmm0
        movsd   xmm5, xmm1
        mulsd   xmm4, xmm4
        mulsd   xmm5, xmm5
        addsd   xmm4, xmm5                      ; xmm4 = n
        divsd   xmm2, xmm4                      ; xmm2 = c/n
        @@.xch  xmm0, xmm1
        mulsd   xmm0, xmm2
        mulsd   xmm1, xmm2
   .return:
        retn
$endp
}

macro @@cidivr.fpu
{
$usprocf @@cidivr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c   | st1 = b | st2 = a
        fld     st2
        fmul    st0, st0
        fld     st2
        fmul    st0, st0
        faddp                                   ; st0 = n   | st1 = c | st2 = b | st3 = a
        fdivp                                   ; st0 = c/n | st1 = b | st2 = a
        fmul    st2, st0                        ; st0 = c/n | st1 = b | st2 = b'
        fmulp                                   ; st0 = a'  | st1 = b'
        fxch                                    ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cidivr.sse
$else
  @@cidivr.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex division by 1
; z = a + i•b
; cinv(a,b) = 1/(a + i•b) = a/n + i•(-b/n)
; n = a^2 + b^2
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' =  a/n
; return_2 = st0 = b' = -b/n

macro @@cinv.sse
{
$usprocf @@cinv

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm4, xmm0
        movsd   xmm5, xmm1
        mulsd   xmm4, xmm4
        mulsd   xmm5, xmm5
        addsd   xmm4, xmm5                      ; xmm4 = n
        xmovsd  xmm2, ??.1.0
        divsd   xmm2, xmm4                      ; xmm2 = 1/n
        mulsd   xmm0, xmm2
        mulsd   xmm1, xmm2
        @@.chs  xmm1
   .return:
        retn
$endp

$asprocf @@cinv.enter.fpu
                                                ; st0 = b    | st1 = a
        fld     st0
        fmul    st0, st0                        ; st0 = b^2  | st1 = b   | st2 = a
        fld     st2
        fmul    st0, st0                        ; st0 = a^2  | st1 = b^2 | st2 = b   | st3 = a
        faddp                                   ; st0 = n    | st1 = b   | st2 = a
        fdiv    st2, st0                        ; st0 = n    | st1 = b   | st2 = a/n
        fdivp                                   ; st0 = b/n  | st1 = a/n
        fchs                                    ; st0 = -b/n | st1 = a/n
   .return:
        retn
$endp
}

macro @@cinv.fpu
{
$usprocf @@cinv

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b    | st1 = a
        fld     st0
        fmul    st0, st0                        ; st0 = b^2  | st1 = b   | st2 = a
        fld     st2
        fmul    st0, st0                        ; st0 = a^2  | st1 = b^2 | st2 = b   | st3 = a
        faddp                                   ; st0 = n    | st1 = b   | st2 = a
        fdiv    st2, st0                        ; st0 = n    | st1 = b   | st2 = a/n
        fdivp                                   ; st0 = b/n  | st1 = a/n
        fchs                                    ; st0 = -b/n | st1 = a/n
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cinv.sse
$else
  @@cinv.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex division by i
; z = a + i•b
; cdivri(a,b) = i/(a + i•b) = b/n + i•a/n
; n = a^2 + b^2
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = b/n
; return_2 = st0 = b' = a/n

macro @@cdivri.sse
{
$usprocf @@cdivri

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm4, xmm0
        movsd   xmm5, xmm1
        mulsd   xmm4, xmm4
        mulsd   xmm5, xmm5
        addsd   xmm4, xmm5                      ; xmm4 = n
        xmovsd  xmm2, ??.1.0
        divsd   xmm2, xmm4                      ; xmm2 = 1/n
        @@.xch  xmm0, xmm1
        mulsd   xmm0, xmm2
        mulsd   xmm1, xmm2
   .return:
        retn
$endp
}

macro @@cdivri.fpu
{
$usprocf @@cdivri

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld     st1
        fmul    st0, st0                        ; st0 = a^2 | st1 = b   | st2 = a
        fld     st1
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = b | st3 = a
        faddp                                   ; st0 = n   | st1 = b   | st2 = a
        fdiv    st1, st0                        ; st0 = n   | st1 = b/n | st2 = a
        fdivp   st2, st0                        ; st0 = b/n | st1 = a/n
        fxch                                    ; st0 = a/n | st1 = b/n
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cdivri.sse
$else
  @@cdivri.fpu
$end

; ------------------------------------------------------------------------------
