
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

        push    ebx edi

        mov     edi, mt32
        mov     eax, [seed]                     ; eax = seed

        test    eax, eax
        jnz    .e

        rdtsc                                   ; eax:edx = processor's time-stamp counter
        xor     eax, edx

   .e:
        mov     [edi], eax                      ; mt[0] = seed

        mov     ebx, 1                          ; mti = ebx
        mov     ecx, 1812433253
   .a:                                          ; for (mti=1; mti<N; mti++) {...}
        mov     edx, eax                        ; edx = mt[mti-1]
        shr     edx, 30                         ; edx = mt[mti-1] >> 30
        xor     eax, edx                        ; eax = mt[mti-1] ^ (mt[mti-1] >> 30)
        mul     ecx                             ; eax = (mt[mti-1] ^ (mt[mti-1] >> 30)) * 1812433253
        add     eax, ebx                        ; eax = (mt[mti-1] ^ (mt[mti-1] >> 30)) * 1812433253 + mti
        mov     [edi + ebx*4], eax              ; mt[mti] = eax
   .a.next:
        inc     ebx
        cmp     ebx, mt32_n
        jb     .a

        mov     [mti], ebx

        pop     edi ebx
        ret
endp

; ------------------------------------------------------------------------------

; initializes mt[n] with an array of seeds

$align 16
proc mt19937_seeds, seeds, count

    locals
       .c       dd ?
       .j       dd ?
    endl

        stdcall mt19937_seed, 19650218

        mov     ecx, [count]
        cmp     ecx, 0
        jle    .return

   .enter:
        push    ebx esi edi

        mov     esi, [seeds]
        test    esi, esi
        jz     .leave

        mov     edi, mt32

        mov     ebx, 1                          ; i = ebx
        mov     [.j], 0                         ; j = [.j]

        cmp     ecx, mt32_n                     ; ecx = count
        jae    .main
        mov     ecx, mt32_n                     ; ecx = max(mt32_n,count)

   .main:
        mov     [.c], 1664525
   .a:                                          ; for (; k; k--) {...}
        mov     eax, [edi + ebx*4 - 4]          ; eax = mt[i-1]
        mov     edx, eax                        ; edx = mt[i-1]
        shr     edx, 30                         ; edx = mt[i-1] >> 30
        xor     eax, edx                        ; eax = mt[i-1] ^ (mt[i-1] >> 30)
        mul     [.c]                            ; eax = (mt[i-1] ^ (mt[i-1] >> 30)) * 1664525
        mov     edx, [edi + ebx*4]              ; edx = mt[i]
        xor     eax, edx                        ; eax = mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525)
        mov     edx, [.j]                       ; edx = j
        add     eax, edx                        ; eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525)) + j
        mov     edx, [esi + edx*4]              ; edx = seeds[j]
        add     eax, edx                        ; eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525)) + j + seeds[j]
        mov     [edi + ebx*4], eax              ; mt[i] = eax
        ;
        inc     ebx                             ; i++
        inc     [.j]                            ; j++
   .a.i:
        cmp     ebx, mt32_n                     ; compare i to n
        jb     .a.i.out
   .a.i.ae.n:                                   ; i >= n
        mov     eax, [edi + (mt32_n-1)*4]       ; eax = mt[n-1]
        mov     [edi], eax                      ; mt[0] = mt[n-1]
        mov     ebx, 1                          ; i = 1
   .a.i.out:
   .a.j:
        mov     eax, [count]
        cmp     [.j], eax                       ; compare j to count
        jb     .a.j.out
   .a.j.ae.count:                               ; j >= count
        mov     [.j], 0                         ; j = 0
   .a.j.out:
   .a.next:
        dec     ecx
        jnz    .a

        mov     ecx, mt32_n-1
        mov     esi, 1566083941
   .b:                                          ; for (k=N-1; k; k--) {...}
        mov     eax, [edi + ebx*4 - 4]          ; eax = mt[i-1]
        mov     edx, eax                        ; edx = mt[i-1]
        shr     edx, 30                         ; edx = mt[i-1] >> 30
        xor     eax, edx                        ; eax = mt[i-1] ^ (mt[i-1] >> 30)
        mul     esi                             ; eax = (mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941
        mov     edx, [edi + ebx*4]              ; edx = mt[i]
        xor     eax, edx                        ; eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941))
        sub     eax, ebx                        ; eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941)) - i
        mov     [edi + ebx*4], eax              ; mt[i] = eax
        ;
        inc     ebx                             ; i++
   .b.i:
        cmp     ebx, mt32_n                     ; compare i to n
        jb     .b.i.out
   .b.i.ae.n:                                   ; i >= n
        mov     eax, [edi + (mt32_n-1)*4]       ; eax = mt[n-1]
        mov     [edi], eax                      ; mt[0] = mt[n-1]
        mov     ebx, 1                          ; i = 1
   .b.i.out:
   .b.next:
        dec     ecx
        jnz    .b

        mov     eax, 0x80000000
        mov     [edi], eax                      ; mt[0] = 0x80000000UL; /* MSB is 1; assuring non-zero initial array */

   .leave:
        pop     edi esi ebx
   .return:
        ret
endp

; ------------------------------------------------------------------------------

; generates a random uint number on [0, 2^32-1]-interval

$align 16
proc mt19937_igen

   .enter:
        push    ebx edi

        mov     edi, mt32

        mov     ebx, [mti]
        cmp     ebx, mt32_n
        jb     .tempering.x

        cmp     ebx, mt32_n+1
        jne    .generate
   .seed:
        ; if mt19937_seed() has not been called, a default initial seed is used
        stdcall mt19937_seed, 5489

   .generate:                                   ; generate N words at one time
        ; __MT_GEN_NO_JUMP
        mov     ecx, mt32_matrix_0
        ; __MT_GEN_JUMP
;       mov     ecx, mt32_matrix_A

        xor     ebx, ebx                        ; i = ebx

   .c:                                          ; for (i=0; i<N-M; i++) {...}
        mov     eax, [edi + ebx*4]              ; eax = mt[i]
        and     eax, mt32_U_mask                ; eax = mt[i] & U_mask
        mov     edx, [edi + ebx*4 + 4]          ; edx = mt[i+1]
        and     edx, mt32_L_mask                ; edx = mt[i+1] & L_mask
        or      eax, edx                        ; eax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     eax, 1                          ; eax = (eax>>1)
        ;
        ; __MT_GEN_NO_JUMP
        sbb     edx, edx                        ; edx = ?-1:0
        xor     eax, [ecx + edx*4]              ; eax = (eax>>1) ^ (?matrix_A:0)
        ; __MT_GEN_JUMP
;       jnc    .c.set
;  .c.xor.a:
;       xor     eax, ecx                        ; eax = (eax>>1) ^ matrix_A
        ;
   .c.set:
        mov     edx, [edi + ebx*4 + mt32_m*4]   ; edx = mt[i+m]
        xor     eax, edx                        ; eax = (eax) ^ mt[i+m]
        mov     [edi + ebx*4], eax              ; mt[i] = eax
   .c.next:
        inc     ebx
        cmp     ebx, mt32_n-mt32_m
        jb     .c

   .b:                                          ; for (; i<N-1; i++) {...}
        mov     eax, [edi + ebx*4]              ; eax = mt[i]
        and     eax, mt32_U_mask                ; eax = mt[i] & U_mask
        mov     edx, [edi + ebx*4 + 4]          ; edx = mt[i+1]
        and     edx, mt32_L_mask                ; edx = mt[i+1] & L_mask
        or      eax, edx                        ; eax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     eax, 1                          ; eax = (eax>>1)
        ;
        ; __MT_GEN_NO_JUMP
        sbb     edx, edx                        ; edx = ?-1:0
        xor     eax, [ecx + edx*4]              ; eax = (eax>>1) ^ (?matrix_A:0)
        ; __MT_GEN_JUMP
;       jnc    .b.set
;  .b.xor.a:
;       xor     eax, ecx                        ; eax = (eax>>1) ^ matrix_A
        ;
   .b.set:
        mov     edx, [edi + ebx*4 + mt32_mn*4]  ; edx = mt[i+(m-n)]
        xor     eax, edx                        ; eax = (eax) ^ mt[i+(m-n)]
        mov     [edi + ebx*4], eax              ; mt[i] = eax
   .b.next:
        inc     ebx
        cmp     ebx, mt32_n-1
        jb     .b

   .a:
        mov     eax, [edi + (mt32_n-1)*4]       ; eax = mt[n-1]
        and     eax, mt32_U_mask                ; eax = mt[n-1] & U_mask
        mov     edx, [edi]                      ; edx = mt[0]
        and     edx, mt32_L_mask                ; edx = mt[0] & L_mask
        or      eax, edx                        ; eax = (mt[n-1] & U_mask) | (mt[0] & L_mask)
        shr     eax, 1                          ; eax = (eax>>1)
        ;
        ; __MT_GEN_NO_JUMP
        sbb     edx, edx                        ; edx = ?-1:0
        xor     eax, [ecx + edx*4]              ; eax = (eax>>1) ^ (?matrix_A:0)
        ; __MT_GEN_JUMP
;       jnc    .a.set
;  .a.xor.a:
;       xor     eax, ecx                        ; eax = (eax>>1) ^ matrix_A
        ;
   .a.set:
        mov     edx, [edi + (mt32_m-1)*4]       ; edx = mt[m-1]
        xor     eax, edx                        ; eax = (eax) ^ (mt[m-1])
        mov     [edi + (mt32_n-1)*4], eax       ; mt[n-1] = eax

        mov     [mti], 0

   .tempering:
        mov     ebx, [mti]
   .tempering.x:
        mov     eax, [edi + ebx*4]              ; x = mt[mti] = eax
        inc     [mti]

        mov     edx, eax                        ; x ^= (x >> 11);
        shr     edx, 11
        xor     eax, edx

        mov     edx, eax                        ; x ^= (x << 7) & 0x9d2c5680UL;
        shl     edx, 7
        and     edx, 0x9D2C5680
        xor     eax, edx

        mov     edx, eax                        ; x ^= (x << 15) & 0xefc60000UL;
        shl     edx, 15
        and     edx, 0xEFC60000
        xor     eax, edx

        mov     edx, eax                        ; x ^= (x >> 18);
        shr     edx, 18
        xor     eax, edx

   .leave:
        pop     edi ebx
        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,1)-interval (53-bit resolution)
;
; unsigned long a=genrand_int32()>>5, b=genrand_int32()>>6;
; return(a*67108864.0+b)*(1.0/9007199254740992.0);
;
; (a*(2^26) + b)*(2^(-53))

$align 16
proc mt19937_fgen

        call    mt19937_igen
        shr     eax, 5                          ; a
        push    eax                             ; a->
        call    mt19937_igen
        pop     dword [esp - 8]                 ; a<-
        shr     eax, 6                          ; b
        mov     [esp - 4], eax

        fild    dword [esp - 8]                 ; a
        fmul    qword [mt_2p26]                 ; a*(2^26)
        fild    dword [esp - 4]                 ; b
        faddp                                   ; a*(2^26) + b
        fmul    qword [mt_2m53]                 ; (a*(2^26) + b)*(2^(-53))

        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,2•pi)-interval (53-bit resolution)
;
; unsigned long a=genrand_int32()>>5, b=genrand_int32()>>6;
; return(a*67108864.0+b)*(2.0*pi/9007199254740992.0);
;
; (a*(2^26) + b)*(2^(-53))*2*pi

$align 16
proc mt19937_fgen2pi

        call    mt19937_igen
        shr     eax, 5                          ; a
        push    eax                             ; a->
        call    mt19937_igen
        pop     dword [esp - 8]                 ; a<-
        shr     eax, 6                          ; b
        mov     [esp - 4], eax

        fild    dword [esp - 8]                 ; a
        fmul    qword [mt_2p26]                 ; a*(2^26)
        fild    dword [esp - 4]                 ; b
        faddp                                   ; a*(2^26) + b
        fmul    qword [mt_2m53_2pi]             ; (a*(2^26) + b)*(2^(-53))*2*pi

        ret
endp

; ------------------------------------------------------------------------------

macro c
{
proc mt19937_test

    locals
       .seeds   dd 4 dup(?)
    endl

        push    ebx

        lea     ecx, [.seeds]
        mov     dword [ecx + 00], 0x123
        mov     dword [ecx + 04], 0x234
        mov     dword [ecx + 08], 0x345
        mov     dword [ecx + 12], 0x456
        stdcall mt19937_seeds, ecx, 4

        mov     ebx, 1000
   .a:
        stdcall mt19937_igen
        dec     ebx
        jnz    .a
;       int3

        pop     ebx
        ret
endp
}

; ------------------------------------------------------------------------------
