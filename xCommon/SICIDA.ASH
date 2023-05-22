
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; Instruction Disassembler
; header file

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; Based on ldasm.h and ldasm.c by vol4ok
; https://github.com/vol4ok/libsplice
; @modifier:
; https://github.com/Rprop/LDasm  | r_prop@outlook.com
; https://github.com/rrrfff/LDasm | rrrfff@foxmail.com

; ------------------------------------------------------------------------------

; IDA opcode flags

IDA_INVALID         = 0x00000001
IDA_PREFIX          = 0x00000002
IDA_REX             = 0x00000004
IDA_MODRM           = 0x00000008
IDA_SIB             = 0x00000010
IDA_DISP            = 0x00000020
IDA_IMM             = 0x00000040
IDA_RELATIVE        = 0x00000080
IDA_VEX2            = 0x00000100
IDA_VEX3            = 0x00000200
IDA_EVEX            = 0x00000400

OP_NONE             = 0x00
OP_INVALID          = 0x80

OP_DATA_I8          = 0x01
OP_DATA_I16         = 0x02
OP_DATA_I16_I32     = 0x04
OP_DATA_I16_I32_I64 = 0x08
OP_EXTENDED         = 0x10
OP_RELATIVE         = 0x20
OP_MODRM            = 0x40
OP_PREFIX           = 0x80

; ------------------------------------------------------------------------------

; IDA data

struct T_ida_data
  instr_size    db ?
  flags         dd ?
  prefix_size   db ?
  rex           db ?
  prex_size     db ? ; VEX/EVEX prefix size
  prex_0        db ? ; VEX.2:C5H VEX.3:C4H EVEX:62H
  prex_1        db ?
  prex_2        db ?
  prex_3        db ?
  modrm         db ?
  sib           db ?
  opcode_offset db ?
  opcode_size   db ?
  disp_offset   db ?
  disp_size     db ?
  imm_offset    db ?
  imm_size      db ?
ends

; ------------------------------------------------------------------------------
