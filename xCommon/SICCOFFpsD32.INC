
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; public symbols (x32)
; no name mangling

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

publics sic_version, 'sic_version',\            ; compiler version
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
