
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler simple test

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

macro $ifdef sym
{
  macro system.end \{ end if \}

  local @sym
  @sym = 0
  if defined sym
    @sym = sym
  end if
  if @sym <> 0
}

macro $else { else }

macro $end
{
  system.end
  purge system.end
}

; ------------------------------------------------------------------------------

include '%INCLUDE%\WIN32A.INC'
include '..\..\..\xCommon\SIC.ASH'
include '..\..\..\xCommon\SICIDA.ASH'
siccall FIX invoke

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

section '.data' data readable writeable

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
        msvcrt, 'MSVCRT.DLL',\
        sic, 'SICx32.DLL'

import  kernel32,\
        FormatMessage, 'FormatMessageA',\
        ExitProcess, 'ExitProcess'

import  user32,\
        MessageBox, 'MessageBoxA'

import  msvcrt,\
        vsprintf, 'vsprintf'

import  sic,\
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

; ------------------------------------------------------------------------------
