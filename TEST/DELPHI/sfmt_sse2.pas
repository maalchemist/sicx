unit sfmt_sse2;

// SIMD oriented Fast Mersenne Twister pseudorandom number generator (SFMT)
// CPUID Flags: SSE2

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
{$IFDEF VER_LDXE2} {$DEFINE SKIPUNIT} {$ENDIF} // Delphi XE2 required for SSE2 instructions

{$IFDEF SKIPUNIT}
interface
implementation
{$ELSE}

interface

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
  sfmt, sfmtu, sfmtt;

{
  Allocate 16-byte aligned memory and variables
}
procedure sfmt_init;
var
  P : Pointer;
  U : PAnsiChar absolute P;
begin
  if sfmt_mem <> nil then Exit;

  sfmt_mask_size   := GetN16UInt32 (SizeOf(T_SFMT_MASK));
  sfmt_parity_size := GetN16UInt32 (SizeOf(T_SFMT_PARITY));
  sfmt_state_size  := 16*SFMT_N; // GetN16UInt32 (16*SFMT_N)

  sfmt_mem_size := sfmt_mask_size + sfmt_parity_size + sfmt_state_size;
  sfmt_mem := GetA16Memory (sfmt_mem_size, P);

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
 * @param a a 128-bit part of the interal state array
 * @param b a 128-bit part of the interal state array
 * @param c a 128-bit part of the interal state array
 * @param d a 128-bit part of the interal state array
 * @return new value
 */
inline static __m128i __vectorcall mm_recursion(__m128i a, __m128i b, __m128i c, __m128i d)
{
    __m128i v, x, y, z;
    y = _mm_srli_epi32(b, SFMT_SR1);
    z = _mm_srli_si128(c, SFMT_SR2);
    v = _mm_slli_epi32(d, SFMT_SL1);
    z = _mm_xor_si128(z, a);
    z = _mm_xor_si128(z, v);
    x = _mm_slli_si128(a, SFMT_SL2);
    y = _mm_and_si128(y, sse2_param_mask.si);
    z = _mm_xor_si128(z, x);
    return _mm_xor_si128(z, y);
}
// *)

{
  This function fills the internal state array with pseudorandom integers.
  @param sfmt SFMT internal state
  A_sfmt_state - 16-byte aligned memory
  A_sfmt_mask  - 16-byte aligned memory
}
{$IFDEF CPUX64}
{$IFDEF __FOLDING}
procedure sfmt_sse2_gen_rand_all (A_sfmt_state, A_sfmt_mask: Pointer); register;
// rcx | sfmt_state |    |
// rdx | sfmt_mask  |    |
// r8  |            | i  |
// r9  |            |    |
//     |            | r1 | xmm2
//     |            | r2 | xmm3 xmm4
const
  OFF2 = 16*(SFMT_N-2);
  OFF3 = 16*(SFMT_N-1);
  OFFA = 16*(SFMT_POS1);
  OFFB = 16*(SFMT_POS1-SFMT_N);
asm
        xor     r8, r8                          // i = 0
        movapd  xmm2, dqword [rcx + OFF2]       // r1 = pstate[SFMT_N - 2].si
        movapd  xmm3, dqword [rcx + OFF3]       // r2 = pstate[SFMT_N - 1].si
        movapd  xmm4, xmm3                      // xmm4 = r2

    @LOOP_A: // for (i = 0; i < SFMT_N - SFMT_POS1; i++)
        // pstate[i].si = mm_recursion(pstate[i].si, pstate[i + SFMT_POS1].si, r1, r2)

        movapd  xmm0, dqword [rcx]              // xmm0 = pstate[i].si
        movapd  xmm1, dqword [rcx + OFFA]       // xmm1 = pstate[i + SFMT_POS1].si

    {$REGION 'mm_recursion (a=xmm0, b=xmm1, c=xmm2, d=xmm3)'}
        // CPUID Flags: SSE2
        PSRLD   xmm1, SFMT_SR1                  // xmm1 = y
        PSRLDQ  xmm2, SFMT_SR2                  // xmm2 = z
        PSLLD   xmm3, SFMT_SL1                  // xmm3 = v
        PXOR    xmm2, xmm0                      // xmm2 = z
        PXOR    xmm3, xmm2                      // xmm3 = z
        PSLLDQ  xmm0, SFMT_SL2                  // xmm0 = x
        PAND    xmm1, DQWORD [rdx]              // xmm1 = y
        PXOR    xmm3, xmm0                      // xmm3 = z
        PXOR    xmm3, xmm1                      // xmm3 = result
    {$ENDREGION}

        movapd  dqword [rcx], xmm3              // pstate[i].si = mm_recursion() = xmm3
        movapd  xmm2, xmm4                      // r1 = r2
        movapd  xmm4, xmm3                      // xmm4 = r2

        add     rcx, 16
        inc     r8
        cmp     r8, SFMT_N - SFMT_POS1
        jb      @LOOP_A

    @LOOP_B: // for (; i < SFMT_N; i++)
        // pstate[i].si = mm_recursion(pstate[i].si, pstate[i + SFMT_POS1 - SFMT_N].si, r1, r2)

        movapd  xmm0, dqword [rcx]              // xmm0 = pstate[i].si
        movapd  xmm1, dqword [rcx + OFFB]       // xmm1 = pstate[i + SFMT_POS1 - SFMT_N].si

    {$REGION 'mm_recursion (a=xmm0, b=xmm1, c=xmm2, d=xmm3)'}
        // CPUID Flags: SSE2
        PSRLD   xmm1, SFMT_SR1                  // xmm1 = y
        PSRLDQ  xmm2, SFMT_SR2                  // xmm2 = z
        PSLLD   xmm3, SFMT_SL1                  // xmm3 = v
        PXOR    xmm2, xmm0                      // xmm2 = z
        PXOR    xmm3, xmm2                      // xmm3 = z
        PSLLDQ  xmm0, SFMT_SL2                  // xmm0 = x
        PAND    xmm1, DQWORD [rdx]              // xmm1 = y
        PXOR    xmm3, xmm0                      // xmm3 = z
        PXOR    xmm3, xmm1                      // xmm3 = result
    {$ENDREGION}

        movapd  dqword [rcx], xmm3              // pstate[i].si = mm_recursion() = xmm3
        movapd  xmm2, xmm4                      // r1 = r2
        movapd  xmm4, xmm3                      // xmm4 = r2

        add     rcx, 16
        inc     r8
        cmp     r8, SFMT_N
        jb      @LOOP_B
end;
{$ENDIF}
{$ELSE}
{$IFDEF __FOLDING}
procedure sfmt_sse2_gen_rand_all (A_sfmt_state, A_sfmt_mask: Pointer); register;
// eax | sfmt_state |    |
// edx | sfmt_mask  |    |
// ecx |            | i  |
//     |            | r1 | xmm2
//     |            | r2 | xmm3 xmm4
const
  OFF2 = 16*(SFMT_N-2);
  OFF3 = 16*(SFMT_N-1);
  OFFA = 16*(SFMT_POS1);
  OFFB = 16*(SFMT_POS1-SFMT_N);
asm
        xor     ecx, ecx                        // i = 0
        movapd  xmm2, dqword [eax + OFF2]       // r1 = pstate[SFMT_N - 2].si
        movapd  xmm3, dqword [eax + OFF3]       // r2 = pstate[SFMT_N - 1].si
        movapd  xmm4, xmm3                      // xmm4 = r2

    @LOOP_A: // for (i = 0; i < SFMT_N - SFMT_POS1; i++)
        // pstate[i].si = mm_recursion(pstate[i].si, pstate[i + SFMT_POS1].si, r1, r2)

        movapd  xmm0, dqword [eax]              // xmm0 = pstate[i].si
        movapd  xmm1, dqword [eax + OFFA]       // xmm1 = pstate[i + SFMT_POS1].si

    {$REGION 'mm_recursion (a=xmm0, b=xmm1, c=xmm2, d=xmm3)'}
        // CPUID Flags: SSE2
        PSRLD   xmm1, SFMT_SR1                  // xmm1 = y
        PSRLDQ  xmm2, SFMT_SR2                  // xmm2 = z
        PSLLD   xmm3, SFMT_SL1                  // xmm3 = v
        PXOR    xmm2, xmm0                      // xmm2 = z
        PXOR    xmm3, xmm2                      // xmm3 = z
        PSLLDQ  xmm0, SFMT_SL2                  // xmm0 = x
        PAND    xmm1, DQWORD [edx]              // xmm1 = y
        PXOR    xmm3, xmm0                      // xmm3 = z
        PXOR    xmm3, xmm1                      // xmm3 = result
    {$ENDREGION}

        movapd  dqword [eax], xmm3              // pstate[i].si = mm_recursion() = xmm3
        movapd  xmm2, xmm4                      // r1 = r2
        movapd  xmm4, xmm3                      // xmm4 = r2

        add     eax, 16
        inc     ecx
        cmp     ecx, SFMT_N - SFMT_POS1
        jb      @LOOP_A

    @LOOP_B: // for (; i < SFMT_N; i++)
        // pstate[i].si = mm_recursion(pstate[i].si, pstate[i + SFMT_POS1 - SFMT_N].si, r1, r2)

        movapd  xmm0, dqword [eax]              // xmm0 = pstate[i].si
        movapd  xmm1, dqword [eax + OFFB]       // xmm1 = pstate[i + SFMT_POS1 - SFMT_N].si

    {$REGION 'mm_recursion (a=xmm0, b=xmm1, c=xmm2, d=xmm3)'}
        // CPUID Flags: SSE2
        PSRLD   xmm1, SFMT_SR1                  // xmm1 = y
        PSRLDQ  xmm2, SFMT_SR2                  // xmm2 = z
        PSLLD   xmm3, SFMT_SL1                  // xmm3 = v
        PXOR    xmm2, xmm0                      // xmm2 = z
        PXOR    xmm3, xmm2                      // xmm3 = z
        PSLLDQ  xmm0, SFMT_SL2                  // xmm0 = x
        PAND    xmm1, DQWORD [edx]              // xmm1 = y
        PXOR    xmm3, xmm0                      // xmm3 = z
        PXOR    xmm3, xmm1                      // xmm3 = result
    {$ENDREGION}

        movapd  dqword [eax], xmm3              // pstate[i].si = mm_recursion() = xmm3
        movapd  xmm2, xmm4                      // r1 = r2
        movapd  xmm4, xmm3                      // xmm4 = r2

        add     eax, 16
        inc     ecx
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
    sfmt_sse2_gen_rand_all (sfmt_state, sfmt_mask);
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
    sfmt_sse2_gen_rand_all (sfmt_state, sfmt_mask);
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

{$ENDIF}
end.

