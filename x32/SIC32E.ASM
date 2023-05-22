
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
        ; 6.2.1.1
        mov eax, 0x01010206
        ret
    $else
        ; 6.2.1.0
        mov eax, 0x00010206
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
        push    ebx

   .main:
        mov     eax, 1
        cpuid                                   ; !!! cpuid changes ebx register

        xor     eax, eax

   .SSE2:
        test    edx, 0x04000000                 ; EDX:26 - SSE2 bit
        jz     .leave

   .SSE3:
        test    ecx, 0x00000001                 ; ECX:00 - SSE3 bit
        jz     .leave

   .SSE4.1:
        test    ecx, 0x00080000                 ; ECX:19 - SSSE4.1 bit
        jz     .leave

   .support:
        inc     eax

   .leave:
        pop     ebx
    $else
        mov     eax, 1
    $end
   .return:
        ret
$endp

; ------------------------------------------------------------------------------

; INT sic_va_count ( VOID )
;
; variable argument count
;
; <- eax : variable argument count (ecx)
;
$proc sic_va_count

        mov eax, ecx
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

   .enter:
        pushsa  ebx, esi                        ; push & 16-byte stack align for x64

        mov     esi, [config]
;       mov     rsi, rcx

    macro c
    {
        mov     [.locale], 0
        lea     edx, [.locale]
        cinvoke setlocale, 2, edx               ; setlocale (LC_CTYPE, "")
    }

        test    esi, esi                        ; esi = T_sic_config structure offset
        jz     .return

    .cflags:
        mov     eax, [esi + T_sic_config.cflags]
        mov     [@_CFG.cflags], eax             ; assign config flags

; !!! cpuid changes rbx register

    .cpuid.enter:
        ;
        mov     eax, 1                          ; Basic CPUID Information
        cpuid                                   ; EAX = 01H
        xor     eax, eax
    .sse?:
        test    edx, 0x02000000                 ; EDX:25 - SSE bit
        jz     .sse.out
        or      eax, SIC_CPU_FLAG_SSE
    .sse.out:
    .sse2?:
        test    edx, 0x04000000                 ; EDX:26 - SSE2 bit
        jz     .sse2.out
        or      eax, SIC_CPU_FLAG_SSE2
    .sse2.out:
    .sse3?:
        test    ecx, 0x00000001                 ; ECX:00 - SSE3 bit
        jz     .sse3.out
        or      eax, SIC_CPU_FLAG_SSE3
    .sse3.out:
    .ssse3?:
        test    ecx, 0x00000200                 ; ECX:09 - SSSE3 bit
        jz     .ssse3.out
        or      eax, SIC_CPU_FLAG_SSSE3
    .ssse3.out:
    .sse4.1?:
        test    ecx, 0x00080000                 ; ECX:19 - SSSE4.1 bit
        jz     .sse4.1.out
        or      eax, SIC_CPU_FLAG_SSE4.1
    .sse4.1.out:
    .sse4.2?:
        test    ecx, 0x00100000                 ; ECX:20 - SSSE4.2 bit
        jz     .sse4.2.out
        or      eax, SIC_CPU_FLAG_SSE4.2
    .sse4.2.out:
    .avx?:
        test    ecx, 0x10000000                 ; ECX:28 - AVX bit
        jz     .avx.out
        or      eax, SIC_CPU_FLAG_AVX
    .avx.out:
    .fma?:
        test    ecx, 0x00001000                 ; ECX:12 - FMA bit
        jz     .fma.out
        or      eax, SIC_CPU_FLAG_FMA
    .fma.out:
    .popcnt?:
        test    ecx, 0x00800000                 ; ECX:23 - POPCNT bit
        jz     .popcnt.out
        or      eax, SIC_CPU_FLAG_POPCNT
    .popcnt.out:
    .rdrand?:
        test    ecx, 0x40000000                 ; ECX:30 - RDRAND bit
        jz     .rdrand.out
        or      eax, SIC_CPU_FLAG_RDRAND
    .rdrand.out:
        ;
        push    eax                             ; Structured Extended Feature Flags Enumeration Leaf
        mov     eax, 0x07                       ; EAX = 07H, ECX = 0
        xor     ecx, ecx
        cpuid
        pop     eax
    .avx2?:
        test    ebx, 0x00000020                 ; EBX:05 - AVX2 bit
        jz     .avx2.out
        or      eax, SIC_CPU_FLAG_AVX2
    .avx2.out:
    .bmi1?:
        test    ebx, 0x00000008                 ; EBX:03 - BMI1 bit
        jz     .bmi1.out
        or      eax, SIC_CPU_FLAG_BMI1
    .bmi1.out:
    .bmi2?:
        test    ebx, 0x00000100                 ; EBX:08 - BMI2 bit
        jz     .bmi2.out
        or      eax, SIC_CPU_FLAG_BMI2
    .bmi2.out:
    .adx?:
        test    ebx, 0x00080000                 ; EBX:19 - ADX bit
        jz     .adx.out
        or      eax, SIC_CPU_FLAG_ADX
    .adx.out:
    .rdseed?:
        test    ebx, 0x00040000                 ; EBX:18 - RDSEED bit
        jz     .rdrand.out
        or      eax, SIC_CPU_FLAG_RDSEED
    .rdseed.out:
        ;
        push    eax                             ; Processor Extended State Enumeration Main Leaf
        mov     eax, 0x0D                       ; EAX = 0DH, ECX = 0
        xor     ecx, ecx
        cpuid
        mov     ebx, eax
        pop     eax
    .avx512?:
        test    ebx, 0x000000E0                 ; EAX(->EBX):05-07:11100000 - AVX-512 state bits
        jz     .avx512.out
        or      eax, SIC_CPU_FLAG_AVX512
    .avx512.out:
        ;
        push    eax                             ; Extended Function CPUID Information
        mov     eax, 0x80000001                 ; EAX = 80000001H
        cpuid
        pop     eax
    .lzcnt?:
        test    ecx, 0x00000020                 ; ECX:05 - LZCNT bit
        jz     .lzcnt.out
        or      eax, SIC_CPU_FLAG_LZCNT
    .lzcnt.out:
        ;
    .cpuid.leave:
        mov     [@_CFG.cpu_flags], eax          ; assign CPU flags
        mov     [esi + T_sic_config.cpu_flags], eax

    .memory:
        mov     edx, [esi + T_sic_config.memory]
        test    edx, edx
        jz     .memory.default
        cmp     edx, 0x01000000                 ; 16MB
        jbe    .memory.setup
    .memory.default:
        mov     edx, 0x00010000                 ; edx = default memory block size (64K)
    .memory.setup:
        mov     [@_CFG.memory], edx
        mov     [esi + T_sic_config.memory], edx
        mov     eax, edx
        shl     eax, 1
        mov     [@_CFG.fdata_size], eax         ; fdata_size = 2 * mem_block_size
        mov     [esi + T_sic_config.fdata_size], edx
        mov     [@_CFG.cdata_size], edx         ; cdata_size = mem_block_size
        mov     [esi + T_sic_config.cdata_size], edx
        mov     [@_CFG.vdata_size], edx         ; vdata_size = mem_block_size
        mov     [esi + T_sic_config.vdata_size], edx
        mov     [@_CFG.rdata_size], edx         ; rdata_size = mem_block_size
        mov     [esi + T_sic_config.rdata_size], edx

        push    edx
        mov     eax, edx
        mov     ecx, 5
        mul     ecx                             ; eax = 5 * mem_block_size
        mov     [@_CFG.stack_size], eax         ; stack_size = 5 * mem_block_size
        mov     [esi + T_sic_config.stack_size], eax
        pop     edx

        push    edx
        mov     eax, edx
        mov     ecx, 3
        mul     ecx                             ; eax = 3 * mem_block_size
        mov     [@_CFG.rpn_size], eax           ; rpn_size = 3 * mem_block_size
        mov     [esi + T_sic_config.rpn_size], eax
        pop     edx

        shl     edx, 2                          ; edx = 4 * mem_block_size
        mov     [@_CFG.code_size], edx          ; code_size = 4 * mem_block_size
        mov     [esi + T_sic_config.code_size], edx

    .section:
        mov     eax, [@_CFG.section_code]
        mov     [esi + T_sic_config.section_code], eax

        mov     eax, [@_CFG.section_data]
        mov     [esi + T_sic_config.section_data], eax

        mov     eax, [@_CFG.section_idata]
        mov     [esi + T_sic_config.section_idata], eax

        mov     eax, [@_CFG.section_edata]
        mov     [esi + T_sic_config.section_edata], eax

        mov     eax, [@_CFG.section_rsrc]
        mov     [esi + T_sic_config.section_rsrc], eax

        mov     eax, [@_CFG.section_reloc]
        mov     [esi + T_sic_config.section_reloc], eax

    .data:
        mov     eax, [@_CFG.fcode_size]
        mov     [esi + T_sic_config.fcode_size], eax

        mov     ecx, sizeof.fitem32             ; fdata_count = ?
        mov     eax, [@_CFG.fdata_size]
        sub     eax, sizeof.table.header
        cdq
        idiv    ecx
        mov     [@_CFG.fdata_count], eax        ; fdata_count = (fdata_size - sizeof.table.header) / sizeof.fitem32
        mov     [esi + T_sic_config.fdata_count], eax

        mov     ecx, sizeof.citem32             ; cdata_count = ?
        mov     eax, [@_CFG.cdata_size]
        sub     eax, sizeof.table.header
        cdq
        idiv    ecx
        mov     [@_CFG.cdata_count], eax        ; cdata_count = (cdata_size - sizeof.table.header) / sizeof.citem32
        mov     [esi + T_sic_config.cdata_count], eax

        mov     ecx, sizeof.vitem32             ; vdata_count = ?
        mov     eax, [@_CFG.vdata_size]
        sub     eax, sizeof.table.header
        cdq
        idiv    ecx
        mov     [@_CFG.vdata_count], eax        ; vdata_count = (vdata_size - sizeof.table.header) / sizeof.vitem32
        mov     [esi + T_sic_config.vdata_count], eax

        mov     ecx, sizeof.citem32             ; rdata_count = ?
        mov     eax, [@_CFG.rdata_size]
        sub     eax, sizeof.table.header
        cdq
        idiv    ecx
        mov     [@_CFG.rdata_count], eax        ; rdata_count = (rdata_size - sizeof.table.header) / sizeof.citem32
        mov     [esi + T_sic_config.rdata_count], eax

        mov     ecx, sizeof.sitem32             ; stack_count = ?
        mov     eax, [@_CFG.stack_size]
        cdq
        idiv    ecx
        mov     [@_CFG.stack_count], eax        ; stack_count = stack_size / sizeof.sitem32
        mov     [esi + T_sic_config.stack_count], eax

        mov     ecx, sizeof.sitem32             ; rpn_count = ?
        mov     eax, [@_CFG.rpn_size]
        cdq
        idiv    ecx
        dec     eax
        mov     [@_CFG.rpn_count], eax          ; rpn_count = rpn_size / sizeof.sitem32 - 1
        mov     [esi + T_sic_config.rpn_count], eax

        mov     eax, [@_CFG.fitem_nsize]
        dec     eax                             ; ignore terminating zero
        mov     [esi + T_sic_config.fitem_nsize], eax

        mov     eax, [@_CFG.citem_nsize]
        dec     eax                             ; ignore terminating zero
        mov     [esi + T_sic_config.citem_nsize], eax

        mov     eax, [@_CFG.vitem_nsize]
        dec     eax                             ; ignore terminating zero
        mov     [esi + T_sic_config.vitem_nsize], eax

        mov     eax, [@_CFG.uddata_scount]
        mov     [esi + T_sic_config.uddata_scount], eax

    .return:
        pop     esi ebx
        ret
$endp

; ------------------------------------------------------------------------------

; VOID sic_cretab ( VOID )
;
; create global tables
;
$proc sic_cretab

        push    ebx

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
        pop     ebx
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
       .FO      dd ?
       .AC      dd ?
       .CS      dd ?
       .RT      dd ?
    endl

   .enter:
        push    ebx esi edi

        inc     [@_FDATA.REFS]

        cmp     [@_FDATA], 0
        jz     .alloc
        mov     eax, [@_FDATA]                  ; eax = table offset
        mov     eax, [eax + table.header.icount]; eax = table item count
        jmp    .return

    .alloc:
        stdcall halloc, [@_CFG.fdata_size]
        mov     [@_FDATA], eax                  ; eax = table offset
        test    eax, eax
        jz     .return                          ; error. memory allocation error

    .header:                                    ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.fdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.fitem32
        mov     [eax + table.header.tnsize], fitem.nsize
        mov     [eax + table.header.titype], 1

    .GFT.on:
        mov     eax, @_GFT.count
        test    eax, eax
        jz     .GFT.off
        cmp     eax, [@_CFG.fdata_count]
        ja     .GFT.off                         ; error. table size too large

        mov     esi, @_GFT                      ; add built-in functions
        mov     edi,-@_GFT.data.size - 1
        mov     ebx, @_GFT.count                ; ebx = item count
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

        mov     esi, @_SFT                      ; add built-in functions
        mov     edi,-@_SFT.data.size - 1
        mov     ebx, @_SFT.count                ; ebx = item count
    .SFT.afun:
        call   .XFT
    .SFT.off:

    .result:
        mov     eax, [@_FDATA]                  ; eax = table offset
        mov     eax, [eax + table.header.icount]; eax = table item count

    .return:
        pop     edi esi ebx
        ret

$sproc .XFT

    .XFT.afun:
;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + edi + XFT_data_size + 2]
        add     esi, edi
        add     esi, XFT_data_size + 2          ; esi = current item name offset

        movzx   edi, byte [esi - 1]             ; edi = current item name size
    .XFT.afun.fo:
      if XFT_offset_size = 4
        mov     ecx, dword [esi + 1 + edi]      ; ecx = function entry offset (relative)
      else
        movzx   ecx, word [esi + 1 + edi]       ; ecx = function entry offset (relative)
      end if
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10                        ; rcx = function entry offset (absolute)
    $else
        add     ecx, SIC_F_BASE                 ; ecx = function entry offset (absolute)
    $end
        mov     [.FO], ecx                      ; [.FO] = function offset
        ;
    .XFT.afun.ac:
        mov     cl, byte [esi + 1 + edi + XFT_offset_size]
        cmp     cl, 0x80
        je     .XFT.afun.ac.vany
        movsx   eax, cl
        jmp    .XFT.afun.ac.assign
    .XFT.afun.ac.vany:
        mov     cx, 0x8000
        movzx   eax, cx
    .XFT.afun.ac.assign:
        mov     [.AC], eax                      ; [.AC] = function argument count
        ;
    .XFT.afun.cs:
        movzx   eax, byte [esi + 1 + edi + XFT_offset_size + 1]
        mov     [.CS], eax                      ; [.CS] = function code size
    .XFT.afun.rt:
        movsx   eax, byte [esi + 1 + edi + XFT_offset_size + 2]
        mov     [.RT], eax                      ; [.RT] = function return type
    .XFT.taset:
        stdcall taset, [@_FDATA], esi, [.FO], [.AC], [.CS], [.RT]
        dec     ebx
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
       .MODULE  dd ?
       .PATH    dd ?
       .FILE    dd ?
       .FSIZE   dd ?
       .BUFFER  dd ?
    endl

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        inc     [@_EF.REFS]

        xor     eax, eax
        cmp     [@_EF.DHL], eax
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
        mov     [.MODULE], eax
        mov     edi, eax
        stdcall halloc, .CBUFFER
        mov     [.PATH], eax
        mov     esi, eax
        ; DWORD GetModuleFileName ( HMODULE, LPTSTR, DWORD )
        invoke  GetModuleFileName, 0, edi, .CBUFFER
        lea     ebx, [.FILE]
        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, edi, .CBUFFER, esi, ebx
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, [.FILE], S_UDF_FILE
        cinvoke strcpy, [.FILE], S_UDF_FILE

   .UDF_FILE_CREATE:
        ; HANDLE CreateFile ( LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE )
        invoke  CreateFile, esi, .CF_ACCESS, .CF_SHARE, NULL, OPEN_EXISTING, .CF_FLAGS, 0
        cmp     eax, INVALID_HANDLE_VALUE
        je     .return
        mov     edi, eax
        ; DWORD GetFileSize ( HANDLE, LPDWORD )
        invoke  GetFileSize, edi, NULL
        mov     [.FSIZE], eax
        ; BOOL CloseHandle ( HANDLE )
        invoke  CloseHandle, edi
        cmp     [.FSIZE], 0
        jle    .return

   .UDF_ALLOC:
        stdcall halloc, [.FSIZE]
        mov     edi, eax
        mov     [.BUFFER], edi
   .UDF_READ:
        ; DWORD GetPrivateProfileSectionNames ( LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSectionNames, edi, [.FSIZE], esi
        test    eax, eax
        jz     .UDF_FREE
        lea     ebx, [edi - 1]
   .UDF_TEST:
        mov     eax, [@_CFG.uddata_scount]
        cmp     [.DC], eax
        jg     .UDF_FREE
        lea     edi, [ebx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax
        jz     .UDF_FREE
;       xor     rdx, rdx
        mov     edx, eax
        lea     ebx, [edi + edx]
        cmp     byte [edi], '*'                 ; skip commented item
        je     .UDF_TEST
        cmp     byte [edi], '#'                 ; skip commented item
        je     .UDF_TEST
        cmp     byte [edi], ';'                 ; skip commented item
        je     .UDF_TEST
   .UDF_ADD:
        stdcall funloas, esi, [.FSIZE], edi
        add     [.IC], eax
        test    ecx, ecx                        ; ecx = library handle
        jz     .UDF_TEST
        push    ecx
;       push    ecx
        inc     [.DC]
        jmp    .UDF_TEST
   .UDF_FREE:
        stdcall hfree, [.BUFFER]

   .return:
;       xor     rdi, rdi
        mov     edi, [.DC]
        test    edi, edi
        jz     .leave
        shl     edi, 3                          ; edi = [.DC] * 8
        stdcall halloc, edi
        mov     [@_EF.DHL], eax
        test    eax, eax
        jnz    .DLL.ADD
   .DLL.FREE:
        sub     edi, 8
        pop     ecx                             ; ecx = library handle
;       pop     ecx                             ; ecx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, ecx
        test    edi, edi
        jnz    .DLL.FREE
        jmp    .leave
   .DLL.ADD:
        sub     edi, 8
        pop     ecx                             ; ecx = library handle
;       pop     ecx                             ; ecx = library handle
        mov     [eax + edi], ecx
        test    edi, edi
        jnz    .DLL.ADD
        mov     eax, [.DC]
        mov     [@_EF.DC], eax
   .leave:
        stdcall hfree, [.MODULE]
        stdcall hfree, [.PATH]

   .leave.out:
        mov     eax, [.IC]
        mov     [@_EF.IC], eax
        pop     edi esi ebx
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
        pushsa  esi, edi                        ; push & 16-byte stack align for x64

        dec     [@_EF.REFS]
        cmp     [@_EF.REFS], 0
        jg     .return
        mov     [@_EF.REFS], 0

;       xor     rdi, rdi
        mov     edi, [@_EF.DC]
        mov     [@_EF.DC], 0
        mov     [@_EF.IC], 0
        mov     esi, [@_EF.DHL]
        test    esi, esi
        jz     .return
        test    edi, edi
        jz     .FREE.DLLs
        shl     edi, 3                          ; edi = [.DC] * 8
   .FREE.DLL:
        sub     edi, 8
        mov     ecx, [esi + edi]                ; ecx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, ecx
        test    edi, edi
        jnz    .FREE.DLL
   .FREE.DLLs:
        stdcall hfree, [@_EF.DHL]
        mov     [@_EF.DHL], 0

   .return:
        pop     edi esi
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
       .LO      dd ?
       .HI      dd ?
       .CT      dd ?
    endl

   .enter:
        push    ebx esi edi

        inc     [@_CDATA.REFS]

        cmp     [@_CDATA], 0
        jz     .alloc
        mov     eax, [@_CDATA]                  ; eax = table offset
        mov     eax, [eax + table.header.icount]; eax = table item count
        jmp    .return

   .alloc:
        stdcall halloc, [@_CFG.cdata_size]
        mov     [@_CDATA], eax                  ; eax = table offset
        test    eax, eax
        jz     .return                          ; error. memory allocation error

   .header:                                     ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.cdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.citem32
        mov     [eax + table.header.tnsize], citem.nsize
        mov     [eax + table.header.titype], 2

        mov     eax, @_GCT.count
        test    eax, eax
        jz     .result
        cmp     eax, [@_CFG.cdata_count]
        ja     .result                          ; error. table size too large

        mov     esi, @_GCT                      ; add predefined constants
        mov     edi,-@_GCT.data.size - 1
        mov     ebx, @_GCT.count
   .acon:
;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + edi + @_GCT.data.size + 2]
        add     esi, edi
        add     esi, @_GCT.data.size + 2        ; esi = current item name offset

        movzx   edi, byte [esi - 1]             ; edi = current item name size
        xor     edx, edx
        mov     dl, byte [esi + 9 + edi]
        mov     [.CT], edx                      ; [.CT] = constant item type
        mov     edx, dword [esi + 1 + edi]
        mov     [.LO], edx                      ; [.LO] = constant value LO
        mov     edx, dword [esi + 5 + edi]
        mov     [.HI], edx                      ; [.HI] = constant value HI
        stdcall taset, [@_CDATA], esi, [.LO], [.HI], [.CT], 0
        dec     ebx
        jnz    .acon

   .result:
        mov     eax, [@_CDATA]                  ; eax = table offset
        mov     eax, [eax + table.header.icount]; eax = table item count

   .return:
        pop     edi esi ebx
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
       .MODULE  dd ?
       .PATH    dd ?
       .FILE    dd ?
       .FSIZE   dd ?
       .BUFFER  dd ?
    endl

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        mov     [.IC], 0

   .UDC_FILE:
        stdcall halloc, .CBUFFER
        mov     [.MODULE], eax
        mov     edi, eax
        stdcall halloc, .CBUFFER
        mov     [.PATH], eax
        mov     esi, eax
        ; DWORD GetModuleFileName ( HMODULE, LPTSTR, DWORD )
        invoke  GetModuleFileName, 0, edi, .CBUFFER
        lea     ebx, [.FILE]
        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, edi, .CBUFFER, esi, ebx
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, [.FILE], S_UDC_FILE
        cinvoke strcpy, [.FILE], S_UDC_FILE

   .UDC_FILE_CREATE:
        ; HANDLE CreateFile ( LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE )
        invoke  CreateFile, esi, .CF_ACCESS, .CF_SHARE, NULL, OPEN_EXISTING, .CF_FLAGS, 0
        cmp     eax, INVALID_HANDLE_VALUE
        je     .return
        mov     edi, eax
        ; DWORD GetFileSize ( HANDLE, LPDWORD )
        invoke  GetFileSize, edi, NULL
        mov     [.FSIZE], eax
        ; BOOL CloseHandle ( HANDLE )
        invoke  CloseHandle, edi
        cmp     [.FSIZE], 0
        jle    .return

   .UDC_ALLOC:
        stdcall halloc, [.FSIZE]
        mov     edi, eax
        mov     [.BUFFER], edi
   .UDC_READ:
        ; DWORD GetPrivateProfileSectionNames ( LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSectionNames, edi, [.FSIZE], esi
        test    eax, eax
        jz     .UDC_FREE
        lea     ebx, [edi - 1]
   .UDC_TEST:
        lea     edi, [ebx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax
        jz     .UDC_FREE
;       xor     rdx, rdx
        mov     edx, eax
        lea     ebx, [edi + edx]
        cmp     byte [edi], '*'                 ; skip commented item
        je     .UDC_TEST
        cmp     byte [edi], '#'                 ; skip commented item
        je     .UDC_TEST
        cmp     byte [edi], ';'                 ; skip commented item
        je     .UDC_TEST
   .UDC_ADD:
        stdcall conloas, esi, [.FSIZE], edi
        add     [.IC], eax
        jmp    .UDC_TEST
   .UDC_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        stdcall hfree, [.MODULE]
        stdcall hfree, [.PATH]
        mov     eax, [.IC]
        pop     edi esi ebx
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
       .OFF     dd ?
    endl

   .enter:
        push    ebx esi edi

        inc     [@_VDATA.REFS]

        cmp     [@_VDATA], 0
        jz     .alloc
        mov     eax, [@_VDATA]                  ; eax = table offset
        mov     eax, [eax + table.header.icount]; eax = table item count
        jmp    .return

   .alloc:
        stdcall halloc, [@_CFG.vdata_size]
        mov     [@_VDATA], eax                  ; eax = table offset
        test    eax, eax
        jz     .return                          ; error. memory allocation error

   .header:                                     ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.vdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.vitem32
        mov     [eax + table.header.tnsize], vitem.nsize
        mov     [eax + table.header.titype], 3

   .result:
        mov     edx, [@_VDATA]                  ; edx = table offset
;       xor     rax, rax
        mov     eax, [edx + table.header.icount]; eax = table item count

   .return:
        pop     edi esi ebx
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
       .MODULE  dd ?
       .PATH    dd ?
       .FILE    dd ?
       .FSIZE   dd ?
       .BUFFER  dd ?
    endl

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        inc     [@_EV.REFS]

        xor     eax, eax
        cmp     [@_EV.DHL], eax
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
        mov     [.MODULE], eax
        mov     edi, eax
        stdcall halloc, .CBUFFER
        mov     [.PATH], eax
        mov     esi, eax
        ; DWORD GetModuleFileName ( HMODULE, LPTSTR, DWORD )
        invoke  GetModuleFileName, 0, edi, .CBUFFER
        lea     ebx, [.FILE]
        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, edi, .CBUFFER, esi, ebx
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, [.FILE], S_UDV_FILE
        cinvoke strcpy, [.FILE], S_UDV_FILE

   .UDV_FILE_CREATE:
        ; HANDLE CreateFile ( LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE )
        invoke  CreateFile, esi, .CF_ACCESS, .CF_SHARE, NULL, OPEN_EXISTING, .CF_FLAGS, 0
        cmp     eax, INVALID_HANDLE_VALUE
        je     .return
        mov     edi, eax
        ; DWORD GetFileSize ( HANDLE, LPDWORD )
        invoke  GetFileSize, edi, NULL
        mov     [.FSIZE], eax
        ; BOOL CloseHandle ( HANDLE )
        invoke  CloseHandle, edi
        cmp     [.FSIZE], 0
        jle    .return

   .UDV_ALLOC:
        stdcall halloc, [.FSIZE]
        mov     edi, eax
        mov     [.BUFFER], edi
   .UDV_READ:
        ; DWORD GetPrivateProfileSectionNames ( LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSectionNames, edi, [.FSIZE], esi
        test    eax, eax
        jz     .UDV_FREE
        lea     ebx, [edi - 1]
   .UDV_TEST:
        mov     eax, [@_CFG.uddata_scount]
        cmp     [.DC], eax
        jg     .UDV_FREE
        lea     edi, [ebx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax
        jz     .UDV_FREE
;       xor     rdx, rdx
        mov     edx, eax
        lea     ebx, [edi + edx]
        cmp     byte [edi], '*'                 ; skip commented item
        je     .UDV_TEST
        cmp     byte [edi], '#'                 ; skip commented item
        je     .UDV_TEST
        cmp     byte [edi], ';'                 ; skip commented item
        je     .UDV_TEST
   .UDV_ADD:
        stdcall varloas, esi, [.FSIZE], edi
        add     [.IC], eax
        test    ecx, ecx                        ; ecx = library handle
        jz     .UDV_TEST
        push    ecx
;       push    ecx
        inc     [.DC]
        jmp    .UDV_TEST
   .UDV_FREE:
        stdcall hfree, [.BUFFER]

   .return:
;       xor     rdi, rdi
        mov     edi, [.DC]
        test    edi, edi
        jz     .leave
        shl     edi, 3                          ; edi = [.DC] * 8
        stdcall halloc, edi
        mov     [@_EV.DHL], eax
        test    eax, eax
        jnz    .DLL.ADD
   .DLL.FREE:
        sub     edi, 8
        pop     ecx                             ; ecx = library handle
;       pop     ecx                             ; ecx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, ecx
        test    edi, edi
        jnz    .DLL.FREE
        jmp    .leave
   .DLL.ADD:
        sub     edi, 8
        pop     ecx                             ; ecx = library handle
;       pop     ecx                             ; ecx = library handle
        mov     [eax + edi], ecx
        test    edi, edi
        jnz    .DLL.ADD
        mov     eax, [.DC]
        mov     [@_EV.DC], eax
   .leave:
        stdcall hfree, [.MODULE]
        stdcall hfree, [.PATH]

   .leave.out:
        mov     eax, [.IC]
        mov     [@_EV.IC], eax
        pop     edi esi ebx
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
        pushsa  esi, edi                        ; push & 16-byte stack align for x64

        dec     [@_EV.REFS]
        cmp     [@_EV.REFS], 0
        jg     .return
        mov     [@_EV.REFS], 0

;       xor     rdi, rdi
        mov     edi, [@_EV.DC]
        mov     [@_EV.DC], 0
        mov     [@_EV.IC], 0
        mov     esi, [@_EV.DHL]
        test    esi, esi
        jz     .return
        test    edi, edi
        jz     .FREE.DLLs
        shl     edi, 3                          ; edi = [.DC] * 8
   .FREE.DLL:
        sub     edi, 8
        mov     ecx, [esi + edi]                ; ecx = library handle
        ; BOOL FreeLibrary ( HMODULE )
        invoke  FreeLibrary, ecx
        test    edi, edi
        jnz    .FREE.DLL
   .FREE.DLLs:
        stdcall hfree, [@_EV.DHL]
        mov     [@_EV.DHL], 0

   .return:
        pop     edi esi
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
        xor     eax, eax
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

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        push    esi

        mov     esi, [sic]                      ; esi = T_sic_data structure offset
        test    esi, esi
        jz     .return                          ; error. null T_sic_data structure offset

    .zero.sic:                                  ; zero T_sic_data structure fields
        stdcall zerosic, esi

    .fdata.alloc:
        stdcall halloc, [@_CFG.fdata_size]      ; allocate memory for function data segment
        test    eax, eax
        jz     .return                          ; error. memory allocation error
        mov     [esi + T_sic_data.fdata], eax   ; save function data segment offset

    .fdata.header:                              ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.fdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.fitem32
        mov     [eax + table.header.tnsize], fitem.nsize
        mov     [eax + table.header.titype], 1

    .cdata.alloc:
        stdcall halloc, [@_CFG.cdata_size]      ; allocate memory for constant data segment
        test    eax, eax
        jz     .return                          ; error. memory allocation error
        mov     [esi + T_sic_data.cdata], eax   ; save constant data segment offset

    .cdata.header:                              ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.cdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.citem32
        mov     [eax + table.header.tnsize], citem.nsize
        mov     [eax + table.header.titype], 2

    .vdata.alloc:
        stdcall halloc, [@_CFG.vdata_size]      ; allocate memory for variable data segment
        test    eax, eax
        jz     .return                          ; error. memory allocation error
        mov     [esi + T_sic_data.vdata], eax   ; save variable data segment offset

    .vdata.header:                              ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.vdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.vitem32
        mov     [eax + table.header.tnsize], vitem.nsize
        mov     [eax + table.header.titype], 3

    .rdata.alloc:
        stdcall halloc, [@_CFG.rdata_size]      ; allocate memory for runtime data segment
        test    eax, eax
        jz     .return                          ; error. memory allocation error
        mov     [esi + T_sic_data.rdata], eax   ; save runtime data segment offset

    .rdata.header:                              ; assign table header
        mov     [eax + table.header.icount], 0
        mov     edx, [@_CFG.rdata_count]
        mov     [eax + table.header.mcount], edx
        mov     [eax + table.header.tisize], sizeof.citem32
        mov     [eax + table.header.tnsize], citem.nsize
        mov     [eax + table.header.titype], 2

    .return:
        pop     esi
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

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        push    esi

        xor     eax, eax
        mov     esi, [sic]                      ; esi = T_sic_data structure offset
        test    esi, esi
        jz     .return                          ; error. null T_sic_data structure offset

    .free.code:                                 ; free code segment
        stdcall cfree, [esi + T_sic_data.code]
    .free.data:                                 ; free data segment
        stdcall hfree, [esi + T_sic_data.data]
    .free.fdata:                                ; free function data segment
        stdcall hfree, [esi + T_sic_data.fdata]
    .free.cdata:                                ; free constant data segment
        stdcall hfree, [esi + T_sic_data.cdata]
    .free.vdata:                                ; free variable data segment
        stdcall hfree, [esi + T_sic_data.vdata]
    .free.rdata:                                ; free runtime data segment
        stdcall hfree, [esi + T_sic_data.rdata]

    .zero.sic:                                  ; zero T_sic_data structure fields
        stdcall zerosic, esi

    .return:
        pop     esi
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
       .AC      dd ? ; argument count
       .FF      dd ? ; function flags
       .RT      dd ? ; return type
    endl

;       mov     [sic], rcx
;       mov     [fun], rdx
;       mov     [fuo], r8
;       mov     [fac], r9

    .verify.fun:
        stdcall verify.name, [fun]
        cmp     eax, 0
        jg     .verify.fun.out
        dec     eax
        jmp    .return
    .verify.fun.out:

        stdcall sic_gefut, [sic]                ; eax(ecx) = function table offset
        xor     edx, edx
        mov     dx, word [fac]                  ; dx = function argument count
        mov     [.AC], edx
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
        mov     [.FF], edx
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
        stdcall taset, ecx, [fun], [fuo], [.AC], [.FF], [.RT]
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
       .OFF     dd ?
       .AC      dd ?
       .CS      dd ?
       .RT      dd ?
    endl

;       mov     [sic], rcx
;       mov     [fun], rdx
;       mov     [fuo], r8
;       mov     [fui], r9

        push    esi edi

    .verify.fun:
        stdcall verify.name, [fun]
        cmp     eax, 0
        jg     .verify.fun.out
        dec     eax
        jmp    .return
    .verify.fun.out:

    .verify.fuo:
        stdcall verify.name, [fuo]
        cmp     eax, 0
        jg     .verify.fuo.out
        dec     eax
        jmp    .return
    .verify.fuo.out:

        stdcall sic_gefut, [sic]                ; eax(ecx) = function table offset
        mov     edi, ecx                        ; edi = function table offset
        stdcall taget, ecx, [fuo], -1           ; eax = item index
        cmp     eax, 0
        jl     .return                          ; error. function not found

        shl     eax, 6                          ; eax = [item index] * 64 = [item index] * sizeof.fitem
        lea     esi, [edi + sizeof.table.header + eax]
                                                ; esi = item offset
        mov     edx, [esi + fitem32.offset]     ; edx = function offset
        mov     [.OFF], edx
        movzx   edx, word [esi + fitem32.acount]; edx = function argument count
        mov     [.AC], edx
        movzx   edx, word [esi + fitem32.cosize]; edx = function code size
        mov     [.CS], edx
        movsx   edx, word [esi + fitem32.retype]; edx = function return type
        mov     [.RT], edx
        cmp     [fui], 0
        jz     .taset                           ; esi = item offset
        mov     [esi + fitem32.offset], 0       ; invalidate original function
    .taset:
        stdcall taset, edi, [fun], [.OFF], [.AC], [.CS], [.RT]
    .return:
        pop     edi esi
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

;       xor     r9, r9                          ;
        stdcall sic_refun, [sic], [fun], [fuo], 0
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

;       mov     [sic], rcx
;       mov     [fun], rdx
;       mov     [fum], r8
;       mov     [], r9

        push    ebx edi

        stdcall sic_gefut, [sic]                ; eax(ecx) = function table offset
        mov     ebx, ecx                        ; ebx = function table offset

    .fun:
        stdcall taget, ecx, [fun], -1           ; eax = item index
        cmp     eax, 0                          ; edx = item offset
        jl     .return                          ; error. function not found
        mov     edi, edx                        ; edi = item offset
    .fum:
        stdcall taget, ebx, [fum], -1           ; eax = item index
        cmp     eax, 0                          ; edx = item offset
        jl     .return                          ; error. function not found

        cmp     edi, edx
        je     .return
    .exchange.retype:
        mov     cx, [edi + fitem32.retype]
        mov     bx, [edx + fitem32.retype]
        mov     [edi + fitem32.retype], bx
        mov     [edx + fitem32.retype], cx
    .exchange.acount:
        mov     cx, [edi + fitem32.acount]
        mov     bx, [edx + fitem32.acount]
        mov     [edi + fitem32.acount], bx
        mov     [edx + fitem32.acount], cx
    .exchange.cosize:
        mov     cx, [edi + fitem32.cosize]
        mov     bx, [edx + fitem32.cosize]
        mov     [edi + fitem32.cosize], bx
        mov     [edx + fitem32.cosize], cx
    .exchange.offset:
        mov     ecx, [edi + fitem32.offset]
        mov     ebx, [edx + fitem32.offset]
        mov     [edi + fitem32.offset], ebx
        mov     [edx + fitem32.offset], ecx

    .return:
        pop     edi ebx
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
$proc sic_aconf, sic, con, cov, cov.HI

    locals
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       movsd   qword [cov], xmm2
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
;       xor     rdx, rdx
        mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     al, 'f'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     al, 'i'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     al, 's'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     al, 'o'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     al, 'p'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     ax, 'pf'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     ax, 'pi'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cov], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        xor     edx, edx
;       mov     edx, dword [cov + 4]            ; edx = constant value HI
        mov     [.HI], edx
        mov     edx, dword [cov + 0]            ; edx = constant value LO
        mov     [.LO], edx
        xor     eax, eax
        mov     ax, 'ps'
        stdcall taset, ecx, [con], [.LO], [.HI], eax, 0
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
       .LO      dd ?
       .HI      dd ?
       .DT      dd ?
    endl

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [coo], r8
;       mov     [coi], r9

        push    esi edi

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        mov     edi, ecx                        ; edi = constant table offset
        stdcall taget, ecx, [coo], -1           ; eax = item index
        cmp     eax, 0
        jl     .return                          ; error. constant not found

        shl     eax, 6                          ; eax = [item index] * 64 = [item index] * sizeof.citem
        lea     esi, [edi + sizeof.table.header + eax]
                                                ; esi = item offset
;       xor     rdx, rdx
        mov     edx, dword [esi + citem32.value + 0]
        mov     [.LO], edx                      ; constant value LO
        mov     edx, dword [esi + citem32.value + 4]
        mov     [.HI], edx                      ; constant value HI
        movzx   edx, word [esi + citem32.datype]
        mov     [.DT], edx                      ; constant data type
        xor     eax, eax                        ; eax = 0
        cmp     [coi], eax
        jz     .taset                           ; esi = item offset
        dec     eax                             ; invalidate original constant. citem.value = FFFFFFFFFFFFFFFF
    $ifdef _X64
        mov     [rsi + citem64.value], rax
    $else
        mov     dword [esi + citem32.value + 0], eax
        mov     dword [esi + citem32.value + 4], eax
    $end
    .taset:
        stdcall taset, edi, [con], [.LO], [.HI], [.DT], 0
    .return:
        pop     edi esi
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

;       xor     r9, r9                          ;
        stdcall sic_recon, [sic], [con], [coo], 0
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

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [com], r8
;       mov     [], r9

        push    ebx edi

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        mov     ebx, ecx                        ; ebx = constant table offset

    .con:
        stdcall taget, ecx, [con], -1           ; eax = item index
        cmp     eax, 0                          ; edx = item offset
        jl     .return                          ; error. constant not found
        mov     edi, edx                        ; edi = item offset
    .com:
        stdcall taget, ebx, [com], -1           ; eax = item index
        cmp     eax, 0                          ; edx = item offset
        jl     .return                          ; error. constant not found

        cmp     edi, edx
        je     .return
    .exchange.cotype:
        mov     cx, [edi + citem32.cotype]
        mov     bx, [edx + citem32.cotype]
        mov     [edi + citem32.cotype], bx
        mov     [edx + citem32.cotype], cx
    .exchange.datype:
        mov     cx, [edi + citem32.datype]
        mov     bx, [edx + citem32.datype]
        mov     [edi + citem32.datype], bx
        mov     [edx + citem32.datype], cx
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
        pop     edi ebx
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     al, 'f'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     al, 'i'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     al, 's'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     al, 'o'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     al, 'p'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     ax, 'pf'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     ax, 'pi'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        xor     eax, eax
        mov     ax, 'ps'
        stdcall taset, ecx, [van], [vao], 0, eax, 0
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
       .OFF     dd ?
       .DT      dd ?
    endl

;       mov     [sic], rcx
;       mov     [van], rdx
;       mov     [vao], r8
;       mov     [vai], r9

        push    edi

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        mov     edi, ecx                        ; edi = variable table offset
        stdcall taget, ecx, [vao], -1           ; eax = item index
        cmp     eax, 0
        jl     .return                          ; error. variable not found

        shl     eax, 6                          ; eax = [item index] * 64 = [item index] * sizeof.vitem
        lea     ecx, [edi + sizeof.table.header + eax]
                                                ; ecx = item offset
        mov     edx, [ecx + vitem32.offset]     ; edx = variable offset
        mov     [.OFF], edx
        movzx   edx, word [ecx + vitem32.datype]
        mov     [.DT], edx                      ; variable data type
        xor     eax, eax                        ; eax = 0
        cmp     dword [vai], eax
        jz     .taset                           ; ecx = item offset
        mov     [ecx + vitem32.offset], eax     ; invalidate original variable
    .taset:
        stdcall taset, edi, [van], [.OFF], eax, [.DT], 0
    .return:
        pop     edi
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

;       xor     r9, r9                          ;
        stdcall sic_revar, [sic], [van], [vao], 0
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

;       mov     [sic], rcx
;       mov     [van], rdx
;       mov     [vam], r8
;       mov     [], r9

        push    ebx edi

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        mov     ebx, ecx                        ; ebx = variable table offset

    .van:
        stdcall taget, ecx, [van], -1           ; eax = item index
        cmp     eax, 0                          ; edx = item offset
        jl     .return                          ; error. variable not found
        mov     edi, edx                        ; edi = item offset
    .vam:
        stdcall taget, ebx, [vam], -1           ; eax = item index
        cmp     eax, 0                          ; edx = item offset
        jl     .return                          ; error. variable not found

        cmp     edi, edx
        je     .return
    .exchange.vatype:
        mov     cx, [edi + vitem32.vatype]
        mov     bx, [edx + vitem32.vatype]
        mov     [edi + vitem32.vatype], bx
        mov     [edx + vitem32.vatype], cx
    .exchange.datype:
        mov     cx, [edi + vitem32.datype]
        mov     bx, [edx + vitem32.datype]
        mov     [edi + vitem32.datype], bx
        mov     [edx + vitem32.datype], cx
    .exchange.offset:
        mov     ecx, [edi + citem32.offset]
        mov     ebx, [edx + citem32.offset]
        mov     [edi + citem32.offset], ebx
        mov     [edx + citem32.offset], ecx

    .return:
        pop     edi ebx
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

;       mov     [sic], rcx
;       mov     [fun], rdx
;       mov     [], r8
;       mov     [], r9

    .verify.fun:
        stdcall verify.name, [fun]
        cmp     eax, 0
        jg     .verify.fun.out
        dec     eax
        jmp    .return
    .verify.fun.out:

        stdcall sic_gefut, [sic]                ; eax(ecx) = function table offset
        stdcall tinva, ecx, [fun]
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
;       mov     [con], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        stdcall tinva, ecx, [con]
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
;       mov     [van], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        stdcall tinva, ecx, [van]
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

;       mov     [sic], rcx
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

        stdcall sic_gefut, [sic]                ; eax(ecx) = function table offset
        stdcall tapac, ecx, 1
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

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        stdcall tapac, ecx, 2
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

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        stdcall tapac, ecx, 3
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
; <- eax : function table offset
; <- ecx : function table offset
;
$proc sic_gefut, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     eax, [@_FDATA]                  ; eax = global table offset
        mov     ecx, [sic]                      ; ecx = T_sic_data structure offset
        test    ecx, ecx
        jz     .return                          ; sic = null
        mov     eax, [ecx + T_sic_data.fdata]   ; eax = local table offset
    .return:
        mov     ecx, eax                        ; ecx = table offset
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

        stdcall sic_gefut, [sic]                ; eax(ecx) = table offset
        test    eax, eax
        jz     .return

        mov     eax, [eax + table.header.icount]

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
;       mov     [fin], rdx
;       mov     [fui], r8
;       mov     [], r9

        push    esi edi

        stdcall sic_gefut, [sic]                ; eax(ecx) = table offset
        mov     esi, eax                        ; esi = table offset
        mov     eax, -1
        test    esi, esi
        jz     .return
        mov     edi, [fui]                      ; edi = item structure offset
        test    edi, edi
        jz     .return
;       xor     rdx, rdx
        mov     edx, dword [fin]                ; edx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [esi + table.header.icount]
        jge    .return

        mov     eax, edx                        ; eax = item index
        shl     edx, 6                          ; edx = edx * 64

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + sizeof.table.header + edx]
        add     esi, edx
        add     esi, sizeof.table.header

        mov     ecx, sizeof.fitem32
        call    momem

    .return:
        pop     edi esi
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
;       mov     [fun], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gefut, [sic]                ; eax(ecx) = table offset
        stdcall taget, ecx, [fun], -1
        ret
$endp

; ------------------------------------------------------------------------------

; LPVOID sic_gecot ( LPVOID sic )
;
; get global or local constant table offset
; deal with global table if sic = null or sic.cdata = nil
;
; -> sic : T_sic_data structure offset
; <- eax : constant table offset
; <- ecx : constant table offset
;
$proc sic_gecot, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     eax, [@_CDATA]                  ; eax = global table offset
        mov     ecx, [sic]                      ; ecx = T_sic_data structure offset
        test    ecx, ecx
        jz     .return                          ; sic = null
        mov     eax, [ecx + T_sic_data.cdata]   ; eax = local table offset
    .return:
        mov     ecx, eax                        ; ecx = table offset
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

        stdcall sic_gecot, [sic]                ; eax(ecx) = table offset
        test    eax, eax
        jz     .return

        mov     eax, [eax + table.header.icount]

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
;       mov     [cin], rdx
;       mov     [coi], r8
;       mov     [], r9

        push    esi edi

        stdcall sic_gecot, [sic]                ; eax(ecx) = table offset
        mov     esi, eax
        mov     eax, -1
        test    esi, esi
        jz     .return
        mov     edi, [coi]                      ; edi = item structure offset
        test    edi, edi
        jz     .return
;       xor     rdx, rdx
        mov     edx, dword [cin]                ; edx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [esi + table.header.icount]
        jge    .return

   .item:
        mov     eax, edx                        ; eax = item index
        shl     edx, 6                          ; edx = edx * 64

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + sizeof.table.header + edx]
        add     esi, edx
        add     esi, sizeof.table.header

        mov     ecx, sizeof.citem32
        call    momem

   .return:
        pop     edi esi
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
;       mov     [con], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gecot, [sic]                ; eax(ecx) = constant table offset
        stdcall taget, ecx, [con], -1
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
; <- eax : variable table offset
;
$proc sic_gevat, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     eax, [@_VDATA]                  ; eax = global table offset
        mov     ecx, [sic]                      ; ecx = T_sic_data structure offset
        test    ecx, ecx
        jz     .return                          ; sic = null
        mov     eax, [ecx + T_sic_data.vdata]   ; eax = local table offset
    .return:
        mov     ecx, eax                        ; ecx = table offset
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

        stdcall sic_gevat, [sic]                ; eax(ecx) = table offset
        test    eax, eax
        jz     .return

        mov     eax, [eax + table.header.icount]

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
;       mov     [vin], rdx
;       mov     [vai], r8
;       mov     [], r9

        push    ebx esi edi

        stdcall sic_gevat, [sic]                ; eax(ecx) = table offset
        mov     esi, eax
        mov     eax, -1
        test    esi, esi
        jz     .return
        mov     edi, [vai]                      ; edi = item structure offset
        test    edi, edi
        jz     .return
;       xor     rdx, rdx
        mov     edx, dword [vin]                ; edx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [esi + table.header.icount]
        jge    .return

   .item:
        mov     eax, edx                        ; eax = item index
        shl     edx, 6                          ; edx = edx * 64

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + sizeof.table.header + edx]
        add     esi, edx
        add     esi, sizeof.table.header

        mov     ebx, esi                        ; ebx = esi = item offset
        mov     ecx, sizeof.vitem32
        call    momem

   .return:
        pop     edi esi ebx
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
;       mov     [van], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gevat, [sic]                ; eax(ecx) = variable table offset
        stdcall taget, ecx, [van], -1
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
; <- eax : runtime table offset
;
$proc sic_gerut, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     eax, [@_RDATA]                  ; eax = global table offset
        mov     ecx, [sic]                      ; ecx = T_sic_data structure offset
        test    ecx, ecx
        jz     .return                          ; sic = null
        mov     eax, [ecx + T_sic_data.rdata]   ; eax = local table offset
    .return:
        mov     ecx, eax                        ; ecx = table offset
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

        stdcall sic_gerut, [sic]                ; eax(ecx) = table offset
        test    eax, eax
        jz     .return

        mov     eax, [eax + table.header.icount]

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
;       mov     [rin], rdx
;       mov     [rui], r8
;       mov     [], r9

        push    ebx esi edi

        stdcall sic_gerut, [sic]                ; eax(ecx) = table offset
        mov     esi, eax
        mov     eax, -1
        test    esi, esi
        jz     .return
        mov     edi, [rui]                      ; edi = item structure offset
        test    edi, edi
        jz     .return
;       xor     rdx, rdx
        mov     edx, dword [rin]                ; edx = item index
        cmp     edx, 0
        jl     .return
        cmp     edx, [esi + table.header.icount]
        jge    .return

   .item:
        mov     eax, edx                        ; eax = item index
        shl     edx, 6                          ; edx = edx * 64

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + sizeof.table.header + edx]
        add     esi, edx
        add     esi, sizeof.table.header

        mov     ebx, esi                        ; ebx = esi = item offset
        mov     ecx, sizeof.citem32
        call    momem

   .return:
        pop     edi esi ebx
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
;       mov     [run], rdx
;       mov     [], r8
;       mov     [], r9

        stdcall sic_gerut, [sic]                ; eax(ecx) = variable table offset
        stdcall taget, ecx, [run], -1
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
;       mov     [err], rdx
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
        test    esi, esi
        je     .error                           ; error. null T_sic_data structure offset

        mov     [.err], 0x00020000
        mov     edx, [esi + T_sic_data.code]    ; edx = code segment offset
        test    edx, edx
        je     .error                           ; error. null code segment offset
        mov     edx, [esi + T_sic_data.entry]   ; edx = entry point
        test    edx, edx
        je     .error                           ; error. null entry point

        mov     [.err], 0x00040000
        mov     eax, [esi + T_sic_data.size]
        cmp     eax, CODE_MIN_SIZE_X32
        jge    .call                            ; valid code size

   .error:
        mov     eax, [.err]                     ; eax = error code
        mov     edx, [err]
        mov     [edx], eax                      ; return error code
    $ifdef _X64
        pxor    xmm0, xmm0                      ; return zero on error
        movsd   qword [rsi + T_sic_data.value], xmm0
    $else
        fldz                                    ; return zero on error
        fst     qword [esi + T_sic_data.value]
    $end
        jmp    .leave

   .call:                                       ; execute code
        call    edx                             ; <- eax = FPU exception flags or 0
        mov     edx, [err]
        mov     [edx], eax                      ; return error code

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

        mov     edx, [esi + T_sic_data.entry]   ; edx = entry point
        call    edx                             ; execute code

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

        mov     edx, [esi + T_sic_data.entry]   ; edx = entry point
        call    edx                             ; execute code

        ; copy result to T_sic_data.value
    $ifdef _SSEX
        movsd   qword [esi + T_sic_data.value], xmm0
    $else
        fstp    qword [esi + T_sic_data.value]
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
;       mov     [s], rdx
;       mov     [sop], r8
;       mov     [err], r9

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
;       xor     rax, rax
        mov     edx, [sop]
        mov     eax, [edx]                      ; eax = compiler options
        stdcall [proc], esi, [s], eax
        mov     ecx, [esi + T_sic_data.coops]   ; ecx = actual compiler options
        mov     edx, [sop]
        mov     [edx], ecx                      ; return actual compiler options
        test    eax, eax
        je     .error                           ; error. compiler error

        mov     edx, [esi + T_sic_data.code]    ; edx = code segment offset
        test    edx, edx
        je     .error                           ; error. null code segment offset
        mov     edx, [esi + T_sic_data.entry]   ; edx = entry point
        test    edx, edx
        je     .error                           ; error. null entry point

        cmp     [esi + T_sic_data.size], CODE_MIN_SIZE_X32
        jge    .call                            ; valid code size

   .error:
        mov     eax, [.err]                     ; eax = error code
        mov     edx, [err]
        mov     [edx], eax                      ; return error code
    $ifdef _X64
        pxor    xmm0, xmm0                      ; return zero on error
        movsd   qword [rsi + T_sic_data.value], xmm0
    $else
        fldz                                    ; return zero on error
        fst     qword [esi + T_sic_data.value]
    $end
        jmp    .leave

   .call:                                       ; execute code
        call    edx                             ; <- eax = FPU exception flags or 0
        mov     edx, [err]
        mov     [edx], eax                      ; return error code

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
       .sic     T_sic32_data ?
       .fpu_cw  dw ?
    endl

;       mov     [s], rcx
;       mov     [sop], rdx
;       mov     [err], r8
;       mov     [proc], r9

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

        lea     esi, [.sic]
        stdcall sic_init, esi
        stdcall [proc], esi, [s], [sop], [err]
        mov     ecx, [esi + T_sic_data.coops]   ; ecx = actual compiler options
        mov     edx, [sop]
        mov     [edx], ecx                      ; return actual compiler options

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
