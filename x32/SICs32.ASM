
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (PE DLL format)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC:

; ------------------------------------------------------------------------------

RS_Description EQU 'Simple compiler (32-BIT-SSE)'
RS_Version     EQU '6.2.2'
RS_Product     EQU 'SICs32'
RS_Filename    EQU 'SICs32.DLL'
RS_ProgramID   EQU 'ru.maalchemist.SICs32'
RS_Company     EQU 'AL-CHEMIST GUILD'
RS_Copyright   EQU 'Copyright © 2000-3000 AL-CHEMIST GUILD'

RS_WWW         EQU 'http://maalchemist.ru',13,10,'http://maalchemist.narod.ru'
RS_Email       EQU 'maalchemist@yandex.ru',13,10,'maalchemist@gmail.com',13,10,'maa@maalchemist.ru'

RS_LANG        = LANG_NEUTRAL + SUBLANG_DEFAULT

; ------------------------------------------------------------------------------

format PE   DLL
entry zentry

DEFINE  _COFF   FALSE
DEFINE   _X64   FALSE
DEFINE   _X32    TRUE
DEFINE   _VEX    TRUE
DEFINE  _EVEX    TRUE
DEFINE  _SSEX    TRUE
DEFINE  _SSE4.1  TRUE
DEFINE  _SSE3    TRUE
DEFINE  _SSE2    TRUE
DEFINE   _UDF    TRUE                           ; user-defined files

; ------------------------------------------------------------------------------

include 'SIC32I.INC'
$.define DEBUG_CODE

; ------------------------------------------------------------------------------

section '.code' code readable executable
SIC_BOF_section_code:

; DLL ENTRY POINT
; reason : DLL_PROCESS_ATTACH
;          DLL_PROCESS_DETACH
;          DLL_THREAD_ATTACH
;          DLL_THREAD_DETACH
proc zentry hinstance, reason, reserved

;       mov     [hinstance], rcx
;       mov     [reason], rdx
;       mov     [reserved], r8
;       mov     [], r9

        mov     eax, TRUE
        ret
endp

include 'SIC32E.ASM'
include '..\xCommon\SICEX.ASM'

include 'SIC32IDA.ASM'
include 'SIC32B.ASM'
include 'SIC32C.ASM'
include 'SIC32OP.ASM'
include 'SIC32U.ASM'
include 'SIC32UC.ASM'
include 'SIC32UD.ASM'
include 'SIC32UF.ASM'
include 'SIC32Fu.ASM'
include 'SIC32Rand.ASM'
include 'SICmt32.ASM'

SIC_EOF_section_code:

; ------------------------------------------------------------------------------

section '.data' data readable writeable
SIC_BOF_section_data:

include 'SIC32V.ASM'
include 'SICmt32V.ASM'
include '..\xCommon\SICC.ASM'
include '..\xCommon\SICF.ASM'
include '..\xCommon\SICIDA.ASM'
include '..\xCommon\SICFuCOs.ASM' ; '..\xCommon\SICFuCO.ASM'

SIC_EOF_section_data:

; ------------------------------------------------------------------------------

section '.idata' import data readable writeable
SIC_BOF_section_idata:

library kernel32, 'KERNEL32.DLL',\
        user32, 'USER32.DLL',\
        msvcrt, 'MSVCRT.DLL'

; IMPORT KERNEL32.DLL
import  kernel32,\
        GetCurrentDirectory, 'GetCurrentDirectoryA',\
        SetCurrentDirectory, 'SetCurrentDirectoryA',\
        GetModuleFileName, 'GetModuleFileNameA',\
        GetFullPathName, 'GetFullPathNameA',\
        GetPrivateProfileSectionNames, 'GetPrivateProfileSectionNamesA',\
        GetPrivateProfileSection, 'GetPrivateProfileSectionA',\
        SetDllDirectory, 'SetDllDirectoryA',\
        LoadLibrary, 'LoadLibraryA',\
        LoadLibraryEx, 'LoadLibraryExA',\
        FreeLibrary, 'FreeLibrary',\
        GetProcAddress, 'GetProcAddress',\
        CreateFile, 'CreateFileA',\
        GetFileSize, 'GetFileSize',\
        CompareString, 'CompareStringA',\
        lstrlen, 'lstrlenA',\
        lstrcpy, 'lstrcpyA',\
        lstrcpyn, 'lstrcpynA',\
        VirtualAlloc, 'VirtualAlloc',\
        VirtualFree, 'VirtualFree',\
        VirtualProtect, 'VirtualProtect',\
        GetProcessHeap, 'GetProcessHeap',\
        HeapAlloc, 'HeapAlloc',\
        HeapReAlloc, 'HeapReAlloc',\
        HeapFree, 'HeapFree',\
        GetCurrentProcess, 'GetCurrentProcess',\
        FlushInstructionCache, 'FlushInstructionCache',\
        CloseHandle, 'CloseHandle',\
        GetLastError, 'GetLastError'

; IMPORT USER32.DLL
import  user32,\
        MessageBox, 'MessageBoxA'

; IMPORT MSVCRT.DLL
import  msvcrt,\
        setlocale, 'setlocale',\
        strtol, 'strtol',\
        strtod, 'strtod',\
        _strtoi64, '_strtoi64',\
        _strtoui64, '_strtoui64',\
        strlen, 'strlen',\
        strcpy, 'strcpy',\
        strncpy, 'strncpy',\
        strcmp, 'strcmp',\
        _stricmp, '_stricmp',\
        strncmp, 'strncmp',\
        _strnicmp, '_strnicmp',\
        wctomb, 'wctomb',\
        vsprintf, 'vsprintf'

SIC_EOF_section_idata:

; ------------------------------------------------------------------------------

section '.edata' export data readable
SIC_BOF_section_edata:

; EXPORT
;
; !!! export function with name 'sic_ldasm' causes a number of AV-engines
; !!! to treat SICs as Trojan.Ursu... or Gen:Variant.Ursu...
;
; !!! export function with name 'sic_ida' causes a number of AV-engines
; !!! to treat SICs as Trojan.Ursu... or Gen:Variant.Ursu...
;
export  'SICs32.DLL',\
        sic_version, 'sic_version',\            ; compiler version
        sic_cpu_support, 'sic_cpu_support',\    ; compiler support for the CPU
        sic_setup, 'sic_setup',\                ; setup compiler
        sic_cretab, 'sic_cretab',\              ; create global tables
        sic_fretab, 'sic_fretab',\              ; destroy global tables
        sic_funtac, 'sic_funtac',\              ; create global function table
        sic_funtaf, 'sic_funtaf',\              ; destroy global function table
        sic_funloa, 'sic_funloa',\              ; load external user defined functions
        sic_funulo, 'sic_funulo',\              ; unload external user defined functions
        sic_contac, 'sic_contac',\              ; create global constant table
        sic_contaf, 'sic_contaf',\              ; destroy global constant table
        sic_conloa, 'sic_conloa',\              ; load external user defined constants
        sic_conulo, 'sic_conulo',\              ; unload external user defined constants
        sic_vartac, 'sic_vartac',\              ; create global variable table
        sic_vartaf, 'sic_vartaf',\              ; destroy global variable table
        sic_varloa, 'sic_varloa',\              ; load external user defined variables
        sic_varulo, 'sic_varulo',\              ; unload external user defined variables
        sic_runtac, 'sic_runtac',\              ; create global runtime table
        sic_runtaf, 'sic_runtaf',\              ; destroy global runtime table
        sic_init, 'sic_init',\                  ; allocate memory for sic constant & variable data segments
        sic_done, 'sic_done',\                  ; free memory previously allocated for sic segments
        sic_afun, 'sic_afun',\                  ; add|set user defined function
        sic_refun, 'sic_refun',\                ; rename function
        sic_dufun, 'sic_dufun',\                ; duplicate function
        sic_exfun, 'sic_exfun',\                ; exchange functions
        sic_aconf, 'sic_aconf',\                ; add|set user defined float constant
        sic_aconi, 'sic_aconi',\                ; add|set user defined integer constant
        sic_acons, 'sic_acons',\                ; add|set user defined string constant
        sic_acono, 'sic_acono',\                ; add|set user defined offset constant
        sic_aconp, 'sic_aconp',\                ; add|set user defined pointer constant
        sic_aconpf, 'sic_aconpf',\              ; add|set user defined float pointer constant
        sic_aconpi, 'sic_aconpi',\              ; add|set user defined integer pointer constant
        sic_aconps, 'sic_aconps',\              ; add|set user defined string pointer constant
        sic_recon, 'sic_recon',\                ; rename constant
        sic_ducon, 'sic_ducon',\                ; duplicate constant
        sic_excon, 'sic_excon',\                ; exchange constants
        sic_avarf, 'sic_avarf',\                ; add|set user defined float variable
        sic_avari, 'sic_avari',\                ; add|set user defined integer variable
        sic_avars, 'sic_avars',\                ; add|set user defined string variable
        sic_avaro, 'sic_avaro',\                ; add|set user defined offset variable
        sic_avarp, 'sic_avarp',\                ; add|set user defined pointer variable
        sic_avarpf, 'sic_avarpf',\              ; add|set user defined float pointer variable
        sic_avarpi, 'sic_avarpi',\              ; add|set user defined integer pointer variable
        sic_avarps, 'sic_avarps',\              ; add|set user defined string pointer variable
        sic_revar, 'sic_revar',\                ; rename variable
        sic_duvar, 'sic_duvar',\                ; duplicate variable
        sic_exvar, 'sic_exvar',\                ; exchange variables
        sic_invaf, 'sic_invaf',\                ; invalidate function
        sic_invac, 'sic_invac',\                ; invalidate constant
        sic_invav, 'sic_invav',\                ; invalidate variable
        sic_patab, 'sic_patab',\                ; pack tables
        sic_pafut, 'sic_pafut',\                ; pack function table
        sic_pacot, 'sic_pacot',\                ; pack constant table
        sic_pavat, 'sic_pavat',\                ; pack variable table
        sic_gefut, 'sic_gefut',\                ; get function table offset
        sic_gefuc, 'sic_gefuc',\                ; get function item count
        sic_gefui, 'sic_gefui',\                ; get function item
        sic_gefun, 'sic_gefun',\                ; get item index in function table
        sic_gecot, 'sic_gecot',\                ; get constant table offset
        sic_gecoc, 'sic_gecoc',\                ; get constant item count
        sic_gecoi, 'sic_gecoi',\                ; get constant item
        sic_gecon, 'sic_gecon',\                ; get item index in constant table
        sic_gevat, 'sic_gevat',\                ; get variable table offset
        sic_gevac, 'sic_gevac',\                ; get variable item count
        sic_gevai, 'sic_gevai',\                ; get variable item
        sic_gevar, 'sic_gevar',\                ; get item index in variable table
        sic_gerut, 'sic_gerut',\                ; get runtime table offset
        sic_geruc, 'sic_geruc',\                ; get runtime item count
        sic_gerui, 'sic_gerui',\                ; get runtime item
        sic_gerun, 'sic_gerun',\                ; get item index in runtime table
        sic_compile, 'sic_compile',\            ; compile string
        sic_build, 'sic_build',\                ; compile complex string
        sic_exec, 'sic_exec',\                  ; execute code
        sic_pcall, 'sic_call',\                 ; execute code
        sic_cexec, 'sic_cexec',\                ; compile & execute string
        sic_bexec, 'sic_bexec',\                ; compile & execute complex string
        sic_scexec, 'sic_scexec',\              ; compile & execute string
        sic_sbexec, 'sic_sbexec',\              ; compile & execute complex string
        sic_va_count, 'sic_va_count',\          ; variable argument count
        sic_inda, 'sic_inda',\                  ; instruction disassembler
        cpuseed32, 'cpuseed',\                  ; cpu random generator
        cpuseed64, 'cpuseed64',\                ; cpu random generator
        cpuseed32, 'cpuseed32',\                ; cpu random generator
        cpuseed16, 'cpuseed16',\                ; cpu random generator
        cpurand32, 'cpurand',\                  ; cpu random generator
        cpurand64, 'cpurand64',\                ; cpu random generator
        cpurand32, 'cpurand32',\                ; cpu random generator
        cpurand16, 'cpurand16',\                ; cpu random generator
        cpurandf, 'cpurandf',\                  ; cpu random generator
        cpurandf2pi, 'cpurandf2pi',\            ; cpu random generator
        mt19937_igen, 'mt19937_igen',\          ; mt19937 random generator
        mt19937_fgen, 'mt19937_fgen',\          ; mt19937 random generator
        mt19937_fgen2pi, 'mt19937_fgen2pi',\    ; mt19937 random generator
        mt19937_seed, 'mt19937_seed',\          ; mt19937 seed by value
        mt19937_seeds, 'mt19937_seeds',\        ; mt19937 seed by array
        sic_erf, 'sic_erf',\                    ; error function
        sic_erfc, 'sic_erfc',\                  ; complementary error function
        sic_cdfnorm, 'sic_cdfnorm',\            ; normal distribution function
        sic_erfinv, 'sic_erfinv',\              ; inverse error function
        sic_erfcinv, 'sic_erfcinv',\            ; inverse complementary error function
        sic_cdfnorminv, 'sic_cdfnorminv',\      ; inverse of normal distribution function
        sic_lgamma, 'sic_lgamma',\              ; natural logarithm of the absolute value of gamma function
        sic_lgammas, 'sic_lgammas',\            ; natural logarithm of the absolute value and the sign of gamma function
        sic_tgamma, 'sic_tgamma',\              ; gamma function
        sic_rgamma, 'sic_rgamma',\              ; reciprocal gamma function
        sic_rtgamma, 'sic_rtgamma',\            ; reciprocal gamma function
        sic_beta, 'sic_beta'                    ; beta function

SIC_EOF_section_edata:

; ------------------------------------------------------------------------------

; macro SKIP_RESOURCE {
section '.rsrc' resource data readable
SIC_BOF_section_rsrc:

directory \
    RT_VERSION, r_version_info,\
    RT_MANIFEST, manifests

resource r_version_info,\
    1, RS_LANG, version_info

versioninfo version_info,\
    VOS__WINDOWS32, VFT_APP, VFT2_UNKNOWN, RS_LANG, 0,\
    'ProductName', RS_Product,\
    'ProductVersion', RS_Version,\
    'FileDescription', RS_Description,\
    'FileVersion', RS_Version,\
    'OriginalFilename', RS_Filename,\
    'ProgramID', RS_ProgramID,\
    'CompanyName', RS_Company,\
    'LegalCopyright', RS_Copyright,\
    'WWW', RS_WWW,\
    'E-mail', RS_Email

resource manifests,\
    1, RS_LANG, manifest
         
resdata manifest
    file 'SICs32.xml'
endres

SIC_EOF_section_rsrc:
; }

; ------------------------------------------------------------------------------

; macro SKIP_RELOC {
section '.reloc' fixups data readable discardable
SIC_BOF_section_reloc:

if $=$$
  dd 0, 8 ; if there are no fixups, generate dummy entry
end if

SIC_EOF_section_reloc:
; }

; ------------------------------------------------------------------------------
