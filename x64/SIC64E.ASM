
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; export functions

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_E:

; ------------------------------------------------------------------------------

; DWORD sic_version ( VOID )
;
; compiler version
;
; <- eax : compiler version
;          F0V2V1V0
;          V0 - version L0
;          V1 - version L1
;          V2 - version L2
;          F0 - flags
;               0 : SICx*
;               1 : SICs*
;
$proc sic_version

    $ifdef _SSEX
        ; 6.2.2.1
        mov rax, 0x01020206
        ret
    $else
        ; 6.2.2.0
        mov rax, 0x00020206
        ret
    $end
$endp

; ------------------------------------------------------------------------------

; BOOL sic_cpu_support ( VOID )
;
; compiler support for the CPU
;
; <- eax : 1 - CPU supported
;          0 - CPU not supported
;
$proc sic_cpu_support

    $ifdef _SSEX
   .enter:
        push    rbx                             ; !!! cpuid changes rbx register

   .main:
        mov     rax, 1                          ; Basic CPUID Information
        cpuid                                   ; EAX = 01H
        xor     rax, rax

;  .SSE2:
;       test    edx, 0x04000000                 ; EDX:26 - SSE2 bit
;       jz     .leave

   .SSE3:
        test    ecx, 0x00000001                 ; ECX:00 - SSE3 bit
        jz     .leave

   .SSE4.1:
        test    ecx, 0x00080000                 ; ECX:19 - SSSE4.1 bit
        jz     .leave

   .support:
        inc     rax

   .leave:
        pop     rbx
    $else
        mov     rax, 1
    $end
   .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_va_count ( VOID )
;
; variable argument count
;
; <- rax : variable argument count (r13)
;
$proc sic_va_count

        mov rax, r13
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_setup ( LPVOID config )
;
; setup compiler
;
; <-> config : T_sic_config structure offset
;
; --> config.cflags : compiler configuration flags
;                     SIC_CFG_FLAG_CASE_SENSITIVE
;                     SIC_CFG_FLAG_NO_UDF
;                     SIC_CFG_FLAG_NO_UDC
;                     SIC_CFG_FLAG_NO_UDV
; --> config.memory : memory block size
;                     default = 64K
;                     maximum = 0x00100000 (1024K)
;                     maximum code size = 4 * memory block size
;
; config.cflags = 0
; config.memory = 0
;   case insensitive compiler
;   memory block size = 64K (default)
;
; config.cflags = 0
; config.memory = 0x00100000
;   case insensitive compiler
;   memory block size = 1024K
;
; config.cflags = SIC_CFG_FLAG_CASE_SENSITIVE
; config.memory = 0
;   case sensitive compiler
;   memory block size = 64K (default)
;
$proc sic_setup, config

    macro c
    {
    locals
       .locale  dd ?
    endl
    }

;       mov     [config], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

    .enter:                                     ; !!! cpuid changes rbx register
        pushsa  rbx, rsi                        ; push & 16-byte stack align for x64

;       mov     esi, [config]
        mov     rsi, rcx

    macro c
    {
        mov     [.locale], 0
        lea     rdx, [.locale]
        cinvoke setlocale, 2, rdx               ; setlocale (LC_CTYPE, "")
    }

        test    rsi, rsi                        ; rsi = T_sic_config structure offset
        jz     .return

    .cflags:
        mov     eax, [rsi + T_sic_config.cflags]
        mov     [@_CFG.cflags], eax             ; assign config flags

    .cpuid.enter:
        ;
        mov     rax, 1                          ; Basic CPUID Information
        cpuid                                   ; EAX = 01H
        xor     rax, rax
    .sse?:
        test    edx, 0x02000000                 ; EDX:25 - SSE bit
        jz     .sse.out
        or      rax, SIC_CPU_FLAG_SSE
    .sse.out:
    .sse2?:
        test    edx, 0x04000000                 ; EDX:26 - SSE2 bit
        jz     .sse2.out
        or      rax, SIC_CPU_FLAG_SSE2
    .sse2.out:
    .sse3?:
        test    ecx, 0x00000001                 ; ECX:00 - SSE3 bit
        jz     .sse3.out
        or      rax, SIC_CPU_FLAG_SSE3
    .sse3.out:
    .ssse3?:
        test    ecx, 0x00000200                 ; ECX:09 - SSSE3 bit
        jz     .ssse3.out
        or      rax, SIC_CPU_FLAG_SSSE3
    .ssse3.out:
    .sse4.1?:
        test    ecx, 0x00080000                 ; ECX:19 - SSSE4.1 bit
        jz     .sse4.1.out
        or      rax, SIC_CPU_FLAG_SSE4.1
    .sse4.1.out:
    .sse4.2?:
        test    ecx, 0x00100000                 ; ECX:20 - SSSE4.2 bit
        jz     .sse4.2.out
        or      rax, SIC_CPU_FLAG_SSE4.2
    .sse4.2.out:
    .avx?:
        test    ecx, 0x10000000                 ; ECX:28 - AVX bit
        jz     .avx.out
        or      rax, SIC_CPU_FLAG_AVX
    .avx.out:
    .fma?:
        test    ecx, 0x00001000                 ; ECX:12 - FMA bit
        jz     .fma.out
        or      rax, SIC_CPU_FLAG_FMA
    .fma.out:
    .popcnt?:
        test    ecx, 0x00800000                 ; ECX:23 - POPCNT bit
        jz     .popcnt.out
        or      rax, SIC_CPU_FLAG_POPCNT
    .popcnt.out:
    .rdrand?:
        test    ecx, 0x40000000                 ; ECX:30 - RDRAND bit
        jz     .rdrand.out
        or      rax, SIC_CPU_FLAG_RDRAND
    .rdrand.out:
        ;
        push    rax                             ; Structured Extended Feature Flags Enumeration Leaf
        mov     rax, 0x07                       ; EAX = 07H, ECX = 0
        xor     rcx, rcx
        cpuid
        pop     rax
    .avx2?:
        test    ebx, 0x00000020                 ; EBX:05 - AVX2 bit
        jz     .avx2.out
        or      rax, SIC_CPU_FLAG_AVX2
    .avx2.out:
    .bmi1?:
        test    ebx, 0x00000008                 ; EBX:03 - BMI1 bit
        jz     .bmi1.out
        or      rax, SIC_CPU_FLAG_BMI1
    .bmi1.out:
    .bmi2?:
        test    ebx, 0x00000100                 ; EBX:08 - BMI2 bit
        jz     .bmi2.out
        or      rax, SIC_CPU_FLAG_BMI2
    .bmi2.out:
    .adx?:
        test    ebx, 0x00080000                 ; EBX:19 - ADX bit
        jz     .adx.out
        or      rax, SIC_CPU_FLAG_ADX
    .adx.out:
    .rdseed?:
        test    ebx, 0x00040000                 ; EBX:18 - RDSEED bit
        jz     .rdrand.out
        or      rax, SIC_CPU_FLAG_RDSEED
    .rdseed.out:
    .avx512f?:
        test    ebx, 0x00010000                 ; EBX:16 - AVX512F bit
        jz     .avx512f.out
        or      rax, SIC_CPU_FLAG_AVX512F
    .avx512f.out:
    .avx512vl?:
        test    ebx, 0x80000000                 ; EBX:31 - AVX512VL bit
        jz     .avx512vl.out
        or      rax, SIC_CPU_FLAG_AVX512VL
    .avx512vl.out:
        ;
        push    rax                             ; Processor Extended State Enumeration Main Leaf
        mov     rax, 0x0D                       ; EAX = 0DH, ECX = 0
        xor     rcx, rcx
        cpuid
        mov     rbx, rax
        pop     rax
    .avx512?:
        test    ebx, 0x000000E0                 ; EAX(->EBX):05-07:11100000 - AVX-512 state bits
        jz     .avx512.out
        or      eax, SIC_CPU_FLAG_AVX512
    .avx512.out:
        ;
        push    rax                             ; Extended Function CPUID Information
        mov     rax, 0x80000001                 ; EAX = 80000001H
        cpuid
        pop     rax
    .lzcnt?:
        test    ecx, 0x00000020                 ; ECX:05 - LZCNT bit
        jz     .lzcnt.out
        or      eax, SIC_CPU_FLAG_LZCNT
    .lzcnt.out:
        ;
    .cpuid.leave:
        mov     [@_CFG.cpu_flags], eax          ; assign CPU flags
        mov     [rsi + T_sic_config.cpu_flags], eax

    .memory:
        mov     rdx, [rsi + T_sic_config.memory]
        test    rdx, rdx
        jz     .memory.default
        cmp     rdx, 0x01000000                 ; 16MB
        jbe    .memory.setup
    .memory.default:
        mov     rdx, 0x00010000                 ; rdx = default memory block size (64K)
    .memory.setup:
        mov     [@_CFG.memory], rdx
        mov     [rsi + T_sic_config.memory], rdx
;       mov     rax, rdx
;       shl     rax, 1                          ; fdata_size = 2 * mem_block_size
        lea     rax, [2*rdx]                    ; fdata_size = 2 * mem_block_size
        mov     [@_CFG.fdata_size], rax
        mov     [rsi + T_sic_config.fdata_size], rax
        mov     [@_CFG.cdata_size], rdx         ; cdata_size = mem_block_size
        mov     [rsi + T_sic_config.cdata_size], rdx
        mov     [@_CFG.vdata_size], rdx         ; vdata_size = mem_block_size
        mov     [rsi + T_sic_config.vdata_size], rdx
        mov     [@_CFG.rdata_size], rdx         ; rdata_size = mem_block_size
        mov     [rsi + T_sic_config.rdata_size], rdx

;       push    rdx
;       mov     rax, rdx
;       mov     rcx, 5
;       mul     rcx                             ; rax = 5 * mem_block_size
        lea     rax, [4*rdx + rdx]              ; rax = 5 * mem_block_size
        mov     [@_CFG.stack_size], rax         ; stack_size = 5 * mem_block_size
        mov     [rsi + T_sic_config.stack_size], rax
;       pop     rdx

;       push    rdx
;       mov     rax, rdx
;       mov     rcx, 3
;       mul     rcx                             ; rax = 3 * mem_block_size
        lea     rax, [4*rdx - rdx]              ; rax = 3 * mem_block_size
        mov     [@_CFG.rpn_size], rax           ; rpn_size = 3 * mem_block_size
        mov     [rsi + T_sic_config.rpn_size], rax
;       pop     rdx

        shl     rdx, 2                          ; rdx = 4 * mem_block_size
        mov     [@_CFG.code_size], rdx          ; code_size = 4 * mem_block_size
        mov     [rsi + T_sic_config.code_size], rdx

    .section:
        mov     eax, [@_CFG.section_code]
        mov     [rsi + T_sic_config.section_code], eax

        mov     eax, [@_CFG.section_data]
        mov     [rsi + T_sic_config.section_data], eax

        mov     eax, [@_CFG.section_idata]
        mov     [rsi + T_sic_config.section_idata], eax

        mov     eax, [@_CFG.section_edata]
        mov     [rsi + T_sic_config.section_edata], eax

        mov     eax, [@_CFG.section_rsrc]
        mov     [rsi + T_sic_config.section_rsrc], eax

        mov     eax, [@_CFG.section_reloc]
        mov     [rsi + T_sic_config.section_reloc], eax

    .data:
        mov     eax, [@_CFG.fcode_size]
        mov     [rsi + T_sic_config.fcode_size], eax

        mov     rcx, sizeof.fitem64             ; fdata_count = ?
        mov     rax, [@_CFG.fdata_size]
        sub     rax, sizeof.table.header
        cqo
        idiv    rcx
        mov     [@_CFG.fdata_count], eax        ; fdata_count = (fdata_size - sizeof.table.header) / sizeof.fitem64
        mov     [rsi + T_sic_config.fdata_count], eax

        mov     rcx, sizeof.citem64             ; cdata_count = ?
        mov     rax, [@_CFG.cdata_size]
        sub     rax, sizeof.table.header
        cqo
        idiv    rcx
        mov     [@_CFG.cdata_count], eax        ; cdata_count = (cdata_size - sizeof.table.header) / sizeof.citem64
        mov     [rsi + T_sic_config.cdata_count], eax

        mov     rcx, sizeof.vitem64             ; vdata_count = ?
        mov     rax, [@_CFG.vdata_size]
        sub     rax, sizeof.table.header
        cqo
        idiv    rcx
        mov     [@_CFG.vdata_count], eax        ; vdata_count = (vdata_size - sizeof.table.header) / sizeof.vitem64
        mov     [rsi + T_sic_config.vdata_count], eax

        mov     rcx, sizeof.citem64             ; rdata_count = ?
        mov     rax, [@_CFG.rdata_size]
        sub     rax, sizeof.table.header
        cqo
        idiv    rcx
        mov     [@_CFG.rdata_count], eax        ; rdata_count = (rdata_size - sizeof.table.header) / sizeof.citem64
        mov     [rsi + T_sic_config.rdata_count], eax

        mov     rcx, sizeof.sitem64             ; stack_count = ?
        mov     rax, [@_CFG.stack_size]
        cqo
        idiv    rcx
        mov     [@_CFG.stack_count], eax        ; stack_count = stack_size / sizeof.sitem64
        mov     [rsi + T_sic_config.stack_count], eax

        mov     rcx, sizeof.sitem64             ; rpn_count = ?
        mov     rax, [@_CFG.rpn_size]
        cqo
        idiv    rcx
        dec     rax
        mov     [@_CFG.rpn_count], eax          ; rpn_count = rpn_size / sizeof.sitem64 - 1
        mov     [rsi + T_sic_config.rpn_count], eax

        mov     eax, [@_CFG.fitem_nsize]
        dec     eax                             ; ignore terminating zero
        mov     [rsi + T_sic_config.fitem_nsize], eax

        mov     eax, [@_CFG.citem_nsize]
        dec     eax                             ; ignore terminating zero
        mov     [rsi + T_sic_config.citem_nsize], eax

        mov     eax, [@_CFG.vitem_nsize]
        dec     eax                             ; ignore terminating zero
        mov     [rsi + T_sic_config.vitem_nsize], eax

        mov     eax, [@_CFG.uddata_scount]
        mov     [rsi + T_sic_config.uddata_scount], eax

    .return:
        pop     rsi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_cretab ( VOID )
;
; create global tables
;
$proc sic_cretab

        push    rbx

        stdcall sic_funtac
        stdcall sic_contac
        stdcall sic_vartac
        stdcall sic_runtac

        mov     ebx, [@_CFG.cflags]             ; ebx = config flags

   .funloa:
        test    ebx, SIC_CFG_FLAG_NO_UDF
        jnz    .funloa.out
        stdcall sic_funloa
   .funloa.out:

   .conloa:
        test    ebx, SIC_CFG_FLAG_NO_UDC
        jnz    .conloa.out
        stdcall sic_conloa
   .conloa.out:

   .varloa:
        test    ebx, SIC_CFG_FLAG_NO_UDV
        jnz    .varloa.out
        stdcall sic_varloa
   .varloa.out:

   .return:
        pop     rbx
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_fretab ( VOID )
;
; destroy global tables
;
$proc sic_fretab

        stdcall sic_runtaf
        stdcall sic_varulo
        stdcall sic_vartaf
        stdcall sic_conulo
        stdcall sic_contaf
        stdcall sic_funulo
        stdcall sic_funtaf
   .return:
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_funtac ( VOID )
;
; create global function table
; assign table header and add built-in functions
;
; <- eax : function table item count or zero on error
;
$proc sic_funtac

    locals
       .FO      dq ?
       .AC      dq ?
       .CS      dq ?
       .RT      dq ?
    endl

   .enter:
        push    rbx rsi rdi

        inc     [@_FDATA.REFS]

        cmp     [@_FDATA], 0
        jz     .alloc
        mov     rax, [@_FDATA]                  ; eax = table offset
        mov     eax, [rax + table.header.icount]; eax = table item count
        jmp    .return

    .alloc:
        stdcall halloc, [@_CFG.fdata_size]
        mov     [@_FDATA], rax                  ; rax = table offset
        test    rax, rax
        jz     .return                          ; error. memory allocation error

    .header:                                    ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.fdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.fitem64
        mov     [rax + table.header.tnsize], fitem.nsize
        mov     [rax + table.header.titype], 1

    .GFT.on:
        mov     eax, @_GFT.count
        test    eax, eax
        jz     .GFT.off
        cmp     eax, [@_CFG.fdata_count]
        ja     .GFT.off                         ; error. table size too large

        mov     rsi, @_GFT                      ; add built-in functions
        mov     rdi,-@_GFT.data.size - 1
        mov     rbx, @_GFT.count                ; ebx = item count
    .GFT.afun:
        call   .XFT
    .GFT.off:

    .SFT.on:
        mov     eax, @_SFT.count
        test    eax, eax
        jz     .SFT.off
        add     eax, @_GFT.count
        cmp     eax, [@_CFG.fdata_count]
        ja     .SFT.off                         ; error. table size too large

        mov     rsi, @_SFT                      ; add built-in functions
        mov     rdi,-@_SFT.data.size - 1
        mov     rbx, @_SFT.count                ; ebx = item count
    .SFT.afun:
        call   .XFT
    .SFT.off:

    .result:
        mov     rax, [@_FDATA]                  ; eax = table offset
        mov     eax, [rax + table.header.icount]; eax = table item count

    .return:
        pop     rdi rsi rbx
        ret

$sproc .XFT

    .XFT.afun:
;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + rdi + XFT_data_size + 2]
        add     rsi, rdi
        add     rsi, XFT_data_size + 2          ; rsi = current item name offset

        movzx   rdi, byte [rsi - 1]             ; rdi = current item name size
    .XFT.afun.fo:
      if XFT_offset_size = 4
        mov     ecx, dword [rsi + 1 + rdi]      ; rcx = function entry offset (relative)
      else
        movzx   rcx, word [rsi + 1 + rdi]       ; rcx = function entry offset (relative)
      end if
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10                        ; rcx = function entry offset (absolute)
    $else
        add     ecx, SIC_F_BASE                 ; ecx = function entry offset (absolute)
    $end
        mov     [.FO], rcx                      ; [.FO] = function offset
        ;
    .XFT.afun.ac:
        mov     cl, byte [rsi + 1 + rdi + XFT_offset_size]
        cmp     cl, 0x80
        je     .XFT.afun.ac.vany
        movsx   rax, cl
        jmp    .XFT.afun.ac.assign
    .XFT.afun.ac.vany:
        mov     cx, 0x8000
        movzx   rax, cx
    .XFT.afun.ac.assign:
        mov     [.AC], rax                      ; [.AC] = function argument count
        ;
    .XFT.afun.cs:
        movzx   rax, byte [rsi + 1 + rdi + XFT_offset_size + 1]
        mov     [.CS], rax                      ; [.CS] = function code size
    .XFT.afun.rt:
        movsx   rax, byte [rsi + 1 + rdi + XFT_offset_size + 2]
        mov     [.RT], rax                      ; [.RT] = function return type
    .XFT.taset:
        stdcall taset, [@_FDATA], rsi, [.FO], [.AC], [.CS], [.RT]
        dec     rbx
        jnz    .XFT.afun
        retn
$endp

$endp

; ------------------------------------------------------------------------------

; VOID sic_funtaf ( VOID )
;
; destroy global function table
;
$proc sic_funtaf

        dec     [@_FDATA.REFS]
        cmp     [@_FDATA.REFS], 0
        jg     .return
        mov     [@_FDATA.REFS], 0

        stdcall hfree, [@_FDATA]
        mov     [@_FDATA], 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_funloa ( VOID )
;
; load external user defined functions
;
; <- eax : external function item count

$ifdef _UDF
$proc sic_funloa

       .CBUFFER     EQU 4096

       .CF_ACCESS   = GENERIC_READ + GENERIC_WRITE
       .CF_SHARE    = FILE_SHARE_READ + FILE_SHARE_WRITE
       .CF_FLAGS    = FILE_ATTRIBUTE_ARCHIVE

    locals
       .DC      dd ?
       .IC      dd ?
       .MODULE  dq ?
       .PATH    dq ?
       .FILE    dq ?
       .FSIZE   dd ?
       .BUFFER  dq ?
    endl

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        inc     [@_EF.REFS]

        xor     rax, rax
        cmp     [@_EF.DHL], rax
        jz     .UDF
        mov     eax, [@_EF.IC]
        mov     [.IC], eax
        jmp    .leave.out

   .UDF:
        mov     [@_EF.DC], eax
        mov     [@_EF.IC], eax
        mov     [.DC], eax
        mov     [.IC], eax

   .UDF_FILE:
        stdcall halloc, .CBUFFER
        mov     [.MODULE], rax
        mov     rdi, rax
        stdcall halloc, .CBUFFER
        mov     [.PATH], rax
        mov     rsi, rax
        ; DWORD GetModuleFileName ( HMODULE, LPTSTR, DWORD )
        invoke  GetModuleFileName, 0, rdi, .CBUFFER
        lea     rbx, [.FILE]
        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, rdi, .CBUFFER, rsi, rbx
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, [.FILE], S_UDF_FILE
        cinvoke strcpy, [.FILE], S_UDF_FILE

   .UDF_FILE_CREATE:
        ; HANDLE CreateFile ( LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE )
        invoke  CreateFile, rsi, .CF_ACCESS, .CF_SHARE, NULL, OPEN_EXISTING, .CF_FLAGS, 0
        cmp     rax, INVALID_HANDLE_VALUE
        je     .return
        mov     rdi, rax
        ; DWORD GetFileSize ( HANDLE, LPDWORD )
        invoke  GetFileSize, rdi, NULL
        mov     [.FSIZE], eax
        ; BOOL CloseHandle ( HANDLE )
        invoke  CloseHandle, rdi
        cmp     [.FSIZE], 0
        jle    .return

   .UDF_ALLOC:
        stdcall halloc, [.FSIZE]
        mov     rdi, rax
        mov     [.BUFFER], rdi
   .UDF_READ:
        ; DWORD GetPrivateProfileSectionNames ( LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSectionNames, rdi, [.FSIZE], rsi
        test    eax, eax
        jz     .UDF_FREE
        lea     rbx, [rdi - 1]
   .UDF_TEST:
        mov     eax, [@_CFG.uddata_scount]
        cmp     [.DC], eax
        jg     .UDF_FREE
        lea     rdi, [rbx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .UDF_FREE
        xor     rdx, rdx
        mov     edx, eax
        lea     rbx, [rdi + rdx]
        cmp     byte [rdi], '*'                 ; skip commented item
        je     .UDF_TEST
        cmp     byte [rdi], '#'                 ; skip commented item
        je     .UDF_TEST
        cmp     byte [rdi], ';'                 ; skip commented item
        je     .UDF_TEST
   .UDF_ADD:
        stdcall funloas, rsi, [.FSIZE], rdi
        add     [.IC], eax
        test    rcx, rcx                        ; rcx = library handle
        jz     .UDF_TEST
        push    rcx
        push    rcx
        inc     [.DC]
        jmp    .UDF_TEST
   .UDF_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        xor     rdi, rdi
        mov     edi, [.DC]
        test    rdi, rdi
        jz     .leave
        shl     rdi, 3                          ; rdi = [.DC] * 8
        stdcall halloc, rdi
        mov     [@_EF.DHL], rax
        test    rax, rax
        jnz    .DLL.ADD
   .DLL.FREE:
        sub     rdi, 8
        pop     rcx                             ; rcx = library handle
        pop     rcx                             ; rcx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, rcx
        test    rdi, rdi
        jnz    .DLL.FREE
        jmp    .leave
   .DLL.ADD:
        sub     rdi, 8
        pop     rcx                             ; rcx = library handle
        pop     rcx                             ; rcx = library handle
        mov     [rax + rdi], rcx
        test    rdi, rdi
        jnz    .DLL.ADD
        mov     eax, [.DC]
        mov     [@_EF.DC], eax
   .leave:
        stdcall hfree, [.MODULE]
        stdcall hfree, [.PATH]

   .leave.out:
        mov     eax, [.IC]
        mov     [@_EF.IC], eax
        pop     rdi rsi rbx
        ret
$endp
$else
$proc sic_funloa
        ret
$endp
$end

; ------------------------------------------------------------------------------

; VOID sic_funulo ( VOID )
;
; unload external user defined functions

$ifdef _UDF
$proc sic_funulo

   .enter:
        pushsa  rsi, rdi                        ; push & 16-byte stack align for x64

        dec     [@_EF.REFS]
        cmp     [@_EF.REFS], 0
        jg     .return
        mov     [@_EF.REFS], 0

        xor     rdi, rdi
        mov     edi, [@_EF.DC]
        mov     [@_EF.DC], 0
        mov     [@_EF.IC], 0
        mov     rsi, [@_EF.DHL]
        test    rsi, rsi
        jz     .return
        test    rdi, rdi
        jz     .FREE.DLLs
        shl     rdi, 3                          ; rdi = [.DC] * 8
   .FREE.DLL:
        sub     rdi, 8
        mov     rcx, [rsi + rdi]                ; rcx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, rcx
        test    rdi, rdi
        jnz    .FREE.DLL
   .FREE.DLLs:
        stdcall hfree, [@_EF.DHL]
        mov     [@_EF.DHL], 0

   .return:
        pop     rdi rsi
        ret
$endp
$else
$proc sic_funulo
        ret
$endp
$end

; ------------------------------------------------------------------------------

; DWORD sic_contac ( VOID )
;
; create global constant table
; assign table header and add predefined constants
;
; <- eax : constant table item count or zero on error
;
$proc sic_contac

    locals
       .LO      dq ?
       .HI      dq ?
       .CT      dq ?
    endl

   .enter:
        push    rbx rsi rdi

        inc     [@_CDATA.REFS]

        cmp     [@_CDATA], 0
        jz     .alloc
        mov     rax, [@_CDATA]                  ; rax = table offset
        mov     eax, [rax + table.header.icount]; eax = table item count
        jmp    .return

   .alloc:
        stdcall halloc, [@_CFG.cdata_size]
        mov     [@_CDATA], rax                  ; rax = table offset
        test    rax, rax
        jz     .return                          ; error. memory allocation error

   .header:                                     ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.cdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.citem64
        mov     [rax + table.header.tnsize], citem.nsize
        mov     [rax + table.header.titype], 2

        mov     eax, @_GCT.count
        test    eax, eax
        jz     .result
        cmp     eax, [@_CFG.cdata_count]
        ja     .result                          ; error. table size too large

        mov     rsi, @_GCT                      ; add predefined constants
        mov     rdi,-@_GCT.data.size - 1
        mov     rbx, @_GCT.count
   .acon:
;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + rdi + @_GCT.data.size + 2]
        add     rsi, rdi
        add     rsi, @_GCT.data.size + 2        ; rsi = current item name offset

        movzx   rdi, byte [rsi - 1]             ; rdi = current item name size
        xor     rdx, rdx
        mov     dl, byte [rsi + 9 + rdi]
        mov     [.CT], rdx                      ; [.CT] = constant item type
        mov     edx, dword [rsi + 1 + rdi]
        mov     [.LO], rdx                      ; [.LO] = constant value LO
        mov     edx, dword [rsi + 5 + rdi]
        mov     [.HI], rdx                      ; [.HI] = constant value HI
        stdcall taset, [@_CDATA], rsi, [.LO], [.HI], [.CT], 0
        dec     rbx
        jnz    .acon

   .result:
        mov     rax, [@_CDATA]                  ; rax = table offset
        mov     eax, [rax + table.header.icount]; eax = table item count

   .return:
        pop     rdi rsi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_contaf ( VOID )
;
; destroy global constant table
;
$proc sic_contaf

        dec     [@_CDATA.REFS]
        cmp     [@_CDATA.REFS], 0
        jg     .return
        mov     [@_CDATA.REFS], 0

        stdcall hfree, [@_CDATA]
        mov     [@_CDATA], 0
   .return:
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_conloa ( VOID )
;
; load external user defined constants
;
; <- eax : external constant item count

$ifdef _UDF
$proc sic_conloa

       .CBUFFER     EQU 4096

       .CF_ACCESS   = GENERIC_READ + GENERIC_WRITE
       .CF_SHARE    = FILE_SHARE_READ + FILE_SHARE_WRITE
       .CF_FLAGS    = FILE_ATTRIBUTE_ARCHIVE

    locals
       .IC      dd ?
       .MODULE  dq ?
       .PATH    dq ?
       .FILE    dq ?
       .FSIZE   dd ?
       .BUFFER  dq ?
    endl

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        mov     [.IC], 0

   .UDC_FILE:
        stdcall halloc, .CBUFFER
        mov     [.MODULE], rax
        mov     rdi, rax
        stdcall halloc, .CBUFFER
        mov     [.PATH], rax
        mov     rsi, rax
        ; DWORD GetModuleFileName ( HMODULE, LPTSTR, DWORD )
        invoke  GetModuleFileName, 0, rdi, .CBUFFER
        lea     rbx, [.FILE]
        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, rdi, .CBUFFER, rsi, rbx
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, [.FILE], S_UDC_FILE
        cinvoke strcpy, [.FILE], S_UDC_FILE

   .UDC_FILE_CREATE:
        ; HANDLE CreateFile ( LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE )
        invoke  CreateFile, rsi, .CF_ACCESS, .CF_SHARE, NULL, OPEN_EXISTING, .CF_FLAGS, 0
        cmp     rax, INVALID_HANDLE_VALUE
        je     .return
        mov     rdi, rax
        ; DWORD GetFileSize ( HANDLE, LPDWORD )
        invoke  GetFileSize, rdi, NULL
        mov     [.FSIZE], eax
        ; BOOL CloseHandle ( HANDLE )
        invoke  CloseHandle, rdi
        cmp     [.FSIZE], 0
        jle    .return

   .UDC_ALLOC:
        stdcall halloc, [.FSIZE]
        mov     rdi, rax
        mov     [.BUFFER], rdi
   .UDC_READ:
        ; DWORD GetPrivateProfileSectionNames ( LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSectionNames, rdi, [.FSIZE], rsi
        test    eax, eax
        jz     .UDC_FREE
        lea     rbx, [rdi - 1]
   .UDC_TEST:
        lea     rdi, [rbx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .UDC_FREE
        xor     rdx, rdx
        mov     edx, eax
        lea     rbx, [rdi + rdx]
        cmp     byte [rdi], '*'                 ; skip commented item
        je     .UDC_TEST
        cmp     byte [rdi], '#'                 ; skip commented item
        je     .UDC_TEST
        cmp     byte [rdi], ';'                 ; skip commented item
        je     .UDC_TEST
   .UDC_ADD:
        stdcall conloas, rsi, [.FSIZE], rdi
        add     [.IC], eax
        jmp    .UDC_TEST
   .UDC_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        stdcall hfree, [.MODULE]
        stdcall hfree, [.PATH]
        mov     eax, [.IC]
        pop     rdi rsi rbx
        ret
$endp
$else
$proc sic_conloa
        ret
$endp
$end

; ------------------------------------------------------------------------------

; VOID sic_conulo ( VOID )
;
; unload external user defined constants
;
$proc sic_conulo

        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_vartac ( VOID )
;
; create global variable table
; assign table header and add predefined variables
;
; <- eax : variable table item count or zero on error
;
$proc sic_vartac

    locals
       .OFF     dq ?
    endl

   .enter:
        push    rbx rsi rdi

        inc     [@_VDATA.REFS]

        cmp     [@_VDATA], 0
        jz     .alloc
        mov     rax, [@_VDATA]                  ; rax = table offset
        mov     eax, [rax + table.header.icount]; eax = table item count
        jmp    .return

   .alloc:
        stdcall halloc, [@_CFG.vdata_size]
        mov     [@_VDATA], rax                  ; rax = table offset
        test    rax, rax
        jz     .return                          ; error. memory allocation error

   .header:                                     ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.vdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.vitem64
        mov     [rax + table.header.tnsize], vitem.nsize
        mov     [rax + table.header.titype], 3

   .result:
        mov     rdx, [@_VDATA]                  ; rax = table offset
        xor     rax, rax
        mov     eax, [rdx + table.header.icount]; eax = table item count

   .return:
        pop     rdi rsi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_vartaf ( VOID )
;
; destroy global variable table
;
$proc sic_vartaf

        dec     [@_VDATA.REFS]
        cmp     [@_VDATA.REFS], 0
        jg     .return
        mov     [@_VDATA.REFS], 0

        stdcall hfree, [@_VDATA]
        mov     [@_VDATA], 0
   .return:
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_varloa ( VOID )
;
; load external user defined variables
;
; <- eax : external variable item count

$ifdef _UDF
$proc sic_varloa

       .CBUFFER     EQU 4096

       .CF_ACCESS   = GENERIC_READ + GENERIC_WRITE
       .CF_SHARE    = FILE_SHARE_READ + FILE_SHARE_WRITE
       .CF_FLAGS    = FILE_ATTRIBUTE_ARCHIVE

    locals
       .DC      dd ?
       .IC      dd ?
       .MODULE  dq ?
       .PATH    dq ?
       .FILE    dq ?
       .FSIZE   dd ?
       .BUFFER  dq ?
    endl

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        inc     [@_EV.REFS]

        xor     rax, rax
        cmp     [@_EV.DHL], rax
        jz     .UDV
        mov     eax, [@_EV.IC]
        mov     [.IC], eax
        jmp    .leave.out

   .UDV:
        mov     [@_EV.DC], eax
        mov     [@_EV.IC], eax
        mov     [.DC], eax
        mov     [.IC], eax

   .UDV_FILE:
        stdcall halloc, .CBUFFER
        mov     [.MODULE], rax
        mov     rdi, rax
        stdcall halloc, .CBUFFER
        mov     [.PATH], rax
        mov     rsi, rax
        ; DWORD GetModuleFileName ( HMODULE, LPTSTR, DWORD )
        invoke  GetModuleFileName, 0, rdi, .CBUFFER
        lea     rbx, [.FILE]
        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, rdi, .CBUFFER, rsi, rbx
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, [.FILE], S_UDV_FILE
        cinvoke strcpy, [.FILE], S_UDV_FILE

   .UDV_FILE_CREATE:
        ; HANDLE CreateFile ( LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE )
        invoke  CreateFile, rsi, .CF_ACCESS, .CF_SHARE, NULL, OPEN_EXISTING, .CF_FLAGS, 0
        cmp     rax, INVALID_HANDLE_VALUE
        je     .return
        mov     rdi, rax
        ; DWORD GetFileSize ( HANDLE, LPDWORD )
        invoke  GetFileSize, rdi, NULL
        mov     [.FSIZE], eax
        ; BOOL CloseHandle ( HANDLE )
        invoke  CloseHandle, rdi
        cmp     [.FSIZE], 0
        jle    .return

   .UDV_ALLOC:
        stdcall halloc, [.FSIZE]
        mov     rdi, rax
        mov     [.BUFFER], rdi
   .UDV_READ:
        ; DWORD GetPrivateProfileSectionNames ( LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSectionNames, rdi, [.FSIZE], rsi
        test    eax, eax
        jz     .UDV_FREE
        lea     rbx, [rdi - 1]
   .UDV_TEST:
        mov     eax, [@_CFG.uddata_scount]
        cmp     [.DC], eax
        jg     .UDV_FREE
        lea     rdi, [rbx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .UDV_FREE
        xor     rdx, rdx
        mov     edx, eax
        lea     rbx, [rdi + rdx]
        cmp     byte [rdi], '*'                 ; skip commented item
        je     .UDV_TEST
        cmp     byte [rdi], '#'                 ; skip commented item
        je     .UDV_TEST
        cmp     byte [rdi], ';'                 ; skip commented item
        je     .UDV_TEST
   .UDV_ADD:
        stdcall varloas, rsi, [.FSIZE], rdi
        add     [.IC], eax
        test    rcx, rcx                        ; rcx = library handle
        jz     .UDV_TEST
        push    rcx
        push    rcx
        inc     [.DC]
        jmp    .UDV_TEST
   .UDV_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        xor     rdi, rdi
        mov     edi, [.DC]
        test    rdi, rdi
        jz     .leave
        shl     rdi, 3                          ; rdi = [.DC] * 8
        stdcall halloc, rdi
        mov     [@_EV.DHL], rax
        test    rax, rax
        jnz    .DLL.ADD
   .DLL.FREE:
        sub     rdi, 8
        pop     rcx                             ; rcx = library handle
        pop     rcx                             ; rcx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, rcx
        test    rdi, rdi
        jnz    .DLL.FREE
        jmp    .leave
   .DLL.ADD:
        sub     rdi, 8
        pop     rcx                             ; rcx = library handle
        pop     rcx                             ; rcx = library handle
        mov     [rax + rdi], rcx
        test    rdi, rdi
        jnz    .DLL.ADD
        mov     eax, [.DC]
        mov     [@_EV.DC], eax
   .leave:
        stdcall hfree, [.MODULE]
        stdcall hfree, [.PATH]

   .leave.out:
        mov     eax, [.IC]
        mov     [@_EV.IC], eax
        pop     rdi rsi rbx
        ret
$endp
$else
$proc sic_varloa
        ret
$endp
$end

; ------------------------------------------------------------------------------

; VOID sic_varulo ( VOID )
;
; unload external user defined variables

$ifdef _UDF
$proc sic_varulo

   .enter:
        pushsa  rsi, rdi                        ; push & 16-byte stack align for x64

        dec     [@_EV.REFS]
        cmp     [@_EV.REFS], 0
        jg     .return
        mov     [@_EV.REFS], 0

        xor     rdi, rdi
        mov     edi, [@_EV.DC]
        mov     [@_EV.DC], 0
        mov     [@_EV.IC], 0
        mov     rsi, [@_EV.DHL]
        test    rsi, rsi
        jz     .return
        test    rdi, rdi
        jz     .FREE.DLLs
        shl     rdi, 3                          ; rdi = [.DC] * 8
   .FREE.DLL:
        sub     rdi, 8
        mov     rcx, [rsi + rdi]                ; rcx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, rcx
        test    rdi, rdi
        jnz    .FREE.DLL
   .FREE.DLLs:
        stdcall hfree, [@_EV.DHL]
        mov     [@_EV.DHL], 0

   .return:
        pop     rdi rsi
        ret
$endp
$else
$proc sic_varulo
        ret
$endp
$end

; ------------------------------------------------------------------------------

; DWORD sic_runtac ( VOID )
;
; create global runtime table
;
; <- eax : runtime table item count
;
$proc sic_runtac

   .return:
        xor     rax, rax
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_runtaf ( VOID )
;
; destroy global runtime table
;
$proc sic_runtaf

   .return:
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_init ( LPVOID sic )
;
; allocate memory for sic constant & variable data segments
; assign table headers
;
; -> sic : T_sic_data structure offset
;
$proc sic_init, sic

        mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        push    rsi

        mov     rsi, [sic]                      ; rsi = T_sic_data structure offset
        test    rsi, rsi
        jz     .return                          ; error. null T_sic_data structure offset

    .zero.sic:                                  ; zero T_sic_data structure fields
        stdcall zerosic, rsi

    .fdata.alloc:
        stdcall halloc, [@_CFG.fdata_size]      ; allocate memory for function data segment
        test    rax, rax
        jz     .return                          ; error. memory allocation error
        mov     [rsi + T_sic_data.fdata], rax   ; save function data segment offset

    .fdata.header:                              ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.fdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.fitem64
        mov     [rax + table.header.tnsize], fitem.nsize
        mov     [rax + table.header.titype], 1

    .cdata.alloc:
        stdcall halloc, [@_CFG.cdata_size]      ; allocate memory for constant data segment
        test    rax, rax
        jz     .return                          ; error. memory allocation error
        mov     [rsi + T_sic_data.cdata], rax   ; save constant data segment offset

    .cdata.header:                              ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.cdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.citem64
        mov     [rax + table.header.tnsize], citem.nsize
        mov     [rax + table.header.titype], 2

    .vdata.alloc:
        stdcall halloc, [@_CFG.vdata_size]      ; allocate memory for variable data segment
        test    rax, rax
        jz     .return                          ; error. memory allocation error
        mov     [rsi + T_sic_data.vdata], rax   ; save variable data segment offset

    .vdata.header:                              ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.vdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.vitem64
        mov     [rax + table.header.tnsize], vitem.nsize
        mov     [rax + table.header.titype], 3

    .rdata.alloc:
        stdcall halloc, [@_CFG.rdata_size]      ; allocate memory for runtime data segment
        test    rax, rax
        jz     .return                          ; error. memory allocation error
        mov     [rsi + T_sic_data.rdata], rax   ; save runtime data segment offset

    .rdata.header:                              ; assign table header
        mov     [rax + table.header.icount], 0
        mov     edx, [@_CFG.rdata_count]
        mov     [rax + table.header.mcount], edx
        mov     [rax + table.header.tisize], sizeof.citem64
        mov     [rax + table.header.tnsize], citem.nsize
        mov     [rax + table.header.titype], 2

    .return:
        pop     rsi
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_done ( LPVOID sic )
;
; free memory previously allocated for sic data and code segments
;
; -> sic : T_sic_data structure offset
;
$proc sic_done, sic

        mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        push    rsi

        xor     rax, rax
        mov     rsi, [sic]                      ; rsi = T_sic_data structure offset
        test    rsi, rsi
        jz     .return                          ; error. null T_sic_data structure offset

    .free.code:                                 ; free code segment
        stdcall cfree, [rsi + T_sic_data.code]
    .free.data:                                 ; free data segment
        stdcall hfree, [rsi + T_sic_data.data]
    .free.fdata:                                ; free function data segment
        stdcall hfree, [rsi + T_sic_data.fdata]
    .free.cdata:                                ; free constant data segment
        stdcall hfree, [rsi + T_sic_data.cdata]
    .free.vdata:                                ; free variable data segment
        stdcall hfree, [rsi + T_sic_data.vdata]
    .free.rdata:                                ; free runtime data segment
        stdcall hfree, [rsi + T_sic_data.rdata]

    .zero.sic:                                  ; zero T_sic_data structure fields
        stdcall zerosic, rsi

    .return:
        pop     rsi
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_afun ( LPVOID sic, LPCSTR fun, LPVOID fuo, INT16 fac, UINT16 fuf )
;
; add|set user defined global or local function ( fun ) and assign data ( fuo, fac, fuf )
; deal with global table if sic = null or sic.fdata = null
;
; -> sic : T_sic_data structure offset
; -> fun : function name
; -> fuo : function offset
; -> fac : function argument count
; ->       fac < 0 - variable number of arguments
; ->                 ABS(fac) = minimum argument count
; ->       fac = 0x8000 - any variable number of arguments
; -> fuf : function flags
;          LO.BYTE = fuf AND 0x00FF
;          HI.BYTE = fuf SHR 8
;          x32 : LO.BYTE
;                cdecl   : count of 4-byte arguments
;                stdcall : 0xFF
;          x64 : LO.BYTE
;                4-bit mask for integer and pointer arguments
;                ex.: 0010 - second argument is integer or pointer
;                     0101 - first and third arguments are integer or pointer
;          x** : HI.BYTE AND (00001111B) - function return type
;                0x01 (00000001B) - 1-byte integer
;                0x02 (00000010B) - 2-byte integer
;                0x04 (00000100B) - 4-byte integer
;                0x08 (00001000B) - 8-byte integer
;                0x09 (00001001B) - 2 double values (*)
;                0x0A (00001010B) - 3 double values (*)
;                0x0C (00001100B) - 4 double values (*)
;                0x0F (00001111B) - void, no result
;                double otherwise
;          x** : HI.BYTE AND (00100000B) - dynamic function flag
;                dynamic functions are not calculated automatically at compile time
; (*) multiple-result functions must return double values through the FPU register stack (both on x32 and x64 systems)
; <- eax : function index or negative value on error
;
$proc sic_afun, sic, fun, fuo, fac, fuf

    locals
       .AC      dq ? ; argument count
       .FF      dq ? ; function flags
       .RT      dq ? ; return type
    endl

        mov     [sic], rcx
        mov     [fun], rdx
        mov     [fuo], r8
        mov     [fac], r9

    .verify.fun:
        stdcall verify.name, [fun]
        cmp     rax, 0
        jg     .verify.fun.out
        dec     rax
        jmp    .return
    .verify.fun.out:

        stdcall sic_gefut, [sic]                ; rax(rcx) = function table offset
        xor     rdx, rdx
        mov     dx, word [fac]                  ; dx = function argument count
        mov     [.AC], rdx
        mov     edx, dword [fuf]                ; edx = function flags
        cmp     dl, 0
        jge    .eflag
    .stdcall:
    $ifdef _X64
        mov     rax, -1                         ; x64 : error. no stdcall functions
        jmp    .return
    $else
        or      dx, 0100000000000000B           ; x32 : set stdcall function flag
    $end
    .eflag:
        or      dx, 1000000000000000B           ; set external function flag
        mov     [.FF], rdx
    .RT.1:
        mov     [.RT], 1
        and     dx, 0000111100000000B           ; 0x0F00
        cmp     dx, 0000111100000000B           ; 0x0F00
        je     .RT.0
        cmp     dx, 0000100100000000B           ; 0x0900
        je     .RT.2
        cmp     dx, 0000101000000000B           ; 0x0A00
        je     .RT.3
        cmp     dx, 0000110000000000B           ; 0x0C00
        je     .RT.4
        jmp    .taset
    .RT.2:
        mov     [.RT], 2
        jmp    .taset
    .RT.3:
        mov     [.RT], 3
        jmp    .taset
    .RT.4:
        mov     [.RT], 4
        jmp    .taset
    .RT.0:
        mov     [.RT], 0                        ; void procedure
;       jmp    .taset
    .taset:
        stdcall taset, rcx, [fun], [fuo], [.AC], [.FF], [.RT]
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_refun ( LPVOID sic, LPCSTR fun, LPCSTR fuo, BOOL fui )
;
; rename global or local function
; deal with global table if sic = null or sic.fdata = null
;
; -> sic : T_sic_data structure offset
; -> fun : function new name
; -> fuo : function original name
; -> fui : invalidate original function if TRUE
; <- eax : function index or negative value on error
;
$proc sic_refun, sic, fun, fuo, fui

    locals
       .OFF     dq ?
       .AC      dq ?
       .CS      dq ?
       .RT      dq ?
    endl

        mov     [sic], rcx
        mov     [fun], rdx
        mov     [fuo], r8
        mov     [fui], r9

        push    rsi rdi

    .verify.fun:
        stdcall verify.name, [fun]
        cmp     rax, 0
        jg     .verify.fun.out
        dec     rax
        jmp    .return
    .verify.fun.out:

    .verify.fuo:
        stdcall verify.name, [fuo]
        cmp     rax, 0
        jg     .verify.fuo.out
        dec     rax
        jmp    .return
    .verify.fuo.out:

        stdcall sic_gefut, [sic]                ; rax(rcx) = function table offset
        mov     rdi, rcx                        ; rdi = function table offset
        stdcall taget, rcx, [fuo], -1           ; rax = item index
        cmp     rax, 0
        jl     .return                          ; error. function not found

        shl     rax, 6                          ; rax = [item index] * 64 = [item index] * sizeof.fitem
        lea     rsi, [rdi + sizeof.table.header + rax]
                                                ; rsi = item offset
        mov     rdx, [rsi + fitem64.offset]     ; rdx = function offset
        mov     [.OFF], rdx
        movzx   rdx, word [rsi + fitem64.acount]; rdx = function argument count
        mov     [.AC], rdx
        movzx   rdx, word [rsi + fitem64.cosize]; rdx = function code size
        mov     [.CS], rdx
        movsx   rdx, word [rsi + fitem64.retype]; rdx = function return type
        mov     [.RT], rdx
        cmp     [fui], 0
        jz     .taset                           ; rsi = item offset
        mov     [rsi + fitem64.offset], 0       ; invalidate original function
    .taset:
        stdcall taset, rdi, [fun], [.OFF], [.AC], [.CS], [.RT]
    .return:
        pop     rdi rsi
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_dufun ( LPVOID sic, LPCSTR fun, LPCSTR fuo )
;
; duplicate global or local function
; deal with global table if sic = null or sic.fdata = null
;
; -> sic : T_sic_data structure offset
; -> fun : function dup name
; -> fuo : function original name
; <- eax : function index or negative value on error
;
$proc sic_dufun, sic, fun, fuo

;       mov     [sic], rcx
;       mov     [fun], rdx
;       mov     [fuo], r8
;       mov     [], r9

        xor     r9, r9                          ;
        stdcall sic_refun, rcx, rdx, r8, r9     ;
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_exfun ( LPVOID sic, LPCSTR fun, LPCSTR fum )
;
; exchange global or local functions
; deal with global table if sic = null or sic.fdata = null
;
; -> sic : T_sic_data structure offset
; -> fun : function name
; -> fum : function name
; <- eax : function index or negative value on error
;
$proc sic_exfun, sic, fun, fum

        mov     [sic], rcx
        mov     [fun], rdx
        mov     [fum], r8
;       mov     [], r9

        push    rbx rdi

        stdcall sic_gefut, [sic]                ; rax(rcx) = function table offset
        mov     rbx, rcx                        ; rbx = function table offset

    .fun:
        stdcall taget, rcx, [fun], -1           ; rax = item index
        cmp     rax, 0                          ; rdx = item offset
        jl     .return                          ; error. function not found
        mov     rdi, rdx                        ; rdi = item offset
    .fum:
        stdcall taget, rbx, [fum], -1           ; rax = item index
        cmp     rax, 0                          ; rdx = item offset
        jl     .return                          ; error. function not found

        cmp     rdi, rdx
        je     .return
    .exchange.retype:
        mov     cx, [rdi + fitem64.retype]
        mov     bx, [rdx + fitem64.retype]
        mov     [rdi + fitem64.retype], bx
        mov     [rdx + fitem64.retype], cx
    .exchange.acount:
        mov     cx, [rdi + fitem64.acount]
        mov     bx, [rdx + fitem64.acount]
        mov     [rdi + fitem64.acount], bx
        mov     [rdx + fitem64.acount], cx
    .exchange.cosize:
        mov     cx, [rdi + fitem64.cosize]
        mov     bx, [rdx + fitem64.cosize]
        mov     [rdi + fitem64.cosize], bx
        mov     [rdx + fitem64.cosize], cx
    .exchange.offset:
        mov     rcx, [rdi + fitem64.offset]
        mov     rbx, [rdx + fitem64.offset]
        mov     [rdi + fitem64.offset], rbx
        mov     [rdx + fitem64.offset], rcx

    .return:
        pop     rdi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_aconf ( LPVOID sic, LPCSTR con, DOUBLE cov )
;
; add|set user defined global or local float constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_aconf, sic, con, cov; cov.HI

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        movsd   qword [cov], xmm2
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     al, 'f'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_aconi ( LPVOID sic, LPCSTR con, INT_PTR cov )
;
; add|set user defined global or local integer constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_aconi, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     al, 'i'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_acons ( LPVOID sic, LPCSTR con, LPCSTR cov )
;
; add|set user defined global or local string constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_acons, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     al, 's'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_acono ( LPVOID sic, LPCSTR con, LPVOID cov )
;
; add|set user defined global or local offset constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_acono, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     al, 'o'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_aconp ( LPVOID sic, LPCSTR con, LPVOID cov )
;
; add|set user defined global or local pointer constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_aconp, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     al, 'p'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_aconpf ( LPVOID sic, LPCSTR con, LPVOID cov )
;
; add|set user defined global or local float pointer constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_aconpf, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     ax, 'pf'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_aconpi ( LPVOID sic, LPCSTR con, LPVOID cov )
;
; add|set user defined global or local integer pointer constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_aconpi, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     ax, 'pi'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_aconps ( LPVOID sic, LPCSTR con, LPVOID cov )
;
; add|set user defined global or local string pointer constant ( con ) and assign data ( cov )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cov : constant value
; <- eax : constant index or negative value on error
;
$proc sic_aconps, sic, con, cov

    locals
       .LO      dq ?
       .HI      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; rdx = constant value HI
        mov     [.HI], rdx
        mov     edx, dword [cov + 0]            ; rdx = constant value LO
        mov     [.LO], rdx
        xor     rax, rax
        mov     ax, 'ps'
        stdcall taset, rcx, [con], [.LO], [.HI], rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_recon ( LPVOID sic, LPCSTR con, LPCSTR coo, BOOL coi )
;
; rename global or local constant
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant new name
; -> coo : constant original name
; -> coi : invalidate original constant if TRUE
; <- eax : constant index or negative value on error
;
$proc sic_recon, sic, con, coo, coi

    locals
       .LO      dq ?
       .HI      dq ?
       .DT      dq ?
    endl

;       mov     [sic], rcx
        mov     [con], rdx
        mov     [coo], r8
        mov     [coi], r9

        push    rsi rdi

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        mov     rdi, rcx                        ; rdi = constant table offset
        stdcall taget, rcx, [coo], -1           ; eax = item index
        cmp     rax, 0
        jl     .return                          ; error. constant not found

        shl     rax, 6                          ; rax = [item index] * 64 = [item index] * sizeof.citem
        lea     rsi, [rdi + sizeof.table.header + rax]
                                                ; rsi = item offset
        xor     rdx, rdx
        mov     edx, dword [rsi + citem64.value + 0]
        mov     [.LO], rdx                      ; constant value LO
        mov     edx, dword [rsi + citem64.value + 4]
        mov     [.HI], rdx                      ; constant value HI
        movzx   rdx, word [rsi + citem64.datype]
        mov     [.DT], rdx                      ; constant data type
        xor     rax, rax                        ; rax = 0
        cmp     [coi], rax
        jz     .taset                           ; rsi = item offset
        dec     rax                             ; invalidate original constant. citem.value = FFFFFFFFFFFFFFFF
    $ifdef _X64
        mov     [rsi + citem64.value], rax
    $else
        mov     dword [esi + citem32.value + 0], eax
        mov     dword [esi + citem32.value + 4], eax
    $end
    .taset:
        stdcall taset, rdi, [con], [.LO], [.HI], [.DT], 0
    .return:
        pop     rdi rsi
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_ducon ( LPVOID sic, LPCSTR con, LPCSTR coo )
;
; duplicate global or local constant
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant dup name
; -> coo : constant original name
; <- eax : constant index or negative value on error
;
$proc sic_ducon, sic, con, coo

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [coo], r8
;       mov     [], r9

        xor     r9, r9                          ;
        stdcall sic_recon, rcx, rdx, r8, r9     ;
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_excon ( LPVOID sic, LPCSTR con, LPCSTR com )
;
; exchange global or local constants
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> com : constant name
; <- eax : constant index or negative value on error
;
$proc sic_excon, sic, con, com

        mov     [sic], rcx
        mov     [con], rdx
        mov     [com], r8
;       mov     [], r9

        push    rbx rdi

        stdcall sic_gecot, [sic]                ; rax(rcx) = constant table offset
        mov     rbx, rcx                        ; rbx = constant table offset

    .con:
        stdcall taget, rcx, [con], -1           ; rax = item index
        cmp     rax, 0                          ; rdx = item offset
        jl     .return                          ; error. constant not found
        mov     rdi, rdx                        ; rdi = item offset
    .com:
        stdcall taget, rbx, [com], -1           ; rax = item index
        cmp     rax, 0                          ; rdx = item offset
        jl     .return                          ; error. constant not found

        cmp     rdi, rdx
        je     .return
    .exchange.cotype:
        mov     cx, [rdi + citem64.cotype]
        mov     bx, [rdx + citem64.cotype]
        mov     [rdi + citem64.cotype], bx
        mov     [rdx + citem64.cotype], cx
    .exchange.datype:
        mov     cx, [rdi + citem64.datype]
        mov     bx, [rdx + citem64.datype]
        mov     [rdi + citem64.datype], bx
        mov     [rdx + citem64.datype], cx
    $ifdef _X64
    .exchange.value:
        mov     rcx, [rdi + citem64.value]
        mov     rbx, [rdx + citem64.value]
        mov     [rdi + citem64.value], rbx
        mov     [rdx + citem64.value], rcx
    $else
    .exchange.value.LO:
        mov     ecx, dword [edi + citem32.value + 0]
        mov     ebx, dword [edx + citem32.value + 0]
        mov     dword [edi + citem32.value + 0], ebx
        mov     dword [edx + citem32.value + 0], ecx
    .exchange.value.HI:
        mov     ecx, dword [edi + citem32.value + 4]
        mov     ebx, dword [edx + citem32.value + 4]
        mov     dword [edi + citem32.value + 4], ebx
        mov     dword [edx + citem32.value + 4], ecx
    $end

    .return:
        pop     rdi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avarf ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local float variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avarf, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     al, 'f'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avari ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local integer variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avari, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     al, 'i'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avars ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local string variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avars, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     al, 's'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avaro ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local offset variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avaro, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     al, 'o'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avarp ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local pointer variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avarp, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     al, 'p'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avarpf ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local float pointer variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avarpf, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     ax, 'pf'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avarpi ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local integer pointer variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avarpi, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     ax, 'pi'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_avarps ( LPVOID sic, LPCSTR van, LPVOID vao )
;
; add|set user defined global or local string pointer variable ( van ) and assign data ( vao )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; -> vao : variable offset
; <- eax : variable index or negative value on error
;
$proc sic_avarps, sic, van, vao

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        xor     rax, rax
        mov     ax, 'ps'
        stdcall taset, rcx, [van], [vao], 0, rax, 0
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_revar ( LPVOID sic, LPCSTR van, LPCSTR vao, BOOL vai )
;
; rename global or local variable
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable new name
; -> vao : variable original name
; -> vai : invalidate original variable if TRUE
; <- eax : variable index or negative value on error
;
$proc sic_revar, sic, van, vao, vai

    locals
       .OFF     dq ?
       .DT      dq ?
    endl

;       mov     [sic], rcx
        mov     [van], rdx
        mov     [vao], r8
        mov     [vai], r9

        push    rdi

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        mov     rdi, rcx                        ; rdi = variable table offset
        stdcall taget, rcx, [vao], -1           ; rax = item index
        cmp     rax, 0
        jl     .return                          ; error. variable not found

        shl     rax, 6                          ; rax = [item index] * 64 = [item index] * sizeof.vitem
        lea     rcx, [rdi + sizeof.table.header + rax]
                                                ; rcx = item offset
        mov     rdx, [rcx + vitem64.offset]     ; rdx = variable offset
        mov     [.OFF], rdx
        movzx   rdx, word [rcx + vitem64.datype]
        mov     [.DT], rdx                      ; variable data type
        xor     rax, rax                        ; rax = 0
        cmp     dword [vai], eax
        jz     .taset                           ; rcx = item offset
        mov     [rcx + vitem64.offset], rax     ; invalidate original variable
    .taset:
        stdcall taset, rdi, [van], [.OFF], rax, [.DT], 0
    .return:
        pop     rdi
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_duvar ( LPVOID sic, LPCSTR van, LPCSTR vao )
;
; duplicate global or local variable
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable dup name
; -> vao : variable original name
; <- eax : variable index or negative value on error
;
$proc sic_duvar, sic, van, vao

;       mov     [sic], rcx
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        xor     r9, r9                          ;
        stdcall sic_revar, rcx, rdx, r8, r9     ;
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_exvar ( LPVOID sic, LPCSTR van, LPCSTR vam )
;
; exchange global or local variables
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable dup name
; -> vam : variable original name
; <- eax : variable index or negative value on error
;
$proc sic_exvar, sic, van, vam

        mov     [sic], rcx
        mov     [van], rdx
        mov     [vam], r8
;       mov     [], r9

        push    rbx rdi

        stdcall sic_gevat, [sic]                ; rax(rcx) = variable table offset
        mov     rbx, rcx                        ; rbx = variable table offset

    .van:
        stdcall taget, rcx, [van], -1           ; rax = item index
        cmp     rax, 0                          ; rdx = item offset
        jl     .return                          ; error. variable not found
        mov     rdi, rdx                        ; rdi = item offset
    .vam:
        stdcall taget, rbx, [vam], -1           ; rax = item index
        cmp     rax, 0                          ; rdx = item offset
        jl     .return                          ; error. variable not found

        cmp     rdi, rdx
        je     .return
    .exchange.vatype:
        mov     cx, [rdi + vitem64.vatype]
        mov     bx, [rdx + vitem64.vatype]
        mov     [rdi + vitem64.vatype], bx
        mov     [rdx + vitem64.vatype], cx
    .exchange.datype:
        mov     cx, [rdi + vitem64.datype]
        mov     bx, [rdx + vitem64.datype]
        mov     [rdi + vitem64.datype], bx
        mov     [rdx + vitem64.datype], cx
    .exchange.offset:
        mov     rcx, [rdi + citem64.offset]
        mov     rbx, [rdx + citem64.offset]
        mov     [rdi + citem64.offset], rbx
        mov     [rdx + citem64.offset], rcx

    .return:
        pop     rdi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_invaf ( LPVOID sic, LPCSTR fun )
;
; invalidate global or local function ( fun )
; deal with global table if sic = null or sic.fdata = null
;
; -> sic : T_sic_data structure offset
; -> fun : function name
; <- eax : function index or negative value on error
;
$proc sic_invaf, sic, fun

        mov     [sic], rcx
        mov     [fun], rdx
;       mov     [], r8
;       mov     [], r9

    .verify.fun:
        stdcall verify.name, [fun]
        cmp     rax, 0
        jg     .verify.fun.out
        dec     rax
        jmp    .return
    .verify.fun.out:

        stdcall sic_gefut, [sic]                ; rax(rcx) = function table offset
        stdcall tinva, rcx, [fun]
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_invac ( LPVOID sic, LPCSTR con )
;
; invalidate global or local constant ( con )
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; <- eax : constant index or negative value on error
;
$proc sic_invac, sic, con

;       mov     [sic], rcx
        mov     [con], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        stdcall tinva, rcx, [con]
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_invav ( LPVOID sic, LPCSTR van )
;
; invalidate global or local variable ( van )
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; <- eax : variable index or negative value on error
;
$proc sic_invav, sic, van

;       mov     [sic], rcx
        mov     [van], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        stdcall tinva, rcx, [van]
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_patab ( LPVOID sic )
;
; pack global or local tables ( remove invalid items, decrease and fix table size )
; deal with global tables if sic = null or sic.?data = null
; !!! you can`t add any item to the packed table
;
$proc sic_patab, sic

        mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_pafut, [sic]
        stdcall sic_pacot, [sic]
        stdcall sic_pavat, [sic]

        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_pafut ( LPVOID sic )
;
; pack global or local function table ( remove invalid items, decrease and fix table size )
; deal with global table if sic = null or sic.fdata = null
; !!! you can`t add any item to the packed table
;
; -> sic : T_sic_data structure offset
; <- eax : table item count or zero on error
;
$proc sic_pafut, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gefut, rcx                  ; rax(rcx) = function table offset
        stdcall tapac, rcx, 1
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_pacot ( LPVOID sic )
;
; pack global or local constant table ( remove invalid items, decrease and fix table size )
; deal with global table if sic = null or sic.cdata = null
; !!! you can`t add any item to the packed table
;
; -> sic : T_sic_data structure offset
; <- eax : table item count or zero on error
;
$proc sic_pacot, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        stdcall tapac, rcx, 2
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_pavat ( LPVOID sic )
;
; pack global or local variable table ( remove invalid items, decrease and fix table size )
; deal with global table if sic = null or sic.vdata = null
; !!! you can`t add any item to the packed table
;
; -> sic : T_sic_data structure offset
; <- eax : table item count or zero on error
;
$proc sic_pavat, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        stdcall tapac, rcx, 3
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; LPVOID sic_gefut ( LPVOID sic )
;
; get global or local function table offset
; deal with global table if sic = null or sic.fdata = nil
;
; -> sic : T_sic_data structure offset
; <- rax : function table offset
; <- rax : function table offset
;
$proc sic_gefut, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     rax, [@_FDATA]                  ; rax = global table offset
;       mov     rcx, [sic]                      ; rcx = T_sic_data structure offset
        test    rcx, rcx
        jz     .return                          ; sic = null
        mov     rax, [rcx + T_sic_data.fdata]   ; rax = local table offset
    .return:
        mov     rcx, rax                        ; rcx = table offset
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_gefuc ( LPVOID sic )
;
; get global or local function item count
; deal with global table if sic = null or sic.fdata = nil
;
; -> sic : T_sic_data structure offset
; <- eax : function item count
;
$proc sic_gefuc, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gefut, rcx                  ; rax(rcx) = table offset
        test    rax, rax
        jz     .return

        mov     eax, [rax + table.header.icount]

    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gefui ( LPVOID sic, INT fin, LPVOID fui )
;
; get global or local function item
; deal with global table if sic = null or sic.fdata = nil
;
; -> sic : T_sic_data structure offset
; -> fin : function index
; <- fui : function item
; <- eax : function index or negative value on error
;
$proc sic_gefui, sic, fin, fui

;       mov     [sic], rcx
        mov     [fin], rdx
        mov     [fui], r8
;       mov     [], r9

        push    rsi rdi

        stdcall sic_gefut, rcx                  ; rax(rcx) = table offset
        mov     rsi, rax                        ; rsi = table offset
        mov     rax, -1
        test    rsi, rsi
        jz     .return
        mov     rdi, [fui]                      ; rdi = item structure offset
        test    rdi, rdi
        jz     .return
        xor     rdx, rdx
        mov     edx, dword [fin]                ; rdx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [rsi + table.header.icount]
        jge    .return

        mov     rax, rdx                        ; rax = item index
        shl     rdx, 6                          ; rdx = rdx * 64

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + sizeof.table.header + rdx]
        add     rsi, rdx
        add     rsi, sizeof.table.header

        mov     rcx, sizeof.fitem64
        call    momem

    .return:
        pop     rdi rsi
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gefun ( LPVOID sic, LPCSTR fun )
;
; get global or local function ( fun ) index in function table
; deal with global table if sic = null or sic.fdata = nil
;
; -> sic : T_sic_data structure offset
; -> fun : function name
; <- eax : function index or negative value on error
;
$proc sic_gefun, sic, fun

;       mov     [sic], rcx
        mov     [fun], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gefut, rcx                  ; rax(rcx) = table offset
        stdcall taget, rcx, [fun], -1
        ret
$endp

; ------------------------------------------------------------------------------

; LPVOID sic_gecot ( LPVOID sic )
;
; get global or local constant table offset
; deal with global table if sic = null or sic.cdata = nil
;
; -> sic : T_sic_data structure offset
; <- rax : constant table offset
; <- rcx : constant table offset
;
$proc sic_gecot, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     rax, [@_CDATA]                  ; rax = global table offset
;       mov     rcx, [sic]                      ; rcx = T_sic_data structure offset
        test    rcx, rcx
        jz     .return                          ; sic = null
        mov     rax, [rcx + T_sic_data.cdata]   ; rax = local table offset
    .return:
        mov     rcx, rax                        ; rcx = table offset
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_gecoc ( LPVOID sic )
;
; get global or local constant item count
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; <- eax : constant item count
;
$proc sic_gecoc, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = table offset
        test    rax, rax
        jz     .return

        mov     eax, [rax + table.header.icount]

    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gecoi ( LPVOID sic, INT cin, LPVOID coi )
;
; get global or local constant item
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> cin : constant index
; <- coi : constant item
; <- eax : constant index or negative value on error
;
$proc sic_gecoi, sic, cin, coi

;       mov     [sic], rcx
        mov     [cin], rdx
        mov     [coi], r8
;       mov     [], r9

        push    rsi rdi

        stdcall sic_gecot, rcx                  ; rax(rcx) = table offset
        mov     rsi, rax
        mov     rax, -1
        test    rsi, rsi
        jz     .return
        mov     rdi, [coi]                      ; rdi = item structure offset
        test    rdi, rdi
        jz     .return
        xor     rdx, rdx
        mov     edx, dword [cin]                ; rdx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [rsi + table.header.icount]
        jge    .return

   .item:
        mov     rax, rdx                        ; rax = item index
        shl     rdx, 6                          ; rdx = rdx * 64

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + sizeof.table.header + rdx]
        add     rsi, rdx
        add     rsi, sizeof.table.header

        mov     rcx, sizeof.citem64
        call    momem

   .return:
        pop     rdi rsi
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gecon ( LPVOID sic, LPCSTR con )
;
; get global or local constant ( con ) index in constant table
; deal with global table if sic = null or sic.cdata = null
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; <- eax : constant index or negative value on error
;
$proc sic_gecon, sic, con

;       mov     [sic], rcx
        mov     [con], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gecot, rcx                  ; rax(rcx) = constant table offset
        stdcall taget, rcx, [con], -1
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; LPVOID sic_gevat ( LPVOID sic )
;
; get global or local variable table offset
; deal with global table if sic = null or sic.vdata = nil
;
; -> sic : T_sic_data structure offset
; <- rax : variable table offset
;
$proc sic_gevat, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     rax, [@_VDATA]                  ; rax = global table offset
;       mov     rcx, [sic]                      ; rcx = T_sic_data structure offset
        test    rcx, rcx
        jz     .return                          ; sic = null
        mov     rax, [rcx + T_sic_data.vdata]   ; rax = local table offset
    .return:
        mov     rcx, rax                        ; rcx = table offset
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_gevac ( LPVOID sic )
;
; get global or local variable item count
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; <- eax : variable item count
;
$proc sic_gevac, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = table offset
        test    rax, rax
        jz     .return

        mov     eax, [rax + table.header.icount]

    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gevai ( LPVOID sic, INT vin, LPVOID vai )
;
; get global or local variable item
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> vin : variable index
; <- vai : variable item
; <- eax : variable index or negative value on error
;
$proc sic_gevai, sic, vin, vai

;       mov     [sic], rcx
        mov     [vin], rdx
        mov     [vai], r8
;       mov     [], r9

        push    rbx rsi rdi

        stdcall sic_gevat, rcx                  ; rax(rcx) = table offset
        mov     rsi, rax
        mov     rax, -1
        test    rsi, rsi
        jz     .return
        mov     rdi, [vai]                      ; rdi = item structure offset
        test    rdi, rdi
        jz     .return
        xor     rdx, rdx
        mov     edx, dword [vin]                ; rdx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [rsi + table.header.icount]
        jge    .return

   .item:
        mov     rax, rdx                        ; rax = item index
        shl     rdx, 6                          ; rdx = rdx * 64

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + sizeof.table.header + rdx]
        add     rsi, rdx
        add     rsi, sizeof.table.header

        mov     rbx, rsi                        ; rbx = rsi = item offset
        mov     rcx, sizeof.vitem64
        call    momem

   .return:
        pop     rdi rsi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gevar ( LPVOID sic, LPCSTR van )
;
; get global or local variable ( van ) index in variable table
; deal with global table if sic = null or sic.vdata = null
;
; -> sic : T_sic_data structure offset
; -> van : variable name
; <- eax : variable index or negative value on error
;
$proc sic_gevar, sic, van

;       mov     [sic], rcx
        mov     [van], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gevat, rcx                  ; rax(rcx) = variable table offset
        stdcall taget, rcx, [van], -1
    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; LPVOID sic_gerut ( LPVOID sic )
;
; get global or local runtime table offset
; deal with global table if sic = null or sic.rdata = nil
;
; -> sic : T_sic_data structure offset
; <- rax : runtime table offset
;
$proc sic_gerut, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     rax, [@_RDATA]                  ; rax = global table offset
;       mov     rcx, [sic]                      ; rcx = T_sic_data structure offset
        test    rcx, rcx
        jz     .return                          ; sic = null
        mov     rax, [rcx + T_sic_data.rdata]   ; rax = local table offset
    .return:
        mov     rcx, rax                        ; rcx = table offset
        ret
$endp

; ------------------------------------------------------------------------------

; DWORD sic_geruc ( LPVOID sic )
;
; get global or local runtime item count
; deal with global table if sic = null or sic.rdata = null
;
; -> sic : T_sic_data structure offset
; <- eax : runtime item count
;
$proc sic_geruc, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gerut, rcx                  ; rax(rcx) = table offset
        test    rax, rax
        jz     .return

        mov     eax, [rax + table.header.icount]

    .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gerui ( LPVOID sic, INT rin, LPVOID rui )
;
; get global or local runtime item
; deal with global table if sic = null or sic.rdata = null
;
; -> sic : T_sic_data structure offset
; -> rin : runtime index
; <- rui : runtime item
; <- eax : runtime index or negative value on error
;
$proc sic_gerui, sic, rin, rui

;       mov     [sic], rcx
        mov     [rin], rdx
        mov     [rui], r8
;       mov     [], r9

        push    rbx rsi rdi

        stdcall sic_gerut, rcx                  ; rax(rcx) = table offset
        mov     rsi, rax
        mov     rax, -1
        test    rsi, rsi
        jz     .return
        mov     rdi, [rui]                      ; rdi = item structure offset
        test    rdi, rdi
        jz     .return
        xor     rdx, rdx
        mov     edx, dword [rin]                ; rdx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [rsi + table.header.icount]
        jge    .return

   .item:
        mov     rax, rdx                        ; rax = item index
        shl     rdx, 6                          ; rdx = rdx * 64

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + sizeof.table.header + rdx]
        add     rsi, rdx
        add     rsi, sizeof.table.header

        mov     rbx, rsi                        ; rbx = rsi = item offset
        mov     rcx, sizeof.citem64
        call    momem

   .return:
        pop     rdi rsi rbx
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_gerun ( LPVOID sic, LPCSTR run )
;
; get global or local item ( run ) index in runtime table
; deal with global table if sic = null or sic.rdata = null
;
; -> sic : T_sic_data structure offset
; -> run : runtime name
; <- eax : runtime index or negative value on error
;
$proc sic_gerun, sic, run

;       mov     [sic], rcx
        mov     [run], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gerut, rcx                  ; rax(rcx) = variable table offset
        stdcall taget, rcx, [run], -1
    .return:
        ret
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; DOUBLE sic_exec ( LPVOID sic, LPDWORD err )
;
; execute code
;
; -> sic : T_sic_data structure offset
;
; <- st0 : result or zero on error
; <- err : error code or zero on success
;          err = 0x00010000 -> null T_sic_data structure offset
;          err = 0x00020000 -> null code segment offset
;          err = 0x00040000 -> invalid code size
;
;          if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;          err and 0x00000008 = OE flag
;          err and 0x00000004 = ZE flag
;          err and 0x00000001 = IE flag
;
$proc sic_exec, sic, err

    locals
      $ifdef _SSEX
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
      $end
       .err     dd ?
       .fpu_cw  dw ?
    endl

;       mov     [sic], rcx
        mov     [err], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifdef _X64                                 ; push & 16-byte stack align for x64
        pushsa  rbx, rsi, rdi, r13              ; built-in functions can modify RDI, RBX, R13 registers
    $else
        push    ebx esi edi                     ; built-in functions can modify EDI, EBX registers
    $end
    $ifdef _SSEX                                ; built-in functions can modify xmm6, xmm7 registers
      $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
      $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
      $end
    $end
        fnstcw  [.fpu_cw]                       ; save control word

    $ifdef _X64
        mov     rsi, rcx                        ; rsi = T_sic_data structure offset
    $else
        mov     esi, [sic]                      ; esi = T_sic_data structure offset
    $end

        mov     [.err], 0x00010000
        test    rsi, rsi
        je     .error                           ; error. null T_sic_data structure offset

        mov     [.err], 0x00020000
        mov     rdx, [rsi + T_sic_data.code]    ; rdx = code segment offset
        test    rdx, rdx
        je     .error                           ; error. null code segment offset
        mov     rdx, [rsi + T_sic_data.entry]   ; rdx = entry point
        test    rdx, rdx
        je     .error                           ; error. null entry point

        mov     [.err], 0x00040000
        mov     eax, [rsi + T_sic_data.size]
        cmp     eax, CODE_MIN_SIZE_X64
        jge    .call                            ; valid code size

   .error:
        mov     eax, [.err]                     ; eax = error code
        mov     rdx, [err]
        mov     [rdx], eax                      ; return error code
    $ifdef _X64
        pxor    xmm0, xmm0                      ; return zero on error
        movsd   qword [rsi + T_sic_data.value], xmm0
    $else
        fldz                                    ; return zero on error
        fst     qword [esi + T_sic_data.value]
    $end
        jmp    .leave

   .call:                                       ; execute code
        call    rdx                             ; <- eax = FPU exception flags or 0
        mov     rdx, [err]
        mov     [rdx], eax                      ; return error code

        ; copy result to T_sic_data.value
    $ifdef _X64
      $ifdef _SSEX
        movsd   qword [rsi + T_sic_data.value], xmm0
      $else
        fstp    qword [rsi + T_sic_data.value]
        movsd   xmm0, qword [rsi + T_sic_data.value]
      $end
    $else
      $ifdef _SSEX
        movsd   qword [esi + T_sic_data.value], xmm0
        fld     qword [esi + T_sic_data.value]
      $else
        fst     qword [esi + T_sic_data.value]
      $end
    $end

   .leave:
        fldcw   [.fpu_cw]                       ; restore control word
    $ifdef _SSEX
      $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
      $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
      $end
    $end
    $ifdef _X64
        pop     r13 rdi rsi rbx
    $else
        pop     edi esi ebx
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE sic_pexec ( LPVOID sic )
;
; execute code
;
; -> sic : T_sic_data structure offset
; <- st0 : result
;
$proc sic_pexec, sic

    locals
      $ifdef _SSEX
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
      $end
       .fpu_cw  dw ?
    endl

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifdef _X64                                 ; push & 16-byte stack align for x64
        pushsa  rbx, rsi, rdi, r13              ; built-in functions can modify RDI, RBX, R13 registers
    $else
        push    ebx esi edi                     ; built-in functions can modify EDI, EBX registers
    $end
    $ifdef _SSEX                                ; built-in functions can modify xmm6, xmm7 registers
      $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
      $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
      $end
    $end
        fnstcw  [.fpu_cw]                       ; save control word

    $ifdef _X64
        mov     rsi, rcx                        ; rsi = T_sic_data structure offset
    $else
        mov     esi, [sic]                      ; esi = T_sic_data structure offset
    $end

        mov     rdx, [rsi + T_sic_data.entry]   ; rdx = entry point
        call    rdx                             ; execute code

        ; copy result to T_sic_data.value
    $ifdef _X64
      $ifdef _SSEX
        movsd   qword [rsi + T_sic_data.value], xmm0
      $else
        fstp    qword [rsi + T_sic_data.value]
        movsd   xmm0, qword [rsi + T_sic_data.value]
      $end
    $else
      $ifdef _SSEX
        movsd   qword [esi + T_sic_data.value], xmm0
        fld     qword [esi + T_sic_data.value]
      $else
        fst     qword [esi + T_sic_data.value]
      $end
    $end

   .leave:
        fldcw   [.fpu_cw]                       ; restore control word
    $ifdef _SSEX
      $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
      $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
      $end
    $end
    $ifdef _X64
        pop     r13 rdi rsi rbx
    $else
        pop     edi esi ebx
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_pcall ( LPVOID sic )
;
; execute code
;
; -> sic       : T_sic_data structure offset
; <- sic.value : result
;
$proc sic_pcall, sic

    locals
      $ifdef _SSEX
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
      $end
       .fpu_cw  dw ?
    endl

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifdef _X64                                 ; push & 16-byte stack align for x64
        pushsa  rbx, rsi, rdi, r13              ; built-in functions can modify RDI, RBX, R13 registers
    $else
        push    ebx esi edi                     ; built-in functions can modify EDI, EBX registers
    $end
    $ifdef _SSEX                                ; built-in functions can modify xmm6, xmm7 registers
      $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
      $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
      $end
    $end
        fnstcw  [.fpu_cw]                       ; save control word

    $ifdef _X64
        mov     rsi, rcx                        ; rsi = T_sic_data structure offset
    $else
        mov     esi, [sic]                      ; esi = T_sic_data structure offset
    $end

        mov     rdx, [rsi + T_sic_data.entry]   ; rdx = entry point
        call    rdx                             ; execute code

        ; copy result to T_sic_data.value
    $ifdef _SSEX
        movsd   qword [rsi + T_sic_data.value], xmm0
    $else
        fstp    qword [rsi + T_sic_data.value]
    $end

   .leave:
        fldcw   [.fpu_cw]                       ; restore control word
    $ifdef _SSEX
      $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
      $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
      $end
    $end
    $ifdef _X64
        pop     r13 rdi rsi rbx
    $else
        pop     edi esi ebx
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE cexec.proc ( LPVOID sic, LPCSTR s, LPDWORD sop, LPDWORD err, LPVOID proc )
;
; compile & execute string (internal use)
;
; -> sic  : T_sic_data structure offset
; -> s    : string to compile
; -> sop  : sic compiler options offset
; -> proc : procedure address to call
;
; <- st0  : result or zero on error
; <- sop  : actual compiler options
; <- err  : error code or zero on success
;           err = 0x00000100 -> compiler error
;
;           if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;           err and 0x00000008 = OE flag
;           err and 0x00000004 = ZE flag
;           err and 0x00000001 = IE flag
;
$proc cexec.proc, sic, s, sop, err, proc

    locals
      $ifdef _SSEX
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
      $end
       .err     dd ?
       .fpu_cw  dw ?
    endl

;       mov     [sic], rcx
        mov     [s], rdx
        mov     [sop], r8
        mov     [err], r9

   .enter:
    $ifdef _X64                                 ; push & 16-byte stack align for x64
        pushsa  rbx, rsi, rdi, r13              ; built-in functions can modify RDI, RBX, R13 registers
    $else
        push    ebx esi edi                     ; built-in functions can modify EDI, EBX registers
    $end
    $ifdef _SSEX                                ; built-in functions can modify xmm6, xmm7 registers
      $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
      $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
      $end
    $end
        fnstcw  [.fpu_cw]                       ; save control word

    $ifdef _X64
        mov     rsi, rcx                        ; rsi = T_sic_data structure offset
    $else
        mov     esi, [sic]                      ; esi = T_sic_data structure offset
    $end

        mov     [.err], 0x00000100
        xor     rax, rax
        mov     rdx, [sop]
        mov     eax, [rdx]                      ; eax = compiler options
        stdcall [proc], rsi, [s], rax
        mov     ecx, [rsi + T_sic_data.coops]   ; ecx = actual compiler options
        mov     rdx, [sop]
        mov     [rdx], ecx                      ; return actual compiler options
        test    rax, rax
        je     .error                           ; error. compiler error

        mov     rdx, [rsi + T_sic_data.code]    ; rdx = code segment offset
        test    rdx, rdx
        je     .error                           ; error. null code segment offset
        mov     rdx, [rsi + T_sic_data.entry]   ; rdx = entry point
        test    rdx, rdx
        je     .error                           ; error. null entry point

        cmp     [rsi + T_sic_data.size], CODE_MIN_SIZE_X64
        jge    .call                            ; valid code size

   .error:
        mov     eax, [.err]                     ; eax = error code
        mov     rdx, [err]
        mov     [rdx], eax                      ; return error code
    $ifdef _X64
        pxor    xmm0, xmm0                      ; return zero on error
        movsd   qword [rsi + T_sic_data.value], xmm0
    $else
        fldz                                    ; return zero on error
        fst     qword [esi + T_sic_data.value]
    $end
        jmp    .leave

   .call:                                       ; execute code
        call    rdx                             ; <- eax = FPU exception flags or 0
        mov     rdx, [err]
        mov     [rdx], eax                      ; return error code

        ; copy result to T_sic_data.value
    $ifdef _X64
      $ifdef _SSEX
        movsd   qword [rsi + T_sic_data.value], xmm0
      $else
        fstp    qword [rsi + T_sic_data.value]
        movsd   xmm0, qword [rsi + T_sic_data.value]
      $end
    $else
      $ifdef _SSEX
        movsd   qword [esi + T_sic_data.value], xmm0
        fld     qword [esi + T_sic_data.value]
      $else
        fst     qword [esi + T_sic_data.value]
      $end
    $end

   .leave:
        fldcw   [.fpu_cw]                       ; restore control word
    $ifdef _SSEX
      $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
      $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
      $end
    $end
    $ifdef _X64
        pop     r13 rdi rsi rbx
    $else
        pop     edi esi ebx
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE sic_cexec ( LPVOID sic, LPCSTR s, LPDWORD sop, LPDWORD err )
;
; compile & execute string
;
; -> sic : T_sic_data structure offset
; -> s   : string to compile
; -> sop : sic compiler options offset
;
; <- st0 : result or zero on error
; <- sop : actual compiler options
; <- err : error code or zero on success
;          err = 0x00000100 -> compiler error
;
;          if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;          err and 0x00000008 = OE flag
;          err and 0x00000004 = ZE flag
;          err and 0x00000001 = IE flag
;
$proc sic_cexec, sic, s, sop, err

;       mov     [sic], rcx
;       mov     [s], rdx
;       mov     [sop], r8
;       mov     [err], r9

    $ifdef _X64
        stdcall cexec.proc, rcx, rdx, r8, r9, sic_compile
    $else
        stdcall cexec.proc, [sic], [s], [sop], [err], sic_compile
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE sic_bexec ( LPVOID sic, LPCSTR s, LPDWORD sop, LPDWORD err )
;
; compile & execute string
; <s> can be multiline expression with ';' as delimiter
;
; -> sic : T_sic_data structure offset
; -> s   : string to compile
; -> sop : sic compiler options offset
;
; <- st0 : result or zero on error
; <- sop : actual compiler options
; <- err : error code or zero on success
;          err = 0x00000100 -> compiler error
;
;          if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;          err and 0x00000008 = OE flag
;          err and 0x00000004 = ZE flag
;          err and 0x00000001 = IE flag
;
$proc sic_bexec, sic, s, sop, err

;       mov     [sic], rcx
;       mov     [s], rdx
;       mov     [sop], r8
;       mov     [err], r9

    $ifdef _X64
        stdcall cexec.proc, rcx, rdx, r8, r9, sic_build
    $else
        stdcall cexec.proc, [sic], [s], [sop], [err], sic_build
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE scexec.proc ( LPCSTR s, LPDWORD sop, LPDWORD err, LPVOID proc )
;
; compile & execute string (internal use)
;
; -> s    : string to compile
; -> sop  : sic compiler options offset
; -> proc : procedure address to call
;
; <- st0 : result or zero on error
; <- sop : actual compiler options
; <- err : error code or zero on success
;          err = 0x00000100 -> compiler error
;
;          if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;          err and 0x00000008 = OE flag
;          err and 0x00000004 = ZE flag
;          err and 0x00000001 = IE flag
;
$proc scexec.proc, s, sop, err, proc

    locals
      $ifdef _SSEX
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
      $end
      $ifdef _X64
       .result  dq ?
      $end
       .sic     T_sic64_data ?
       .fpu_cw  dw ?
    endl

        mov     [s], rcx
        mov     [sop], rdx
        mov     [err], r8
        mov     [proc], r9

   .enter:
    $ifdef _X64                                 ; push & 16-byte stack align for x64
        pushsa  rbx, rsi, rdi, r13              ; built-in functions can modify RDI, RBX, R13 registers
    $else
        push    ebx esi edi                     ; built-in functions can modify EDI, EBX registers
    $end
    $ifdef _SSEX                                ; built-in functions can modify xmm6, xmm7 registers
      $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
      $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
      $end
    $end
        fnstcw  [.fpu_cw]                       ; save control word

        lea     rsi, [.sic]
        stdcall sic_init, rsi
        stdcall [proc], rsi, [s], [sop], [err]
        mov     ecx, [rsi + T_sic_data.coops]   ; ecx = actual compiler options
        mov     rdx, [sop]
        mov     [rdx], ecx                      ; return actual compiler options

    $ifdef _X64
        movsd   qword [.result], xmm0           ; save result
        stdcall sic_done, rsi
        movsd   xmm0, qword [.result]           ; restore result
    $else
        stdcall sic_done, esi
    $end

   .leave:
        fldcw   [.fpu_cw]                       ; restore control word
    $ifdef _SSEX
      $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
      $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
      $end
    $end
    $ifdef _X64
        pop     r13 rdi rsi rbx
    $else
        pop     edi esi ebx
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE sic_scexec ( LPCSTR s, LPDWORD sop, LPDWORD err )
;
; compile & execute string
;
; -> s   : string to compile
; -> sop : sic compiler options offset
;
; <- st0 : result or zero on error
; <- sop : actual compiler options
; <- err : error code or zero on success
;          err = 0x00000100 -> compiler error
;
;          if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;          err and 0x00000008 = OE flag
;          err and 0x00000004 = ZE flag
;          err and 0x00000001 = IE flag
;
$proc sic_scexec, s, sop, err

;       mov     [s], rcx
;       mov     [sop], rdx
;       mov     [err], r8
;       mov     [], r9

    $ifdef _X64
        stdcall scexec.proc, rcx, rdx, r8, sic_cexec
    $else
        stdcall scexec.proc, [s], [sop], [err], sic_cexec
    $end
        ret
$endp

; ------------------------------------------------------------------------------

; DOUBLE sic_sbexec ( LPCSTR s, LPDWORD sop, LPDWORD err )
;
; compile & execute string
; <s> can be multiline expression with ';' as delimiter
;
; -> s   : string to compile
; -> sop : sic compiler options offset
;
; <- st0 : result or zero on error
; <- sop : actual compiler options
; <- err : error code or zero on success
;          err = 0x00000100 -> compiler error
;
;          if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
;          err and 0x00000008 = OE flag
;          err and 0x00000004 = ZE flag
;          err and 0x00000001 = IE flag
;
$proc sic_sbexec, s, sop, err

;       mov     [s], rcx
;       mov     [sop], rdx
;       mov     [err], r8
;       mov     [], r9

    $ifdef _X64
        stdcall scexec.proc, rcx, rdx, r8, sic_bexec
    $else
        stdcall scexec.proc, [s], [sop], [err], sic_bexec
    $end
        ret
$endp

; ------------------------------------------------------------------------------
