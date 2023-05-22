
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler simple test (no SICx.DLL)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

format PE   GUI 4.0
entry zentry

DEFINE  _COFF   FALSE
DEFINE   _X64   FALSE
DEFINE   _X32    TRUE
DEFINE   _VEX   FALSE
DEFINE  _EVEX   FALSE
DEFINE  _SSEX   FALSE
DEFINE  _SSE4.1 FALSE
DEFINE  _SSE3   FALSE
DEFINE  _SSE2   FALSE
DEFINE   _UDF    TRUE                           ; user-defined files

; ------------------------------------------------------------------------------

include 'SIC32I.INC'
siccall FIX  stdcall

; ------------------------------------------------------------------------------

; be sure value is floating point
macro virtual.float value
{
  virtual at 0
    dt value
  end virtual
}

; ------------------------------------------------------------------------------

; named 64-bit float
struc dqn name, value
{
  ; be sure value is floating point
  virtual.float value

  dq value
  .name db name,0
}

; ------------------------------------------------------------------------------

section '.code' code readable executable

zentry:

;       and     rsp, 0xFFFFFFFFFFFFFFF0         ; 16-byte stack align
; ----------------------------------------------

        ; setup compiler
        mov     [@@cfg + T_sic32_config.cflags], 0
        mov     [@@cfg + T_sic32_config.memory], 0
        siccall sic_setup, @@cfg

        ; create global tables
        siccall sic_cretab

        ; add user defined functions
        siccall sic_afun, NULL, X2x32.name, X2x32, 1, 0

        ; rename functions
        siccall sic_refun, NULL, spower, spow, FALSE
        siccall sic_refun, NULL, sarcsin, sasin, FALSE
        siccall sic_refun, NULL, sarccos, sacos, FALSE

        ; invalidate "meander" function
        siccall sic_invaf, NULL, smeand

        ; add user defined global constants
        siccall sic_aconf, NULL, @C.name, @C

; ----------------------------------------------

        ; initialize T_sic_data structures
        siccall sic_init, @@sic

        ; add user defined local variables
        siccall sic_avarf, @@sic, @@b.name, @@b
        siccall sic_avarf, @@sic, @@x.name, @@x
        siccall sic_avarf, @@sic, @@a.name, @@a
        siccall sic_avarf, @@sic, @@z.name, @@z
        siccall sic_avarf, @@sic, @@c.name, @@c
        siccall sic_avarf, @@sic, @@y.name, @@y

; ----------------------------------------------

        ; pack global tables
        siccall sic_patab, NULL

        ; pack local tables
        siccall sic_patab, @@sic

; ----------------------------------------------

        ; compile and execute expressions
        stdcall coexec, @@sic, saa
        stdcall coexec, @@sic, sab
        stdcall coexec, @@sic, s_jn
        stdcall coexec, @@sic, s_yn
        stdcall coexec, @@sic, sad
        stdcall coexec, @@sic, sae

; ----------------------------------------------

        ; free T_sic_data structures
        siccall sic_done, @@sic

        ; free global tables
        siccall sic_fretab

; ----------------------------------------------

        invoke  ExitProcess, 0

; ------------------------------------------------------------------------------

; compile & execute
proc coexec, sic, s

    locals
       .buffer  rb 1024
       .args    rb 16
       .error   dd ?
       .result  dq ?
    endl

;       mov     [sic], rcx
;       mov     [s], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
;       test    rsp, 0x0F                       ; 16-byte stack align job
;       jz      @F
;       push    rax
;     @@:
        push    esi edi

        lea     esi, [.buffer]

;       siccall sic_build, [sic], [s], SIC_OPT_DEFAULT_X32
        siccall sic_compile, [sic], [s], SIC_OPT_DEFAULT_X32
        cmp     eax, 1
        jl     .error.compile

        lea     eax, [.error]
        siccall sic_exec, [sic], eax
;       movsd   qword [.result], xmm0
        fstp    qword [.result]

        mov     eax, [s]
        mov     dword [.args], eax
        mov     eax, dword [.result + 0]
        mov     dword [.args + 04], eax
        mov     eax, dword [.result + 4]
        mov     dword [.args + 08], eax

        lea     eax, [.args]
        cinvoke vsprintf, esi, .sfmt, eax

        cmp     [.error], 0
        jne    .error.exec

   .success:
        invoke  MessageBox, 0, esi, .sres, MB_ICONINFORMATION
        jmp    .return
   .error.compile:
        invoke  MessageBox, 0, .scerr, .serr, MB_ICONERROR
        jmp    .return
   .error.exec:
        invoke  MessageBox, 0, esi, .serr, MB_ICONERROR

   .return:
        pop     edi esi
        ret

       .sres    db 'Result',0
       .serr    db 'Error',0
       .scerr   db 'Invalid expression',0
       .sfmt    db '%s',13,10,13,10,'= %0.10g',0
endp

; ------------------------------------------------------------------------------

; user defined function
proc X2x32 c, p, p.HI

        jmp     @F
       .2.0     dq 2.0
    @@:
        fld     qword [p]
        fmul    qword [.2.0]
        ret
endp
X2x32.name db 'X2',0

proc X2x64, p

        jmp     @F
       .2.0     dq 2.0
    @@:
        mulsd   xmm0, qword [.2.0]
        ret
endp
X2x64.name db 'X2',0

; ------------------------------------------------------------------------------

include 'SIC32IC.INC'

; ------------------------------------------------------------------------------

section '.data' data readable writeable

include 'SIC32ID.INC'

; ------------------------------------------------------------------------------

@@sic   T_sic32_data
@@cfg   T_sic32_config

@@a     dqn 'a', 2.0
@@b     dqn 'b', 8.0
@@c     dqn 'c', 16.0
@@x     dqn 'x', 1.1
@@y     dqn 'y', 2.2
@@z     dqn 'z', 3.3

@C      dqn '@C', 1.23456789

spow    db 'pow',0
spower  db 'power',0
sasin   db 'asin',0
sarcsin db 'arcsin',0
sacos   db 'acos',0
sarccos db 'arccos',0
smeand  db 'meander',0

; ------------------------------------------------------------------------------

; expressions to evaluate
saa     db 'sin(logn(10,ln(33.33)*sqrt(abs(',13,10,\
           'sin(a)*tan(11.11)+',13,10,\
           'cos(b)*cotan(22.22)))+',13,10,\
           'exp(c)+power(x,y))-',13,10,\
           'a/b+x*y+z**10)-log10(100*a)+logn(x,y)*z-',13,10,\
           'sqr(a*b)+sqrt(abs(atan2(a,x)))+',13,10,\
           'cos(a*b/c-x*y/z)+hypot(x,y)+',13,10,\
           'arcsin(cos(a*b*c))+arccos(sin(x*y*z))+',13,10,\
           'sh(x)+ch(y)+th(z)+cth(a)+sch(b)+csh(c)',0

sab     db '5 + X2(11)',0

s_jn    db 'crt_jn (2:int, 2.387000)',0
s_yn    db 'crt_yn (2:int, 2.387000)',0

sad     db '@_izoom2x (2:int, 3:int, 10.0)',0
sae     db '@_izoom2x2x (2:int, 20.0, 3:int, 30.0)',0

; ------------------------------------------------------------------------------

section '.idata' import data readable writeable

library kernel32, 'KERNEL32.DLL',\
        user32, 'USER32.DLL',\
        msvcrt, 'MSVCRT.DLL'

import  kernel32,\
        FormatMessage, 'FormatMessageA',\
        ExitProcess, 'ExitProcess',\
        GetCurrentDirectory, 'GetCurrentDirectoryA',\
        SetCurrentDirectory, 'SetCurrentDirectoryA',\
        GetModuleFileName, 'GetModuleFileNameA',\
        GetFullPathName, 'GetFullPathNameA',\
        GetPrivateProfileSectionNames, 'GetPrivateProfileSectionNamesA',\
        GetPrivateProfileSection, 'GetPrivateProfileSectionA',\
        SetDllDirectory, 'SetDllDirectoryA',\
        LoadLibrary, 'LoadLibraryA',\
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

import  user32,\
        MessageBox, 'MessageBoxA'

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

; ------------------------------------------------------------------------------
