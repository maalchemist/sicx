
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; public symbols (x32)
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

publics sic_version, '?sic_version@@YGKXZ',\            ; compiler version
        sic_cpu_support, '?sic_cpu_support@@YGHXZ',\    ; compiler support for the CPU
        sic_setup, '?sic_setup@@YGXPAX@Z',\             ; setup compiler
        sic_cretab, '?sic_cretab@@YGXXZ',\              ; create global tables
        sic_fretab, '?sic_fretab@@YGXXZ',\              ; destroy global tables
        sic_funtac, '?sic_funtac@@YGKXZ',\              ; create global function table
        sic_funtaf, '?sic_funtaf@@YGXXZ',\              ; destroy global function table
        sic_funloa, '?sic_funloa@@YGKXZ',\              ; load external user defined functions
        sic_funulo, '?sic_funulo@@YGXXZ',\              ; unload external user defined functions
        sic_contac, '?sic_contac@@YGKXZ',\              ; create global constant table
        sic_contaf, '?sic_contaf@@YGXXZ',\              ; destroy global constant table
        sic_conloa, '?sic_conloa@@YGKXZ',\              ; load external user defined constants
        sic_conulo, '?sic_conulo@@YGXXZ',\              ; unload external user defined constants
        sic_vartac, '?sic_vartac@@YGKXZ',\              ; create global variable table
        sic_vartaf, '?sic_vartaf@@YGXXZ',\              ; destroy global variable table
        sic_varloa, '?sic_varloa@@YGKXZ',\              ; load external user defined variables
        sic_varulo, '?sic_varulo@@YGXXZ',\              ; unload external user defined variables
        sic_runtac, '?sic_runtac@@YGKXZ',\              ; create global runtime table
        sic_runtaf, '?sic_runtaf@@YGXXZ',\              ; destroy global runtime table
        sic_init, '?sic_init@@YGXPAX@Z',\               ; allocate memory for sic constant & variable data segments
        sic_done, '?sic_done@@YGXPAX@Z',\               ; free memory previously allocated for sic segments
        sic_afun, '?sic_afun@@YGHPAXPBD0FG@Z',\         ; add|set user defined function
        sic_refun, '?sic_refun@@YGHPAXPBD1H@Z',\        ; rename function
        sic_dufun, '?sic_dufun@@YGHPAXPBD1@Z',\         ; duplicate function
        sic_exfun, '?sic_exfun@@YGHPAXPBD1@Z',\         ; exchange functions
        sic_aconf, '?sic_aconf@@YGHPAXPBDN@Z',\         ; add|set user defined float constant
        sic_aconi, '?sic_aconi@@YGHPAXPBDH@Z',\         ; add|set user defined integer constant
        sic_acons, '?sic_acons@@YGHPAXPBD1@Z',\         ; add|set user defined string constant
        sic_acono, '?sic_acono@@YGHPAXPBD0@Z',\         ; add|set user defined offset constant
        sic_aconp, '?sic_aconp@@YGHPAXPBD0@Z',\         ; add|set user defined pointer constant
        sic_aconpf, '?sic_aconpf@@YGHPAXPBD0@Z',\       ; add|set user defined float pointer constant
        sic_aconpi, '?sic_aconpi@@YGHPAXPBD0@Z',\       ; add|set user defined integer pointer constant
        sic_aconps, '?sic_aconps@@YGHPAXPBD0@Z',\       ; add|set user defined string pointer constant
        sic_recon, '?sic_recon@@YGHPAXPBD1H@Z',\        ; rename constant
        sic_ducon, '?sic_ducon@@YGHPAXPBD1@Z',\         ; duplicate constant
        sic_excon, '?sic_excon@@YGHPAXPBD1@Z',\         ; exchange constants
        sic_avarf, '?sic_avarf@@YGHPAXPBD0@Z',\         ; add|set user defined float variable
        sic_avari, '?sic_avari@@YGHPAXPBD0@Z',\         ; add|set user defined integer variable
        sic_avars, '?sic_avars@@YGHPAXPBD0@Z',\         ; add|set user defined string variable
        sic_avaro, '?sic_avaro@@YGHPAXPBD0@Z',\         ; add|set user defined offset variable
        sic_avarp, '?sic_avarp@@YGHPAXPBD0@Z',\         ; add|set user defined pointer variable
        sic_avarpf, '?sic_avarpf@@YGHPAXPBD0@Z',\       ; add|set user defined float pointer variable
        sic_avarpi, '?sic_avarpi@@YGHPAXPBD0@Z',\       ; add|set user defined integer pointer variable
        sic_avarps, '?sic_avarps@@YGHPAXPBD0@Z',\       ; add|set user defined string pointer variable
        sic_revar, '?sic_revar@@YGHPAXPBD1H@Z',\        ; rename variable
        sic_duvar, '?sic_duvar@@YGHPAXPBD1@Z',\         ; duplicate variable
        sic_exvar, '?sic_exvar@@YGHPAXPBD1@Z',\         ; exchange variables
        sic_invaf, '?sic_invaf@@YGHPAXPBD@Z',\          ; invalidate function
        sic_invac, '?sic_invac@@YGHPAXPBD@Z',\          ; invalidate constant
        sic_invav, '?sic_invav@@YGHPAXPBD@Z',\          ; invalidate variable
        sic_patab, '?sic_patab@@YGXPAX@Z',\             ; pack tables
        sic_pafut, '?sic_pafut@@YGKPAX@Z',\             ; pack function table
        sic_pacot, '?sic_pacot@@YGKPAX@Z',\             ; pack constant table
        sic_pavat, '?sic_pavat@@YGKPAX@Z',\             ; pack variable table
        sic_gefut, '?sic_gefut@@YGPAXPAX@Z',\           ; get function table offset
        sic_gefuc, '?sic_gefuc@@YGKPAX@Z',\             ; get function item count
        sic_gefui, '?sic_gefui@@YGHPAXH0@Z',\           ; get function item
        sic_gefun, '?sic_gefun@@YGHPAXPBD@Z',\          ; get item index in function table
        sic_gecot, '?sic_gecot@@YGPAXPAX@Z',\           ; get constant table offset
        sic_gecoc, '?sic_gecoc@@YGKPAX@Z',\             ; get constant item count
        sic_gecoi, '?sic_gecoi@@YGHPAXH0@Z',\           ; get constant item
        sic_gecon, '?sic_gecon@@YGHPAXPBD@Z',\          ; get item index in constant table
        sic_gevat, '?sic_gevat@@YGPAXPAX@Z',\           ; get variable table offset
        sic_gevac, '?sic_gevac@@YGKPAX@Z',\             ; get variable item count
        sic_gevai, '?sic_gevai@@YGHPAXH0@Z',\           ; get variable item
        sic_gevar, '?sic_gevar@@YGHPAXPBD@Z',\          ; get item index in variable table
        sic_gerut, '?sic_gerut@@YGPAXPAX@Z',\           ; get runtime table offset
        sic_geruc, '?sic_geruc@@YGKPAX@Z',\             ; get runtime item count
        sic_gerui, '?sic_gerui@@YGHPAXH0@Z',\           ; get runtime item
        sic_gerun, '?sic_gerun@@YGHPAXPBD@Z',\          ; get item index in runtime table
        sic_compile, '?sic_compile@@YGKPAXPBDK@Z',\     ; compile string
        sic_build, '?sic_build@@YGKPAXPBDK@Z',\         ; compile complex string
        sic_exec, '?sic_exec@@YGNPAXPAK@Z',\            ; execute code
        sic_pcall, '?sic_call@@YGXPAX@Z',\              ; execute code
        sic_cexec, '?sic_cexec@@YGNPAXPBDPAK2@Z',\      ; compile & execute string
        sic_bexec, '?sic_bexec@@YGNPAXPBDPAK2@Z',\      ; compile & execute complex string
        sic_scexec, '?sic_scexec@@YGNPBDPAK1@Z',\       ; compile & execute string
        sic_sbexec, '?sic_sbexec@@YGNPBDPAK1@Z',\       ; compile & execute complex string
        sic_va_count, '?sic_va_count@@YGHXZ',\          ; variable argument count
        sic_inda, '?sic_inda@@YAHPEAX0E@Z',\            ; instruction disassembler
        cpuseed32, '?cpuseed@@YGIXZ',\                  ; cpu random generator
        cpuseed64, '?cpuseed64@@YG_KXZ',\               ; cpu random generator
        cpuseed32, '?cpuseed32@@YGIXZ',\                ; cpu random generator
        cpuseed16, '?cpuseed16@@YGGXZ',\                ; cpu random generator
        cpurand32, '?cpurand@@YGIXZ',\                  ; cpu random generator
        cpurand64, '?cpurand64@@YG_KXZ',\               ; cpu random generator
        cpurand32, '?cpurand32@@YGIXZ',\                ; cpu random generator
        cpurand16, '?cpurand16@@YGGXZ',\                ; cpu random generator
        cpurandf, '?cpurandf@@YGNXZ',\                  ; cpu random generator
        cpurandf2pi, '?cpurandf2pi@@YGNXZ',\            ; cpu random generator
        mt19937_igen, '?mt19937_igen@@YGIXZ',\          ; mt19937 random generator
        mt19937_fgen, '?mt19937_fgen@@YGNXZ',\          ; mt19937 random generator
        mt19937_fgen2pi, '?mt19937_fgen2pi@@YGNXZ',\    ; mt19937 random generator
        mt19937_seed, '?mt19937_seed@@YGXI@Z',\         ; mt19937 seed by value
        mt19937_seeds, '?mt19937_seeds@@YGXPAII@Z',\    ; mt19937 seed by array
        sic_erf, '?sic_erf@@YGNN@Z',\                   ; error function
        sic_erfc, '?sic_erfc@@YGNN@Z',\                 ; complementary error function
        sic_cdfnorm, '?sic_cdfnorm@@YGNN@Z',\           ; normal distribution function
        sic_erfinv, '?sic_erfinv@@YGNN@Z',\             ; inverse error function
        sic_erfcinv, '?sic_erfcinv@@YGNN@Z',\           ; inverse complementary error function
        sic_cdfnorminv, '?sic_cdfnorminv@@YGNN@Z',\     ; inverse of normal distribution function
        sic_lgamma, '?sic_lgamma@@YGNN@Z',\             ; natural logarithm of the absolute value of gamma function
        sic_lgammas, '?sic_lgammas@@YGNNPAK@Z',\        ; natural logarithm of the absolute value and the sign of gamma function
        sic_tgamma, '?sic_tgamma@@YGNN@Z',\             ; gamma function
        sic_rgamma, '?sic_rgamma@@YGNN@Z',\             ; reciprocal gamma function
        sic_rtgamma, '?sic_rtgamma@@YGNN@Z',\           ; reciprocal gamma function
        sic_beta, '?sic_beta@@YGNNN@Z'                  ; beta function

; ------------------------------------------------------------------------------
