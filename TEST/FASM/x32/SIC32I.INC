
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; includes (release)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; x64
; r8q EQU r8
; r9q EQU r9
;
; xax EQU rax
; xbx EQU rbx
; xcx EQU rcx
; xdx EQU rdx
; xdi EQU rdi
; xsi EQU rsi
; xsp EQU rsp
; xbp EQU rbp

; x32
  alb EQU al
  blb EQU bl
  clb EQU cl
  dlb EQU dl

  ahb EQU ah
  bhb EQU bh
  chb EQU ch
  dhb EQU dh

  xax EQU eax
  xbx EQU ebx
  xcx EQU ecx
  xdx EQU edx
  xdi EQU edi
  xsi EQU esi
  xsp EQU esp
  xbp EQU ebp

; ------------------------------------------------------------------------------

include '%INCLUDE%\WIN32A.INC'

include '..\..\..\xCommon\SYSTEM.INC'
include '..\..\..\xCommon\FJXX.INC'
include '..\..\..\xCommon\MSCOFF32.INC'
include '..\..\..\xCommon\PROCS32.INC'
include '..\..\..\xCommon\SIC.ASH'
include '..\..\..\xCommon\SICIDA.ASH'
include '..\..\..\xCommon\SIC.INC'
include '..\..\..\xCommon\SICV.INC'
include '..\..\..\xCommon\SICC.INC'
include '..\..\..\xCommon\SICCa32.INC'

; ------------------------------------------------------------------------------
