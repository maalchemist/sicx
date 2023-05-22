unit sfmtt;

// SIMD oriented Fast Mersenne Twister pseudorandom number generator (SFMT)
// Types, Constants & Variables

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

interface

{$IF NOT DECLARED(PUInt32)}
type PUInt32 = ^UInt32;
{$IFEND}

{$UNDEF SFMT_MEXP_607}
{$UNDEF SFMT_MEXP_1279}
{$UNDEF SFMT_MEXP_2281}
{$UNDEF SFMT_MEXP_4253}
{$UNDEF SFMT_MEXP_11213}
{$UNDEF SFMT_MEXP_19937}
{$UNDEF SFMT_MEXP_44497}
{$UNDEF SFMT_MEXP_86243}
{$UNDEF SFMT_MEXP_132049}
{$UNDEF SFMT_MEXP_216091}

{.$DEFINE SFMT_MEXP_607}
{.$DEFINE SFMT_MEXP_1279}
{.$DEFINE SFMT_MEXP_2281} // AVX2
{.$DEFINE SFMT_MEXP_4253}
{.$DEFINE SFMT_MEXP_11213}
{$DEFINE SFMT_MEXP_19937} // AVX2
{.$DEFINE SFMT_MEXP_44497}
{.$DEFINE SFMT_MEXP_86243}
{.$DEFINE SFMT_MEXP_132049} // AVX2
{.$DEFINE SFMT_MEXP_216091}

const
{$IFDEF SFMT_MEXP_607}
  SFMT_MEXP    = 607;
  // SFMT_N    = 5;

  SFMT_POS1    = 2;
  SFMT_SL1     = 15;
  SFMT_SL2     = 3;
  SFMT_SR1     = 13;
  SFMT_SR2     = 3;
  SFMT_MSK1    = $fdff37ff;
  SFMT_MSK2    = $ef7f3f7d;
  SFMT_MSK3    = $ff777b7d;
  SFMT_MSK4    = $7ff7fb2f;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $00000000;
  SFMT_PARITY4 = $5986f054;

  SFMT_IDSTR   = 'SFMT-607:2-15-3-13-3:fdff37ff-ef7f3f7d-ff777b7d-7ff7fb2f';
{$ENDIF}

{$IFDEF SFMT_MEXP_1279}
  SFMT_MEXP    = 1279;
  // SFMT_N    = 10;

  SFMT_POS1    = 7;
  SFMT_SL1     = 14;
  SFMT_SL2     = 3;
  SFMT_SR1     = 5;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $f7fefffd;
  SFMT_MSK2    = $7fefcfff;
  SFMT_MSK3    = $aff3ef3f;
  SFMT_MSK4    = $b5ffff7f;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $00000000;
  SFMT_PARITY4 = $20000000;

  SFMT_IDSTR   = 'SFMT-1279:7-14-3-5-1:f7fefffd-7fefcfff-aff3ef3f-b5ffff7f';
{$ENDIF}

{$IFDEF SFMT_MEXP_2281}
  SFMT_MEXP    = 2281;
  // SFMT_N    = 18;

  SFMT_POS1    = 12;
  SFMT_SL1     = 19;
  SFMT_SL2     = 1;
  SFMT_SR1     = 5;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $bff7ffbf;
  SFMT_MSK2    = $fdfffffe;
  SFMT_MSK3    = $f7ffef7f;
  SFMT_MSK4    = $f2f7cbbf;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $00000000;
  SFMT_PARITY4 = $41dfa600;

  SFMT_IDSTR   = 'SFMT-2281:12-19-1-5-1:bff7ffbf-fdfffffe-f7ffef7f-f2f7cbbf';
{$ENDIF}

{$IFDEF SFMT_MEXP_4253}
  SFMT_MEXP    = 4253;
  // SFMT_N    = 34;

  SFMT_POS1    = 17;
  SFMT_SL1     = 20;
  SFMT_SL2     = 1;
  SFMT_SR1     = 7;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $9f7bffff;
  SFMT_MSK2    = $9fffff5f;
  SFMT_MSK3    = $3efffffb;
  SFMT_MSK4    = $fffff7bb;
  SFMT_PARITY1 = $a8000001;
  SFMT_PARITY2 = $af5390a3;
  SFMT_PARITY3 = $b740b3f8;
  SFMT_PARITY4 = $6c11486d;

  SFMT_IDSTR   = 'SFMT-4253:17-20-1-7-1:9f7bffff-9fffff5f-3efffffb-fffff7bb';
{$ENDIF}

{$IFDEF SFMT_MEXP_11213}
  SFMT_MEXP    = 11213;
  // SFMT_N    = 88;

  SFMT_POS1    = 68;
  SFMT_SL1     = 14;
  SFMT_SL2     = 3;
  SFMT_SR1     = 7;
  SFMT_SR2     = 3;
  SFMT_MSK1    = $effff7fb;
  SFMT_MSK2    = $ffffffef;
  SFMT_MSK3    = $dfdfbfff;
  SFMT_MSK4    = $7fffdbfd;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $e8148000;
  SFMT_PARITY4 = $d0c7afa3;

  SFMT_IDSTR   = 'SFMT-11213:68-14-3-7-3:effff7fb-ffffffef-dfdfbfff-7fffdbfd';
{$ENDIF}

{$IFDEF SFMT_MEXP_19937}
  SFMT_MEXP    = 19937;
  // SFMT_N    = 156;

  SFMT_POS1    = 122;
  SFMT_SL1     = 18;
  SFMT_SL2     = 1;
  SFMT_SR1     = 11;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $dfffffef;
  SFMT_MSK2    = $ddfecb7f;
  SFMT_MSK3    = $bffaffff;
  SFMT_MSK4    = $bffffff6;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $00000000;
  SFMT_PARITY4 = $13c9e684;

  SFMT_IDSTR   = 'SFMT-19937:122-18-1-11-1:dfffffef-ddfecb7f-bffaffff-bffffff6';
{$ENDIF}

{$IFDEF SFMT_MEXP_44497}
  SFMT_MEXP    = 44497;
  // SFMT_N    = 348;

  SFMT_POS1    = 330;
  SFMT_SL1     = 5;
  SFMT_SL2     = 3;
  SFMT_SR1     = 9;
  SFMT_SR2     = 3;
  SFMT_MSK1    = $effffffb;
  SFMT_MSK2    = $dfbebfff;
  SFMT_MSK3    = $bfbf7bef;
  SFMT_MSK4    = $9ffd7bff;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $a3ac4000;
  SFMT_PARITY4 = $ecc1327a;

  SFMT_IDSTR   = 'SFMT-44497:330-5-3-9-3:effffffb-dfbebfff-bfbf7bef-9ffd7bff';
{$ENDIF}

{$IFDEF SFMT_MEXP_86243}
  SFMT_MEXP    = 86243;
  // SFMT_N    = 674;

  SFMT_POS1    = 366;
  SFMT_SL1     = 6;
  SFMT_SL2     = 7;
  SFMT_SR1     = 19;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $fdbffbff;
  SFMT_MSK2    = $bff7ff3f;
  SFMT_MSK3    = $fd77efff;
  SFMT_MSK4    = $bf9ff3ff;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $00000000;
  SFMT_PARITY4 = $e9528d85;

  SFMT_IDSTR   = 'SFMT-86243:366-6-7-19-1:fdbffbff-bff7ff3f-fd77efff-bf9ff3ff';
{$ENDIF}

{$IFDEF SFMT_MEXP_132049}
  SFMT_MEXP    = 132049;
  // SFMT_N    = 1032;

  SFMT_POS1    = 110;
  SFMT_SL1     = 19;
  SFMT_SL2     = 1;
  SFMT_SR1     = 21;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $ffffbb5f;
  SFMT_MSK2    = $fb6ebf95;
  SFMT_MSK3    = $fffefffa;
  SFMT_MSK4    = $cff77fff;
  SFMT_PARITY1 = $00000001;
  SFMT_PARITY2 = $00000000;
  SFMT_PARITY3 = $cb520000;
  SFMT_PARITY4 = $c7e91c7d;

  SFMT_IDSTR   = 'SFMT-132049:110-19-1-21-1:ffffbb5f-fb6ebf95-fffefffa-cff77fff';
{$ENDIF}

{$IFDEF SFMT_MEXP_216091}
  SFMT_MEXP    = 216091;
  // SFMT_N    = 1689;

  SFMT_POS1    = 627;
  SFMT_SL1     = 11;
  SFMT_SL2     = 3;
  SFMT_SR1     = 10;
  SFMT_SR2     = 1;
  SFMT_MSK1    = $bff7bff7;
  SFMT_MSK2    = $bfffffff;
  SFMT_MSK3    = $bffffa7f;
  SFMT_MSK4    = $ffddfbfb;
  SFMT_PARITY1 = $f8000001;
  SFMT_PARITY2 = $89e80709;
  SFMT_PARITY3 = $3bd2b64b;
  SFMT_PARITY4 = $0c64b1e4;

  SFMT_IDSTR   = 'SFMT-216091:627-11-3-10-1:bff7bff7-bfffffff-bffffa7f-ffddfbfb';
{$ENDIF}

const
  SFMT_N   = SFMT_MEXP div 128 + 1; // #define SFMT_N (SFMT_MEXP / 128 + 1)
  SFMT_N32 = SFMT_N * 4;
  SFMT_N64 = SFMT_N * 2;

type
  P_SFMT_MASK = ^T_SFMT_MASK;
  T_SFMT_MASK = array [0..3] of UInt32;

  P_SFMT_PARITY = ^T_SFMT_PARITY;
  T_SFMT_PARITY = array [0..3] of UInt32;

  P_SFMT_ARRAY32 = ^T_SFMT_ARRAY32;
  T_SFMT_ARRAY32 = array [0..SFMT_N32-1] of UInt32;

  P_SFMT_ARRAY64 = ^T_SFMT_ARRAY64;
  T_SFMT_ARRAY64 = array [0..SFMT_N64-1] of UInt64;

type
  T_UInt64_LH32 = packed record
    LO : UInt32;
    HI : UInt32;
  end;

  T_UInt64_LH16 = packed record
    LOLO : UInt16;
    LOHI : UInt16;
    HILO : UInt16;
    HIHI : UInt16;
  end;

  T_UInt32_LH16 = packed record
    LO : UInt16;
    HI : UInt16;
  end;

var
  sfmt_mem         : Pointer = nil;
  sfmt_mem_size    : UInt32 = 0;
  sfmt_mask        : P_SFMT_MASK = nil;
  sfmt_mask_size   : UInt32 = 0;
  sfmt_parity      : P_SFMT_PARITY = nil;
  sfmt_parity_size : UInt32 = 0;
  sfmt_state       : Pointer = nil;
  sfmt_state_size  : UInt32 = 0;
  sfmt_index       : UInt32 = 0;

implementation

end.

