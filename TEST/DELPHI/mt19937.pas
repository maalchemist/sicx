unit mt19937;

// Mersenne Twister pseudorandom number generator

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com
//
// Free for any use.
// No warranty of any kind.

// Mersenne Twister Home Page
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
//
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.tgz
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
// Copyright (C) 1997-2002, Makoto Matsumoto and Takuji Nishimura
//
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/mt19937-64.tgz
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/mt19937-64.c
// Copyright (C) 2004, Makoto Matsumoto and Takuji Nishimura

{$IFDEF FPC} // Lazarus
  {$ASMMODE INTEL}
{$ENDIF}

{$DEFINE __RDTSC}
{$IFDEF VER120} {$UNDEF __RDTSC} {$ENDIF} // Delphi 4.0
{$IFDEF VER130} {$UNDEF __RDTSC} {$ENDIF} // Delphi 5.0

{$DEFINE __MT_GEN_NO_JUMP}
{.$UNDEF __MT_GEN_NO_JUMP}

interface

const
  {$IFDEF CPUX64}
  mt64_n      = 312;
  mt64_m      = 156;
  mt64_nm     = mt64_n-mt64_m;
  mt64_mn     = mt64_m-mt64_n;
  mt64_U_mask = $FFFFFFFF80000000;  // Most significant 33 bits
  mt64_L_mask = $000000007FFFFFFF;  // Least significant 31 bits
  {$ELSE}
  mt32_n      = 624;
  mt32_m      = 397;
  mt32_nm     = mt32_n-mt32_m;
  mt32_mn     = mt32_m-mt32_n;
  mt32_U_mask = $80000000;          // Most significant w-r bits
  mt32_L_mask = $7FFFFFFF;          // Least significant r bits
  {$ENDIF}

{$IFDEF CPUX64}
function  mt19937_igen: UInt64; register;
procedure mt19937_seed (ASeed: UInt64); register;
procedure mt19937_seeds (ASeeds: Pointer; ACount: UInt64); register;
{$ELSE}
function  mt19937_igen: Cardinal; register;
procedure mt19937_seed (ASeed: Cardinal); register;
procedure mt19937_seeds (ASeeds: Pointer; ACount: Cardinal); register;
{$ENDIF}

{$IFNDEF CPUX64}
function  mt19937_gen0: Double; register;
{$ENDIF}
function  mt19937_fgen: Double; register;
function  mt19937_fgen2pi: Double; register;

implementation

var
  {$IFDEF CPUX64}
  mt64 : array [0..mt64_n-1] of UInt64;   // The array for the state vector
  mti  : UInt64 = mt64_n+1;               // mti==n+1 means mt[n] is not initialized
  {$ELSE}
  mt32 : array [0..mt32_n-1] of Cardinal; // The array for the state vector
  mti  : Cardinal = mt32_n+1;             // mti==n+1 means mt[n] is not initialized
  {$ENDIF}

const
  mt_2p26     : Double = 67108864.0;                                   // 2^26
  mt_2m32     : Double = 2.3283064365386962890625E-10;                 // 2^(-32)
  mt_2m53     : Double = 1.11022302462515654042363166809082031250E-16; // 2^(-53)
  mt_2m53_2pi : Double = 6.97573699601726379895848180918594501997E-16; // 2^(-53)*2*pi

const // Constant vector a
  {$IFDEF __MT_GEN_NO_JUMP}
    {$IFDEF CPUX64}
    mt64_matrix_A : array [-1..0] of UInt64 = ($B5026F5AA96619E9, 0);
    {$ELSE}
    mt32_matrix_A : array [-1..0] of Cardinal = ($9908B0DF, 0);
    {$ENDIF}
  {$ELSE}
    {$IFDEF CPUX64}
    mt64_matrix_A = $B5026F5AA96619E9;
    {$ELSE}
    mt32_matrix_A = $9908B0DF;
    {$ENDIF}
  {$ENDIF}

{$IFDEF CPUX64}

// initializes mt[n] with a seed
procedure mt19937_seed (ASeed: UInt64);
// rcx | seed |
// rdx |      |
// r8  |      |
// r9  |      |
asm
        lea     r11, mt64                       // r11 = @mt64

        test    rcx, rcx
        jnz     @e

        rdtsc                                   // eax:edx = processor's time-stamp counter
        mov     rcx, rdx
        xor     rcx, rsp
        shl     rcx, 32
        or      rcx, rax

    @e:
        mov     rax, rcx                        // rax = seed
        mov     [r11], rax                      // mt[0] = seed

        mov     r10, 1                          // mti = r10
        mov     rcx, 6364136223846793005
    @a:                                         // for (mti=1; mti<N; mti++) {...}
        mov     rdx, rax                        // rdx = mt[mti-1]
        shr     rdx, 62                         // rdx = mt[mti-1] >> 62
        xor     rax, rdx                        // rax = mt[mti-1] ^ (mt[mti-1] >> 62)
        mul     rcx                             // rax = (mt[mti-1] ^ (mt[mti-1] >> 62)) * 6364136223846793005
        add     rax, r10                        // rax = (mt[mti-1] ^ (mt[mti-1] >> 62)) * 6364136223846793005 + mti
        mov     [r11 + r10*8], rax              // mt[mti] = rax
    @a_next:
        inc     r10
        cmp     r10, mt64_n
        jb      @a

        mov     mti, r10
end;

{$ELSE}

// initializes mt[n] with a seed
procedure mt19937_seed (ASeed: Cardinal);
// eax | seed |
// edx |      |
// ecx |      |
//     |      |
asm
        push    ebx
        push    edi

        lea     edi, mt32                       // edi = @mt32
     // mov     eax, [seed]                     // eax = seed

        test    eax, eax
        jnz     @e

        {$IFDEF __RDTSC}
        rdtsc                                   // eax:edx = processor's time-stamp counter
        {$ELSE}
     // rdtsc
        DB      $0F, $31
        {$ENDIF}
        xor     eax, edx

    @e:
        mov     [edi], eax                      // mt[0] = seed

        mov     ebx, 1                          // mti = ebx
        mov     ecx, 1812433253
    @a:                                         // for (mti=1; mti<N; mti++) {...}
        mov     edx, eax                        // edx = mt[mti-1]
        shr     edx, 30                         // edx = mt[mti-1] >> 30
        xor     eax, edx                        // eax = mt[mti-1] ^ (mt[mti-1] >> 30)
        mul     ecx                             // eax = (mt[mti-1] ^ (mt[mti-1] >> 30)) * 1812433253
        add     eax, ebx                        // eax = (mt[mti-1] ^ (mt[mti-1] >> 30)) * 1812433253 + mti
        mov     [edi + ebx*4], eax              // mt[mti] = eax
    @a_next:
        inc     ebx
        cmp     ebx, mt32_n
        jb      @a

        mov     mti, ebx

        pop     edi
        pop     ebx
end;

{$ENDIF}

{$IFDEF CPUX64}

// initializes mt[n] with an array of seeds
procedure mt19937_seeds (ASeeds: Pointer; ACount: UInt64);
// rcx | seeds |
// rdx | count |
// r8  |       |
// r9  |       |
var
  vseeds : UInt64;
  vcount : UInt64;
asm
        mov     [vseeds], rcx
        mov     [vcount], rdx

        mov     rcx, 19650218
        call    mt19937_seed

        mov     rcx, [vcount]
        cmp     rcx, 0
        jle     @return

    @enter:
        push    rsi

        mov     rsi, [vseeds]
        test    rsi, rsi
        jz      @leave

        lea     r11, mt64                       // r11 = @mt64

        mov     r8, 1                           // i = r8
        xor     r9, r9                          // j = r9

        cmp     rcx, mt64_n                     // rcx = count
        jae     @main
        mov     rcx, mt64_n                     // rcx = max(mt64_n,count)

    @main:
        mov     r10, 3935559000370003845
    @a:                                         // for (; k; k--) {...}
        mov     rax, [r11 + r8*8 - 8]           // rax = mt[i-1]
        mov     rdx, rax                        // rdx = mt[i-1]
        shr     rdx, 62                         // rdx = mt[i-1] >> 62
        xor     rax, rdx                        // rax = mt[i-1] ^ (mt[i-1] >> 62)
        mul     r10                             // rax = (mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845
        mov     rdx, [r11 + r8*8]               // rdx = mt[i]
        xor     rax, rdx                        // rax = mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845)
        add     rax, r9                         // rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845)) + j
        mov     rdx, [rsi + r9*8]               // rdx = seeds[j]
        add     rax, rdx                        // rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 3935559000370003845)) + j + seeds[j]
        mov     [r11 + r8*8], rax               // mt[i] = rax

        inc     r8                              // i++
        inc     r9                              // j++
    @a_i:
        cmp     r8, mt64_n                      // compare i to n
        jb      @a_i_out
    @a_i_ae_n:                                  // i >= n
        mov     rax, [r11 + (mt64_n-1)*8]       // rax = mt[n-1]
        mov     [r11], rax                      // mt[0] = mt[n-1]
        mov     r8, 1                           // i = 1
    @a_i_out:
    @a_j:
        cmp     r9, [vcount]                    // compare j to count
        jb      @a_j_out
    @a_j_ae_count:                              // j >= count
        mov     r9, 0                           // j = 0
    @a_j_out:
    @a_next:
        dec     rcx
        jnz     @a

        mov     rcx, mt64_n-1
        mov     r10, 2862933555777941757
    @b:                                         // for (k=N-1; k; k--) {...}
        mov     rax, [r11 + r8*8 - 8]           // rax = mt[i-1]
        mov     rdx, rax                        // rdx = mt[i-1]
        shr     rdx, 62                         // rdx = (mt[i-1] >> 62)
        xor     rax, rdx                        // rax = (mt[i-1] ^ (mt[i-1] >> 62))
        mul     r10                             // rax = (mt[i-1] ^ (mt[i-1] >> 62)) * 2862933555777941757
        mov     rdx, [r11 + r8*8]               // rdx = mt[i]
        xor     rax, rdx                        // rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 2862933555777941757))
        sub     rax, r8                         // rax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62)) * 2862933555777941757)) - i
        mov     [r11 + r8*8], rax               // mt[i] = rax

        inc     r8                              // i++
    @b_i:
        cmp     r8, mt64_n                      // compare i to n
        jb      @b_i_out
    @b_i_ae_n:                                  // i >= n
        mov     rax, [r11 + (mt64_n-1)*8]       // rax = mt[n-1]
        mov     [r11], rax                      // mt[0] = mt[n-1]
        mov     r8, 1                           // i = 1
    @b_i_out:
    @b_next:
        dec     rcx
        jnz     @b

        mov     rax, $8000000000000000
        mov     [r11], rax                      // mt[0] = 1ULL << 63; /* MSB is 1; assuring non-zero initial array */

    @leave:
        pop     rsi
    @return:
end;

{$ELSE}

// initializes mt[n] with an array of seeds
procedure mt19937_seeds (ASeeds: Pointer; ACount: Cardinal);
// eax | seeds |
// edx | count |
// ecx |       |
//     |       |
var
  vseeds : Cardinal;
  vcount : Cardinal;
  c, j   : Cardinal;
asm
        mov     [vseeds], eax
        mov     [vcount], edx

        mov     eax, 19650218
        call    mt19937_seed

        mov     ecx, [vcount]
        cmp     ecx, 0
        jle     @return

    @enter:
        push    ebx
        push    esi
        push    edi

        mov     esi, [vseeds]
        test    esi, esi
        jz      @leave

        lea     edi, mt32                       // edi = @mt32

        mov     ebx, 1                          // i = ebx
        mov     j, 0                            // j = [.j]

        cmp     ecx, mt32_n                     // ecx = count
        jae     @main
        mov     ecx, mt32_n                     // ecx = max(mt32_n,count)

    @main:
        mov     c, 1664525
    @a:                                         // for (; k; k--) {...}
        mov     eax, [edi + ebx*4 - 4]          // eax = mt[i-1]
        mov     edx, eax                        // edx = mt[i-1]
        shr     edx, 30                         // edx = mt[i-1] >> 30
        xor     eax, edx                        // eax = mt[i-1] ^ (mt[i-1] >> 30)
        mul     c                               // eax = (mt[i-1] ^ (mt[i-1] >> 30)) * 1664525
        mov     edx, [edi + ebx*4]              // edx = mt[i]
        xor     eax, edx                        // eax = mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525)
        mov     edx, j                          // edx = j
        add     eax, edx                        // eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525)) + j
        mov     edx, [esi + edx*4]              // edx = seeds[j]
        add     eax, edx                        // eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525)) + j + seeds[j]
        mov     [edi + ebx*4], eax              // mt[i] = eax

        inc     ebx                             // i++
        inc     j                               // j++
    @a_i:
        cmp     ebx, mt32_n                     // compare i to n
        jb      @a_i_out
    @a_i_ae_n:                                  // i >= n
        mov     eax, [edi + (mt32_n-1)*4]       // eax = mt[n-1]
        mov     [edi], eax                      // mt[0] = mt[n-1]
        mov     ebx, 1                          // i = 1
    @a_i_out:
    @a_j:
        mov     eax, [vcount]
        cmp     j, eax                          // compare j to count
        jb      @a_j_out
    @a_j_ae_count:                              // j >= count
        mov     j, 0                            // j = 0
    @a_j_out:
    @a_next:
        dec     ecx
        jnz     @a

        mov     ecx, mt32_n-1
        mov     esi, 1566083941
    @b:                                         // for (k=N-1; k; k--) {...}
        mov     eax, [edi + ebx*4 - 4]          // eax = mt[i-1]
        mov     edx, eax                        // edx = mt[i-1]
        shr     edx, 30                         // edx = mt[i-1] >> 30
        xor     eax, edx                        // eax = mt[i-1] ^ (mt[i-1] >> 30)
        mul     esi                             // eax = (mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941
        mov     edx, [edi + ebx*4]              // edx = mt[i]
        xor     eax, edx                        // eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941))
        sub     eax, ebx                        // eax = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941)) - i
        mov     [edi + ebx*4], eax              // mt[i] = eax

        inc     ebx                             // i++
    @b_i:
        cmp     ebx, mt32_n                     // compare i to n
        jb      @b_i_out
    @b_i_ae_n:                                  // i >= n
        mov     eax, [edi + (mt32_n-1)*4]       // eax = mt[n-1]
        mov     [edi], eax                      // mt[0] = mt[n-1]
        mov     ebx, 1                          // i = 1
    @b_i_out:
    @b_next:
        dec     ecx
        jnz     @b

        mov     eax, $80000000
        mov     [edi], eax                      // mt[0] = 0x80000000UL; /* MSB is 1; assuring non-zero initial array */

    @leave:
        pop     edi
        pop     esi
        pop     ebx
    @return:
end;

{$ENDIF}

{$IFDEF CPUX64}

// generates a random uint number on [0, 2^64-1]-interval
function mt19937_igen: UInt64;
asm
    @enter:
        lea     r11, mt64                       // r11 = @mt64

        mov     r10, mti
        cmp     r10, mt64_n
        jb      @tempering_x

        cmp     r10, mt64_n+1
        jne     @generate
    @seed:
        // if mt19937_seed() has not been called, a default initial seed is used
        mov     rcx, 5489
        call    mt19937_seed

    @generate:                                  // generate N words at one time
    {$IFDEF __MT_GEN_NO_JUMP}
        lea     rcx, mt64_matrix_A[8]           // rcx = @mt64_matrix_A[0]
    {$ELSE}
        mov     rcx, mt64_matrix_A
    {$ENDIF}

        xor     r10, r10                        // i = r10

    @c:                                         // for (i=0; i<N-M; i++) {...}
        mov     rax, [r11 + r10*8]              // rax = mt[i]
        and     rax, mt64_U_mask                // rax = mt[i] & U_mask
        mov     rdx, [r11 + r10*8 + 8]          // rdx = mt[i+1]
        and     rdx, mt64_L_mask                // rdx = mt[i+1] & L_mask
        or      rax, rdx                        // rax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     rax, 1                          // rax = (rax>>1)
    {$IFDEF __MT_GEN_NO_JUMP}
        sbb     rdx, rdx                        // rdx = ?-1:0
        xor     rax, [rcx + rdx*8]              // rax = (rax>>1) ^ (?matrix_A:0)
    {$ELSE}
        jnc     @c_set
    @c_xor_a:
        xor     rax, rcx                        // rax = (rax>>1) ^ matrix_A
    {$ENDIF}
    @c_set:
        mov     rdx, [r11 + r10*8 + mt64_m*8]   // rdx = mt[i+m]
        xor     rax, rdx                        // rax = (rax) ^ mt[i+m]
        mov     [r11 + r10*8], rax              // mt[i] = rax
    @c_next:
        inc     r10
        cmp     r10, mt64_n-mt64_m
        jb      @c

    @b:                                         // for (; i<N-1; i++) {...}
        mov     rax, [r11 + r10*8]              // rax = mt[i]
        and     rax, mt64_U_mask                // rax = mt[i] & U_mask
        mov     rdx, [r11 + r10*8 + 8]          // rdx = mt[i+1]
        and     rdx, mt64_L_mask                // rdx = mt[i+1] & L_mask
        or      rax, rdx                        // rax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     rax, 1                          // rax = (rax>>1)
    {$IFDEF __MT_GEN_NO_JUMP}
        sbb     rdx, rdx                        // rdx = ?-1:0
        xor     rax, [rcx + rdx*8]              // rax = (rax>>1) ^ (?matrix_A:0)
    {$ELSE}
        jnc     @b_set
    @b_xor_a:
        xor     rax, rcx                        // rax = (rax>>1) ^ matrix_A
    {$ENDIF}
    @b_set:
        mov     rdx, [r11 + r10*8 + mt64_mn*8]  // rdx = mt[i+(m-n)]
        xor     rax, rdx                        // rax = (rax) ^ mt[i+(m-n)]
        mov     [r11 + r10*8], rax              // mt[i] = rax
    @b_next:
        inc     r10
        cmp     r10, mt64_n-1
        jb      @b

    @a:
        mov     rax, [r11 + (mt64_n-1)*8]       // rax = mt[n-1]
        and     rax, mt64_U_mask                // rax = mt[n-1] & U_mask
        mov     rdx, [r11]                      // rdx = mt[0]
        and     rdx, mt64_L_mask                // rdx = mt[0] & L_mask
        or      rax, rdx                        // rax = (mt[n-1] & U_mask) | (mt[0] & L_mask)
        shr     rax, 1                          // rax = (rax>>1)
    {$IFDEF __MT_GEN_NO_JUMP}
        sbb     rdx, rdx                        // rdx = ?-1:0
        xor     rax, [rcx + rdx*8]              // rax = (rax>>1) ^ (?matrix_A:0)
    {$ELSE}
        jnc     @a_set
    @a_xor_a:
        xor     rax, rcx                        // rax = (rax>>1) ^ matrix_A
    {$ENDIF}
    @a_set:
        mov     rdx, [r11 + (mt64_m-1)*8]       // rdx = mt[m-1]
        xor     rax, rdx                        // rax = (rax) ^ (mt[m-1])
        mov     [r11 + (mt64_n-1)*8], rax       // mt[n-1] = rax

        mov     mti, 0

    @tempering:
        mov     r10, mti
    @tempering_x:
        mov     rax, [r11 + r10*8]              // x = mt[mti] = rax
        inc     mti

        mov     rdx, rax                        // x ^= (x >> 29) & 0x5555555555555555ULL;
        shr     rdx, 29
        mov     rcx, $5555555555555555
        and     rdx, rcx
        xor     rax, rdx

        mov     rdx, rax                        // x ^= (x << 17) & 0x71D67FFFEDA60000ULL;
        shl     rdx, 17
        mov     rcx, $71D67FFFEDA60000
        and     rdx, rcx
        xor     rax, rdx

        mov     rdx, rax                        // x ^= (x << 37) & 0xFFF7EEE000000000ULL;
        shl     rdx, 37
        mov     rcx, $FFF7EEE000000000
        and     rdx, rcx
        xor     rax, rdx

        mov     rdx, rax                        // x ^= (x >> 43);
        shr     rdx, 43
        xor     rax, rdx

    @leave:
end;

{$ELSE}

// generates a random uint number on [0, 2^32-1]-interval
function mt19937_igen: Cardinal;
asm
    @enter:
        push    ebx
        push    edi

        lea     edi, mt32                       // edi = @mt32

        mov     ebx, mti
        cmp     ebx, mt32_n
        jb      @tempering_x

        cmp     ebx, mt32_n+1
        jne     @generate
    @seed:
        // if mt19937_seed() has not been called, a default initial seed is used
        mov     eax, 5489
        call    mt19937_seed

    @generate:                                  // generate N words at one time
    {$IFDEF __MT_GEN_NO_JUMP}
        lea     ecx, mt32_matrix_A[4]           // rcx = @mt64_matrix_A[0]
    {$ELSE}
        mov     ecx, mt32_matrix_A
    {$ENDIF}
        xor     ebx, ebx                        // i = ebx

    @c:                                         // for (i=0; i<N-M; i++) {...}
        mov     eax, [edi + ebx*4]              // eax = mt[i]
        and     eax, mt32_U_mask                // eax = mt[i] & U_mask
        mov     edx, [edi + ebx*4 + 4]          // edx = mt[i+1]
        and     edx, mt32_L_mask                // edx = mt[i+1] & L_mask
        or      eax, edx                        // eax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     eax, 1                          // eax = (eax>>1)
    {$IFDEF __MT_GEN_NO_JUMP}
        sbb     edx, edx                        // edx = ?-1:0
        xor     eax, [ecx + edx*4]              // eax = (eax>>1) ^ (?matrix_A:0)
    {$ELSE}
        jnc     @c_set
    @c_xor_a:
        xor     eax, ecx                        // eax = (eax>>1) ^ matrix_A
    {$ENDIF}
    @c_set:
        mov     edx, [edi + ebx*4 + mt32_m*4]   // edx = mt[i+m]
        xor     eax, edx                        // eax = (eax) ^ mt[i+m]
        mov     [edi + ebx*4], eax              // mt[i] = eax
    @c_next:
        inc     ebx
        cmp     ebx, mt32_n-mt32_m
        jb      @c

    @b:                                         // for (; i<N-1; i++) {...}
        mov     eax, [edi + ebx*4]              // eax = mt[i]
        and     eax, mt32_U_mask                // eax = mt[i] & U_mask
        mov     edx, [edi + ebx*4 + 4]          // edx = mt[i+1]
        and     edx, mt32_L_mask                // edx = mt[i+1] & L_mask
        or      eax, edx                        // eax = (mt[i] & U_mask) | (mt[i+1] & L_mask)
        shr     eax, 1                          // eax = (eax>>1)
    {$IFDEF __MT_GEN_NO_JUMP}
        sbb     edx, edx                        // edx = ?-1:0
        xor     eax, [ecx + edx*4]              // eax = (eax>>1) ^ (?matrix_A:0)
    {$ELSE}
        jnc     @b_set
    @b_xor_a:
        xor     eax, ecx                        // eax = (eax>>1) ^ matrix_A
    {$ENDIF}
    @b_set:
        mov     edx, [edi + ebx*4 + mt32_mn*4]  // edx = mt[i+(m-n)]
        xor     eax, edx                        // eax = (eax) ^ mt[i+(m-n)]
        mov     [edi + ebx*4], eax              // mt[i] = eax
    @b_next:
        inc     ebx
        cmp     ebx, mt32_n-1
        jb      @b

    @a:
        mov     eax, [edi + (mt32_n-1)*4]       // eax = mt[n-1]
        and     eax, mt32_U_mask                // eax = mt[n-1] & U_mask
        mov     edx, [edi]                      // edx = mt[0]
        and     edx, mt32_L_mask                // edx = mt[0] & L_mask
        or      eax, edx                        // eax = (mt[n-1] & U_mask) | (mt[0] & L_mask)
        shr     eax, 1                          // eax = (eax>>1)
    {$IFDEF __MT_GEN_NO_JUMP}
        sbb     edx, edx                        // edx = ?-1:0
        xor     eax, [ecx + edx*4]              // eax = (eax>>1) ^ (?matrix_A:0)
    {$ELSE}
        jnc     @a_set
    @a_xor_a:
        xor     eax, ecx                        // eax = (eax>>1) ^ matrix_A
    {$ENDIF}
    @a_set:
        mov     edx, [edi + (mt32_m-1)*4]       // edx = mt[m-1]
        xor     eax, edx                        // eax = (eax) ^ (mt[m-1])
        mov     [edi + (mt32_n-1)*4], eax       // mt[n-1] = eax

        mov     mti, 0

    @tempering:
        mov     ebx, mti
    @tempering_x:
        mov     eax, [edi + ebx*4]              // x = mt[mti] = rax
        inc     mti

        mov     edx, eax                        // x ^= (x >> 11);
        shr     edx, 11
        xor     eax, edx

        mov     edx, eax                        // x ^= (x << 7) & 0x9d2c5680UL;
        shl     edx, 7
        and     edx, $9D2C5680
        xor     eax, edx

        mov     edx, eax                        // x ^= (x << 15) & 0xefc60000UL;
        shl     edx, 15
        and     edx, $EFC60000
        xor     eax, edx

        mov     edx, eax                        // x ^= (x >> 18);
        shr     edx, 18
        xor     eax, edx

    @leave:
        pop     edi
        pop     ebx
end;

{$ENDIF}

{$IFNDEF CPUX64}

// generates a random float number on [0,1)-interval (32-bit resolution)
//
// return genrand_int32()*(1.0/4294967296.0);
//
// a*(2^(-32))
function mt19937_gen0: Double;
asm
        call    mt19937_igen
        mov     [esp - 8], eax                  // a
        mov     dword [esp - 4], 0              // convert unsigned uint32 to int64
        fild    qword [esp - 8]                 // a
        fmul    qword ptr mt_2m32               // a*(2^(-32))
end;

{$ENDIF}

{$IFDEF CPUX64}

// generates a random float number on [0,1)-interval (53-bit resolution)
//
// return (genrand64_int64() >> 11) * (1.0/9007199254740992.0);
//
// a*(2^(-53))
function mt19937_fgen: Double;
asm
        call    mt19937_igen
        shr     rax, 11                         // a
       cvtsi2sd xmm0, rax
        mulsd   xmm0, qword ptr mt_2m53         // a*(2^(-53))
end;

{$ELSE}

// generates a random float number on [0,1)-interval (53-bit resolution)
//
// unsigned long a=genrand_int32()>>5, b=genrand_int32()>>6;
// return(a*67108864.0+b)*(1.0/9007199254740992.0);
//
// (a*(2^26) + b)*(2^(-53))
function mt19937_fgen: Double;
asm
        call    mt19937_igen
        shr     eax, 5                          // a
        push    eax                             // a->
        call    mt19937_igen
        pop     dword [esp - 8]                 // a<-
        shr     eax, 6                          // b
        mov     [esp - 4], eax

        fild    dword [esp - 8]                 // a
        fmul    qword ptr mt_2p26               // a*(2^26)
        fild    dword [esp - 4]                 // b
        faddp                                   // a*(2^26) + b
        fmul    qword ptr mt_2m53               // (a*(2^26) + b)*(2^(-53))
end;

{$ENDIF}

{$IFDEF CPUX64}

// generates a random float number on [0,2•pi)-interval (53-bit resolution)
//
// return (genrand64_int64() >> 11) * (2.0*pi/9007199254740992.0);
//
// a*(2^(-53))*2*pi
function mt19937_fgen2pi: Double;
asm
        call    mt19937_igen
        shr     rax, 11                         // a
       cvtsi2sd xmm0, rax
        mulsd   xmm0, qword ptr mt_2m53_2pi     // a*(2^(-53))*2*pi
end;

{$ELSE}

// generates a random float number on [0,2•pi)-interval (53-bit resolution)
//
// unsigned long a=genrand_int32()>>5, b=genrand_int32()>>6;
// return(a*67108864.0+b)*(2.0*pi/9007199254740992.0);
//
// (a*(2^26) + b)*(2^(-53))*2*pi
function mt19937_fgen2pi: Double;
asm
        call    mt19937_igen
        shr     eax, 5                          // a
        push    eax                             // a->
        call    mt19937_igen
        pop     dword [esp - 8]                 // a<-
        shr     eax, 6                          // b
        mov     [esp - 4], eax

        fild    dword [esp - 8]                 // a
        fmul    qword ptr mt_2p26               // a*(2^26)
        fild    dword [esp - 4]                 // b
        faddp                                   // a*(2^26) + b
        fmul    qword ptr mt_2m53_2pi           // (a*(2^26) + b)*(2^(-53))*2*pi
end;

{$ENDIF}

end.

