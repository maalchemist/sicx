
; FASM SOURCE FILE
; http://flatassembler.net

; MS COFF macros

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

macro extrns [e, s]
{
  forward
;  if used e
    extrn s as e:qword
;  end if
}

macro publics [p, s]
{
  forward
;  if used p
    if (s eq '')
     public p
    else
     public p as s
    end if
;  end if
}

; ------------------------------------------------------------------------------
