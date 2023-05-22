unit sfmt;

// SIMD oriented Fast Mersenne Twister pseudorandom number generator (SFMT)
// Common utils

// Copyright � 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
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

interface

uses
  sfmtt;

function sfmt_get_idstring: string;

procedure sfmt_init_gen_rand (ASeed: UInt32);
procedure sfmt_init_by_array (ASeeds: P_SFMT_ARRAY32; ACount: UInt32);

implementation

{
}
function sfmt_get_idstring: string;
begin
  Result := SFMT_IDSTR;
end;

{
 This function certificate the period of 2^(MEXP)
 @param sfmt SFMT internal state
}
procedure period_certification;
var
  P     : PUInt32;
  U     : PAnsiChar absolute P;
  i, j  : UInt32;
  inner : UInt32;
  work  : UInt32;
begin
  P := PUInt32(sfmt_state);

  inner := 0;
  for i := 0 to 3 do begin
    inner := inner xor (P^ and sfmt_parity[i]);
    U := U + 4;
  end;

  i := 16;
  while i > 0 do begin
    inner := inner xor (inner shr i);
    i := i shr 1;
  end;

  inner := inner and 1;
  // check OK
  if inner = 1 then Exit;

  // check NG, and modification
  P := PUInt32(sfmt_state);
  for i := 0 to 3 do begin
    work := 1;
    for j := 0 to 31 do begin
      if (work and sfmt_parity[i]) <> 0 then begin
        P^ := P^ xor work;
        Exit;
      end;
      work := work shl 1;
    end;
    U := U + 4;
  end;
end;

{
  This function initializes the internal state array with a 32-bit integer seed
  @param sfmt SFMT internal state
  @param seed a 32-bit integer used as the seed
}
procedure sfmt_init_gen_rand (ASeed: UInt32);
const
  C : UInt32 = 1812433253;
var
  P : PUInt32;
  U : PAnsiChar absolute P;
  V : UInt32;
  i : UInt32;
begin
  P := PUint32(sfmt_state);
  V := ASeed;
  P^ := ASeed;

  for i := 1 to SFMT_N32 - 1 do begin
    U := U + 4;
    V := C * (V xor (V shr 30)) + i;
    P^ := V;
  end;

  sfmt_index := SFMT_N32;
  period_certification;
end;

{
  This function represents a function used in the initialization by init_by_array.
  @param x 32-bit integer
  @return 32-bit integer
}
function func1 (x: UInt32): UInt32;
const
  C : UInt32 = 1664525;
begin
  Result := (x xor (x shr 27)) * C;
  // return (x ^ (x >> 27)) * (uint32_t)1664525UL;
end;

{
  This function represents a function used in the initialization by init_by_array.
  @param x 32-bit integer
  @return 32-bit integer
}
function func2 (x: UInt32): UInt32;
const
  C : UInt32 = 1566083941;
begin
  Result := (x xor (x shr 27)) * C;
  // return (x ^ (x >> 27)) * (uint32_t)1566083941UL;
end;

{
  This function initializes the internal state array, with an array of 32-bit integers used as the seeds.
  @param sfmt SFMT internal state
  @param init_key the array of 32-bit integers, used as a seed.
  @param key_length the length of init_key.
}
procedure sfmt_init_by_array (ASeeds: P_SFMT_ARRAY32; ACount: UInt32);
var
  P     : P_SFMT_ARRAY32;
  U     : UInt32;
  i, j  : UInt32;
  count : UInt32;
  r     : UInt32;
  lag   : UInt32;
  mid   : UInt32;
  size  : UInt32;
begin
  P := P_SFMT_ARRAY32(sfmt_state);

  size := SFMT_N * 4;
  if size >= 623 then begin
    lag := 11;
  end else
  if size >= 68 then begin
    lag := 7;
  end else
  if size >= 39 then begin
    lag := 5;
  end else begin
    lag := 3;
  end;
  mid := (size - lag) shr 1;

  FillChar (sfmt_state^, sfmt_state_size, $8B);

  if (ACount + 1 > SFMT_N32) then begin
    count := ACount + 1;
  end else begin
    count := SFMT_N32;
  end;

  r := func1 (P[0] xor P[mid] xor P[SFMT_N32 - 1]);
  P[mid] := P[mid] + r;
  r := r + ACount;
  U := mid + lag; P[U] := P[U] + r;
  P[0] := r;

  Dec (count);
  i := 1;
  j := 0;

  while (j < count) and (j < ACount) do begin
    r := func1 (P[i] xor P[(i + mid) mod SFMT_N32] xor P[(i + SFMT_N32 - 1) mod SFMT_N32]);
    U := (i + mid) mod SFMT_N32; P[U] := P[U] + r;
    r := r + ASeeds[j] + i;
    U := (i + mid + lag) mod SFMT_N32; P[U] := P[U] + r;
    P[i] := r;
    i := (i + 1) mod SFMT_N32;
    Inc (j);
  end;

  while j < count do begin
    r := func1 (P[i] xor P[(i + mid) mod SFMT_N32] xor P[(i + SFMT_N32 - 1) mod SFMT_N32]);
    U := (i + mid) mod SFMT_N32; P[U] := P[U] + r;
    r := r + i;
    U := (i + mid + lag) mod SFMT_N32; P[U] := P[U] + r;
    P[i] := r;
    i := (i + 1) mod SFMT_N32;
    Inc (j);
  end;

  for j := 0 to SFMT_N32 - 1 do begin
    r := func2 (P[i] + P[(i + mid) mod SFMT_N32] + P[(i + SFMT_N32 - 1) mod SFMT_N32]);
    U := (i + mid) mod SFMT_N32; P[U] := P[U] xor r;
    r := r - i;
    U := (i + mid + lag) mod SFMT_N32; P[U] := P[U] xor r;
    P[i] := r;
    i := (i + 1) mod SFMT_N32;
  end;

  sfmt_index := SFMT_N32;
  period_certification;
end;

end.

