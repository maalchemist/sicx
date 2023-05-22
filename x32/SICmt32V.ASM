
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; Mersenne Twister pseudorandom number generator

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; Mersenne Twister Home Page
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
;
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.tgz
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
; Copyright (C) 1997-2002, Makoto Matsumoto and Takuji Nishimura
;
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/mt19937-64.tgz
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/mt19937-64.c
; Copyright (C) 2004, Makoto Matsumoto and Takuji Nishimura

; ------------------------------------------------------------------------------

mt32_n      = 624
mt32_m      = 397
mt32_nm     = mt32_n-mt32_m
mt32_mn     = mt32_m-mt32_n
mt32_U_mask = 0x80000000            ; Most significant w-r bits
mt32_L_mask = 0x7FFFFFFF            ; Least significant r bits

$align 16
mt32 dd mt32_n dup ?                ; The array for the state vector
$align 16
mti  dd mt32_n+1                    ; mti==n+1 means mt[n] is not initialized

$align 16
mt_2p26     dq 6.7108864E+07                                ; 2^26
$align 16
mt_2p32     dq 4.294967296E+09                              ; 2^32
$align 16
mt_2m53     dq 1.11022302462515654042363166809082031250E-16 ; 2^(-53)
$align 16
mt_2m53_2pi dq 6.97573699601726379895848180918594501997E-16 ; 2^(-53)*2*pi

; __MT_GEN_NO_JUMP
$align 16
mt32_matrix_A dd 0x9908B0DF         ; Constant vector a
mt32_matrix_0 dd 0
; __MT_GEN_JUMP
; mt32_matrix_A = 0x9908B0DF

; ------------------------------------------------------------------------------
