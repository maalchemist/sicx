
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

; initializes mt[n] with a seed

$align 16
proc mt19937_seed, seed

;       mov     [seed], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     r11, mt64

        test    rcx, rcx
        jnz    .e

        rdtsc                                   ; eax:edx = processor's time-stamp counter
        mov     rcx, rdx
        xor     rcx, rsp
        shl     rcx, 32
        or      rcx, rax

   .e:
        mov     rax, rcx                        ; rax = seed
        mov     [r11], rax                      ; mt[0] = seed

        mov     r10, 1                          ; mti = r10
        mov     rcx, 6364136223846793005
   .a:                                          ; for (mti=1; mti<N; mti++) {...}
        mov     rdx, rax                        ; rdx = mt[mti-1]
        shr     rdx, 62                         ; rdx = mt[mti-1] >> 62
        xor     rax, rdx                        ; rax = mt[mti-1] ^ (mt[mti-1] >> 62)
        mul     rcx                             ; rax = (mt[mti-1] ^ (mt[mti-1] >> 62)) * 6364136223846793005
        add     rax, r10                        ; rax = (mt[mti-1] ^ (mt[mti-1] >> 62)) * 6364136223846793005 + mti
        mov     [r11 + r10*8], rax              ; mt[mti] = rax
   .a.next:
        inc     r10
        cmp     r10, mt64_n
        jb     .a

        mov     [mti], r10

        ret
endp

; ------------------------------------------------------------------------------

; initializes mt[n] with an array of seeds

$align 16
proc mt19937_seeds, seeds, count

        mov     [seeds], rcx
        mov     [count], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall mt19937_seed, 19650218

        mov     rcx, [count]
        cmp     rcx, 0
        jle    .return

   .enter:
        push    rsi

        mov     rsi, [seeds]
        test    rsi, rsi
        jz     .leave

        mov     r11, mt64

        mov     r8, 1                           ; i = r8
        xor     r9, r9                          ; j = r9

        cmp     rcx, mt64_n                     ; rcx = count
        jae    .main
        mov     rcx, mt64_n                     ; rcx = max(mt64_n,count)

   .main:
        mov     r10, 3935559000370003845
   .a:                                          ; for (; k; k--) {...}
        mov     rax, [r11 + r8*8 - 8]           ; rax = mt[i-1]
        mov     rdx, rax                        ; rdx = mt[i-1]
        shr     rdx, 62                         ; rdx = mt[i-1] >> 62
        xor     rax, rdx                        ; rax = mt[i-1] ^ (mt[i-1] >> 62)
        mul     r10                             ; rax = (mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845
        mov     rdx, [r11 + r8*8]               ; rdx = mt[i]
        xor     rax, rdx                        ; rax = mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845)
        add     rax, r9                         ; rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845)) + j
        mov     rdx, [rsi + r9*8]               ; rdx = seeds[j]
        add     rax, rdx                        ; rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845)) + j + seeds[j]
        mov     [r11 + r8*8], rax               ; mt[i] = rax
        ;
        inc     r8                              ; i++
        inc     r9                              ; j++
   .a.i:
        cmp     r8, mt64_n                      ; compare i to n
        jb     .a.i.out
   .a.i.ae.n:                                   ; i >= n
        mov     rax, [r11 + (mt64_n-1)*8]       ; rax = mt[n-1]
        mov     [r11], rax                      ; mt[0] = mt[n-1]
        mov     r8, 1                           ; i = 1
   .a.i.out:
   .a.j:
        cmp     r9, [count]                     ; compare j to count
        jb     .a.j.out
   .a.j.ae.count:                               ; j >= count
        mov     r9, 0                           ; j = 0
   .a.j.out:
   .a.next:
        dec     rcx
        jnz    .a

        mov     rcx, mt64_n-1
        mov     r10, 2862933555777941757
   .b:                                          ; for (k=N-1; k; k--) {...}
        mov     rax, [r11 + r8*8 - 8]           ; rax = mt[i-1]
        mov     rdx, rax                        ; rdx = mt[i-1]
        shr     rdx, 62                         ; rdx = (mt[i-1] >> 62)
        xor     rax, rdx                        ; rax = (mt[i-1] ^ (mt[i-1] >> 62))
        mul     r10                             ; rax = (mt[i-1] ^ (mt[i-1] >> 62)) * 2862933555777941757
        mov     rdx, [r11 + r8*8]               ; rdx = mt[i]
        xor     rax, rdx                        ; rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 2862933555777941757))
        sub     rax, r8                         ; rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 2862933555777941757)) - i
        mov     [r11 + r8*8], rax               ; mt[i] = rax
        ;
        inc     r8                              ; i++
   .b.i:
        cmp     r8, mt64_n                      ; compare i to n
        jb     .b.i.out
   .b.i.ae.n:                                   ; i >= n
        mov     rax, [r11 + (mt64_n-1)*8]       ; rax = mt[n-1]
        mov     [r11], rax                      ; mt[0] = mt[n-1]
        mov     r8, 1                           ; i = 1
   .b.i.out:
   .b.next:
        dec     rcx
        jnz    .b

        mov     rax, 0x8000000000000000
        mov     [r11], rax                      ; mt[0] = 1ULL << 63; /* MSB is 1; assuring non-zero initial array */

   .leave:
        pop     rsi
   .return:
        ret
endp

; ------------------------------------------------------------------------------

; generates a random uint number on [0, 2^64-1]-interval

$align 16
proc mt19937_igen

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        mov     r11, mt64

        mov     r10, [mti]
        cmp     r10, mt64_n
        jb     .tempering.x

        cmp     r10, mt64_n+1
        jne    .generate
   .seed:
        ; if mt19937_seed() has not been called, a default initial seed is used
        stdcall mt19937_seed, 5489

   .generate:                                   ; generate N words at one time
        ; __MT_GEN_NO_JUMP
        mov     rcx, mt64_matrix_0
        ; __MT_GEN_JUMP
;       mov     rcx, mt64_matrix_A

        xor     r10, r10                        ; i = r10

   .c:                                          ; for (i=0; i<N-M; i++) {...}
        mov     rax, [r11 + r10*8]              ; rax = mt[i]
        and     rax, mt64_U_mask                ; rax = mt[i] & U_mask
        mov     rdx, [r11 + r10*8 + 8]          ; rdx = mt[i+1]
        and     rdx, mt64_L_mask                ; rdx = mt[i+1] & L_mask
        or      rax, rdx                        ; rax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     rax, 1                          ; rax = (rax>>1)
        ;
        ; __MT_GEN_NO_JUMP
        sbb     rdx, rdx                        ; rdx = ?-1:0
        xor     rax, [rcx + rdx*8]              ; rax = (rax>>1) ^ (?matrix_A:0)
        ; __MT_GEN_JUMP
;       jnc    .c.set
;  .c.xor.a:
;       xor     rax, rcx                        ; rax = (rax>>1) ^ matrix_A
        ;
   .c.set:
        mov     rdx, [r11 + r10*8 + mt64_m*8]   ; rdx = mt[i+m]
        xor     rax, rdx                        ; rax = (rax) ^ mt[i+m]
        mov     [r11 + r10*8], rax              ; mt[i] = rax
   .c.next:
        inc     r10
        cmp     r10, mt64_n-mt64_m
        jb     .c

   .b:                                          ; for (; i<N-1; i++) {...}
        mov     rax, [r11 + r10*8]              ; rax = mt[i]
        and     rax, mt64_U_mask                ; rax = mt[i] & U_mask
        mov     rdx, [r11 + r10*8 + 8]          ; rdx = mt[i+1]
        and     rdx, mt64_L_mask                ; rdx = mt[i+1] & L_mask
        or      rax, rdx                        ; rax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     rax, 1                          ; rax = (rax>>1)
        ;
        ; __MT_GEN_NO_JUMP
        sbb     rdx, rdx                        ; rdx = ?-1:0
        xor     rax, [rcx + rdx*8]              ; rax = (rax>>1) ^ (?matrix_A:0)
        ; __MT_GEN_JUMP
;       jnc    .b.set
;  .b.xor.a:
;       xor     rax, rcx                        ; rax = (rax>>1) ^ matrix_A
        ;
   .b.set:
        mov     rdx, [r11 + r10*8 + mt64_mn*8]  ; rdx = mt[i+(m-n)]
        xor     rax, rdx                        ; rax = (rax) ^ mt[i+(m-n)]
        mov     [r11 + r10*8], rax              ; mt[i] = rax
   .b.next:
        inc     r10
        cmp     r10, mt64_n-1
        jb     .b

   .a:
        mov     rax, [r11 + (mt64_n-1)*8]       ; rax = mt[n-1]
        and     rax, mt64_U_mask                ; rax = mt[n-1] & U_mask
        mov     rdx, [r11]                      ; rdx = mt[0]
        and     rdx, mt64_L_mask                ; rdx = mt[0] & L_mask
        or      rax, rdx                        ; rax = (mt[n-1] & U_mask) | (mt[0] & L_mask)
        shr     rax, 1                          ; rax = (rax>>1)
        ;
        ; __MT_GEN_NO_JUMP
        sbb     rdx, rdx                        ; rdx = ?-1:0
        xor     rax, [rcx + rdx*8]              ; rax = (rax>>1) ^ (?matrix_A:0)
        ; __MT_GEN_JUMP
;       jnc    .a.set
;  .a.xor.a:
;       xor     rax, rcx                        ; rax = (rax>>1) ^ matrix_A
        ;
   .a.set:
        mov     rdx, [r11 + (mt64_m-1)*8]       ; rdx = mt[m-1]
        xor     rax, rdx                        ; rax = (rax) ^ (mt[m-1])
        mov     [r11 + (mt64_n-1)*8], rax       ; mt[n-1] = rax

        mov     [mti], 0

   .tempering:
        mov     r10, [mti]
   .tempering.x:
        mov     rax, [r11 + r10*8]              ; x = mt[mti] = rax
        inc     [mti]

        mov     rdx, rax                        ; x ^= (x >> 29) & 0x5555555555555555ULL;
        shr     rdx, 29
        mov     rcx, 0x5555555555555555
        and     rdx, rcx
        xor     rax, rdx

        mov     rdx, rax                        ; x ^= (x << 17) & 0x71D67FFFEDA60000ULL;
        shl     rdx, 17
        mov     rcx, 0x71D67FFFEDA60000
        and     rdx, rcx
        xor     rax, rdx

        mov     rdx, rax                        ; x ^= (x << 37) & 0xFFF7EEE000000000ULL;
        shl     rdx, 37
        mov     rcx, 0xFFF7EEE000000000
        and     rdx, rcx
        xor     rax, rdx

        mov     rdx, rax                        ; x ^= (x >> 43);
        shr     rdx, 43
        xor     rax, rdx

   .leave:
        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,1)-interval (53-bit resolution)
;
; return (genrand64_int64() >> 11) * (1.0/9007199254740992.0);
;
; a*(2^(-53))

$align 16
proc mt19937_fgen

        call    mt19937_igen
        shr     rax, 11                         ; a
       cvtsi2sd xmm0, rax
        mulsd   xmm0, [mt_2m53]                 ; a*(2^(-53))

        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,2•pi)-interval (53-bit resolution)
;
; return (genrand64_int64() >> 11) * (2.0*pi/9007199254740992.0);
;
; a*(2^(-53))*2*pi

$align 16
proc mt19937_fgen2pi

        call    mt19937_igen
        shr     rax, 11                         ; a
       cvtsi2sd xmm0, rax
        mulsd   xmm0, [mt_2m53_2pi]             ; a*(2^(-53))*2*pi

        ret
endp

; ------------------------------------------------------------------------------

macro c
{
proc mt19937_test

    locals
       .seeds   dq 4 dup(?)
    endl

        push    rbx

        lea     rcx, [.seeds]
        mov     qword [rcx + 00], 0x12345
        mov     qword [rcx + 08], 0x23456
        mov     qword [rcx + 16], 0x34567
        mov     qword [rcx + 24], 0x45678
        stdcall mt19937_seeds, rcx, 4

        mov     rbx, 1000
   .a:
        stdcall mt19937_igen
        dec     rbx
        jnz    .a
;       int3

        pop     rbx
        ret
endp
}

; ------------------------------------------------------------------------------
