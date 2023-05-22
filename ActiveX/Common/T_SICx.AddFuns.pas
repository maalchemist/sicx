  // STDCALL function flag : $00FF
  // Dynamic function flag : ($20 shl 8)
  // VOID result flag      : ($0F shl 8)
  // Int64 result flag     : ($08 shl 8)
  // Int32 result flag     : ($04 shl 8)
  // Int16 result flag     : ($02 shl 8)

  {$IFDEF CPUX64}

  (*
  [==] ; SIC64.DLL
  cpuseed=cpuseed:::8:D                                   ; dynamic function
  cpuseed64=cpuseed64:::8:D                               ; dynamic function
  cpuseed32=cpuseed32:::4:D                               ; dynamic function
  cpuseed16=cpuseed16:::2:D                               ; dynamic function
  cpurand=cpurand:::8:D                                   ; dynamic function
  cpurand64=cpurand64:::8:D                               ; dynamic function
  cpurand32=cpurand32:::4:D                               ; dynamic function
  cpurand16=cpurand16:::2:D                               ; dynamic function
  cpurandf=cpurandf::::D                                  ; dynamic function
  cpurandf2pi=cpurandf2pi::::D                            ; dynamic function
  mt19937_seed=mt19937_seed:1:0001:-1:D                   ; dynamic function
  mt19937_igen=mt19937_igen:::8:D                         ; dynamic function
  mt19937_fgen=mt19937_fgen::::D                          ; dynamic function
  mt19937_fgen2pi=mt19937_fgen2pi::::D                    ; dynamic function
  sic_erf=sic_erf:1
  sic_erfc=sic_erfc:1
  sic_cdfnorm=sic_cdfnorm:1
  sic_erfinv=sic_erfinv:1
  sic_erfcinv=sic_erfcinv:1
  sic_cdfnorminv=sic_cdfnorminv:1
  sic_lgamma=sic_lgamma:1
  sic_lgammas=sic_lgammas:2:0010
  sic_tgamma=sic_tgamma:1
  sic_rgamma=sic_rgamma:1
  sic_rtgamma=sic_rtgamma:1
  sic_beta=sic_beta:2
  // *)
  sic_afun (ASic, 'cpuseed', @SICxProcs.cpuseed, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed64', @SICxProcs.cpuseed64, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed32', @SICxProcs.cpuseed32, 0, ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed16', @SICxProcs.cpuseed16, 0, ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand', @SICxProcs.cpurand, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand64', @SICxProcs.cpurand64, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand32', @SICxProcs.cpurand32, 0, ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand16', @SICxProcs.cpurand16, 0, ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurandf', @SICxProcs.cpurandf, 0, ($20 shl 8));
  sic_afun (ASic, 'cpurandf2pi', @SICxProcs.cpurandf2pi, 0, ($20 shl 8));
  sic_afun (ASic, 'mt19937_seed', @SICxProcs.mt19937_seed, 1, B_0001 or ($0F shl 8) or ($20 shl 8));
  sic_afun (ASic, 'mt19937_igen', @SICxProcs.mt19937_igen, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen', @SICxProcs.mt19937_fgen, 0, ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen2pi', @SICxProcs.mt19937_fgen2pi, 0, ($20 shl 8));
  sic_afun (ASic, 'sic_erf', @SICxProcs.sic_erf, 1, 0);
  sic_afun (ASic, 'sic_erfc', @SICxProcs.sic_erfc, 1, 0);
  sic_afun (ASic, 'sic_cdfnorm', @SICxProcs.sic_cdfnorm, 1, 0);
  sic_afun (ASic, 'sic_erfinv', @SICxProcs.sic_erfinv, 1, 0);
  sic_afun (ASic, 'sic_erfcinv', @SICxProcs.sic_erfcinv, 1, 0);
  sic_afun (ASic, 'sic_cdfnorminv', @SICxProcs.sic_cdfnorminv, 1, 0);
  sic_afun (ASic, 'sic_lgamma', @SICxProcs.sic_lgamma, 1, 0);
  sic_afun (ASic, 'sic_lgammas', @SICxProcs.sic_lgammas, 2, B_0010);
  sic_afun (ASic, 'sic_tgamma', @SICxProcs.sic_tgamma, 1, 0);
  sic_afun (ASic, 'sic_rgamma', @SICxProcs.sic_rgamma, 1, 0);
  sic_afun (ASic, 'sic_rtgamma', @SICxProcs.sic_rtgamma, 1, 0);
  sic_afun (ASic, 'sic_beta', @SICxProcs.sic_beta, 2, 0);

  {$ELSE}

  (*
  [==] ; SIC32.DLL
  cpuseed=cpuseed::-1:4:D                                 ; dynamic function
  cpuseed64=cpuseed64::-1:8:D                             ; dynamic function
  cpuseed32=cpuseed32::-1:4:D                             ; dynamic function
  cpuseed16=cpuseed16::-1:2:D                             ; dynamic function
  cpurand=cpurand::-1:4:D                                 ; dynamic function
  cpurand64=cpurand64::-1:8:D                             ; dynamic function
  cpurand32=cpurand32::-1:4:D                             ; dynamic function
  cpurand16=cpurand16::-1:2:D                             ; dynamic function
  cpurandf=cpurandf::-1::D                                ; dynamic function
  cpurandf2pi=cpurandf2pi::-1::D                          ; dynamic function
  mt19937_seed=mt19937_seed:1:-1:-1:D                     ; dynamic function
  mt19937_igen=mt19937_igen::-1:4:D                       ; dynamic function
  mt19937_fgen=mt19937_fgen::-1::D                        ; dynamic function
  mt19937_fgen2pi=mt19937_fgen2pi::-1::D                  ; dynamic function
  sic_erf=sic_erf:1:-1
  sic_erfc=sic_erfc:1:-1
  sic_cdfnorm=sic_cdfnorm:1:-1
  sic_erfinv=sic_erfinv:1:-1
  sic_erfcinv=sic_erfcinv:1:-1
  sic_cdfnorminv=sic_cdfnorminv:1:-1
  sic_lgamma=sic_lgamma:1:-1
  sic_lgammas=sic_lgammas:2:-1
  sic_tgamma=sic_tgamma:1:-1
  sic_rgamma=sic_rgamma:1:-1
  sic_rtgamma=sic_rtgamma:1:-1
  sic_beta=sic_beta:2:-1
  // *)
  sic_afun (ASic, 'cpuseed', @SICxProcs.cpuseed, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed64', @SICxProcs.cpuseed64, 0, $00FF or ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed32', @SICxProcs.cpuseed32, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed16', @SICxProcs.cpuseed16, 0, $00FF or ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand', @SICxProcs.cpurand, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand64', @SICxProcs.cpurand64, 0, $00FF or ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand32', @SICxProcs.cpurand32, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand16', @SICxProcs.cpurand16, 0, $00FF or ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurandf', @SICxProcs.cpurandf, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'cpurandf2pi', @SICxProcs.cpurandf2pi, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'mt19937_seed', @SICxProcs.mt19937_seed, 1, $00FF or ($20 shl 8));
  sic_afun (ASic, 'mt19937_igen', @SICxProcs.mt19937_igen, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen', @SICxProcs.mt19937_fgen, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen2pi', @SICxProcs.mt19937_fgen2pi, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'sic_erf', @SICxProcs.sic_erf, 1, $00FF);
  sic_afun (ASic, 'sic_erfc', @SICxProcs.sic_erfc, 1, $00FF);
  sic_afun (ASic, 'sic_cdfnorm', @SICxProcs.sic_cdfnorm, 1, $00FF);
  sic_afun (ASic, 'sic_erfinv', @SICxProcs.sic_erfinv, 1, $00FF);
  sic_afun (ASic, 'sic_erfcinv', @SICxProcs.sic_erfcinv, 1, $00FF);
  sic_afun (ASic, 'sic_cdfnorminv', @SICxProcs.sic_cdfnorminv, 1, $00FF);
  sic_afun (ASic, 'sic_lgamma', @SICxProcs.sic_lgamma, 1, $00FF);
  sic_afun (ASic, 'sic_lgammas', @SICxProcs.sic_lgammas, 2, $00FF);
  sic_afun (ASic, 'sic_tgamma', @SICxProcs.sic_tgamma, 1, $00FF);
  sic_afun (ASic, 'sic_rgamma', @SICxProcs.sic_rgamma, 1, $00FF);
  sic_afun (ASic, 'sic_rtgamma', @SICxProcs.sic_rtgamma, 1, $00FF);
  sic_afun (ASic, 'sic_beta', @SICxProcs.sic_beta, 2, $00FF);

  {$ENDIF}
