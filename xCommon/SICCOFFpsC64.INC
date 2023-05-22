
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; public symbols (x64)
; name mangling

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

publics sic_version, '?sic_version@@YAKXZ',\            ; compiler version
        sic_cpu_support, '?sic_cpu_support@@YAHXZ',\    ; compiler support for the CPU
        sic_setup, '?sic_setup@@YAXPEAX@Z',\            ; setup compiler
        sic_cretab, '?sic_cretab@@YAXXZ',\              ; create global tables
        sic_fretab, '?sic_fretab@@YAXXZ',\              ; destroy global tables
        sic_funtac, '?sic_funtac@@YAKXZ',\              ; create global function table
        sic_funtaf, '?sic_funtaf@@YAXXZ',\              ; destroy global function table
        sic_funloa, '?sic_funloa@@YAKXZ',\              ; load external user defined functions
        sic_funulo, '?sic_funulo@@YAXXZ',\              ; unload external user defined functions
        sic_contac, '?sic_contac@@YAKXZ',\              ; create global constant table
        sic_contaf, '?sic_contaf@@YAXXZ',\              ; destroy global constant table
        sic_conloa, '?sic_conloa@@YAKXZ',\              ; load external user defined constants
        sic_conulo, '?sic_conulo@@YAXXZ',\              ; unload external user defined constants
        sic_vartac, '?sic_vartac@@YAKXZ',\              ; create global variable table
        sic_vartaf, '?sic_vartaf@@YAXXZ',\              ; destroy global variable table
        sic_varloa, '?sic_varloa@@YAKXZ',\              ; load external user defined variables
        sic_varulo, '?sic_varulo@@YAXXZ',\              ; unload external user defined variables
        sic_runtac, '?sic_runtac@@YAKXZ',\              ; create global runtime table
        sic_runtaf, '?sic_runtaf@@YAXXZ',\              ; destroy global runtime table
        sic_init, '?sic_init@@YAXPEAX@Z',\              ; allocate memory for sic constant & variable data segments
        sic_done, '?sic_done@@YAXPEAX@Z',\              ; free memory previously allocated for sic segments
        sic_afun, '?sic_afun@@YAHPEAXPEBD0FG@Z',\       ; add|set user defined function
        sic_refun, '?sic_refun@@YAHPEAXPEBD1H@Z',\      ; rename function
        sic_dufun, '?sic_dufun@@YAHPEAXPEBD1@Z',\       ; duplicate function
        sic_exfun, '?sic_exfun@@YAHPEAXPEBD1@Z',\       ; exchange functions
        sic_aconf, '?sic_aconf@@YAHPEAXPEBDN@Z',\       ; add|set user defined float constant
        sic_aconi, '?sic_aconi@@YAHPEAXPEBD_J@Z',\      ; add|set user defined integer constant
        sic_acons, '?sic_acons@@YAHPEAXPEBD1@Z',\       ; add|set user defined string constant
        sic_acono, '?sic_acono@@YAHPEAXPEBD0@Z',\       ; add|set user defined offset constant
        sic_aconp, '?sic_aconp@@YAHPEAXPEBD0@Z',\       ; add|set user defined pointer constant
        sic_aconpf, '?sic_aconpf@@YAHPEAXPEBD0@Z',\     ; add|set user defined float pointer constant
        sic_aconpi, '?sic_aconpi@@YAHPEAXPEBD0@Z',\     ; add|set user defined integer pointer constant
        sic_aconps, '?sic_aconps@@YAHPEAXPEBD0@Z',\     ; add|set user defined string pointer constant
        sic_recon, '?sic_recon@@YAHPEAXPEBD1H@Z',\      ; rename constant
        sic_ducon, '?sic_ducon@@YAHPEAXPEBD1@Z',\       ; duplicate constant
        sic_excon, '?sic_excon@@YAHPEAXPEBD1@Z',\       ; exchange constants
        sic_avarf, '?sic_avarf@@YAHPEAXPEBD0@Z',\       ; add|set user defined float variable
        sic_avari, '?sic_avari@@YAHPEAXPEBD0@Z',\       ; add|set user defined integer variable
        sic_avars, '?sic_avars@@YAHPEAXPEBD0@Z',\       ; add|set user defined string variable
        sic_avaro, '?sic_avaro@@YAHPEAXPEBD0@Z',\       ; add|set user defined offset variable
        sic_avarp, '?sic_avarp@@YAHPEAXPEBD0@Z',\       ; add|set user defined pointer variable
        sic_avarpf, '?sic_avarpf@@YAHPEAXPEBD0@Z',\     ; add|set user defined float pointer variable
        sic_avarpi, '?sic_avarpi@@YAHPEAXPEBD0@Z',\     ; add|set user defined integer pointer variable
        sic_avarps, '?sic_avarps@@YAHPEAXPEBD0@Z',\     ; add|set user defined string pointer variable
        sic_revar, '?sic_revar@@YAHPEAXPEBD1H@Z',\      ; rename variable
        sic_duvar, '?sic_duvar@@YAHPEAXPEBD1@Z',\       ; duplicate variable
        sic_exvar, '?sic_exvar@@YAHPEAXPEBD1@Z',\       ; exchange variables
        sic_invaf, '?sic_invaf@@YAHPEAXPEBD@Z',\        ; invalidate function
        sic_invac, '?sic_invac@@YAHPEAXPEBD@Z',\        ; invalidate constant
        sic_invav, '?sic_invav@@YAHPEAXPEBD@Z',\        ; invalidate variable
        sic_patab, '?sic_patab@@YAXPEAX@Z',\            ; pack tables
        sic_pafut, '?sic_pafut@@YAKPEAX@Z',\            ; pack function table
        sic_pacot, '?sic_pacot@@YAKPEAX@Z',\            ; pack constant table
        sic_pavat, '?sic_pavat@@YAKPEAX@Z',\            ; pack variable table
        sic_gefut, '?sic_gefut@@YAPEAXPEAX@Z',\         ; get function table offset
        sic_gefuc, '?sic_gefuc@@YAKPEAX@Z',\            ; get function item count
        sic_gefui, '?sic_gefui@@YAHPEAXH0@Z',\          ; get function item
        sic_gefun, '?sic_gefun@@YAHPEAXPEBD@Z',\        ; get item index in function table
        sic_gecot, '?sic_gecot@@YAPEAXPEAX@Z',\         ; get constant table offset
        sic_gecoc, '?sic_gecoc@@YAKPEAX@Z',\            ; get constant item count
        sic_gecoi, '?sic_gecoi@@YAHPEAXH0@Z',\          ; get constant item
        sic_gecon, '?sic_gecon@@YAHPEAXPEBD@Z',\        ; get item index in constant table
        sic_gevat, '?sic_gevat@@YAPEAXPEAX@Z',\         ; get variable table offset
        sic_gevac, '?sic_gevac@@YAKPEAX@Z',\            ; get variable item count
        sic_gevai, '?sic_gevai@@YAHPEAXH0@Z',\          ; get variable item
        sic_gevar, '?sic_gevar@@YAHPEAXPEBD@Z',\        ; get item index in variable table
        sic_gerut, '?sic_gerut@@YAPEAXPEAX@Z',\         ; get runtime table offset
        sic_geruc, '?sic_geruc@@YAKPEAX@Z',\            ; get runtime item count
        sic_gerui, '?sic_gerui@@YAHPEAXH0@Z',\          ; get runtime item
        sic_gerun, '?sic_gerun@@YAHPEAXPEBD@Z',\        ; get item index in runtime table
        sic_compile, '?sic_compile@@YAKPEAXPEBDK@Z',\   ; compile string
        sic_build, '?sic_build@@YAKPEAXPEBDK@Z',\       ; compile complex string
        sic_exec, '?sic_exec@@YANPEAXPEAK@Z',\          ; execute code
        sic_pcall, '?sic_call@@YAXPEAX@Z',\             ; execute code
        sic_cexec, '?sic_cexec@@YANPEAXPEBDPEAK2@Z',\   ; compile & execute string
        sic_bexec, '?sic_bexec@@YANPEAXPEBDPEAK2@Z',\   ; compile & execute complex string
        sic_scexec, '?sic_scexec@@YANPEBDPEAK1@Z',\     ; compile & execute string
        sic_sbexec, '?sic_sbexec@@YANPEBDPEAK1@Z',\     ; compile & execute complex string
        sic_va_count, '?sic_va_count@@YAHXZ',\          ; variable argument count
        sic_inda, '?sic_inda@@YAHPEAX0E@Z',\            ; instruction disassembler
        cpuseed64, '?cpuseed@@YA_KXZ',\                 ; cpu random generator
        cpuseed64, '?cpuseed64@@YA_KXZ',\               ; cpu random generator
        cpuseed32, '?cpuseed32@@YAIXZ',\                ; cpu random generator
        cpuseed16, '?cpuseed16@@YAGXZ',\                ; cpu random generator
        cpurand64, '?cpurand@@YA_KXZ',\                 ; cpu random generator
        cpurand64, '?cpurand64@@YA_KXZ',\               ; cpu random generator
        cpurand32, '?cpurand32@@YAIXZ',\                ; cpu random generator
        cpurand16, '?cpurand16@@YAGXZ',\                ; cpu random generator
        cpurandf, '?cpurandf@@YANXZ',\                  ; cpu random generator
        cpurandf2pi, '?cpurandf2pi@@YANXZ',\            ; cpu random generator
        mt19937_igen, '?mt19937_igen@@YA_KXZ',\         ; mt19937 random generator
        mt19937_fgen, '?mt19937_fgen@@YANXZ',\          ; mt19937 random generator
        mt19937_fgen2pi, '?mt19937_fgen2pi@@YANXZ',\    ; mt19937 random generator
        mt19937_seed, '?mt19937_seed@@YAX_K@Z',\        ; mt19937 seed by value
        mt19937_seeds, '?mt19937_seeds@@YAXPEA_K_K@Z',\ ; mt19937 seed by array
        sic_erf, '?sic_erf@@YANN@Z',\                   ; error function
        sic_erfc, '?sic_erfc@@YANN@Z',\                 ; complementary error function
        sic_cdfnorm, '?sic_cdfnorm@@YANN@Z',\           ; normal distribution function
        sic_erfinv, '?sic_erfinv@@YANN@Z',\             ; inverse error function
        sic_erfcinv, '?sic_erfcinv@@YANN@Z',\           ; inverse complementary error function
        sic_cdfnorminv, '?sic_cdfnorminv@@YANN@Z',\     ; inverse of normal distribution function
        sic_lgamma, '?sic_lgamma@@YANN@Z',\             ; natural logarithm of the absolute value of gamma function
        sic_lgammas, '?sic_lgammas@@YANNPEAK@Z',\       ; natural logarithm of the absolute value and the sign of gamma function
        sic_tgamma, '?sic_tgamma@@YANN@Z',\             ; gamma function
        sic_rgamma, '?sic_rgamma@@YANN@Z',\             ; reciprocal gamma function
        sic_rtgamma, '?sic_rtgamma@@YANN@Z',\           ; reciprocal gamma function
        sic_beta, '?sic_beta@@YANNN@Z'                  ; beta function

; ------------------------------------------------------------------------------
