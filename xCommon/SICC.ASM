
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; constants

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

$align 16

GCT @_GCT,\
    true     ,      SC_true    ,    'i',\
    @true    ,      SC_true    ,    'i',\
    false    ,      SC_false   ,    'i',\
    @false   ,      SC_false   ,    'i',\
    nil      ,      SC_null    ,    'p',\
    @nil     ,      SC_null    ,    'p',\
    null     ,      SC_null    ,    'p',\
    @null    ,      SC_null    ,    'p',\
    @e       ,      SC_e       ,    'f',\
    @inv.e   ,      SC_inv.e   ,    'f',\
    @sqr.e   ,      SC_sqr.e   ,    'f',\
    @pi      ,      SC_pi      ,    'f',\
    @inv.pi  ,      SC_inv.pi  ,    'f',\
    @sqr.pi  ,      SC_sqr.pi  ,    'f',\
    @sqrt.pi ,      SC_sqrt.pi ,    'f',\
    @2pi     ,      SC_2pi     ,    'f',\
    @inv.2pi ,      SC_inv.2pi ,    'f',\
    @pi2     ,      SC_pi2     ,    'f',\
    @inv.pi2 ,      SC_inv.pi2 ,    'f',\
    @pi4     ,      SC_pi4     ,    'f',\
    @inv.pi4 ,      SC_inv.pi4 ,    'f',\
    @golden  ,      SC_golden  ,    'f',\
    @euler   ,      SC_euler   ,    'f'

; ------------------------------------------------------------------------------
