unit sfmt_avx2;

// SIMD oriented Fast Mersenne Twister pseudorandom number generator (SFMT)
// CPUID Flags: AVX, AVX2 [AVX512F, AVX512VL]

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

// http://www.math.sci.hiroshima-u.ac.jp/m-mat/MT/SFMT/index.html
// https://github.com/MersenneTwister-Lab/SFMT
// https://github.com/MersenneTwister-Lab/SFMT/archive/refs/tags/1.5.4.zip

{$I version.inc}
{$DEFINE __FOLDING}

{$UNDEF SKIPUNIT}
{$IFDEF VER_LDX11} {$DEFINE SKIPUNIT} {$ENDIF} // Delphi 11 required for AVX2/AVX512 instructions

{$UNDEF __AVX512}
{.$DEFINE __AVX512}

{$IFDEF SKIPUNIT}
interface
implementation
{$ELSE}

interface

uses
  sfmtt;

// asssumed:
//   SFMT_SL1 >= 16
//   SFMT_N % 2 == 0
//   SFMT_POS1 % 2 == 0

const
  sfmt_avx2_disabled = (SFMT_SL1 < 16) or ((SFMT_N and 1) <> 0) or ((SFMT_POS1 and 1) <> 0);
  sfmt_avx2_enabled  = (SFMT_SL1 >= 16) and ((SFMT_N and 1) = 0) and ((SFMT_POS1 and 1) = 0);

// Raise compiler error if sfmt_avx2 is not enabled
{$IF sfmt_avx2_disabled}
{$sfmt_avx2_disabled}
{$IFEND}

procedure sfmt_init;
procedure sfmt_done;

function sfmt_genrand_uint32: UInt32;
function sfmt_genrand_uint64: UInt64;

function sfmt_genrand_real1: Double;
function sfmt_genrand_real2: Double;
function sfmt_genrand_real3: Double;
function sfmt_genrand_res53: Double;
function sfmt_genrand_res53_mix: Double;
function sfmt_genrand_res53a: Double;
function sfmt_genrand_res53a_mix: Double;

implementation

uses
  sfmt, sfmtu;

{
  Allocate 32-byte aligned memory and variables
}
procedure sfmt_init;
var
  P : Pointer;
  U : PAnsiChar absolute P;
begin
  if sfmt_mem <> nil then Exit;

  sfmt_mask_size   := GetN32UInt32 (SizeOf(T_SFMT_MASK));
  sfmt_parity_size := GetN32UInt32 (SizeOf(T_SFMT_PARITY));
  sfmt_state_size  := GetN32UInt32 (16*SFMT_N);

  sfmt_mem_size := sfmt_mask_size + sfmt_parity_size + sfmt_state_size;
  sfmt_mem := GetA32Memory (sfmt_mem_size, P);

  sfmt_mask := P_SFMT_MASK(P);
  U := U + sfmt_mask_size;
  sfmt_parity := P_SFMT_PARITY(P);
  U := U + sfmt_parity_size;
  sfmt_state := P;

  sfmt_mask[0] := SFMT_MSK1;
  sfmt_mask[1] := SFMT_MSK2;
  sfmt_mask[2] := SFMT_MSK3;
  sfmt_mask[3] := SFMT_MSK4;

  sfmt_parity[0] := SFMT_PARITY1;
  sfmt_parity[1] := SFMT_PARITY2;
  sfmt_parity[2] := SFMT_PARITY3;
  sfmt_parity[3] := SFMT_PARITY4;
end;

{
}
procedure sfmt_done;
begin
  if sfmt_mem = nil then Exit;
  FreeMemory (sfmt_mem);

  sfmt_mem    := nil;
  sfmt_mask   := nil;
  sfmt_parity := nil;
  sfmt_state  := nil;
end;

(*
/**
 * This function represents the recursion formula.
 * @param a 256-bit part of the interal state array
 * @param b 256-bit part of the interal state array
 * @param c 256-bit part of the interal state array
 * @return new value
 */
inline static __m256i mm256_recursion(__m256i a, __m256i b, __m256i c)
{
    __m256i x, y, z, w;
    __m256i mask = _mm256_broadcastsi128_si256(sse2_param_mask.si);
    x = _mm256_slli_si256(a, SFMT_SL2);
    y = _mm256_srli_epi32(b, SFMT_SR1);
#if defined(__AVX512VL__)
    x = _mm256_ternarylogic_epi32(x, y, mask, 0x78); // A ^ (B & C)
#else
    y = _mm256_and_si256(y, mask);
    x = _mm256_xor_si256(x, y);
#endif
    z = _mm256_srli_si256(c, SFMT_SR2);
#if defined(__AVX512VL__)
    x = _mm256_ternarylogic_epi32(x, a, z, 0x96); // XOR3(A,B,C)
#else
    x = _mm256_xor_si256(x, a);
    x = _mm256_xor_si256(x, z);
#endif
    w = _mm256_permute2f128_si256(c, x, 0x21);
    w = _mm256_slli_epi32(w, SFMT_SL1);
    x = _mm256_xor_si256(x, w);
    return x;
}
// *)

{
  This function fills the internal state array with pseudorandom integers.
  @param sfmt SFMT internal state
  A_sfmt_state - 32-byte aligned memory
  A_sfmt_mask  - 32-byte aligned memory
}
{$IFDEF CPUX64}
{$IFDEF __FOLDING}
procedure sfmt_avx2_gen_rand_all (A_sfmt_state, A_sfmt_mask: Pointer); register;
// rcx | sfmt_state |   |
// rdx | sfmt_mask  |   |
// r8  |            | i |
// r9  |            |   |
//     |            | r | ymm2
const
  OFF2 = 16*(SFMT_N-2);
  OFFA = 16*(SFMT_POS1);
  OFFB = 16*(SFMT_POS1-SFMT_N);
asm
        xor     r8, r8                          // i = 0
        vmovdqa ymm2, yword [rcx + OFF2]        // r = LD2(&pstate[SFMT_N - 2])

    @LOOP_A: // for (i = 0; i < SFMT_N - SFMT_POS1; i+=2)
        // r = mm256_recursion(LD2(&pstate[i]), LD2(&pstate[i + SFMT_POS1]), r)

        vmovdqa ymm0, yword [rcx]               // LD2(&pstate[i])
        vmovdqa ymm1, yword [rcx + OFFA]        // LD2(&pstate[i + SFMT_POS1])

    {$REGION 'mm256_recursion (a=ymm0, b=ymm1, c=ymm2)'}
    {$IFDEF __AVX512}
        // CPUID Flags: AVX, AVX2, AVX512F, AVX512VL
        VBROADCASTI128  ymm3, DQWORD [rdx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPTERNLOGD      ymm4, ymm1, ymm3, $78   // ymm4 = x | A ^ (B & C)
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPTERNLOGD      ymm4, ymm0, ymm3, $96   // ymm4 = x | XOR3(A,B,C)
        VPERM2F128      ymm1, ymm2, ymm4, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm4, ymm1        // ymm2 = result
    {$ELSE}
        // CPUID Flags: AVX, AVX2
        VBROADCASTI128  ymm3, DQWORD [rdx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPAND           ymm1, ymm1, ymm3        // ymm1 = y
        VPXOR           ymm1, ymm4, ymm1        // ymm1 = x
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPXOR           ymm0, ymm1, ymm0        // ymm0 = x
        VPXOR           ymm0, ymm3, ymm0        // ymm0 = x
        VPERM2F128      ymm1, ymm2, ymm0, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm0, ymm1        // ymm2 = result
    {$ENDIF}
    {$ENDREGION}

        vmovdqa yword [rcx], ymm2               // ST2(&pstate[i], r)

        add     rcx, 32
        add     r8, 2
        cmp     r8, SFMT_N - SFMT_POS1
        jb      @LOOP_A

    @LOOP_B: // for (; i < SFMT_N; i+=2)
        // r = mm256_recursion(LD2(&pstate[i]), LD2(&pstate[i + SFMT_POS1 - SFMT_N]), r)

        vmovdqa ymm0, yword [rcx]               // LD2(&pstate[i])
        vmovdqa ymm1, yword [rcx + OFFB]        // LD2(&pstate[i + SFMT_POS1 - SFMT_N])

    {$REGION 'mm256_recursion (a=ymm0, b=ymm1, c=ymm2)'}
    {$IFDEF __AVX512}
        // CPUID Flags: AVX, AVX2, AVX512F, AVX512VL
        VBROADCASTI128  ymm3, DQWORD [rdx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPTERNLOGD      ymm4, ymm1, ymm3, $78   // ymm4 = x | A ^ (B & C)
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPTERNLOGD      ymm4, ymm0, ymm3, $96   // ymm4 = x | XOR3(A,B,C)
        VPERM2F128      ymm1, ymm2, ymm4, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm4, ymm1        // ymm2 = result
    {$ELSE}
        // CPUID Flags: AVX, AVX2
        VBROADCASTI128  ymm3, DQWORD [rdx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPAND           ymm1, ymm1, ymm3        // ymm1 = y
        VPXOR           ymm1, ymm4, ymm1        // ymm1 = x
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPXOR           ymm0, ymm1, ymm0        // ymm0 = x
        VPXOR           ymm0, ymm3, ymm0        // ymm0 = x
        VPERM2F128      ymm1, ymm2, ymm0, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm0, ymm1        // ymm2 = result
    {$ENDIF}
    {$ENDREGION}

        vmovdqa yword [rcx], ymm2               // ST2(&pstate[i], r)

        add     rcx, 32
        add     r8, 2
        cmp     r8, SFMT_N
        jb      @LOOP_B
end;
{$ENDIF}
{$ELSE}
{$IFDEF __FOLDING}
procedure sfmt_avx2_gen_rand_all (A_sfmt_state, A_sfmt_mask: Pointer); register;
// eax | sfmt_state |   |
// edx | sfmt_mask  |   |
// ecx |            | i |
//     |            | r | ymm2
const
  OFF2 = 16*(SFMT_N-2);
  OFFA = 16*(SFMT_POS1);
  OFFB = 16*(SFMT_POS1-SFMT_N);
asm
        xor     ecx, ecx                        // i = 0
        vmovdqa ymm2, yword [eax + OFF2]        // r = LD2(&pstate[SFMT_N - 2])

    @LOOP_A: // for (i = 0; i < SFMT_N - SFMT_POS1; i+=2)
        // r = mm256_recursion(LD2(&pstate[i]), LD2(&pstate[i + SFMT_POS1]), r)

        vmovdqa ymm0, yword [eax]               // LD2(&pstate[i])
        vmovdqa ymm1, yword [eax + OFFA]        // LD2(&pstate[i + SFMT_POS1])

    {$REGION 'mm256_recursion (a=ymm0, b=ymm1, c=ymm2)'}
    {$IFDEF __AVX512}
        // CPUID Flags: AVX, AVX2, AVX512F, AVX512VL
        VBROADCASTI128  ymm3, DQWORD [edx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPTERNLOGD      ymm4, ymm1, ymm3, $78   // ymm4 = x | A ^ (B & C)
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPTERNLOGD      ymm4, ymm0, ymm3, $96   // ymm4 = x | XOR3(A,B,C)
        VPERM2F128      ymm1, ymm2, ymm4, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm4, ymm1        // ymm2 = result
    {$ELSE}
        // CPUID Flags: AVX, AVX2
        VBROADCASTI128  ymm3, DQWORD [edx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPAND           ymm1, ymm1, ymm3        // ymm1 = y
        VPXOR           ymm1, ymm4, ymm1        // ymm1 = x
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPXOR           ymm0, ymm1, ymm0        // ymm0 = x
        VPXOR           ymm0, ymm3, ymm0        // ymm0 = x
        VPERM2F128      ymm1, ymm2, ymm0, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm0, ymm1        // ymm2 = result
    {$ENDIF}
    {$ENDREGION}

        vmovdqa yword [eax], ymm2               // ST2(&pstate[i], r)

        add     eax, 32
        add     ecx, 2
        cmp     ecx, SFMT_N - SFMT_POS1
        jb      @LOOP_A

    @LOOP_B: // for (; i < SFMT_N; i+=2)
        // r = mm256_recursion(LD2(&pstate[i]), LD2(&pstate[i + SFMT_POS1 - SFMT_N]), r)

        vmovdqa ymm0, yword [eax]               // LD2(&pstate[i])
        vmovdqa ymm1, yword [eax + OFFB]        // LD2(&pstate[i + SFMT_POS1 - SFMT_N])

    {$REGION 'mm256_recursion (a=ymm0, b=ymm1, c=ymm2)'}
    {$IFDEF __AVX512}
        // CPUID Flags: AVX, AVX2, AVX512F, AVX512VL
        VBROADCASTI128  ymm3, DQWORD [edx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPTERNLOGD      ymm4, ymm1, ymm3, $78   // ymm4 = x | A ^ (B & C)
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPTERNLOGD      ymm4, ymm0, ymm3, $96   // ymm4 = x | XOR3(A,B,C)
        VPERM2F128      ymm1, ymm2, ymm4, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm4, ymm1        // ymm2 = result
    {$ELSE}
        // CPUID Flags: AVX, AVX2
        VBROADCASTI128  ymm3, DQWORD [edx]      // ymm3 = mask
        VPSLLDQ         ymm4, ymm0, SFMT_SL2    // ymm4 = x
        VPSRLD          ymm1, ymm1, SFMT_SR1    // ymm1 = y
        VPAND           ymm1, ymm1, ymm3        // ymm1 = y
        VPXOR           ymm1, ymm4, ymm1        // ymm1 = x
        VPSRLDQ         ymm3, ymm2, SFMT_SR2    // ymm3 = z
        VPXOR           ymm0, ymm1, ymm0        // ymm0 = x
        VPXOR           ymm0, ymm3, ymm0        // ymm0 = x
        VPERM2F128      ymm1, ymm2, ymm0, $21   // ymm1 = w
        VPSLLD          ymm1, ymm1, SFMT_SL1    // ymm1 = w
        VPXOR           ymm2, ymm0, ymm1        // ymm2 = result
    {$ENDIF}
    {$ENDREGION}

        vmovdqa yword [eax], ymm2               // ST2(&pstate[i], r)

        add     eax, 32
        add     ecx, 2
        cmp     ecx, SFMT_N
        jb      @LOOP_B
end;
{$ENDIF}
{$ENDIF}

{
  This function generates and returns 32-bit pseudorandom number.
  init_gen_rand or init_by_array must be called before this function.
  @param sfmt SFMT internal state
  @return 32-bit pseudorandom number
}
function sfmt_genrand_uint32: UInt32;
var
  P : PUInt32;
  U : PAnsiChar absolute P;
begin
  P := PUInt32(sfmt_state);

  if sfmt_index >= SFMT_N32 then begin
    sfmt_avx2_gen_rand_all (sfmt_state, sfmt_mask);
    sfmt_index := 0;
  end;

  U := U + (sfmt_index shl 2); // U + 4*sfmt_index
  Inc (sfmt_index);
  Result := P^;
end;

{
  This function generates and returns 64-bit pseudorandom number.
  init_gen_rand or init_by_array must be called before this function.
  The function gen_rand64 should not be called after gen_rand32,
  unless an initialization is again executed.
  @param sfmt SFMT internal state
  @return 64-bit pseudorandom number
}
function sfmt_genrand_uint64: UInt64;
var
  P : PUInt64;
  U : PAnsiChar absolute P;
begin
  P := PUInt64(sfmt_state);

  if sfmt_index >= SFMT_N32 - 1 then begin
    sfmt_avx2_gen_rand_all (sfmt_state, sfmt_mask);
    sfmt_index := 0;
  end;

  U := U + (sfmt_index shl 2); // U + 4*sfmt_index
  Inc (sfmt_index, 2);
  Result := P^;
end;

// =================================================
// The following real versions are due to Isaku Wada
// =================================================

{
  converts an unsigned 32-bit number to a double on [0,1]-real-interval.
  @param v 32-bit unsigned integer
  @return double on [0,1]-real-interval
}
function sfmt_to_real1 (v: UInt32): Double;
const
  F : Double = 1.0/4294967295.0;
begin
  Result := v * F;
  // return v * (1.0/4294967295.0);
  // divided by 2^32-1
end;

{
  generates a random number on [0,1]-real-interval
  @param sfmt SFMT internal state
  @return double on [0,1]-real-interval
}
function sfmt_genrand_real1: Double;
begin
  Result := sfmt_to_real1 (sfmt_genrand_uint32);
end;

{
  converts an unsigned 32-bit integer to a double on [0,1)-real-interval.
  @param v 32-bit unsigned integer
  @return double on [0,1)-real-interval
}
function sfmt_to_real2 (v: UInt32): Double;
const
  F : Double = 1.0/4294967296.0;
begin
  Result := v * F;
  // return v * (1.0/4294967296.0);
  // divided by 2^32
end;

{
  generates a random number on [0,1)-real-interval
  @param sfmt SFMT internal state
  @return double on [0,1)-real-interval
}
function sfmt_genrand_real2: Double;
begin
  Result := sfmt_to_real2 (sfmt_genrand_uint32);
end;

{
  converts an unsigned 32-bit integer to a double on (0,1)-real-interval.
  @param v 32-bit unsigned integer
  @return double on (0,1)-real-interval
}
function sfmt_to_real3 (v: UInt32): Double;
const
  F : Double = 1.0/4294967296.0;
var
  D : Double;
  U : UInt32 absolute D;
begin
  D := 0;
  U := v;
  Result := (D + 0.5) * F;
  // return (((double)v) + 0.5)*(1.0/4294967296.0);
  // divided by 2^32
end;

{
  generates a random number on (0,1)-real-interval
  @param sfmt SFMT internal state
  @return double on (0,1)-real-interval
}
function sfmt_genrand_real3: Double;
begin
  Result := sfmt_to_real3 (sfmt_genrand_uint32);
end;

{
  converts an unsigned 32-bit integer to double on [0,1) with 53-bit resolution.
  @param v 32-bit unsigned integer
  @return double on [0,1)-real-interval with 53-bit resolution.
}
function sfmt_to_res53 (v: UInt64): Double;
const
  F : Double = 1.0/9007199254740992.0;
begin
  Result := (v shr 11) * F;
  // return (v >> 11) * (1.0/9007199254740992.0);
end;

{
  generates a random number on [0,1) with 53-bit resolution
  @param sfmt SFMT internal state
  @return double on [0,1) with 53-bit resolution
}
function sfmt_genrand_res53: Double;
begin
  Result := sfmt_to_res53 (sfmt_genrand_uint64);
end;

// =================================================
// The following function are added by Saito.
// =================================================

{
  generates a random number on [0,1) with 53-bit resolution from two 32 bit integers
}
function sfmt_to_res53_mix (x, y: UInt32): Double;
var
  U   : T_UInt64_LH32;
  U64 : UInt64 absolute U;
begin
  U.LO := x;
  U.HI := y;
  Result := sfmt_to_res53 (U64);
  // return sfmt_to_res53(x | ((uint64_t)y << 32));
end;

{
  generates a random number on [0,1) with 53-bit resolution using two 32bit integers.
  @param sfmt SFMT internal state
  @return double on [0,1) with 53-bit resolution
}
function sfmt_genrand_res53_mix: Double;
var
  x, y : UInt32;
begin
  x := sfmt_genrand_uint32;
  y := sfmt_genrand_uint32;
  Result := sfmt_to_res53_mix (x, y);
end;

// =================================================
// maa
// =================================================

{
  converts an unsigned 64-bit integer to double on [0,1) with 53-bit resolution.
  @param v 64-bit unsigned integer
  @return double on [0,1)-real-interval with 53-bit resolution.
}
function sfmt_to_res53a (v: UInt64): Double;
const
  F : Double = 1.0/9007199254740992.0;
var
  U : T_UInt64_LH32 absolute v;
begin
  U.HI := U.HI and $001FFFFF; // 0000 0000 0001 1111 1111 1111 1111 1111
  Result := v * F;
end;

{
  generates a random number on [0,1) with 53-bit resolution
  @param sfmt SFMT internal state
  @return double on [0,1) with 53-bit resolution
}
function sfmt_genrand_res53a: Double;
begin
  Result := sfmt_to_res53a (sfmt_genrand_uint64);
end;

{
  generates a random number on [0,1) with 53-bit resolution from two 32 bit integers
}
function sfmt_to_res53a_mix (x, y: UInt32): Double;
var
  U   : T_UInt64_LH32;
  U64 : UInt64 absolute U;
begin
  U.LO := x;
  U.HI := y;
  Result := sfmt_to_res53a (U64);
end;

{
  generates a random number on [0,1) with 53-bit resolution using two 32bit integers.
  @param sfmt SFMT internal state
  @return double on [0,1) with 53-bit resolution
}
function sfmt_genrand_res53a_mix: Double;
var
  x, y : UInt32;
begin
  x := sfmt_genrand_uint32;
  y := sfmt_genrand_uint32;
  Result := sfmt_to_res53a_mix (x, y);
end;

{
}
procedure Test32;
const
  C : array [0..3] of UInt32 = ($1234, $5678, $9abc, $def0);
var
  I : Integer;
  R : array [0..9] of UInt32;
  U : array [0..9] of UInt32;
begin
  sfmt_init_gen_rand (1234);
  for I := 0 to Length (R) - 1 do R[I] := sfmt_genrand_uint32;
  sfmt_init_by_array (@C, 4);
  for I := 0 to Length (U) - 1 do U[I] := sfmt_genrand_uint32;
end;

{
}
procedure Test64;
const
  C : array [0..4] of UInt32 = (5, 4, 3, 2, 1);
var
  I : Integer;
  R : array [0..8] of UInt64;
  U : array [0..8] of UInt64;
begin
  sfmt_init_gen_rand (4321);
  for I := 0 to Length (R) - 1 do R[I] := sfmt_genrand_uint64;
  sfmt_init_by_array (@C, 5);
  for I := 0 to Length (U) - 1 do U[I] := sfmt_genrand_uint64;
end;

{
}
procedure Test;
begin
  sfmt_init;
  try
    // Test32;
    // Test64;
  finally
    sfmt_done;
  end;
end;

{
}
function SysIntToStr_(const AValue: Integer): string;
var
  S : ShortString;
begin
  System.STR (AValue, S);
  Result := string(S);
end;

{
}
function Verify: Boolean;
var
  Smsg : string;
begin
  Smsg := '';

  if SFMT_SL1 < 16 then begin
    Smsg := Smsg +  '[SFMT_SL1:' + SysIntToStr_(SFMT_SL1) + ' < 16] ';
  end;

  if (SFMT_N and 1) <> 0 then begin
    Smsg := Smsg +  '[SFMT_N:' + SysIntToStr_(SFMT_N) + ' is ODD] ';
  end;

  if (SFMT_POS1 and 1) <> 0 then begin
    Smsg := Smsg +  '[SFMT_POS1:' + SysIntToStr_(SFMT_POS1) + ' is ODD] ';
  end;

  Result := Smsg = '';
  if not Result then Assert (false, Smsg);
end;

{$ENDIF}
end.
