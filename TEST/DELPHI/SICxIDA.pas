unit SICxIDA;

// Instruction Disassembler

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

// Based on ldasm.h and ldasm.c by vol4ok
// https://github.com/vol4ok/libsplice
// @modifier:
// https://github.com/Rprop/LDasm  | r_prop@outlook.com
// https://github.com/rrrfff/LDasm | rrrfff@foxmail.com

interface

uses
  Windows, SICxTypes;

// Instruction format:
// | prefix | REX/VEX/EVEX | opcode | modR/M | SIB | disp8/16/32 | imm8/16/32/64 |

const
  // IDA opcode flags
  IDA_INVALID         = $00000001;
  IDA_PREFIX          = $00000002;
  IDA_REX             = $00000004;
  IDA_MODRM           = $00000008;
  IDA_SIB             = $00000010;
  IDA_DISP            = $00000020;
  IDA_IMM             = $00000040;
  IDA_RELATIVE        = $00000080;
  IDA_VEX2            = $00000100;
  IDA_VEX3            = $00000200;
  IDA_EVEX            = $00000400;

const
  OP_NONE             = $00;
  OP_INVALID          = $80;

const
  OP_DATA_I8          = $01;
  OP_DATA_I16         = $02;
  OP_DATA_I16_I32     = $04;
  OP_DATA_I16_I32_I64 = $08;
  OP_EXTENDED         = $10;
  OP_RELATIVE         = $20;
  OP_MODRM            = $40;
  OP_PREFIX           = $80;

const
  IDA_flags : array [0..$FF] of Byte = (
    OP_MODRM,                              { 00 }
    OP_MODRM,                              { 01 }
    OP_MODRM,                              { 02 }
    OP_MODRM,                              { 03 }
    OP_DATA_I8,                            { 04 }
    OP_DATA_I16_I32,                       { 05 }
    OP_NONE,                               { 06 }
    OP_NONE,                               { 07 }
    OP_MODRM,                              { 08 }
    OP_MODRM,                              { 09 }
    OP_MODRM,                              { 0A }
    OP_MODRM,                              { 0B }
    OP_DATA_I8,                            { 0C }
    OP_DATA_I16_I32,                       { 0D }
    OP_NONE,                               { 0E }
    OP_NONE,                               { 0F }

    OP_MODRM,                              { 10 }
    OP_MODRM,                              { 11 }
    OP_MODRM,                              { 12 }
    OP_MODRM,                              { 13 }
    OP_DATA_I8,                            { 14 }
    OP_DATA_I16_I32,                       { 15 }
    OP_NONE,                               { 16 }
    OP_NONE,                               { 17 }
    OP_MODRM,                              { 18 }
    OP_MODRM,                              { 19 }
    OP_MODRM,                              { 1A }
    OP_MODRM,                              { 1B }
    OP_DATA_I8,                            { 1C }
    OP_DATA_I16_I32,                       { 1D }
    OP_NONE,                               { 1E }
    OP_NONE,                               { 1F }

    OP_MODRM,                              { 20 }
    OP_MODRM,                              { 21 }
    OP_MODRM,                              { 22 }
    OP_MODRM,                              { 23 }
    OP_DATA_I8,                            { 24 }
    OP_DATA_I16_I32,                       { 25 }
    OP_PREFIX,                             { 26 }
    OP_NONE,                               { 27 }
    OP_MODRM,                              { 28 }
    OP_MODRM,                              { 29 }
    OP_MODRM,                              { 2A }
    OP_MODRM,                              { 2B }
    OP_DATA_I8,                            { 2C }
    OP_DATA_I16_I32,                       { 2D }
    OP_PREFIX,                             { 2E }
    OP_NONE,                               { 2F }

    OP_MODRM,                              { 30 }
    OP_MODRM,                              { 31 }
    OP_MODRM,                              { 32 }
    OP_MODRM,                              { 33 }
    OP_DATA_I8,                            { 34 }
    OP_DATA_I16_I32,                       { 35 }
    OP_PREFIX,                             { 36 }
    OP_NONE,                               { 37 }
    OP_MODRM,                              { 38 }
    OP_MODRM,                              { 39 }
    OP_MODRM,                              { 3A }
    OP_MODRM,                              { 3B }
    OP_DATA_I8,                            { 3C }
    OP_DATA_I16_I32,                       { 3D }
    OP_PREFIX,                             { 3E }
    OP_NONE,                               { 3F }

    OP_NONE,                               { 40 }
    OP_NONE,                               { 41 }
    OP_NONE,                               { 42 }
    OP_NONE,                               { 43 }
    OP_NONE,                               { 44 }
    OP_NONE,                               { 45 }
    OP_NONE,                               { 46 }
    OP_NONE,                               { 47 }
    OP_NONE,                               { 48 }
    OP_NONE,                               { 49 }
    OP_NONE,                               { 4A }
    OP_NONE,                               { 4B }
    OP_NONE,                               { 4C }
    OP_NONE,                               { 4D }
    OP_NONE,                               { 4E }
    OP_NONE,                               { 4F }

    OP_NONE,                               { 50 }
    OP_NONE,                               { 51 }
    OP_NONE,                               { 52 }
    OP_NONE,                               { 53 }
    OP_NONE,                               { 54 }
    OP_NONE,                               { 55 }
    OP_NONE,                               { 56 }
    OP_NONE,                               { 57 }
    OP_NONE,                               { 58 }
    OP_NONE,                               { 59 }
    OP_NONE,                               { 5A }
    OP_NONE,                               { 5B }
    OP_NONE,                               { 5C }
    OP_NONE,                               { 5D }
    OP_NONE,                               { 5E }
    OP_NONE,                               { 5F }

    OP_NONE,                               { 60 }
    OP_NONE,                               { 61 }
    OP_MODRM,                              { 62 }
    OP_MODRM,                              { 63 }
    OP_PREFIX,                             { 64 }
    OP_PREFIX,                             { 65 }
    OP_PREFIX,                             { 66 }
    OP_PREFIX,                             { 67 }
    OP_DATA_I16_I32,                       { 68 }
    OP_MODRM or OP_DATA_I16_I32,           { 69 }
    OP_DATA_I8,                            { 6A }
    OP_MODRM or OP_DATA_I8,                { 6B }
    OP_NONE,                               { 6C }
    OP_NONE,                               { 6D }
    OP_NONE,                               { 6E }
    OP_NONE,                               { 6F }

    OP_RELATIVE or OP_DATA_I8,             { 70 }
    OP_RELATIVE or OP_DATA_I8,             { 71 }
    OP_RELATIVE or OP_DATA_I8,             { 72 }
    OP_RELATIVE or OP_DATA_I8,             { 73 }
    OP_RELATIVE or OP_DATA_I8,             { 74 }
    OP_RELATIVE or OP_DATA_I8,             { 75 }
    OP_RELATIVE or OP_DATA_I8,             { 76 }
    OP_RELATIVE or OP_DATA_I8,             { 77 }
    OP_RELATIVE or OP_DATA_I8,             { 78 }
    OP_RELATIVE or OP_DATA_I8,             { 79 }
    OP_RELATIVE or OP_DATA_I8,             { 7A }
    OP_RELATIVE or OP_DATA_I8,             { 7B }
    OP_RELATIVE or OP_DATA_I8,             { 7C }
    OP_RELATIVE or OP_DATA_I8,             { 7D }
    OP_RELATIVE or OP_DATA_I8,             { 7E }
    OP_RELATIVE or OP_DATA_I8,             { 7F }

    OP_MODRM or OP_DATA_I8,                { 80 }
    OP_MODRM or OP_DATA_I16_I32,           { 81 }
    OP_MODRM or OP_DATA_I8,                { 82 }
    OP_MODRM or OP_DATA_I8,                { 83 }
    OP_MODRM,                              { 84 }
    OP_MODRM,                              { 85 }
    OP_MODRM,                              { 86 }
    OP_MODRM,                              { 87 }
    OP_MODRM,                              { 88 }
    OP_MODRM,                              { 89 }
    OP_MODRM,                              { 8A }
    OP_MODRM,                              { 8B }
    OP_MODRM,                              { 8C }
    OP_MODRM,                              { 8D }
    OP_MODRM,                              { 8E }
    OP_MODRM,                              { 8F }

    OP_NONE,                               { 90 }
    OP_NONE,                               { 91 }
    OP_NONE,                               { 92 }
    OP_NONE,                               { 93 }
    OP_NONE,                               { 94 }
    OP_NONE,                               { 95 }
    OP_NONE,                               { 96 }
    OP_NONE,                               { 97 }
    OP_NONE,                               { 98 }
    OP_NONE,                               { 99 }
    OP_DATA_I16 or OP_DATA_I16_I32,        { 9A }
    OP_NONE,                               { 9B }
    OP_NONE,                               { 9C }
    OP_NONE,                               { 9D }
    OP_NONE,                               { 9E }
    OP_NONE,                               { 9F }

    OP_DATA_I16_I32_I64,                   { A0 } { OP_DATA_I8 }
    OP_DATA_I16_I32_I64,                   { A1 }
    OP_DATA_I16_I32_I64,                   { A2 } { OP_DATA_I8 }
    OP_DATA_I16_I32_I64,                   { A3 }
    OP_NONE,                               { A4 }
    OP_NONE,                               { A5 }
    OP_NONE,                               { A6 }
    OP_NONE,                               { A7 }
    OP_DATA_I8,                            { A8 }
    OP_DATA_I16_I32,                       { A9 }
    OP_NONE,                               { AA }
    OP_NONE,                               { AB }
    OP_NONE,                               { AC }
    OP_NONE,                               { AD }
    OP_NONE,                               { AE }
    OP_NONE,                               { AF }

    OP_DATA_I8,                            { B0 }
    OP_DATA_I8,                            { B1 }
    OP_DATA_I8,                            { B2 }
    OP_DATA_I8,                            { B3 }
    OP_DATA_I8,                            { B4 }
    OP_DATA_I8,                            { B5 }
    OP_DATA_I8,                            { B6 }
    OP_DATA_I8,                            { B7 }
    OP_DATA_I16_I32_I64,                   { B8 }
    OP_DATA_I16_I32_I64,                   { B9 }
    OP_DATA_I16_I32_I64,                   { BA }
    OP_DATA_I16_I32_I64,                   { BB }
    OP_DATA_I16_I32_I64,                   { BC }
    OP_DATA_I16_I32_I64,                   { BD }
    OP_DATA_I16_I32_I64,                   { BE }
    OP_DATA_I16_I32_I64,                   { BF }

    OP_MODRM or OP_DATA_I8,                { C0 }
    OP_MODRM or OP_DATA_I8,                { C1 }
    OP_DATA_I16,                           { C2 }
    OP_NONE,                               { C3 }
    OP_MODRM,                              { C4 }
    OP_MODRM,                              { C5 }
    OP_MODRM or OP_DATA_I8,                { C6 }
    OP_MODRM or OP_DATA_I16_I32,           { C7 }
    OP_DATA_I8 or OP_DATA_I16,             { C8 }
    OP_NONE,                               { C9 }
    OP_DATA_I16,                           { CA }
    OP_NONE,                               { CB }
    OP_NONE,                               { CC }
    OP_DATA_I8,                            { CD }
    OP_NONE,                               { CE }
    OP_NONE,                               { CF }

    OP_MODRM,                              { D0 }
    OP_MODRM,                              { D1 }
    OP_MODRM,                              { D2 }
    OP_MODRM,                              { D3 }
    OP_DATA_I8,                            { D4 }
    OP_DATA_I8,                            { D5 }
    OP_NONE,                               { D6 }
    OP_NONE,                               { D7 }
    OP_MODRM,                              { D8 }
    OP_MODRM,                              { D9 }
    OP_MODRM,                              { DA }
    OP_MODRM,                              { DB }
    OP_MODRM,                              { DC }
    OP_MODRM,                              { DD }
    OP_MODRM,                              { DE }
    OP_MODRM,                              { DF }

    OP_RELATIVE or OP_DATA_I8,             { E0 }
    OP_RELATIVE or OP_DATA_I8,             { E1 }
    OP_RELATIVE or OP_DATA_I8,             { E2 }
    OP_RELATIVE or OP_DATA_I8,             { E3 }
    OP_DATA_I8,                            { E4 }
    OP_DATA_I8,                            { E5 }
    OP_DATA_I8,                            { E6 }
    OP_DATA_I8,                            { E7 }
    OP_RELATIVE or OP_DATA_I16_I32,        { E8 }
    OP_RELATIVE or OP_DATA_I16_I32,        { E9 }
    OP_DATA_I16 or OP_DATA_I16_I32,        { EA }
    OP_RELATIVE or OP_DATA_I8,             { EB }
    OP_NONE,                               { EC }
    OP_NONE,                               { ED }
    OP_NONE,                               { EE }
    OP_NONE,                               { EF }

    OP_PREFIX,                             { F0 }
    OP_NONE,                               { F1 }
    OP_PREFIX,                             { F2 }
    OP_PREFIX,                             { F3 }
    OP_NONE,                               { F4 }
    OP_NONE,                               { F5 }
    OP_MODRM,                              { F6 }
    OP_MODRM,                              { F7 }
    OP_NONE,                               { F8 }
    OP_NONE,                               { F9 }
    OP_NONE,                               { FA }
    OP_NONE,                               { FB }
    OP_NONE,                               { FC }
    OP_NONE,                               { FD }
    OP_MODRM,                              { FE }
    OP_MODRM                               { FF }
  );
  IDA_flags_ex : array [0..$FF] of Byte = (
    OP_MODRM,                              { 0F00 }
    OP_MODRM,                              { 0F01 }
    OP_MODRM,                              { 0F02 }
    OP_MODRM,                              { 0F03 }
    OP_INVALID,                            { 0F04 }
    OP_NONE,                               { 0F05 }
    OP_NONE,                               { 0F06 }
    OP_NONE,                               { 0F07 }
    OP_NONE,                               { 0F08 }
    OP_NONE,                               { 0F09 }
    OP_INVALID,                            { 0F0A }
    OP_NONE,                               { 0F0B }
    OP_INVALID,                            { 0F0C }
    OP_MODRM,                              { 0F0D }
    OP_INVALID,                            { 0F0E }
    OP_MODRM or OP_DATA_I8,                { 0F0F } { 3Dnow }

    OP_MODRM,                              { 0F10 }
    OP_MODRM,                              { 0F11 }
    OP_MODRM,                              { 0F12 }
    OP_MODRM,                              { 0F13 }
    OP_MODRM,                              { 0F14 }
    OP_MODRM,                              { 0F15 }
    OP_MODRM,                              { 0F16 }
    OP_MODRM,                              { 0F17 }
    OP_MODRM,                              { 0F18 }
    OP_INVALID,                            { 0F19 }
    OP_INVALID,                            { 0F1A }
    OP_INVALID,                            { 0F1B }
    OP_INVALID,                            { 0F1C }
    OP_INVALID,                            { 0F1D }
    OP_INVALID,                            { 0F1E }
    OP_NONE,                               { 0F1F }

    OP_MODRM,                              { 0F20 }
    OP_MODRM,                              { 0F21 }
    OP_MODRM,                              { 0F22 }
    OP_MODRM,                              { 0F23 }
    OP_MODRM or OP_EXTENDED,               { 0F24 } { SSE5 }
    OP_INVALID,                            { 0F25 }
    OP_MODRM,                              { 0F26 }
    OP_INVALID,                            { 0F27 }
    OP_MODRM,                              { 0F28 }
    OP_MODRM,                              { 0F29 }
    OP_MODRM,                              { 0F2A }
    OP_MODRM,                              { 0F2B }
    OP_MODRM,                              { 0F2C }
    OP_MODRM,                              { 0F2D }
    OP_MODRM,                              { 0F2E }
    OP_MODRM,                              { 0F2F }

    OP_NONE,                               { 0F30 }
    OP_NONE,                               { 0F31 }
    OP_NONE,                               { 0F32 }
    OP_NONE,                               { 0F33 }
    OP_NONE,                               { 0F34 }
    OP_NONE,                               { 0F35 }
    OP_INVALID,                            { 0F36 }
    OP_NONE,                               { 0F37 }
    OP_MODRM or OP_EXTENDED,               { 0F38 }
    OP_INVALID,                            { 0F39 }
    OP_MODRM or OP_EXTENDED or OP_DATA_I8, { 0F3A }
    OP_INVALID,                            { 0F3B }
    OP_INVALID,                            { 0F3C }
    OP_INVALID,                            { 0F3D }
    OP_INVALID,                            { 0F3E }
    OP_INVALID,                            { 0F3F }

    OP_MODRM,                              { 0F40 }
    OP_MODRM,                              { 0F41 }
    OP_MODRM,                              { 0F42 }
    OP_MODRM,                              { 0F43 }
    OP_MODRM,                              { 0F44 }
    OP_MODRM,                              { 0F45 }
    OP_MODRM,                              { 0F46 }
    OP_MODRM,                              { 0F47 }
    OP_MODRM,                              { 0F48 }
    OP_MODRM,                              { 0F49 }
    OP_MODRM,                              { 0F4A }
    OP_MODRM,                              { 0F4B }
    OP_MODRM,                              { 0F4C }
    OP_MODRM,                              { 0F4D }
    OP_MODRM,                              { 0F4E }
    OP_MODRM,                              { 0F4F }

    OP_MODRM,                              { 0F50 }
    OP_MODRM,                              { 0F51 }
    OP_MODRM,                              { 0F52 }
    OP_MODRM,                              { 0F53 }
    OP_MODRM,                              { 0F54 }
    OP_MODRM,                              { 0F55 }
    OP_MODRM,                              { 0F56 }
    OP_MODRM,                              { 0F57 }
    OP_MODRM,                              { 0F58 }
    OP_MODRM,                              { 0F59 }
    OP_MODRM,                              { 0F5A }
    OP_MODRM,                              { 0F5B }
    OP_MODRM,                              { 0F5C }
    OP_MODRM,                              { 0F5D }
    OP_MODRM,                              { 0F5E }
    OP_MODRM,                              { 0F5F }

    OP_MODRM,                              { 0F60 }
    OP_MODRM,                              { 0F61 }
    OP_MODRM,                              { 0F62 }
    OP_MODRM,                              { 0F63 }
    OP_MODRM,                              { 0F64 }
    OP_MODRM,                              { 0F65 }
    OP_MODRM,                              { 0F66 }
    OP_MODRM,                              { 0F67 }
    OP_MODRM,                              { 0F68 }
    OP_MODRM,                              { 0F69 }
    OP_MODRM,                              { 0F6A }
    OP_MODRM,                              { 0F6B }
    OP_MODRM,                              { 0F6C }
    OP_MODRM,                              { 0F6D }
    OP_MODRM,                              { 0F6E }
    OP_MODRM,                              { 0F6F }

    OP_MODRM or OP_DATA_I8,                { 0F70 }
    OP_MODRM or OP_DATA_I8,                { 0F71 }
    OP_MODRM or OP_DATA_I8,                { 0F72 }
    OP_MODRM or OP_DATA_I8,                { 0F73 }
    OP_MODRM,                              { 0F74 }
    OP_MODRM,                              { 0F75 }
    OP_MODRM,                              { 0F76 }
    OP_NONE,                               { 0F77 }
    OP_MODRM,                              { 0F78 }
    OP_MODRM,                              { 0F79 }
    OP_INVALID,                            { 0F7A }
    OP_INVALID,                            { 0F7B }
    OP_MODRM,                              { 0F7C }
    OP_MODRM,                              { 0F7D }
    OP_MODRM,                              { 0F7E }
    OP_MODRM,                              { 0F7F }

    OP_RELATIVE or OP_DATA_I16_I32,        { 0F80 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F81 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F82 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F83 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F84 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F85 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F86 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F87 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F88 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F89 }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F8A }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F8B }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F8C }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F8D }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F8E }
    OP_RELATIVE or OP_DATA_I16_I32,        { 0F8F }

    OP_MODRM,                              { 0F90 }
    OP_MODRM,                              { 0F91 }
    OP_MODRM,                              { 0F92 }
    OP_MODRM,                              { 0F93 }
    OP_MODRM,                              { 0F94 }
    OP_MODRM,                              { 0F95 }
    OP_MODRM,                              { 0F96 }
    OP_MODRM,                              { 0F97 }
    OP_MODRM,                              { 0F98 }
    OP_MODRM,                              { 0F99 }
    OP_MODRM,                              { 0F9A }
    OP_MODRM,                              { 0F9B }
    OP_MODRM,                              { 0F9C }
    OP_MODRM,                              { 0F9D }
    OP_MODRM,                              { 0F9E }
    OP_MODRM,                              { 0F9F }

    OP_NONE,                               { 0FA0 }
    OP_NONE,                               { 0FA1 }
    OP_NONE,                               { 0FA2 }
    OP_MODRM,                              { 0FA3 }
    OP_MODRM or OP_DATA_I8,                { 0FA4 }
    OP_MODRM,                              { 0FA5 }
    OP_INVALID,                            { 0FA6 }
    OP_INVALID,                            { 0FA7 }
    OP_NONE,                               { 0FA8 }
    OP_NONE,                               { 0FA9 }
    OP_NONE,                               { 0FAA }
    OP_MODRM,                              { 0FAB }
    OP_MODRM or OP_DATA_I8,                { 0FAC }
    OP_MODRM,                              { 0FAD }
    OP_MODRM,                              { 0FAE }
    OP_MODRM,                              { 0FAF }

    OP_MODRM,                              { 0FB0 }
    OP_MODRM,                              { 0FB1 }
    OP_MODRM,                              { 0FB2 }
    OP_MODRM,                              { 0FB3 }
    OP_MODRM,                              { 0FB4 }
    OP_MODRM,                              { 0FB5 }
    OP_MODRM,                              { 0FB6 }
    OP_MODRM,                              { 0FB7 }
    OP_MODRM,                              { 0FB8 }
    OP_MODRM,                              { 0FB9 }
    OP_MODRM or OP_DATA_I8,                { 0FBA }
    OP_MODRM,                              { 0FBB }
    OP_MODRM,                              { 0FBC }
    OP_MODRM,                              { 0FBD }
    OP_MODRM,                              { 0FBE }
    OP_MODRM,                              { 0FBF }

    OP_MODRM,                              { 0FC0 }
    OP_MODRM,                              { 0FC1 }
    OP_MODRM or OP_DATA_I8,                { 0FC2 }
    OP_MODRM,                              { 0FC3 }
    OP_MODRM or OP_DATA_I8,                { 0FC4 }
    OP_MODRM or OP_DATA_I8,                { 0FC5 }
    OP_MODRM or OP_DATA_I8,                { 0FC6 }
    OP_MODRM,                              { 0FC7 }
    OP_NONE,                               { 0FC8 }
    OP_NONE,                               { 0FC9 }
    OP_NONE,                               { 0FCA }
    OP_NONE,                               { 0FCB }
    OP_NONE,                               { 0FCC }
    OP_NONE,                               { 0FCD }
    OP_NONE,                               { 0FCE }
    OP_NONE,                               { 0FCF }

    OP_MODRM,                              { 0FD0 }
    OP_MODRM,                              { 0FD1 }
    OP_MODRM,                              { 0FD2 }
    OP_MODRM,                              { 0FD3 }
    OP_MODRM,                              { 0FD4 }
    OP_MODRM,                              { 0FD5 }
    OP_MODRM,                              { 0FD6 }
    OP_MODRM,                              { 0FD7 }
    OP_MODRM,                              { 0FD8 }
    OP_MODRM,                              { 0FD9 }
    OP_MODRM,                              { 0FDA }
    OP_MODRM,                              { 0FDB }
    OP_MODRM,                              { 0FDC }
    OP_MODRM,                              { 0FDD }
    OP_MODRM,                              { 0FDE }
    OP_MODRM,                              { 0FDF }

    OP_MODRM,                              { 0FE0 }
    OP_MODRM,                              { 0FE1 }
    OP_MODRM,                              { 0FE2 }
    OP_MODRM,                              { 0FE3 }
    OP_MODRM,                              { 0FE4 }
    OP_MODRM,                              { 0FE5 }
    OP_MODRM,                              { 0FE6 }
    OP_MODRM,                              { 0FE7 }
    OP_MODRM,                              { 0FE8 }
    OP_MODRM,                              { 0FE9 }
    OP_MODRM,                              { 0FEA }
    OP_MODRM,                              { 0FEB }
    OP_MODRM,                              { 0FEC }
    OP_MODRM,                              { 0FED }
    OP_MODRM,                              { 0FEE }
    OP_MODRM,                              { 0FEF }

    OP_MODRM,                              { 0FF0 }
    OP_MODRM,                              { 0FF1 }
    OP_MODRM,                              { 0FF2 }
    OP_MODRM,                              { 0FF3 }
    OP_MODRM,                              { 0FF4 }
    OP_MODRM,                              { 0FF5 }
    OP_MODRM,                              { 0FF6 }
    OP_MODRM,                              { 0FF7 }
    OP_MODRM,                              { 0FF8 }
    OP_MODRM,                              { 0FF9 }
    OP_MODRM,                              { 0FFA }
    OP_MODRM,                              { 0FFB }
    OP_MODRM,                              { 0FFC }
    OP_MODRM,                              { 0FFD }
    OP_MODRM,                              { 0FFE }
    OP_INVALID                             { 0FFF }
  );

function inda (code: PAnsiChar; var data: TSIC_IDAData; x64: Byte): DWORD;

implementation

{
 Description:
 Instruction disassembler

 Arguments:
 code - pointer to the code
 data - pointer to TSIC_IDAData structure
 x64  - x64=0 for 32-bit, x64!=0 for 64-bit code

 Return:
 instruction size
}
function inda (code: PAnsiChar; var data: TSIC_IDAData; x64: Byte): DWORD;
var
  p      : PAnsiChar;
  c      : AnsiChar;
  cop    : Byte absolute c; // current opcode
  pop    : Byte;            // previous opcode
  nop    : Byte;            // next opcode

  IsVEX2 : Boolean;
  IsVEX3 : Boolean;
  IsEVEX : Boolean;

  flag   : Byte;
  pr_66  : Byte;
  pr_67  : Byte;
  rex_w  : Byte;
  vex_mm : Byte;
  vex_pp : Byte;
  m_mod  : Byte;
  m_ro   : Byte;
  m_rm   : Byte;
begin
  Result := 0;

  // init output data
  data.instr_size := 0;
  data.flags := 0;
  data.prefix_size := 0;
  data.rex := 0;
  data.prex_size := 0;
  data.prex_0 := 0;
  data.prex_1 := 0;
  data.prex_2 := 0;
  data.prex_3 := 0;
  data.modrm := 0;
  data.sib := 0;
  data.opcode_offset := 0;
  data.opcode_size := 0;
  data.disp_offset := 0;
  data.disp_size := 0;
  data.imm_offset := 0;
  data.imm_size := 0;

  // dummy check
  if code = nil then Exit;

  flag := 0;
  rex_w := 0;
  pr_66 := 0;
  pr_67 := 0;

  // m_mod := 0;
  // m_ro := 0;
  // m_rm := 0;

  p := code; c := p^;

  // phase 1: parse prefixies
  while (IDA_flags[cop] and OP_PREFIX) <> 0 do begin
    if cop = $66 then pr_66 := 1;
    if cop = $67 then pr_67 := 1;
    Inc (p); c := p^;
    Inc (Result);
    Inc (data.prefix_size);
    data.flags := data.flags or IDA_PREFIX;

    if Result = 15 then begin
      data.flags := data.flags or IDA_INVALID;
      Exit;
    end;
  end;

  // ——————————————————————————————————————————————————————————————————
  // Intel® 64 and IA-32 Architectures Software Developer’s Manual V2A
  // ——————————————————————————————————————————————————————————————————
  // 2.3 INTEL® ADVANCED VECTOR EXTENSIONS (INTEL® AVX)
  // 2.3.5.2 VEX Byte 1, bit [7] - ‘R’
  //   VEX Byte 1, bit [7] contains a bit analogous to a bit inverted REX.R.
  //   In protected and compatibility modes the bit must be set to ‘1’ otherwise the instruction is LES or LDS.
  //   This bit is present in both 2- and 3-byte VEX prefixes.
  // 2.3.5.3 3-byte VEX byte 1, bit[6] - ‘X’
  //   Bit[6] of the 3-byte VEX byte 1 encodes a bit analogous to a bit inverted REX.X.
  //   It is an extension of the SIB Index field in 64-bit modes.
  //   In 32-bit modes, this bit must be set to ‘1’ otherwise the instruction is LES or LDS.
  //   This bit is available only in the 3-byte VEX prefix.
  // ——————————————————————————————————————————————————————————————————

  // parse 2-byte VEX prefix
  // ——————————————————————————————————————————————————
  //           |  7    6    5    4    3    2    1    0
  // ——————————————————————————————————————————————————
  //  0 (0xC5) |  1    1    0    0    0    1    0    1
  //  1        | ~R  ~v3  ~v2  ~v1  ~v0    L   p1   p0
  // ——————————————————————————————————————————————————
  if cop = $C5 then begin
    if x64 <> 0 then begin
      IsVEX2 := true;
    end else begin
      nop := BYTE((p + 1)^);
      IsVEX2 := (nop and $80) = $80; // 10000000B
      // x32
      //  IsVEX2: VEX.R = 1B
      // !IsVEX2: 0xC5 = LDS
    end;

    if IsVEX2 then begin
      data.flags := data.flags or IDA_VEX2;
      data.prex_size := 2;
      data.prex_0 := cop;
      data.prex_1 := BYTE((p + 1)^);

      Inc (p, 2); c := p^;
      Inc (Result, 2);

      // Implied mandatory prefix
      // 01B 0x66
      // 10B 0xF3
      // 11B 0xF2
      vex_pp := data.prex_1 and $03; // 0x03 = 00000011B
      if vex_pp = 1 then pr_66 := 1;

      // [0F] <op>
      flag := IDA_flags_ex[cop];

      if (flag and OP_INVALID) <> 0 then begin
        data.flags := data.flags or IDA_INVALID;
        Exit;
      end;
    end;
  end else

  // parse 3-byte VEX prefix
  // ——————————————————————————————————————————————————
  //           |  7    6    5    4    3    2    1    0
  // ——————————————————————————————————————————————————
  //  0 (0xC4) |  1    1    0    0    0    1    0    0
  //  1        | ~R   ~X   ~B   m4   m3   m2   m1   m0
  //  2        |  W  ~v3  ~v2  ~v1  ~v0    L   p1   p0
  // ——————————————————————————————————————————————————
  if cop = $C4 then begin
    if x64 <> 0 then begin
      IsVEX3 := true;
    end else begin
      nop := BYTE((p + 1)^);
      IsVEX3 := (nop and $C0) = $C0; // 11000000B
      // x32
      //  IsVEX3: VEX.RX = 11B
      // !IsVEX3: 0xC4 = LES
    end;

    if IsVEX3 then begin
      data.flags := data.flags or IDA_VEX3;
      data.prex_size := 3;
      data.prex_0 := cop;
      data.prex_1 := BYTE((p + 1)^);
      data.prex_2 := BYTE((p + 2)^);

      Inc (p, 3); c := p^;
      Inc (Result, 3);

      // Implied mandatory prefix
      // 01B 0x66
      // 10B 0xF3
      // 11B 0xF2
      vex_pp := data.prex_2 and $03; // 0x03 = 00000011B
      if vex_pp = 1 then pr_66 := 1;

      // REX.W
      rex_w := (data.prex_2 shr 7) and 1;

      vex_mm := data.prex_1 and $1F; // 0x1F = 00011111B
      if vex_mm = 3 then begin // [0F3A] <op>
        flag := IDA_flags_ex[$3A];
      end else
      if vex_mm = 2 then begin // [0F38] <op>
        flag := IDA_flags_ex[$38];
      end else
      if vex_mm = 1 then begin // [0F] <op>
        flag := IDA_flags_ex[cop];
      end else begin          // <op>
        data.flags := data.flags or IDA_INVALID;
        Exit;
        // flag := IDA_flags[cop];
      end;

      if (flag and OP_INVALID) <> 0 then begin
        data.flags := data.flags or IDA_INVALID;
        Exit;
      end;
    end;
  end else

  // ——————————————————————————————————————————————————————————————————
  // Intel® 64 and IA-32 Architectures Software Developer’s Manual V2A
  // ——————————————————————————————————————————————————————————————————
  // 2.7 INTEL® AVX-512 ENCODING
  // 2.7.11.2 Opcode Independent #UD
  //   Table 2-38. Opcode Independent, State Dependent EVEX Bit Fields
  //   Non-64-bit #UD: BOUND if EVEX.RX != 11b
  // ——————————————————————————————————————————————————————————————————

  // parse 4-byte EVEX prefix
  // ——————————————————————————————————————————————————
  //           |  7    6    5    4    3    2    1    0
  // ——————————————————————————————————————————————————
  //  0 (0x62) |  0    1    1    0    0    0    1    0
  //  1        |  R    X    B    R'   0    0   m1   m0
  //  2        |  W   v3   v2   v1   v0    1   p1   p0
  //  3        |  z    L'   L    b    V'  a2   a1   a0
  // ——————————————————————————————————————————————————
  if cop = $62 then begin
    if x64 <> 0 then begin
      IsEVEX := true;
    end else begin
      nop := BYTE((p + 1)^);
      IsEVEX := (nop and $C0) = $C0; // 11000000B
      // x32
      //  IsEVEX: EVEX.RX = 11B
      // !IsEVEX: 0x62 = BOUND
    end;

    if IsEVEX then begin
      data.flags := data.flags or IDA_EVEX;
      data.prex_size := 4;
      data.prex_0 := cop;
      data.prex_1 := BYTE((p + 1)^);
      data.prex_2 := BYTE((p + 2)^);
      data.prex_3 := BYTE((p + 3)^);

      Inc (p, 4); c := p^;
      Inc (Result, 4);

      // Implied mandatory prefix
      // 01B 0x66
      // 10B 0xF3
      // 11B 0xF2
      vex_pp := data.prex_2 and $03; // 0x03 = 00000011B
      if vex_pp = 1 then pr_66 := 1;

      // REX.W
      rex_w := (data.prex_2 shr 7) and 1;

      vex_mm := data.prex_1 and $03; // 0x03 = 00000011B
      if vex_mm = 3 then begin // [0F3A] <op>
        flag := IDA_flags_ex[$3A];
      end else
      if vex_mm = 2 then begin // [0F38] <op>
        flag := IDA_flags_ex[$38];
      end else
      if vex_mm = 1 then begin // [0F] <op>
        flag := IDA_flags_ex[cop];
      end else begin          // <op>
        data.flags := data.flags or IDA_INVALID;
        Exit;
        // flag := IDA_flags[cop];
      end;

      if (flag and OP_INVALID) <> 0 then begin
        data.flags := data.flags or IDA_INVALID;
        Exit;
      end;
    end;
  end;

  // parse REX prefix
  // —————————————————
  //  7 6 5 4 3 2 1 0
  // —————————————————
  //  0 1 0 0 W R X B
  // —————————————————
  if data.prex_size = 0 then begin
    if x64 <> 0 then begin
      if (cop shr 4) = 4 then begin
        data.flags := data.flags or IDA_REX;
        data.rex := cop;
        rex_w := (data.rex shr 3) and 1;

        Inc (p); c := p^;
        Inc (Result);

        // can be only one REX prefix
        if (cop shr 4) = 4 then begin
          data.flags := data.flags or IDA_INVALID;
          // Inc (Result); // ???
          Exit;
        end;
      end;
    end;
  end;

  // phase 2: parse opcode
  data.opcode_offset := p - code;
  data.opcode_size := 1;

  pop := cop;
  Inc (p); c := p^;
  Inc (Result);

  if data.prex_size = 0 then begin
    // is 2 byte opcode?
    if pop = $0F then begin
      pop := cop;
      Inc (p); c := p^;
      Inc (Result);
      Inc (data.opcode_size);
      flag := IDA_flags_ex[pop];

      if (flag and OP_INVALID) <> 0 then begin
        data.flags := data.flags or IDA_INVALID;
        Exit;
      end;

      // for SSE instructions
      if (flag and OP_EXTENDED) <> 0 then begin
        pop := cop;
        Inc (p); c := p^;
        Inc (Result);
        Inc (data.opcode_size);
      end;
    end else begin
      flag := IDA_flags[pop];
      // pr_66 = pr_67 for opcodes A0-A3
      if (pop >= $A0) and (pop <= $A3) then pr_66 := pr_67;
    end;
  end;

  // phase 3: parse ModR/M, SIB and DISP
  //
  // ModR/M byte
  // —————————————————————————————
  // | MOD   | REG/opcode | R/M  |
  // | **    | ***        | ***  |
  // —————————————————————————————
  //
  // SIB byte
  // —————————————————————————————
  // | SCALE | INDEX      | BASE |
  // | **    | ***        | ***  |
  // —————————————————————————————
  //
  if (flag and OP_MODRM) <> 0 then begin
    m_mod := (cop shr 6);         //       **------
    m_ro  := (cop and $38) shr 3; // $38 = 00111000
    m_rm  := (cop and 7);         // 7   = 00000111

    data.modrm := cop;
    data.flags := data.flags or IDA_MODRM;
    Inc (p); c := p^;
    Inc (Result);

    // in F6, F7 opcodes immediate data present if R/O == 0
    if (m_ro = 0) or (m_ro = 1) then begin // ???
      if pop = $F6 then flag := flag or OP_DATA_I8;
      if pop = $F7 then flag := flag or OP_DATA_I16_I32_I64;
    end;

    // is SIB byte exist?
    // (mod != 3) && (rm == 4) && !(!is64 && pr_67)
    // (mod != 3) && (rm == 4) && (is64 || !pr_67)
    if (m_mod <> 3) and (m_rm = 4) and ((x64 = 1) or (pr_67 = 0)) then begin
      data.sib := cop;
      data.flags := data.flags or IDA_SIB;
      Inc (p); c := p^;
      Inc (Result);

      // if base == 5 and mod == 0
      if ((data.sib and 7) = 5) and (m_mod = 0) then begin
        data.disp_size := 4;
      end;
    end;

    case m_mod of
      0 : begin
        if x64 <> 0 then begin
          if m_rm = 5 then begin
            data.disp_size := 4;
            data.flags := data.flags or IDA_RELATIVE;
          end;
        end else
        if pr_67 <> 0 then begin
          if m_rm = 6 then data.disp_size := 2;
        end else begin
          if m_rm = 5 then data.disp_size := 4;
        end;
      end;

      1 : begin
        data.disp_size := 1;
      end;

      2 : begin
        if x64 <> 0 then begin
          data.disp_size := 4;
        end else
        if pr_67 <> 0 then begin
          data.disp_size := 2;
        end else begin
          data.disp_size := 4;
        end;
      end;
    end;

    if data.disp_size <> 0 then begin
      data.disp_offset := p - code;
      p := p + data.disp_size; c := p^;
      Result := Result + data.disp_size;
      data.flags := data.flags or IDA_DISP;
    end;
  end;

  // phase 4: parse immediate data
  // (f & OP_DATA_I16_I32_I64) && (rexw || (is64 && (op >= 0xA0) && (op <= 0xA3))
  if ((flag and OP_DATA_I16_I32_I64) <> 0) and ((rex_w <> 0) or ((x64 <> 0) and (pop >= $A0) and (pop <= $A3))) then begin
    data.imm_size := 8;
  end else
  // (f & OP_DATA_I16_I32) || (f & OP_DATA_I16_I32_I64)
  if ((flag and OP_DATA_I16_I32) <> 0) or ((flag and OP_DATA_I16_I32_I64) <> 0) then begin
    data.imm_size := 4 - (pr_66 shl 1);
  end;

  // if exist, add OP_DATA_I16 and OP_DATA_I8 size
  data.imm_size := data.imm_size + (flag and 3);

  if data.imm_size <> 0 then begin
    Result := Result + data.imm_size;
    data.imm_offset := p - code;
    data.flags := data.flags or IDA_IMM;
    if (flag and OP_RELATIVE) <> 0 then begin
      data.flags := data.flags or IDA_RELATIVE;
    end;
  end;

  // instruction is too long
  if Result > 15 then begin
    data.flags := data.flags or IDA_INVALID;
  end;
end;

end.

