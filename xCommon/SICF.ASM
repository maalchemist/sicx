
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; global function table

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; IMPORTANT for native functions

; functions can`t contain more than 1 RETN instruction.
; RETN instrunction must be the last instruction.

; RBX(EBX), RDI(EDI), R13 registers are free to change

; functions with a variable number of arguments:
; | argument count < 0
; | ABS(argument count) = minimum argument count
; | 0x80 or 'any' -> any variable number of arguments

; the size of the built-in function is limited to 255 bytes

; ------------------------------------------------------------------------------

$align 16

; set fifth argument to 's' for nonupdatable system functions
; set fifth argument to 's-' or '-' to bypass function
GFT @_GFT,\
    int3, @@int3, 0, 0, 's',\                           ;  int3             ;               ;  int3
    int.3, @@int.3, 0, 0, 's',\                         ;  int.3            ;               ;  int 3
    finit, @@finit, 0, 0, 's',\                         ;  finit            ;               ;  finit
    fninit, @@fninit, 0, 0, 's',\                       ;  fninit           ;               ;  fninit
    fclex, @@fclex, 0, 0, 's',\                         ;  fclex            ;               ;  fclex
    fnclex, @@fnclex, 0, 0, 's',\                       ;  fnclex           ;               ;  fnclex
    fstp, @@fstp, 0, 0, 's-',\                          ;  fstp             ;               ;  fstp st0
    fstsw, @@fstsw, 1, 0, 's',\                         ;  fstsw            ;               ;  store FPU status word
    fnstsw, @@fnstsw, 1, 0, 's',\                       ;  fnstsw           ;               ;  store FPU status word
    fstef, @@fstef, 1, 0, 's',\                         ;  fstef            ;               ;  store FPU exception flags
    fnstef, @@fnstef, 1, 0, 's',\                       ;  fnstef           ;               ;  store FPU exception flags
    fstcw, @@fstcw, 1, 0, 's',\                         ;  fstcw            ;               ;  store FPU control word
    fnstcw, @@fnstcw, 1, 0, 's',\                       ;  fnstcw           ;               ;  store FPU control word
    fldcw, @@fldcw, 1, 0, 's',\                         ;  fldcw            ;               ;  load FPU control word
    fmaske, @@fmaske, 1, 0, 's',\                       ;  fmaske           ;               ;  mask FPU exceptions
    fnmaske, @@fnmaske, 1, 0, 's',\                     ;  fnmaske          ;               ;  mask FPU exceptions
    var, @@var, 1, 0, 's',\                             ;  var              ;               ;  "var" keyword
    float, @@float, 1, 0, 's',\                         ;  float            ;               ;  "float" keyword
    double, @@double, 1, 0, 's',\                       ;  double           ;               ;  "double" keyword
    cvar, @@cvar, 1, 0, 's',\                           ;  cvar             ;               ;  "cvar" keyword
    complex, @@complex, 1, 0, 's',\                     ;  complex          ;               ;  "complex" keyword
    integer, @@integer, 1, 0, 's',\                     ;  integer          ;               ;  "integer" keyword
    str, @@str, 1, 0, 's',\                             ;  str              ;               ;  "str" keyword
    string, @@string, 1, 0, 's',\                       ;  string           ;               ;  "string" keyword
    ptr, @@ptr, 1, 0, 's',\                             ;  ptr              ;               ;  "ptr" keyword
    pointer, @@pointer, 1, 0, 's',\                     ;  pointer          ;               ;  "pointer" keyword
    absolute, @@absolute, 2, 0, 's',\                   ;  absolute         ;    x :: y     ;  absolute
    assign, @@assign, -2, 0, 's',\                      ;  assign           ;               ;  assign
    reassign, @@reassign, -1, 0, 's',\                  ;  reassign         ;               ;  reassign
    addr, @@addr, -1, 1, 's',\                          ;  addr             ;   &x          ;  address of variable
    saddr, @@saddr, 1, 1, 's',\                         ;  saddr            ;  &&x          ;  address of string array
    tcarg, @@tcarg, 1, 1, 's',\                         ;  tcarg            ;               ;  complex argument typecast for external procedure
    vfloat, @@vfloat, 1, 1, 's',\                       ;  vfloat           ;               ;  address as double variable
    vdouble, @@vdouble, 1, 1, 's',\                     ;  vdouble          ;               ;  address as double variable
    vcomplex, @@vcomplex, 1, 2, 's',\                   ;  vcomplex         ;               ;  address as complex variable
    vint, @@vint, 1, 1, 's',\                           ;  vint             ;               ;  address as integer variable
    vinteger, @@vinteger, 1, 1, 's',\                   ;  vinteger         ;               ;  address as integer variable
    vstr, @@vstr, 1, 1, 's',\                           ;  vstr             ;               ;  address as string variable
    vstring, @@vstring, 1, 1, 's',\                     ;  vstring          ;               ;  address as string variable
    pfloat, @@pdouble, 1, 1, 's',\                      ;  pfloat           ;   *x x^       ;  double indirection operator
    pdouble, @@pdouble, 1, 1, 's',\                     ;  pdouble          ;   *x x^       ;  double indirection operator
    pcomplex, @@pcomplex, 1, 2, 's',\                   ;  pcomplex         ;  **x x^^      ;  complex indirection operator
    pint, @@pint, 1, 'i', 's',\                         ;  pint             ;               ;  integer indirection operator
    pinteger, @@pint, 1, 'i', 's',\                     ;  pinteger         ;               ;  integer indirection operator
    pstr, @@pstr, 1, 'i', 's',\                         ;  pstr             ;               ;  string indirection operator
    pstring, @@pstr, 1, 'i', 's',\                      ;  pstring          ;               ;  string indirection operator
    pint64, @@pint64, 1, 1, 's',\                       ;  pint64           ;               ;  int64 indirection operator
    covalue, @@covalue, 1, 1, 's',\                     ;  covalue          ;      x`       ;  compile-time value
    is.x32, @@is.x32, 0, 'i', 's',\                     ;  is.x32           ;               ;  is x32 DLL?
    is.n32, @@is.n32, 0, 'i', 's',\                     ;  is.n32           ;               ;  is not x32 DLL?
    is.x64, @@is.x64, 0, 'i', 's',\                     ;  is.x64           ;               ;  is x64 DLL?
    is.n64, @@is.n64, 0, 'i', 's',\                     ;  is.n64           ;               ;  is not x64 DLL?
    dll.bits, @@dll.bits, 0, 'i', 's',\                 ;  dll.bits         ;               ;  DLL bitness
    sizeof, @@sizeof, 1, 'i', 's',\                     ;  sizeof           ;               ;  sizeof
    result.set, @@result.set, 1, 1, 's',\               ;  result.set       ;   =x :=x      ;  set default result value
    result.get, @@result.get, 0, 1, 's',\               ;  result.get       ;   (=) ==      ;  get default result value
    co.rcopy, @@co.rcopy, 1, 1, 's',\                   ;  co.rcopy         ;    x=         ;  copy default result value
    co.rxcopy, @@co.rxcopy, 1, 1, 's',\                 ;  co.rxcopy        ;    x:=        ;  copy default result value
    return, @@return, 'any', 0, 's',\                   ;  return           ;               ;  assign result and quit the function
    return.if, @@return.if.true, 'any', 0, 's',\        ;  return.if        ;               ;  assign result and quit the function
    return.if.true, @@return.if.true, 'any', 0, 's',\   ;  return.if.true   ;               ;  assign result and quit the function
    return.if.not, @@return.if.false, 'any', 0, 's',\   ;  return.if.not    ;               ;  assign result and quit the function
    return.if.false, @@return.if.false, 'any', 0, 's',\ ;  return.if.true   ;               ;  assign result and quit the function
    exit, @@exit, 0, 0, 's',\                           ;  exit             ;               ;  quit the function
    quit, @@exit, 0, 0, 's',\                           ;  quit             ;               ;  quit the function
    exit.if, @@exit.if.true, 1, 0, 's',\                ;  exit.if          ;               ;  quit the function
    quit.if, @@exit.if.true, 1, 0, 's',\                ;  quit.if          ;               ;  quit the function
    exit.if.true, @@exit.if.true, 1, 0, 's',\           ;  exit.if.true     ;               ;  quit the function
    quit.if.true, @@exit.if.true, 1, 0, 's',\           ;  quit.if.true     ;               ;  quit the function
    exit.if.not, @@exit.if.false, 1, 0, 's',\           ;  exit.if.not      ;               ;  quit the function
    quit.if.not, @@exit.if.false, 1, 0, 's',\           ;  quit.if.not      ;               ;  quit the function
    exit.if.false, @@exit.if.false, 1, 0, 's',\         ;  exit.if.false    ;               ;  quit the function
    quit.if.false, @@exit.if.false, 1, 0, 's',\         ;  quit.if.false    ;               ;  quit the function
    is.nan, @@is.nan, 1, 'i', ,\                        ;  is.nan           ;               ;  is NaN
    is.inf, @@is.inf, 1, 'i', ,\                        ;  is.inf           ;               ;  is infinity
    is.valid, @@is.valid, 1, 'i', ,\                    ;  is.valid         ;               ;  is valid value
    is.invalid, @@is.invalid, 1, 'i', ,\                ;  is.invalid       ;               ;  is invalid value
    restore, @@restore, 1, 1, 's',\                     ;  restore          ;               ;  copy covalue to the variable x
    reset, @@reset, 1, 0, 's',\                         ;  reset            ;               ;  copy covalue to the variable x
    copy, @@copy, 2, 1, 's',\                           ;  copy             ;    x   = y    ;  copy the value of y to the variable x
    xcopy, @@xcopy, 2, 1, 's',\                         ;  xcopy            ;    x  := y    ;  copy the value of y to the variable x
    pcopy, @@pcopy, 2, 1, 's',\                         ;  pcopy            ;    x *:= y    ;  indirect copy y to px
    pxcopy, @@pxcopy, 2, 1, 's',\                       ;  pxcopy           ;    x *:= y    ;  indirect copy y to px
    copx, @@copx, 2, 1, 's',\                           ;  copx             ;    x =:  y    ;  copy the value of the variable x to the variable y
    ycopx, @@ycopx, 2, 1, 's',\                         ;  ycopx            ;    x =:  y    ;  copy the value of the variable x to the variable y
    pcopx, @@pcopx, 2, 1, 's',\                         ;  pcopx            ;    x =:* y    ;  indirect copy x to py
    pycopx, @@pycopx, 2, 1, 's',\                       ;  pycopx           ;    x =:* y    ;  indirect copy x to py
    copy.int, @@copy.int, 2, 1, 's',\                   ;  copy.int         ;    x  [=] y   ;  copy the int value of y to the variable x
    xcopy.int, @@xcopy.int, 2, 1, 's',\                 ;  xcopy.int        ;    x [:=] y   ;  copy the int value of y to the variable x
    copx.int, @@copx.int, 2, 1, 's',\                   ;  copx.int         ;    x [=:] y   ;  copy the int value of the variable x to the variable y
    ycopx.int, @@ycopx.int, 2, 1, 's',\                 ;  ycopx.int        ;    x [=:] y   ;  copy the int value of the variable x to the variable y
    copy.frac, @@copy.frac, 2, 1, 's',\                 ;  copy.frac        ;    x  {=} y   ;  copy the frac value of y to the variable x
    xcopy.frac, @@xcopy.frac, 2, 1, 's',\               ;  xcopy.frac       ;    x {:=} y   ;  copy the frac value of y to the variable x
    copx.frac, @@copx.frac, 2, 1, 's',\                 ;  copx.frac        ;    x {=:} y   ;  copy the frac value of the variable x to the variable y
    ycopx.frac, @@ycopx.frac, 2, 1, 's',\               ;  ycopx.frac       ;    x {=:} y   ;  copy the frac value of the variable x to the variable y
    copy.round, @@copy.round, 2, 1, 's',\               ;  copy.round       ;    x  <=> y   ;  copy the round value of y to the variable x
    xcopy.round, @@xcopy.round, 2, 1, 's',\             ;  xcopy.round      ;    x <:=> y   ;  copy the round value of y to the variable x
    copx.round, @@copx.round, 2, 1, 's',\               ;  copx.round       ;    x <=:> y   ;  copy the round value of the variable x to the variable y
    ycopx.round, @@ycopx.round, 2, 1, 's',\             ;  ycopx.round      ;    x <=:> y   ;  copy the round value of the variable x to the variable y
    x2copy, @@x2copy, 4, 1, 's',\                       ;  x2copy           ;               ;  copy the value of y_i to the variable x_i
    x3copy, @@x3copy, 6, 1, 's',\                       ;  x3copy           ;               ;  copy the value of y_i to the variable x_i
    x4copy, @@x4copy, 8, 1, 's',\                       ;  x4copy           ;               ;  copy the value of y_i to the variable x_i
    vcopy, @@vcopy, -2, 1, 's',\                        ;  vcopy            ;               ;  copy the value of variable y to the variables x_i
    vxcopy, @@vcopy, -2, 1, 's',\                       ;  vxcopy           ;               ;  copy the value of variable y to the variables x_i
    vcopx, @@vcopx, -2, 1, 's',\                        ;  vcopx            ;               ;  copy the value of variable x to the variables y_i
    vycopx, @@vcopx, -2, 1, 's',\                       ;  vycopx           ;               ;  copy the value of variable x to the variables y_i
    swap, @@swap, 2, 1, 's',\                           ;  swap             ;   x  :=:  y   ;  swap the values of the variables x and y
    swap.int, @@swap.int, 2, 1, 's',\                   ;  swap.int         ;   x [:=:] y   ;  swap the int values of the variables x and y
    swap.frac, @@swap.frac, 2, 1, 's',\                 ;  swap.frac        ;   x {:=:} y   ;  swap the frac values of the variables x and y
    swap.round, @@swap.round, 2, 1, 's',\               ;  swap.round       ;   x <:=:> y   ;  swap the round values of the variables x and y
    swapr, @@swapr, -2, 1, 's',\                        ;  swapr            ;               ;  swap the values of the variables, shift right
    swapl, @@swapl, -2, 1, 's',\                        ;  swapl            ;               ;  swap the values of the variables, shift left
    co.chs, @@co.chs, 1, 1, 's',\                       ;  co.chs           ;               ;  chs + copy function
    co.abs, @@co.abs, 1, 1, 's',\                       ;  co.abs           ;               ;  abs + copy function
    co.nabs, @@co.nabs, 1, 1, 's',\                     ;  co.nabs          ;               ;  nabs + copy function
    co.add, @@co.add, 2, 1, 's',\                       ;  co.add           ;     +=        ;  add + copy function
    co.sub, @@co.sub, 2, 1, 's',\                       ;  co.sub           ;     -=        ;  sub + copy function
    co.subr, @@co.subr, 2, 1, 's',\                     ;  co.subr          ;    ~-=        ;  subr + copy function
    co.mul, @@co.mul, 2, 1, 's',\                       ;  co.mul           ;     *=        ;  mul + copy function
    co.div, @@co.div, 2, 1, 's',\                       ;  co.div           ;     /=        ;  div + copy function
    co.divr, @@co.divr, 2, 1, 's',\                     ;  co.divr          ;    ~/=        ;  divr + copy function
    co.quo, @@co.quo, 2, 1, 's',\                       ;  co.quo           ;     \=        ;  quo + copy function
    co.quor, @@co.quor, 2, 1, 's',\                     ;  co.quor          ;    ~\=        ;  quor + copy function
    co.mod, @@co.mod, 2, 1, 's',\                       ;  co.mod           ;     %=        ;  mod + copy function
    co.modr, @@co.modr, 2, 1, 's',\                     ;  co.modr          ;    ~%=        ;  modr + copy function
    co.bnot, @@co.bnot, 1, 'i', 's',\                   ;  co.bnot          ;     ~=        ;  bnot + copy function
    co.bor, @@co.bor, 2, 'i', 's',\                     ;  co.bor           ;     |=        ;  bor + copy function
    co.bnor, @@co.bnor, 2, 'i', 's',\                   ;  co.bnor          ;    ~|=        ;  bnor + copy function
    co.born, @@co.born, 2, 'i', 's',\                   ;  co.born          ;     |~=       ;  born + copy function
    co.bnorn, @@co.bnorn, 2, 'i', 's',\                 ;  co.bnorn         ;    ~|~=       ;  bnorn + copy function
    co.borc, @@co.borc, 2, 'i', 's',\                   ;  co.borc          ;     |-=       ;  borc + copy function
    co.bnorc, @@co.bnorc, 2, 'i', 's',\                 ;  co.bnorc         ;    ~|-=       ;  bnorc + copy function
    co.bcor, @@co.bcor, 2, 'i', 's',\                   ;  co.bcor          ;    -|=        ;  bcor + copy function
    co.bcorn, @@co.bcorn, 2, 'i', 's',\                 ;  co.bcorn         ;    -|~=       ;  bcorn + copy function
    co.bxor, @@co.bxor, 2, 'i', 's',\                   ;  co.bxor          ;     ^=        ;  bxor + copy function
    co.bxnor, @@co.bxnor, 2, 'i', 's',\                 ;  co.bxnor         ;    ~^=        ;  bxnor + copy function
    co.band, @@co.band, 2, 'i', 's',\                   ;  co.band          ;     &=        ;  band + copy function
    co.bnand, @@co.bnand, 2, 'i', 's',\                 ;  co.bnand         ;    ~&=        ;  bnand + copy function
    co.bandn, @@co.bandn, 2, 'i', 's',\                 ;  co.bandn         ;     &~=       ;  bandn + copy function
    co.bnandn, @@co.bnandn, 2, 'i', 's',\               ;  co.bnandn        ;    ~&~=       ;  bnandn + copy function
    co.breset, @@co.breset, 2, 'i', 's',\               ;  co.breset        ;    |0|=       ;  breset + copy function
    co.bset, @@co.bset, 2, 'i', 's',\                   ;  co.bset          ;    |1|=       ;  bset + copy function
    co.shr, @@co.shr, 2, 'i', 's',\                     ;  co.shr           ;    >>=        ;  shr + copy function
    co.shl, @@co.shl, 2, 'i', 's',\                     ;  co.shl           ;    <<=        ;  shl + copy function
    co.sar, @@co.sar, 2, 'i', 's',\                     ;  co.sar           ;   >>>=        ;  sar + copy function
    co.sal, @@co.sal, 2, 'i', 's',\                     ;  co.sal           ;   <<<=        ;  sal + copy function
    co.ror, @@co.ror, 2, 'i', 's',\                     ;  co.ror           ;   >><=        ;  ror + copy function
    co.rol, @@co.rol, 2, 'i', 's',\                     ;  co.rol           ;   <<>=        ;  rol + copy function
    bsf, @@bsf, 1, 'i', ,\                              ;  bsf              ;   <<?x        ;  bit scan forward
    bsr, @@bsr, 1, 'i', ,\                              ;  bsr              ;   >>?x        ;  bit scan reverse
    hammw, @@hammw, 1, 'i', ,\                          ;  hammw            ;               ;  Hamming weight
    popcount, @@hammw, 1, 'i', ,\                       ;  popcount         ;               ;  Hamming weight
    hammd, @@hammd, 2, 'i', ,\                          ;  hammd            ;               ;  Hamming distance
    bt, @@bt, 2, 'i', ,\                                ;  bt               ;   >?<         ;  bit test
    btc, @@btc, 2, 'i', ,\                              ;  btc              ;   >?~<        ;  bit test and complement
    btr, @@btr, 2, 'i', ,\                              ;  btr              ;   >?-<        ;  bit test and reset
    bts, @@bts, 2, 'i', ,\                              ;  bts              ;   >?+<        ;  bit test and set
    bnot, @@bnot, 1, 'i', ,\                            ;  bnot             ;   ~x          ;  bitwise not
    bor, @@bor, 2, 'i', ,\                              ;  bor              ;    |          ;  bitwise or
    bnor, @@bnor, 2, 'i', ,\                            ;  bnor             ;   ~|          ;  bitwise not or
    born, @@born, 2, 'i', ,\                            ;  born             ;    |~         ;  bitwise or not
    bnorn, @@bnorn, 2, 'i', ,\                          ;  bnorn            ;   ~|~         ;  bitwise not or not
    borc, @@borc, 2, 'i', ,\                            ;  borc             ;    |-         ;  bitwise or clear
    bnorc, @@bnorc, 2, 'i', ,\                          ;  bnorc            ;   ~|-         ;  bitwise not or clear
    bcor, @@bcor, 2, 'i', ,\                            ;  bcor             ;   -|          ;  bitwise clear or
    bcorn, @@bcorn, 2, 'i', ,\                          ;  bcorn            ;   -|~         ;  bitwise clear or not
    bxor, @@bxor, 2, 'i', ,\                            ;  bxor             ;    ^          ;  bitwise xor
    bxnor, @@bxnor, 2, 'i', ,\                          ;  bxnor            ;   ~^          ;  bitwise not xor
    band, @@band, 2, 'i', ,\                            ;  band             ;    &          ;  bitwise and
    bnand, @@bnand, 2, 'i', ,\                          ;  bnand            ;   ~&          ;  bitwise not and
    bandn, @@bandn, 2, 'i', ,\                          ;  bandn            ;    &~         ;  bitwise and not
    bnandn, @@bnandn, 2, 'i', ,\                        ;  bnandn           ;   ~&~         ;  bitwise not and not
    breset, @@breset, 2, 'i', ,\                        ;  breset           ;   |0|         ;  bitwise reset
    bset, @@bset, 2, 'i', ,\                            ;  bset             ;   |1|         ;  bitwise set
    shr, @@shr, 2, 'i', ,\                              ;  shr              ;   >>          ;  bitwise shift right
    shl, @@shl, 2, 'i', ,\                              ;  shl              ;   <<          ;  bitwise shift left
    sar, @@sar, 2, 'i', ,\                              ;  sar              ;   >>>         ;  bitwise shift arithmetic right
    sal, @@sal, 2, 'i', ,\                              ;  sal              ;   <<<         ;  bitwise shift arithmetic left
    ror, @@ror, 2, 'i', ,\                              ;  ror              ;   >><         ;  bitwise rotate right
    rol, @@rol, 2, 'i', ,\                              ;  rol              ;   <<>         ;  bitwise rotate left
    bswap, @@bswap, 1, 'i', ,\                          ;  bswap            ;               ;  byte swap
    b4swap, @@b4swap, 1, 'i', ,\                        ;  b4swap           ;               ;  byte swap
    b2swap, @@b2swap, 1, 'i', ,\                        ;  b2swap           ;               ;  byte swap
    bitswap, @@bitswap, 1, 'i', ,\                      ;  bitswap          ;               ;  bit swap
    bit32swap, @@bit32swap, 1, 'i', ,\                  ;  bit32swap        ;               ;  bit swap
    bit16swap, @@bit16swap, 1, 'i', ,\                  ;  bit16swap        ;               ;  bit swap
    bit8swap, @@bit8swap, 1, 'i', ,\                    ;  bit8swap         ;               ;  bit swap
    ot, @@ot, 1, 'i', ,\                                ;  ot               ;   ?x          ;  value as boolean
    bool, @@ot, 1, 'i', ,\                              ;  bool             ;   ?x          ;  value as boolean
    not, @@not, 1, 'i', ,\                              ;  not              ;   !x          ;  negation
    or, @@or, 2, 'i', ,\                                ;  or               ;   ||          ;  disjunction
    nor, @@nor, 2, 'i', ,\                              ;  nor              ;   !|          ;  negative disjunction
    xor, @@xor, 2, 'i', ,\                              ;  xor              ;   ^^          ;  exclusive disjunction
    xnor, @@xnor, 2, 'i', ,\                            ;  xnor             ;   !^          ;  negative exclusive disjunction
    and, @@and, 2, 'i', ,\                              ;  and              ;   &&          ;  conjunction
    nand, @@nand, 2, 'i', ,\                            ;  nand             ;   !&          ;  negative conjunction
    if, @@if.true, 1, 'i', ,\                           ;  if               ;               ;  true
    if.true, @@if.true, 1, 'i', ,\                      ;  if.true          ;               ;  true
    if.not, @@if.false, 1, 'i', ,\                      ;  if.not           ;               ;  false
    if.false, @@if.false, 1, 'i', ,\                    ;  if.false         ;               ;  false
    if.z, @@if.z, 1, 'i', ,\                            ;  if.z             ;   ==.         ;  zero
    if.nz, @@if.nz, 1, 'i', ,\                          ;  if.nz            ;   !=. <>.     ;  not zero
    if.az, @@if.az, 1, 'i', ,\                          ;  if.az            ;   >.          ;  above zero
    if.aez, @@if.aez, 1, 'i', ,\                        ;  if.aez           ;   >=. !<.     ;  above or equal zero
    if.bz, @@if.bz, 1, 'i', ,\                          ;  if.bz            ;   <.          ;  below zero
    if.bez, @@if.bez, 1, 'i', ,\                        ;  if.bez           ;   <=. !>.     ;  below or equal zero
    if.e, @@if.e, 2, 'i', ,\                            ;  if.e             ;   ==          ;  equal
    if.ne, @@if.ne, 2, 'i', ,\                          ;  if.ne            ;   <> !=       ;  not equal
    if.a, @@if.a, 2, 'i', ,\                            ;  if.a             ;   >           ;  above (greater)
    if.ae, @@if.ae, 2, 'i', ,\                          ;  if.ae            ;   >= !<       ;  above or equal (greater or equal)
    if.b, @@if.b, 2, 'i', ,\                            ;  if.b             ;   <           ;  below (less)
    if.be, @@if.be, 2, 'i', ,\                          ;  if.be            ;   <= !>       ;  below or equal (less or equal)
    if.bea, @@if.bea, 2, 'i', ,\                        ;  if.bea           ;   <==>        ;  three-way comparison
    if.aeb, @@if.aeb, 2, 'i', ,\                        ;  if.aeb           ;   >==<        ;  three-way comparison
    aif.z, @@aif.z, 1, 'i', ,\                          ;  aif.z            ;   ==.~        ;  approximately zero
    aif.nz, @@aif.nz, 1, 'i', ,\                        ;  aif.nz           ;   !=.~ <>.~   ;  approximately not zero
    aif.az, @@aif.az, 1, 'i', ,\                        ;  aif.az           ;   >.~         ;  approximately above zero
    aif.aez, @@aif.aez, 1, 'i', ,\                      ;  aif.aez          ;   >=.~ !<.~   ;  approximately above or equal zero
    aif.bz, @@aif.bz, 1, 'i', ,\                        ;  aif.bz           ;   <.~         ;  approximately below zero
    aif.bez, @@aif.bez, 1, 'i', ,\                      ;  aif.bez          ;   <=.~ !>.~   ;  approximately below or equal zero
    aif.e, @@aif.e, 2, 'i', ,\                          ;  aif.e            ;   ==~         ;  approximately equal
    aif.ne, @@aif.ne, 2, 'i', ,\                        ;  aif.ne           ;   <>~ !=~     ;  approximately not equal
    aif.a, @@aif.a, 2, 'i', ,\                          ;  aif.a            ;   >~          ;  approximately above (greater)
    aif.ae, @@aif.ae, 2, 'i', ,\                        ;  aif.ae           ;   >=~ !<~     ;  approximately above or equal (greater or equal)
    aif.b, @@aif.b, 2, 'i', ,\                          ;  aif.b            ;   <~          ;  approximately below (less)
    aif.be, @@aif.be, 2, 'i', ,\                        ;  aif.be           ;   <=~ !>~     ;  approximately below or equal (less or equal)
    aif.bea, @@aif.bea, 2, 'i', ,\                      ;  aif.bea          ;   <==>~       ;  three-way approximate comparison
    aif.aeb, @@aif.aeb, 2, 'i', ,\                      ;  aif.aeb          ;   >==<~       ;  three-way approximate comparison
    if.or, @@if.or, -2, 'i', ,\                         ;  if.or            ;               ;  multi-or
    if.nor, @@if.nor, -2, 'i', ,\                       ;  if.nor           ;               ;  multi-nor
    if.and, @@if.and, -2, 'i', ,\                       ;  if.and           ;               ;  multi-and
    if.nand, @@if.nand, -2, 'i', ,\                     ;  if.nand          ;               ;  multi-nand
    ie, @@ie.true, 3, 1, ,\                             ;  ie               ;               ;  conditional function
    ie.true, @@ie.true, 3, 1, ,\                        ;  ie.true          ;               ;  conditional function
    ie.not, @@ie.false, 3, 1, ,\                        ;  ie.not           ;               ;  conditional function
    ie.false, @@ie.false, 3, 1, ,\                      ;  ie.false         ;               ;  conditional function
    ie.z, @@ie.z, 3, 1, ,\                              ;  ie.z             ;               ;  conditional function: zero
    ie.nz, @@ie.nz, 3, 1, ,\                            ;  ie.nz            ;               ;  conditional function: not zero
    ie.az, @@ie.az, 3, 1, ,\                            ;  ie.az            ;               ;  conditional function: above zero
    ie.aez, @@ie.aez, 3, 1, ,\                          ;  ie.aez           ;               ;  conditional function: above or equal zero
    ie.bz, @@ie.bz, 3, 1, ,\                            ;  ie.bz            ;               ;  conditional function: below zero
    ie.bez, @@ie.bez, 3, 1, ,\                          ;  ie.bez           ;               ;  conditional function: below or equal zero
    ie.e, @@ie.e, 4, 1, ,\                              ;  ie.e             ;               ;  conditional function: equal
    ie.ne, @@ie.ne, 4, 1, ,\                            ;  ie.ne            ;               ;  conditional function: not equal
    ie.a, @@ie.a, 4, 1, ,\                              ;  ie.a             ;               ;  conditional function: above
    ie.ae, @@ie.ae, 4, 1, ,\                            ;  ie.ae            ;               ;  conditional function: above or equal
    ie.b, @@ie.b, 4, 1, ,\                              ;  ie.b             ;               ;  conditional function: below
    ie.be, @@ie.be, 4, 1, ,\                            ;  ie.be            ;               ;  conditional function: below or equal
    ie.bea, @@ie.bea, 5, 1, ,\                          ;  ie.bea           ;               ;  conditional function
    ie.aeb, @@ie.aeb, 5, 1, ,\                          ;  ie.aeb           ;               ;  conditional function
    ie.or, @@ie.or, -4, 1, ,\                           ;  ie.or            ;               ;  conditional function
    ie.nor, @@ie.nor, -4, 1, ,\                         ;  ie.nor           ;               ;  conditional function
    ie.and, @@ie.and, -4, 1, ,\                         ;  ie.and           ;               ;  conditional function
    ie.nand, @@ie.nand, -4, 1, ,\                       ;  ie.nand          ;               ;  conditional function
    case.e, @@case.e, -2, 1, ,\                         ;  case.e           ;               ;  case switch : x=
    case, @@case.e, -2, 1, ,\                           ;  case             ;               ;  case switch : x=
    rcase.e, @@rcase.e, -2, 1, ,\                       ;  rcase.e          ;               ;  reverse case switch : x=
    rcase, @@rcase.e, -2, 1, ,\                         ;  rcase            ;               ;  reverse case switch : x=
    case.ne, @@case.ne, -2, 1, ,\                       ;  case.ne          ;               ;  case switch : x!=
    ncase, @@case.ne, -2, 1, ,\                         ;  ncase            ;               ;  case switch : x!=
    rcase.ne, @@rcase.ne, -2, 1, ,\                     ;  rcase.ne         ;               ;  reverse case switch : x!=
    rncase, @@rcase.ne, -2, 1, ,\                       ;  rncase           ;               ;  reverse case switch : x!=
    case.a, @@case.a, -2, 1, ,\                         ;  case.a           ;               ;  case switch : x>
    rcase.a, @@rcase.a, -2, 1, ,\                       ;  rcase.a          ;               ;  reverse case switch : x>
    case.ae, @@case.ae, -2, 1, ,\                       ;  case.ae          ;               ;  case switch : x>=
    rcase.ae, @@rcase.ae, -2, 1, ,\                     ;  rcase.ae         ;               ;  reverse case switch : x>=
    case.b, @@case.b, -2, 1, ,\                         ;  case.b           ;               ;  case switch : x<
    rcase.b, @@rcase.b, -2, 1, ,\                       ;  rcase.b          ;               ;  reverse case switch : x<
    case.be, @@case.be, -2, 1, ,\                       ;  case.be          ;               ;  case switch : x<=
    rcase.be, @@rcase.be, -2, 1, ,\                     ;  rcase.be         ;               ;  reverse case switch : x<=
    case.x32, @@case.x32, 2, 1, ,\                      ;  case.x32         ;               ;  case switch
    case.n32, @@case.n32, 2, 1, ,\                      ;  case.n32         ;               ;  case switch
    case.x64, @@case.x64, 2, 1, ,\                      ;  case.x64         ;               ;  case switch
    case.n64, @@case.n64, 2, 1, ,\                      ;  case.n64         ;               ;  case switch
    goto, @@goto, 1, 0, 's',\                           ;  goto             ;               ;  unconditional jump
    goto.if.x32, @@goto.if.x32, 1, 0, 's',\             ;  goto.if.x32      ;               ;  conditional jump
    goto.if.n32, @@goto.if.n32, 1, 0, 's',\             ;  goto.if.n32      ;               ;  conditional jump
    goto.if.x64, @@goto.if.x64, 1, 0, 's',\             ;  goto.if.x64      ;               ;  conditional jump
    goto.if.n64, @@goto.if.n64, 1, 0, 's',\             ;  goto.if.n64      ;               ;  conditional jump
    goto.if, @@goto.if.true, 2, 0, 's',\                ;  goto.if          ;               ;  conditional jump
    goto.if.true, @@goto.if.true, 2, 0, 's',\           ;  goto.if.true     ;               ;  conditional jump
    goto.if.not, @@goto.if.false, 2, 0, 's',\           ;  goto.if.not      ;               ;  conditional jump
    goto.if.false, @@goto.if.false, 2, 0, 's',\         ;  goto.if.false    ;               ;  conditional jump
    goto.if.z, @@goto.if.z, 2, 0, 's',\                 ;  goto.if.z        ;               ;  conditional jump: zero
    goto.if.nz, @@goto.if.nz, 2, 0, 's',\               ;  goto.if.nz       ;               ;  conditional jump: not zero
    goto.if.az, @@goto.if.az, 2, 0, 's',\               ;  goto.if.az       ;               ;  conditional jump: above zero
    goto.if.aez, @@goto.if.aez, 2, 0, 's',\             ;  goto.if.aez      ;               ;  conditional jump: above or equal zero
    goto.if.bz, @@goto.if.bz, 2, 0, 's',\               ;  goto.if.bz       ;               ;  conditional jump: below zero
    goto.if.bez, @@goto.if.bez, 2, 0, 's',\             ;  goto.if.bez      ;               ;  conditional jump: below or equal zero
    goto.if.or, @@goto.if.or, -3, 0, 's',\              ;  goto.if.or       ;               ;  conditional jump
    goto.if.nor, @@goto.if.nor, -3, 0, 's',\            ;  goto.if.nor      ;               ;  conditional jump
    goto.if.and, @@goto.if.and, -3, 0, 's',\            ;  goto.if.and      ;               ;  conditional jump
    goto.if.nand, @@goto.if.nand, -3, 0, 's',\          ;  goto.if.nand     ;               ;  conditional jump
    proc.begin, @@proc.begin, 0, 0, 's',\               ;  proc.begin       ;               ;  begin procedure
    proc.end, @@proc.end, 0, 0, 's',\                   ;  proc.end         ;               ;  end procedure
    arg.getf, @@arg.getf, 1, 1, 's-',\                  ;  arg.getf         ;               ;  get procedure float argument
    arg.geti, @@arg.geti, 1, 'i', 's-',\                ;  arg.geti         ;               ;  get procedure integer argument
    locals.alloc, @@locals.alloc, 1, 0, 's-',\          ;  locals.alloc     ;               ;  allocate memory for local variables
    local.getf, @@local.getf, 1, 1, 's-',\              ;  local.getf       ;               ;  get float local variable
    local.geti, @@local.geti, 1, 'i', 's-',\            ;  local.geti       ;               ;  get integer local variable
    local.setf, @@local.setf, 2, 1, 's-',\              ;  local.setf       ;               ;  set float local variable
    local.seti, @@local.seti, 2, 'i', 's-',\            ;  local.seti       ;               ;  set integer local variable
    retn, @@retn, 0, 0, 's',\                           ;  retn             ;               ;  return from procedure
    call, @@call, 1, 0, 's',\                           ;  call             ;               ;  procedure call
    calls, @@calls, -1, 0, 's',\                        ;  calls            ;               ;  procedure call
    rcalls, @@rcalls, -1, 0, 's',\                      ;  rcalls           ;               ;  reverse procedure call
    call.if.x32, @@call.if.x32, 1, 0, 's',\             ;  call.if.x32      ;               ;  conditional call
    call.if.n32, @@call.if.n32, 1, 0, 's',\             ;  call.if.n32      ;               ;  conditional call
    call.if.x64, @@call.if.x64, 1, 0, 's',\             ;  call.if.x64      ;               ;  conditional call
    call.if.n64, @@call.if.n64, 1, 0, 's',\             ;  call.if.n64      ;               ;  conditional call
    call.ie.x32, @@call.ie.x32, 2, 0, 's',\             ;  call.ie.x32      ;               ;  conditional call
    call.ie.n32, @@call.ie.n32, 2, 0, 's',\             ;  call.ie.n32      ;               ;  conditional call
    call.ie.x64, @@call.ie.x64, 2, 0, 's',\             ;  call.ie.x64      ;               ;  conditional call
    call.ie.n64, @@call.ie.n64, 2, 0, 's',\             ;  call.ie.n64      ;               ;  conditional call
    call.if, @@call.if.true, 2, 0, 's',\                ;  call.if          ;               ;  conditional call
    call.if.true, @@call.if.true, 2, 0, 's',\           ;  call.if.true     ;               ;  conditional call
    call.if.not, @@call.if.false, 2, 0, 's',\           ;  call.if.not      ;               ;  conditional call
    call.if.false, @@call.if.false, 2, 0, 's',\         ;  call.if.false    ;               ;  conditional call
    call.if.z, @@call.if.z, 2, 0, 's',\                 ;  call.if.z        ;               ;  conditional call: zero
    call.if.nz, @@call.if.nz, 2, 0, 's',\               ;  call.if.nz       ;               ;  conditional call: not zero
    call.if.az, @@call.if.az, 2, 0, 's',\               ;  call.if.az       ;               ;  conditional call: above zero
    call.if.aez, @@call.if.aez, 2, 0, 's',\             ;  call.if.aez      ;               ;  conditional call: above or equal zero
    call.if.bz, @@call.if.bz, 2, 0, 's',\               ;  call.if.bz       ;               ;  conditional call: below zero
    call.if.bez, @@call.if.bez, 2, 0, 's',\             ;  call.if.bez      ;               ;  conditional call: below or equal zero
    call.ie, @@call.ie.true, 3, 0, 's',\                ;  call.ie          ;               ;  conditional call
    call.ie.true, @@call.ie.true, 3, 0, 's',\           ;  call.ie.true     ;               ;  conditional call
    call.ie.not, @@call.ie.false, 3, 0, 's',\           ;  call.ie.not      ;               ;  conditional call
    call.ie.false, @@call.ie.false, 3, 0, 's',\         ;  call.ie.false    ;               ;  conditional call
    call.ie.z, @@call.ie.z, 3, 0, 's',\                 ;  call.ie.z        ;               ;  conditional call: zero
    call.ie.nz, @@call.ie.nz, 3, 0, 's',\               ;  call.ie.nz       ;               ;  conditional call: not zero
    call.ie.az, @@call.ie.az, 3, 0, 's',\               ;  call.ie.az       ;               ;  conditional call: above zero
    call.ie.aez, @@call.ie.aez, 3, 0, 's',\             ;  call.ie.aez      ;               ;  conditional call: above or equal zero
    call.ie.bz, @@call.ie.bz, 3, 0, 's',\               ;  call.ie.bz       ;               ;  conditional call: below zero
    call.ie.bez, @@call.ie.bez, 3, 0, 's',\             ;  call.ie.bez      ;               ;  conditional call: below or equal zero
    call.if.or, @@call.if.or, -3, 0, 's',\              ;  call.if.or       ;               ;  conditional call
    call.if.nor, @@call.if.nor, -3, 0, 's',\            ;  call.if.nor      ;               ;  conditional call
    call.if.and, @@call.if.and, -3, 0, 's',\            ;  call.if.and      ;               ;  conditional call
    call.if.nand, @@call.if.nand, -3, 0, 's',\          ;  call.if.nand     ;               ;  conditional call
    call.ie.or, @@call.ie.or, -4, 0, 's',\              ;  call.ie.or       ;               ;  conditional call
    call.ie.nor, @@call.ie.nor, -4, 0, 's',\            ;  call.ie.nor      ;               ;  conditional call
    call.ie.and, @@call.ie.and, -4, 0, 's',\            ;  call.ie.and      ;               ;  conditional call
    call.ie.nand, @@call.ie.nand, -4, 0, 's',\          ;  call.ie.nand     ;               ;  conditional call
    farr, @@farr, 2, 1, 's',\                           ;  farr             ;     -> u[n]   ;  read double array item, forward search
    pfarr, @@pfarr, 2, 1, 's',\                         ;  pfarr            ;    *-> u{n}   ;  read double array item, forward search, indirect
    barr, @@barr, 2, 1, 's',\                           ;  barr             ;     ~>        ;  read double array item, backward search
    pbarr, @@pbarr, 2, 1, 's',\                         ;  pbarr            ;    *~>        ;  read double array item, backward search, indirect
    farw, @@farw, 3, 1, 's',\                           ;  farw             ;               ;  write double array item, forward search
    pfarw, @@pfarw, 3, 1, 's',\                         ;  pfarw            ;               ;  write double array item, forward search, indirect
    barw, @@barw, 3, 1, 's',\                           ;  barw             ;               ;  write double array item, backward search
    pbarw, @@pbarw, 3, 1, 's',\                         ;  pbarw            ;               ;  write double array item, backward search, indirect
    fara, @@fara, 2, 'i', 's',\                         ;  fara             ;    &->        ;  double array item address, forward search
    pfara, @@pfara, 2, 'i', 's',\                       ;  pfara            ;   *&->        ;  double array item address, forward search, indirect
    bara, @@bara, 2, 'i', 's',\                         ;  bara             ;    &~>        ;  double array item address, backward search
    pbara, @@pbara, 2, 'i', 's',\                       ;  pbara            ;   *&~>        ;  double array item address, backward search, indirect
    farv, @@farv, 2, 1, 's',\                           ;  farv             ;    ->>        ;  double array item as variable, forward search
    barv, @@barv, 2, 1, 's',\                           ;  barv             ;    ~>>        ;  double array item as variable, backward search
    matrip, @@matrip, -1, 'i', ,\                       ;  matrip           ;               ;  matrix item position, no range control
    matrip.rc, @@matrip.rc, -1, 'i', ,\                 ;  matrip.rc        ;               ;  matrix item position, range control
    zero, @@fldz, 0, 1, ,\                              ;  zero             ;               ;  load +0.0
    fldz, @@fldz, 0, 1, ,\                              ;  fldz             ;               ;  load +0.0
    fld1, @@fld1, 0, 1, ,\                              ;  fld1             ;               ;  load +1.0
    fldpi, @@fldpi, 0, 1, ,\                            ;  fldpi            ;               ;  load PI
    fldl2t, @@fldl2t, 0, 1, ,\                          ;  fldl2t           ;               ;  load log[2](10)
    fldl2e, @@fldl2e, 0, 1, ,\                          ;  fldl2e           ;               ;  load log[2](e)
    fldlg2, @@fldlg2, 0, 1, ,\                          ;  fldlg2           ;               ;  load log[10](2)
    fldln2, @@fldln2, 0, 1, ,\                          ;  fldln2           ;               ;  load log[e](2)
    nan, @@nan, 0, 1, ,\                                ;  nan              ;               ;  return NaN value
    nanu, @@nanu, 0, 1, ,\                              ;  nanu             ;               ;  return NaN value
    pinf, @@pinf, 0, 1, ,\                              ;  pinf             ;               ;  return positive infinity value
    ninf, @@ninf, 0, 1, ,\                              ;  ninf             ;               ;  return negative infinity value
    peps, @@peps, 0, 1, ,\                              ;  peps             ;               ;  return positive epsilon value
    neps, @@neps, 0, 1, ,\                              ;  neps             ;               ;  return negative epsilon value
    maxd, @@maxd, 0, 1, ,\                              ;  maxd             ;               ;  return maximum double value
    mind, @@mind, 0, 1, ,\                              ;  mind             ;               ;  return minimum double value
    f2xm1, @@f2xm1, 1, 1, ,\                            ;  f2xm1            ;               ;  2^x-1
    fyl2x, @@fyl2x, 2, 1, ,\                            ;  fyl2x            ;               ;  y*log[2](x)
    fyl2xp1, @@fyl2xp1, 2, 1, ,\                        ;  fyl2xp1          ;               ;  y*log[2](x+1)
    fprem, @@fprem, 2, 1, ,\                            ;  fprem            ;               ;  partial remainder
    frprem, @@frprem, 2, 1, ,\                          ;  frprem           ;               ;  reverse partial remainder
    fprem1, @@fprem1, 2, 1, ,\                          ;  fprem1           ;               ;  IEEE partial remainder
    frprem1, @@frprem1, 2, 1, ,\                        ;  frprem1          ;               ;  reverse IEEE partial remainder
    fscale, @@fscale, 2, 1, ,\                          ;  fscale           ;               ;  x*(2^y)
    frscale, @@frscale, 2, 1, ,\                        ;  frscale          ;               ;  y*(2^x)
    fxtracts, @@fxtracts, 1, 1, ,\                      ;  fxtracts         ;               ;  extract significant
    fxtracte, @@fxtracte, 1, 1, ,\                      ;  fxtracte         ;               ;  extract exponent
    fxtractse, @@fxtractse, 1, 2, ,\                    ;  fxtractse        ;               ;  extract significant & exponent
    co.fxtractse, @@co.fxtractse, 3, 1, 's',\           ;  co.fxtractse     ;               ;  significant & exponent
    fxtractes, @@fxtractes, 1, 2, ,\                    ;  fxtractes        ;               ;  extract exponent & significant
    co.fxtractes, @@co.fxtractes, 3, 1, 's',\           ;  co.fxtractes     ;               ;  exponent & significant
    setz, @@setz, 1, 1, ,\                              ;  setz             ;               ;  return +0.0
    set1, @@set1, 1, 1, ,\                              ;  set1             ;               ;  return +1.0
    uplus, @@uplus, 1, 1, ,\                            ;  uplus            ;   +x          ;  prefix + :: unary plus
    chs, @@chs, 1, 1, ,\                                ;  chs              ;   -x          ;  prefix - :: reverse sign
    abs, @@abs, 1, 1, ,\                                ;  abs              ;  (|x|)        ;  absolute value
    nabs, @@nabs, 1, 1, ,\                              ;  nabs             ;  (!x!)        ;  negative absolute value: -abs(x)
    sign, @@sign, 1, 1, ,\                              ;  sign             ;               ;  sign of a number (-1, 0, 1)
    sgn, @@sign, 1, 1, ,\                               ;  sgn              ;               ;  sign of a number (-1, 0, 1)
    rsign, @@rsign, 1, 1, ,\                            ;  rsign            ;               ;  reversed sign of a number (-1, 0, 1)
    rsgn, @@rsign, 1, 1, ,\                             ;  rsgn             ;               ;  reversed sign of a number (-1, 0, 1)
    isign, @@isign, 1, 'i', '-',\                       ;  isign            ;               ;  sign of a number (-1, 0, 1)
    isgn, @@isign, 1, 'i', '-',\                        ;  isgn             ;               ;  sign of a number (-1, 0, 1)
    risign, @@risign, 1, 'i', '-',\                     ;  risign           ;               ;  reversed sign of a number (-1, 0, 1)
    risgn, @@risign, 1, 'i', '-',\                      ;  risgn            ;               ;  reversed sign of a number (-1, 0, 1)
    nzero, @@nzero, 1, 1, ,\                            ;  nzero            ;    !.         ;  non-zero value
    rnzero, @@rnzero, 1, 1, ,\                          ;  rnzero           ;   ~!.         ;  reversed non-zero value
    pos, @@pos, 1, 1, ,\                                ;  pos              ;               ;  positive value or zero
    ramp, @@pos, 1, 1, ,\                               ;  ramp             ;               ;  positive value or zero
    neg, @@neg, 1, 1, ,\                                ;  neg              ;               ;  negative value or zero
    inv, @@inv, 1, 1, ,\                                ;  inv              ;   /x          ;  prefix / :: 1/x
    recip, @@inv, 1, 1, ,\                              ;  recip            ;   /x          ;  prefix / :: 1/x
    inc, @@inc, 1, 1, ,\                                ;  inc              ;               ;  increment by 1
    inc.pre, @@inc.pre, 1, 1, ,\                        ;  inc.pre          ;   ++x         ;  prefix increment by 1
    inc.post, @@inc.post, 1, 1, ,\                      ;  inc.post         ;   x++         ;  postfix increment by 1
    dec, @@dec, 1, 1, ,\                                ;  dec              ;               ;  decrement by 1
    dec.pre, @@dec.pre, 1, 1, ,\                        ;  dec.pre          ;   --x         ;  prefix decrement by 1
    dec.post, @@dec.post, 1, 1, ,\                      ;  dec.post         ;   x--         ;  postfix decrement by 1
    add, @@add, 2, 1, ,\                                ;  add              ;   +           ;  addition
    add.pos, @@add.pos, 2, 1, ,\                        ;  add.pos          ;   ++          ;  positive addition
    add.neg, @@add.neg, 2, 1, ,\                        ;  add.neg          ;   +-          ;  negative addition
    add.int, @@add.int, 2, 1, ,\                        ;  add.int          ;   [+]         ;  int addition
    add.frac, @@add.frac, 2, 1, ,\                      ;  add.frac         ;   {+}         ;  frac addition
    add.round, @@add.round, 2, 1, ,\                    ;  add.round        ;   <+>         ;  round addition
    sub, @@sub, 2, 1, ,\                                ;  sub              ;   -           ;  subtraction
    sub.pos, @@sub.pos, 2, 1, ,\                        ;  sub.pos          ;   -+          ;  positive subtraction
    sub.neg, @@sub.neg, 2, 1, ,\                        ;  sub.neg          ;   --          ;  negative subtraction
    sub.int, @@sub.int, 2, 1, ,\                        ;  sub.int          ;   [-]         ;  int subtraction
    sub.frac, @@sub.frac, 2, 1, ,\                      ;  sub.frac         ;   {-}         ;  frac subtraction
    sub.round, @@sub.round, 2, 1, ,\                    ;  sub.round        ;   <->         ;  round subtraction
    subr, @@subr, 2, 1, ,\                              ;  subr             ;   ~-          ;  reverse subtraction
    subr.pos, @@subr.pos, 2, 1, ,\                      ;  subr.pos         ;   ~-+         ;  reverse positive subtraction
    subr.neg, @@subr.neg, 2, 1, ,\                      ;  subr.neg         ;   ~--         ;  reverse negative subtraction
    subr.int, @@subr.int, 2, 1, ,\                      ;  subr.int         ;   [~-]        ;  reverse int subtraction
    subr.frac, @@subr.frac, 2, 1, ,\                    ;  subr.frac        ;   {~-}        ;  reverse frac subtraction
    subr.round, @@subr.round, 2, 1, ,\                  ;  subr.round       ;   <~->        ;  reverse round subtraction
    mul, @@mul, 2, 1, ,\                                ;  mul              ;   *           ;  multiplication
    mul.pos, @@mul.pos, 2, 1, ,\                        ;  mul.pos          ;   *+          ;  positive multiplication
    mul.neg, @@mul.neg, 2, 1, ,\                        ;  mul.neg          ;   *-          ;  negative multiplication
    mul.int, @@mul.int, 2, 1, ,\                        ;  mul.int          ;   [*]         ;  int multiplication
    mul.frac, @@mul.frac, 2, 1, ,\                      ;  mul.frac         ;   {*}         ;  frac multiplication
    mul.round, @@mul.round, 2, 1, ,\                    ;  mul.round        ;   <*>         ;  round multiplication
    div, @@div, 2, 1, ,\                                ;  div              ;   /           ;  division
    div.pos, @@div.pos, 2, 1, ,\                        ;  div.pos          ;   /+          ;  positive division
    div.neg, @@div.neg, 2, 1, ,\                        ;  div.neg          ;   /-          ;  negative division
    div.int, @@div.int, 2, 1, ,\                        ;  div.int          ;   [/]         ;  int division
    div.frac, @@div.frac, 2, 1, ,\                      ;  div.frac         ;   {/}         ;  frac division
    div.round, @@div.round, 2, 1, ,\                    ;  div.round        ;   </>         ;  round division
    divr, @@divr, 2, 1, ,\                              ;  divr             ;   ~/          ;  reverse division
    divr.pos, @@divr.pos, 2, 1, ,\                      ;  divr.pos         ;   ~/+         ;  reverse positive division
    divr.neg, @@divr.neg, 2, 1, ,\                      ;  divr.neg         ;   ~/-         ;  reverse negative division
    divr.int, @@divr.int, 2, 1, ,\                      ;  divr.int         ;   [~/]        ;  reverse int division
    divr.frac, @@divr.frac, 2, 1, ,\                    ;  divr.frac        ;   {~/}        ;  reverse frac division
    divr.round, @@divr.round, 2, 1, ,\                  ;  divr.round       ;   <~/>        ;  reverse round division
    quo, @@quo, 2, 1, ,\                                ;  quo              ;   \           ;  quotient
    quo.pos, @@quo.pos, 2, 1, ,\                        ;  quo.pos          ;   \+          ;  positive quotient
    quo.neg, @@quo.neg, 2, 1, ,\                        ;  quo.neg          ;   \-          ;  negative quotient
    quo.int, @@quo.int, 2, 1, ,\                        ;  quo.int          ;   [\]         ;  int quotient
    quo.frac, @@quo.frac, 2, 1, ,\                      ;  quo.frac         ;   {\}         ;  frac quotient
    quo.round, @@quo.round, 2, 1, ,\                    ;  quo.round        ;   <\>         ;  round quotient
    quor, @@quor, 2, 1, ,\                              ;  quor             ;   ~\          ;  reverse quotient
    quor.pos, @@quor.pos, 2, 1, ,\                      ;  quor.pos         ;   ~\+         ;  reverse positive quotient
    quor.neg, @@quor.neg, 2, 1, ,\                      ;  quor.neg         ;   ~\-         ;  reverse negative quotient
    quor.int, @@quor.int, 2, 1, ,\                      ;  quor.int         ;   [~\]        ;  reverse int quotient
    quor.frac, @@quor.frac, 2, 1, ,\                    ;  quor.frac        ;   {~\}        ;  reverse frac quotient
    quor.round, @@quor.round, 2, 1, ,\                  ;  quor.round       ;   <~\>        ;  reverse round quotient
    mod, @@mod, 2, 1, ,\                                ;  mod              ;   %           ;  remainder
    mod.pos, @@mod.pos, 2, 1, ,\                        ;  mod.pos          ;   %+          ;  positive remainder
    mod.neg, @@mod.neg, 2, 1, ,\                        ;  mod.neg          ;   %-          ;  negative remainder
    mod.int, @@mod.int, 2, 1, ,\                        ;  mod.int          ;   [%]         ;  int remainder
    mod.frac, @@mod.frac, 2, 1, ,\                      ;  mod.frac         ;   {%}         ;  frac remainder
    mod.round, @@mod.round, 2, 1, ,\                    ;  mod.round        ;   <%>         ;  round remainder
    modr, @@modr, 2, 1, ,\                              ;  modr             ;   ~%          ;  reverse remainder
    modr.pos, @@modr.pos, 2, 1, ,\                      ;  modr.pos         ;   ~%+         ;  reverse positive remainder
    modr.neg, @@modr.neg, 2, 1, ,\                      ;  modr.neg         ;   ~%-         ;  reverse negative remainder
    modr.int, @@modr.int, 2, 1, ,\                      ;  modr.int         ;   [~%]        ;  reverse int remainder
    modr.frac, @@modr.frac, 2, 1, ,\                    ;  modr.frac        ;   {~%}        ;  reverse frac remainder
    modr.round, @@modr.round, 2, 1, ,\                  ;  modr.round       ;   <~%>        ;  reverse round remainder
    quo.mod, @@quo.mod, 2, 2, ,\                        ;  quo.mod          ;   \%          ;  quotient and remainder
    co.quo.mod, @@co.quo.mod, 4, 1, 's',\               ;  co.quo.mod       ;               ;  quotient and remainder
    mod.quo, @@mod.quo, 2, 2, ,\                        ;  mod.quo          ;   %\          ;  remainder and quotient
    co.mod.quo, @@co.mod.quo, 4, 1, 's',\               ;  co.mod.quo       ;               ;  remainder and quotient
    fmadd132, @@fmadd132, 3, 1, ,\                      ;  fmadd132         ;               ;  fused multiply-add               :  x*z+y
    fmadd213, @@fmadd213, 3, 1, ,\                      ;  fmadd213         ;               ;  fused multiply-add               :  x*y+z
    fmadd231, @@fmadd231, 3, 1, ,\                      ;  fmadd231         ;               ;  fused multiply-add               :  y*z+x
    fnmadd132, @@fnmadd132, 3, 1, ,\                    ;  fnmadd132        ;               ;  fused negative multiply-add      : -x*z+y
    fnmadd213, @@fnmadd213, 3, 1, ,\                    ;  fnmadd213        ;               ;  fused negative multiply-add      : -x*y+z
    fnmadd231, @@fnmadd231, 3, 1, ,\                    ;  fnmadd231        ;               ;  fused negative multiply-add      : -y*z+x
    fmsub132, @@fmsub132, 3, 1, ,\                      ;  fmsub132         ;               ;  fused multiply-subtract          :  x*z-y
    fmsub213, @@fmsub213, 3, 1, ,\                      ;  fmsub213         ;               ;  fused multiply-subtract          :  x*y-z
    fmsub231, @@fmsub231, 3, 1, ,\                      ;  fmsub231         ;               ;  fused multiply-subtract          :  y*z-x
    fnmsub132, @@fnmsub132, 3, 1, ,\                    ;  fnmsub132        ;               ;  fused negative multiply-subtract : -x*z-y
    fnmsub213, @@fnmsub213, 3, 1, ,\                    ;  fnmsub213        ;               ;  fused negative multiply-subtract : -x*y-z
    fnmsub231, @@fnmsub231, 3, 1, ,\                    ;  fnmsub231        ;               ;  fused negative multiply-subtract : -y*z-x
    add.mul, @@add.mul, 3, 1, ,\                        ;  add.mul          ;               ;  z+x*y, add  & mul
    add.div, @@add.div, 3, 1, ,\                        ;  add.div          ;               ;  z+x/y, add  & div
    add.divr, @@add.divr, 3, 1, ,\                      ;  add.divr         ;               ;  z+y/x, add  & divr
    sub.mul, @@sub.mul, 3, 1, ,\                        ;  sub.mul          ;               ;  z-x*y, sub  & mul
    sub.div, @@sub.div, 3, 1, ,\                        ;  sub.div          ;               ;  z-x/y, sub  & div
    sub.divr, @@sub.divr, 3, 1, ,\                      ;  sub.divr         ;               ;  z-y/x, sub  & divr
    subr.mul, @@subr.mul, 3, 1, ,\                      ;  subr.mul         ;               ;  x*y-z, subr & mul
    subr.div, @@subr.div, 3, 1, ,\                      ;  subr.div         ;               ;  x/y-z, subr & div
    subr.divr, @@subr.divr, 3, 1, ,\                    ;  subr.divr        ;               ;  y/x-z, subr & divr
    mul.add, @@mul.add, 3, 1, ,\                        ;  mul.add          ;               ;  x*y+z, mul  & add
    mul.sub, @@mul.sub, 3, 1, ,\                        ;  mul.sub          ;               ;  x*y-z, mul  & sub
    mul.subr, @@mul.subr, 3, 1, ,\                      ;  mul.subr         ;               ;  z-x*y, mul  & subr
    div.add, @@div.add, 3, 1, ,\                        ;  div.add          ;               ;  x/y+z, div  & add
    div.sub, @@div.sub, 3, 1, ,\                        ;  div.sub          ;               ;  x/y-z, div  & sub
    div.subr, @@div.subr, 3, 1, ,\                      ;  div.subr         ;               ;  z-x/y, div  & subr
    divr.add, @@divr.add, 3, 1, ,\                      ;  divr.add         ;               ;  y/x+z, divr & add
    divr.sub, @@divr.sub, 3, 1, ,\                      ;  divr.sub         ;               ;  y/x-z, divr & sub
    divr.subr, @@divr.subr, 3, 1, ,\                    ;  divr.subr        ;               ;  z-y/x, divr & subr
    trunc, @@trunc, 1, 'i', ,\                          ;  trunc            ;               ;  integer part of x
    int, @@int, 1, 1, ,\                                ;  int              ;   [x]         ;  integer part of x
    intto, @@intto, 2, 1, ,\                            ;  intto            ;   [x,n]       ;  trunc x to a specified power of ten
    deintto, @@deintto, 2, 1, ,\                        ;  deintto          ;               ;  intto delta
    frac, @@frac, 1, 1, ,\                              ;  frac             ;   {x}         ;  fractional part of x
    fracto, @@fracto, 2, 1, ,\                          ;  fracto           ;   {x,n}       ;  frac x to a specified power of ten
    defracto, @@defracto, 2, 1, ,\                      ;  defracto         ;               ;  fracto delta
    round, @@round, 1, 1, ,\                            ;  round            ;   <x>         ;  round x to the nearest integer number, round half away from zero
    deround, @@deround, 1, 1, ,\                        ;  deround          ;               ;  round delta
    roundto, @@roundto, 2, 1, ,\                        ;  roundto          ;   <x,n>       ;  round x to a specified power of ten
    deroundto, @@deroundto, 2, 1, ,\                    ;  deroundto        ;               ;  roundto delta
    rint, @@rint, 1, 1, ,\                              ;  rint             ;               ;  round to integer
    frndint, @@rint, 1, 1, ,\                           ;  frndint          ;               ;  round to integer
    rheven, @@rheven, 1, 1, ,\                          ;  rheven           ;               ;  round x to the nearest integer number, round half to even
    derheven, @@derheven, 1, 1, ,\                      ;  derheven         ;               ;  rheven delta
    rhodd, @@rhodd, 1, 1, ,\                            ;  rhodd            ;               ;  round x to the nearest integer number, round half to odd
    derhodd, @@derhodd, 1, 1, ,\                        ;  derhodd          ;               ;  rhodd delta
    rzero, @@rzero, 1, 1, ,\                            ;  rzero            ;               ;  round x toward zero
    derzero, @@derzero, 1, 1, ,\                        ;  derzero          ;               ;  rzero delta
    rinf, @@rinf, 1, 1, ,\                              ;  rinf             ;               ;  round x toward infinity
    derinf, @@derinf, 1, 1, ,\                          ;  derinf           ;               ;  rinf delta
    rpinf, @@rpinf, 1, 1, ,\                            ;  rpinf            ;               ;  round x toward +infinity
    derpinf, @@derpinf, 1, 1, ,\                        ;  derpinf          ;               ;  rpinf delta
    rninf, @@rninf, 1, 1, ,\                            ;  rninf            ;               ;  round x toward -infinity
    derninf, @@derninf, 1, 1, ,\                        ;  derninf          ;               ;  rninf delta
    ceil, @@rpinf, 1, 1, ,\                             ;  ceil             ;               ;  integer ceiling
    deceil, @@derpinf, 1, 1, ,\                         ;  deceil           ;               ;  ceil delta
    floor, @@rninf, 1, 1, ,\                            ;  floor            ;               ;  integer floor
    defloor, @@derninf, 1, 1, ,\                        ;  defloor          ;               ;  floor delta
    avg, @@mean, 2, 1, ,\                               ;  avg              ;   |A| |+|     ;  arithmetic average of two values
    mean, @@mean, 2, 1, ,\                              ;  mean             ;   |A| |+|     ;  arithmetic average of two values
    gavg, @@gmean, 2, 1, ,\                             ;  gavg             ;   |G| |*|     ;  geometric average of two values
    gmean, @@gmean, 2, 1, ,\                            ;  gmean            ;   |G| |*|     ;  geometric average of two values
    havg, @@hmean, 2, 1, ,\                             ;  havg             ;   |H| |/|     ;  harmonic average of two values
    hmean, @@hmean, 2, 1, ,\                            ;  hmean            ;   |H| |/|     ;  harmonic average of two values
    chavg, @@chmean, 2, 1, ,\                           ;  chavg            ;   |C| |\|     ;  contraharmonic average of two values
    chmean, @@chmean, 2, 1, ,\                          ;  chmean           ;   |C| |\|     ;  contraharmonic average of two values
    qavg, @@qmean, 2, 1, ,\                             ;  qavg             ;   |Q|         ;  quadratic average of two values
    qmean, @@qmean, 2, 1, ,\                            ;  qmean            ;   |Q|         ;  quadratic average of two values
    heavg, @@hemean, 2, 1, ,\                           ;  heavg            ;   |h|         ;  heronian average of two values
    hemean, @@hemean, 2, 1, ,\                          ;  hemean           ;   |h|         ;  heronian average of two values
    ceavg, @@cemean, 2, 1, ,\                           ;  ceavg            ;   |c|         ;  centroidal average of two values
    cemean, @@cemean, 2, 1, ,\                          ;  cemean           ;   |c|         ;  centroidal average of two values
    min, @@min, 2, 1, ,\                                ;  min              ;   ?<          ;  the smaller of two values
    max, @@max, 2, 1, ,\                                ;  max              ;   ?>          ;  the larger of two values
    minmax, @@minmax, 2, 2, ,\                          ;  minmax           ;   ?<>         ;  the smaller and the larger of two values
    co.minmax, @@co.minmax, 4, 1, 's',\                 ;  co.minmax        ;               ;  the smaller and the larger of two values
    maxmin, @@maxmin, 2, 2, ,\                          ;  maxmin           ;   ?><         ;  the larger and the smaller of two values
    co.maxmin, @@co.maxmin, 4, 1, 's',\                 ;  co.maxmin        ;               ;  the larger and the smaller of two values
    adev, @@adev, 2, 1, ,\                              ;  adev             ;               ;  absolute deviation: abs(x-y)
    nadev, @@nadev, 2, 1, ,\                            ;  nadev            ;               ;  negative absolute deviation: -abs(x-y)
    min.adev, @@min.adev, 3, 1, ,\                      ;  min.adev         ;               ;  the smaller absolute deviation
    minl.adev, @@minl.adev, 3, 1, ,\                    ;  minl.adev        ;               ;  the value with the smaller absolute deviation, prefer argument with a lower index
    minh.adev, @@minh.adev, 3, 1, ,\                    ;  minh.adev        ;               ;  the value with the smaller absolute deviation, prefer argument with a higher index
    max.adev, @@max.adev, 3, 1, ,\                      ;  max.adev         ;               ;  the larger absolute deviation
    maxl.adev, @@maxl.adev, 3, 1, ,\                    ;  maxl.adev        ;               ;  the value with the larger absolute deviation, prefer argument with a lower index
    maxh.adev, @@maxh.adev, 3, 1, ,\                    ;  maxh.adev        ;               ;  the value with the larger absolute deviation, prefer argument with a higher index
    xsigny, @@xsigny, 2, 1, ,\                          ;  xsigny           ;               ;  the magnitude of x and the sign of y
    ysignx, @@ysignx, 2, 1, ,\                          ;  ysignx           ;               ;  the magnitude of y and the sign of x
    xcosign, @@xcosign, 2, 1, ,\                        ;  xcosign          ;               ;  the magnitude of x and the sign of sign(x)*sign(y)
    ycosign, @@ycosign, 2, 1, ,\                        ;  ycosign          ;               ;  the magnitude of y and the sign of sign(x)*sign(y)
    clamp, @@clamp, 3, 1, ,\                            ;  clamp            ;               ;  clamp x in range between min and max
    saturate, @@saturate, 1, 1, ,\                      ;  saturate         ;               ;  clamp x in range between 0 and 1
    lineco, @@lineco, 4, 2, ,\                          ;  lineco           ;               ;  coefficients of linear function
    co.lineco, @@co.lineco, 6, 1, 's',\                 ;  co.lineco        ;               ;  coefficients of linear function
    rescale, @@rescale, 5, 1, ,\                        ;  rescale          ;               ;  rescale
    resclip, @@resclip, 5, 1, ,\                        ;  resclip          ;               ;  rescale with clipping
    delta, @@delta, 2, 1, ,\                            ;  delta            ;               ;  delta function
    deltab, @@deltab, 3, 1, ,\                          ;  deltab           ;               ;  deltab function
    teta, @@teta, 2, 1, ,\                              ;  teta             ;               ;  teta function
    tetae, @@tetae, 2, 1, ,\                            ;  tetae            ;               ;  tetae function
    cycle, @@cycle, 3, 1, ,\                            ;  cycle            ;               ;  cycle function
    gcd, @@gcd, 2, 1, ,\                                ;  gcd              ;               ;  greatest common divisor
    hcf, @@gcd, 2, 1, ,\                                ;  hcf              ;               ;  highest common factor
    lcm, @@lcm, 2, 1, ,\                                ;  lcm              ;               ;  least common multiple
    igcd, @@igcd, 2, 'i', '-',\                         ;  igcd             ;               ;  greatest common divisor
    ihcf, @@igcd, 2, 'i', '-',\                         ;  ihcf             ;               ;  highest common factor
    ilcm, @@ilcm, 2, 'i', '-',\                         ;  ilcm             ;               ;  least common multiple
    percent.mul, @@percent.mul, 2, 1, ,\                ;  percent.mul      ;    *%         ;  what is x percent of y: (x*y)/100
    percent.div, @@percent.div, 2, 1, ,\                ;  percent.div      ;    /%         ;  x is what percent of y: (x/y)*100
    percent.divr, @@percent.divr, 2, 1, ,\              ;  percent.divr     ;   ~/%         ;  y is what percent of x: (y/x)*100
    percent.inc, @@percent.inc, 2, 1, ,\                ;  percent.inc      ;    +%         ;  what is the percentage increase from x to y: [(y-x)/x]*100
    percent.incr, @@percent.incr, 2, 1, ,\              ;  percent.incr     ;   ~+%         ;  what is the percentage increase from y to x: [(x-y)/y]*100
    percent.dec, @@percent.dec, 2, 1, ,\                ;  percent.dec      ;    -%         ;  what is the percentage decrease from x to y: [(x-y)/x]*100
    percent.decr, @@percent.decr, 2, 1, ,\              ;  percent.decr     ;   ~-%         ;  what is the percentage decrease from y to x: [(y-x)/y]*100
    exp, @@exp, 1, 1, ,\                                ;  exp              ;               ;  exponential function
    exp2, @@exp2, 1, 1, ,\                              ;  exp2             ;               ;  2 raised to a power of x
    pow2x, @@exp2, 1, 1, ,\                             ;  pow2x            ;               ;  2 raised to a power of x
    exp10, @@exp10, 1, 1, ,\                            ;  exp10            ;               ;  10 raised to a power of x
    pow10x, @@exp10, 1, 1, ,\                           ;  pow10x           ;               ;  10 raised to a power of x
    fexp, @@fexp, 1, 1, ,\                              ;  fexp             ;               ;  e^x
    fexp2, @@fexp2, 1, 1, ,\                            ;  fexp2            ;               ;  2^x
    fpow2x, @@fexp2, 1, 1, ,\                           ;  fpow2x           ;               ;  2^x
    fexp10, @@fexp10, 1, 1, ,\                          ;  fexp10           ;               ;  10^x
    fpow10x, @@fexp10, 1, 1, ,\                         ;  fpow10x          ;               ;  10^x
    lb, @@log2, 1, 1, ,\                                ;  lb               ;               ;  base-2 logarithm
    log2, @@log2, 1, 1, ,\                              ;  log2             ;               ;  base-2 logarithm
    ln, @@ln, 1, 1, ,\                                  ;  ln               ;               ;  natural logarithm
    loge, @@ln, 1, 1, ,\                                ;  loge             ;               ;  natural logarithm
    lg, @@log10, 1, 1, ,\                               ;  lg               ;               ;  base-10 logarithm
    log10, @@log10, 1, 1, ,\                            ;  log10            ;               ;  base-10 logarithm
    logn, @@logn, 2, 1, ,\                              ;  logn             ;               ;  base-n logarithm
    lognr, @@lognr, 2, 1, ,\                            ;  lognr            ;               ;  reverse base-n logarithm
    flb, @@flog2, 1, 1, ,\                              ;  flb              ;               ;  base-2 logarithm
    flog2, @@flog2, 1, 1, ,\                            ;  flog2            ;               ;  base-2 logarithm
    fln, @@floge, 1, 1, ,\                              ;  fln              ;               ;  natural logarithm
    floge, @@floge, 1, 1, ,\                            ;  floge            ;               ;  natural logarithm
    flg, @@flog10, 1, 1, ,\                             ;  flg              ;               ;  base-10 logarithm
    flog10, @@flog10, 1, 1, ,\                          ;  flog10           ;               ;  base-10 logarithm
    flogn, @@flogn, 2, 1, ,\                            ;  flogn            ;               ;  base-n logarithm
    flognr, @@flognr, 2, 1, ,\                          ;  flognr           ;               ;  reverse base-n logarithm
    pow, @@pow, 2, 1, ,\                                ;  pow              ;   ^ **        ;  power function
    power, @@pow, 2, 1, ,\                              ;  power            ;   ^ **        ;  power function
    apow, @@apow, 2, 1, ,\                              ;  apow             ;               ;  power function
    apower, @@apow, 2, 1, ,\                            ;  apower           ;               ;  power function
    powr, @@powr, 2, 1, ,\                              ;  powr             ;   ~^ ~**      ;  reverse power function
    powerr, @@powr, 2, 1, ,\                            ;  powerr           ;   ~^ ~**      ;  reverse power function
    apowr, @@apowr, 2, 1, ,\                            ;  apowr            ;               ;  reverse power function
    apowerr, @@apowr, 2, 1, ,\                          ;  apowerr          ;               ;  reverse power function
    ipow, @@ipow, 2, 1, ,\                              ;  ipow             ;               ;  integer power function
    ipower, @@ipow, 2, 1, ,\                            ;  ipower           ;               ;  integer power function
    pow2, @@pow2, 1, 1, ,\                              ;  pow2             ;               ;  value raised to a power of 2
    sqr, @@pow2, 1, 1, ,\                               ;  sqr              ;               ;  value raised to a power of 2
    pow3, @@pow3, 1, 1, ,\                              ;  pow3             ;               ;  value raised to a power of 3
    cube, @@pow3, 1, 1, ,\                              ;  cube             ;               ;  value raised to a power of 3
    pow4, @@pow4, 1, 1, ,\                              ;  pow4             ;               ;  value raised to a power of 4
    root, @@root, 2, 1, ,\                              ;  root             ;    */         ;  x^(1/y) root function
    rootr, @@rootr, 2, 1, ,\                            ;  rootr            ;   ~*/         ;  y^(1/x) reverse root function
    root2, @@root2, 1, 1, ,\                            ;  root2            ;               ;  x^(1/2) square root
    sqrt, @@root2, 1, 1, ,\                             ;  sqrt             ;               ;  x^(1/2) square root
    root3, @@root3, 1, 1, ,\                            ;  root3            ;               ;  x^(1/3) cubic root
    cbrt, @@root3, 1, 1, ,\                             ;  cbrt             ;               ;  x^(1/3) cubic root
    root4, @@root4, 1, 1, ,\                            ;  root4            ;               ;  x^(1/4) root function
    hypot, @@hypot, -2, 1, ,\                           ;  hypot            ;               ;  hypotenuse (pythagoras)
    hyp, @@hypot, -2, 1, ,\                             ;  hyp              ;               ;  hypotenuse (pythagoras)
    hypot3, @@hypot3, 3, 1, ,\                          ;  hypot3           ;               ;
    hyp3, @@hypot3, 3, 1, ,\                            ;  hyp3             ;               ;
    fpow, @@fpow, 2, 1, ,\                              ;  fpow             ;               ;  x^y
    fpower, @@fpow, 2, 1, ,\                            ;  fpower           ;               ;  x^y
    fapow, @@fapow, 2, 1, ,\                            ;  fapow            ;               ;  power function
    fapower, @@fapow, 2, 1, ,\                          ;  fapower          ;               ;  power function
    fpowr, @@fpowr, 2, 1, ,\                            ;  fpowr            ;               ;  y^x
    fpowerr, @@fpowr, 2, 1, ,\                          ;  fpowerr          ;               ;  y^x
    fapowr, @@fapowr, 2, 1, ,\                          ;  fapowr           ;               ;  reverse power function
    fapowerr, @@fapowr, 2, 1, ,\                        ;  fapowerr         ;               ;  reverse power function
    sin, @@sin, 1, 1, ,\                                ;  sin              ;               ;  sine
    cos, @@cos, 1, 1, ,\                                ;  cos              ;               ;  cosine
    sincos, @@sincos, 1, 2, ,\                          ;  sincos           ;               ;  sine & cosine
    co.sincos, @@co.sincos, 3, 1, 's',\                 ;  co.sincos        ;               ;  sine & cosine
    cossin, @@cossin, 1, 2, ,\                          ;  cossin           ;               ;  cosine & sine
    co.cossin, @@co.cossin, 3, 1, 's',\                 ;  co.cossin        ;               ;  cosine & sine
    sec, @@sec, 1, 1, ,\                                ;  sec              ;               ;  secant
    csc, @@csc, 1, 1, ,\                                ;  csc              ;               ;  cosecant
    cosec, @@csc, 1, 1, ,\                              ;  cosec            ;               ;  cosecant
    tan, @@tan, 1, 1, ,\                                ;  tan              ;               ;  tangent
    tg, @@tan, 1, 1, ,\                                 ;  tg               ;               ;  tangent
    cotan, @@cotan, 1, 1, ,\                            ;  cotan            ;               ;  cotangent
    ctg, @@cotan, 1, 1, ,\                              ;  ctg              ;               ;  cotangent
    cot, @@cotan, 1, 1, ,\                              ;  cot              ;               ;  cotangent
    fsin, @@fsin, 1, 1, ,\                              ;  fsin             ;               ;  sine
    fsinpi, @@fsinpi, 1, 1, ,\                          ;  fsin2pi          ;               ;  sine (pi*x)
    fcos, @@fcos, 1, 1, ,\                              ;  fcos             ;               ;  cosine
    fcospi, @@fcospi, 1, 1, ,\                          ;  fcos2pi          ;               ;  cosine (pi*x)
    fsincos, @@fsincos, 1, 2, ,\                        ;  fsincos          ;               ;  sine & cosine
    fsincospi, @@fsincospi, 1, 2, ,\                    ;  fsincos2pi       ;               ;  sine & cosine (pi*x)
    co.fsincos, @@co.fsincos, 3, 1, 's',\               ;  co.fsincos       ;               ;  sine & cosine
    co.fsincospi, @@co.fsincospi, 3, 1, 's',\           ;  co.fsincos2pi    ;               ;  sine & cosine (pi*x)
    fcossin, @@fcossin, 1, 2, ,\                        ;  fcossin          ;               ;  cosine & sine
    fcossinpi, @@fcossinpi, 1, 2, ,\                    ;  fcossinpi        ;               ;  cosine & sine (pi*x)
    co.fcossin, @@co.fcossin, 3, 1, 's',\               ;  co.fcossin       ;               ;  cosine & sine
    co.fcossinpi, @@co.fcossinpi, 3, 1, 's',\           ;  co.fcossinpi     ;               ;  cosine & sine (pi*x)
    fsec, @@fsec, 1, 1, ,\                              ;  fsec             ;               ;  secant
    fsecpi, @@fsecpi, 1, 1, ,\                          ;  fsecpi           ;               ;  secant (pi*x)
    fcsc, @@fcosec, 1, 1, ,\                            ;  fcsc             ;               ;  cosecant
    fcosec, @@fcosec, 1, 1, ,\                          ;  fcosec           ;               ;  cosecant
    fcscpi, @@fcosecpi, 1, 1, ,\                        ;  fcscpi           ;               ;  cosecant (pi*x)
    fcosecpi, @@fcosecpi, 1, 1, ,\                      ;  fcosecpi         ;               ;  cosecant (pi*x)
    ftan, @@ftan, 1, 1, ,\                              ;  ftan             ;               ;  tangent
    ftanpi, @@ftanpi, 1, 1, ,\                          ;  ftanpi           ;               ;  tangent (pi*x)
    fcot, @@fcotan, 1, 1, ,\                            ;  fcot             ;               ;  cotangent
    fcotan, @@fcotan, 1, 1, ,\                          ;  fcotan           ;               ;  cotangent
    fcotpi, @@fcotanpi, 1, 1, ,\                        ;  fcotpi           ;               ;  cotangent (pi*x)
    fcotanpi, @@fcotanpi, 1, 1, ,\                      ;  fcotanpi         ;               ;  cotangent (pi*x)
    covercos, @@covercosine, 1, 1, ,\                   ;  covercos         ;               ;  coversed cosine
    coverc, @@covercosine, 1, 1, ,\                     ;  coverc           ;               ;  coversed cosine
    cvc, @@covercosine, 1, 1, ,\                        ;  cvc              ;               ;  coversed cosine
    coversin, @@coversine, 1, 1, ,\                     ;  coversin         ;               ;  coversed sine
    covers, @@coversine, 1, 1, ,\                       ;  covers           ;               ;  coversed sine
    cvs, @@coversine, 1, 1, ,\                          ;  cvs              ;               ;  coversed sine
    vercos, @@vercosine, 1, 1, ,\                       ;  vercos           ;               ;  versed cosine
    verc, @@vercosine, 1, 1, ,\                         ;  verc             ;               ;  versed cosine
    versin, @@versine, 1, 1, ,\                         ;  versin           ;               ;  versed sine
    vers, @@versine, 1, 1, ,\                           ;  vers             ;               ;  versed sine
    havercos, @@havercosine, 1, 1, ,\                   ;  havercos         ;               ;  haversed cosine
    haverc, @@havercosine, 1, 1, ,\                     ;  haverc           ;               ;  haversed cosine
    hvc, @@havercosine, 1, 1, ,\                        ;  hvc              ;               ;  haversed cosine
    haversin, @@haversine, 1, 1, ,\                     ;  haversin         ;               ;  haversed sine
    havers, @@haversine, 1, 1, ,\                       ;  havers           ;               ;  haversed sine
    hvs, @@haversine, 1, 1, ,\                          ;  hvs              ;               ;  haversed sine
    hacovercos, @@hacovercosine, 1, 1, ,\               ;  hacovercos       ;               ;  hacoversed cosine
    hacoverc, @@hacovercosine, 1, 1, ,\                 ;  hacoverc         ;               ;  hacoversed cosine
    hcc, @@hacovercosine, 1, 1, ,\                      ;  hcc              ;               ;  hacoversed cosine
    hacoversin, @@hacoversine, 1, 1, ,\                 ;  hacoversin       ;               ;  hacoversed sine
    hacovers, @@hacoversine, 1, 1, ,\                   ;  hacovers         ;               ;  hacoversed sine
    hcs, @@hacoversine, 1, 1, ,\                        ;  hcs              ;               ;  hacoversed sine
    excsc, @@excsc, 1, 1, ,\                            ;  excsc            ;               ;  excosecant
    excosec, @@excsc, 1, 1, ,\                          ;  excosec          ;               ;  excosecant
    exsec, @@exsec, 1, 1, ,\                            ;  exsec            ;               ;  exsecant
    acos, @@acos, 1, 1, ,\                              ;  acos             ;               ;  inverse cosine
    arccos, @@acos, 1, 1, ,\                            ;  arccos           ;               ;  inverse cosine
    asin, @@asin, 1, 1, ,\                              ;  asin             ;               ;  inverse sine
    arcsin, @@asin, 1, 1, ,\                            ;  arcsin           ;               ;  inverse sine
    acsc, @@acsc, 1, 1, ,\                              ;  acsc             ;               ;  inverse cosecant
    acosec, @@acsc, 1, 1, ,\                            ;  acosec           ;               ;  inverse cosecant
    arccsc, @@acsc, 1, 1, ,\                            ;  arccsc           ;               ;  inverse cosecant
    arccosec, @@acsc, 1, 1, ,\                          ;  arccosec         ;               ;  inverse cosecant
    asec, @@asec, 1, 1, ,\                              ;  asec             ;               ;  inverse secant
    arcsec, @@asec, 1, 1, ,\                            ;  arcsec           ;               ;  inverse secant
    acotan, @@acotan, 1, 1, ,\                          ;  acotan           ;               ;  inverse cotangent
    acot, @@acotan, 1, 1, ,\                            ;  acot             ;               ;  inverse cotangent
    arcctg, @@acotan, 1, 1, ,\                          ;  arcctg           ;               ;  inverse cotangent
    arccotan, @@acotan, 1, 1, ,\                        ;  arccotan         ;               ;  inverse cotangent
    arccot, @@acotan, 1, 1, ,\                          ;  arccot           ;               ;  inverse cotangent
    atan, @@atan, 1, 1, ,\                              ;  atan             ;               ;  inverse tangent
    arctg, @@atan, 1, 1, ,\                             ;  arctg            ;               ;  inverse tangent
    arctan, @@atan, 1, 1, ,\                            ;  arctan           ;               ;  inverse tangent
    atan2, @@atan2, 2, 1, ,\                            ;  atan2            ;               ;  inverse tangent of y/x
    arctg2, @@atan2, 2, 1, ,\                           ;  arctg2           ;               ;  inverse tangent of y/x
    arctan2, @@atan2, 2, 1, ,\                          ;  arctan2          ;               ;  inverse tangent of y/x
    atan2r, @@atan2r, 2, 1, ,\                          ;  atan2r           ;               ;  inverse tangent of y/x
    arctg2r, @@atan2r, 2, 1, ,\                         ;  arctg2r          ;               ;  inverse tangent of y/x
    arctan2r, @@atan2r, 2, 1, ,\                        ;  arctan2r         ;               ;  inverse tangent of y/x
    fasin, @@fasin, 1, 1, ,\                            ;  fasin            ;               ;  inverse sine
    facos, @@facos, 1, 1, ,\                            ;  facos            ;               ;  inverse cosine
    fasec, @@fasec, 1, 1, ,\                            ;  fasec            ;               ;  inverse secant
    facsc, @@facosec, 1, 1, ,\                          ;  facsc            ;               ;  inverse cosecant
    facosec, @@facosec, 1, 1, ,\                        ;  facosec          ;               ;  inverse cosecant
    fatan, @@fatan, 1, 1, ,\                            ;  fatan            ;               ;  inverse tangent
    fatan2, @@fatan2, 2, 1, ,\                          ;  fatan2           ;               ;  inverse tangent of y/x
    fatan2r, @@fatan2r, 2, 1, ,\                        ;  fatan2r          ;               ;  inverse tangent of y/x
    facot, @@facotan, 1, 1, ,\                          ;  facot            ;               ;  inverse cotangent
    facotan, @@facotan, 1, 1, ,\                        ;  facotan          ;               ;  inverse cotangent
    sh, @@sh, 1, 1, ,\                                  ;  sh               ;               ;  hyperbolic sine
    sinh, @@sh, 1, 1, ,\                                ;  sinh             ;               ;  hyperbolic sine
    ch, @@ch, 1, 1, ,\                                  ;  ch               ;               ;  hyperbolic cosine
    cosh, @@ch, 1, 1, ,\                                ;  cosh             ;               ;  hyperbolic cosine
    shch, @@shch, 1, 2, ,\                              ;  shch             ;               ;  hyperbolic sine and cosine
    co.shch, @@co.shch, 3, 1, 's',\                     ;  co.shch          ;               ;  hyperbolic sine and cosine
    chsh, @@chsh, 1, 2, ,\                              ;  chsh             ;               ;  hyperbolic cosine and sine
    co.chsh, @@co.chsh, 3, 1, 's',\                     ;  co.chsh          ;               ;  hyperbolic cosine and sine
    sch, @@sch, 1, 1, ,\                                ;  sch              ;               ;  hyperbolic secant
    sech, @@sch, 1, 1, ,\                               ;  sech             ;               ;  hyperbolic secant
    csh, @@csh, 1, 1, ,\                                ;  csh              ;               ;  hyperbolic cosecant
    csch, @@csh, 1, 1, ,\                               ;  csch             ;               ;  hyperbolic cosecant
    cosech, @@csh, 1, 1, ,\                             ;  cosech           ;               ;  hyperbolic cosecant
    th, @@th, 1, 1, ,\                                  ;  th               ;               ;  hyperbolic tangent
    tanh, @@th, 1, 1, ,\                                ;  tanh             ;               ;  hyperbolic tangent
    cth, @@cth, 1, 1, ,\                                ;  cth              ;               ;  hyperbolic cotangent
    coth, @@cth, 1, 1, ,\                               ;  coth             ;               ;  hyperbolic cotangent
    cotanh, @@cth, 1, 1, ,\                             ;  cotanh           ;               ;  hyperbolic cotangent
    fsh, @@fsinh, 1, 1, ,\                              ;  fsh              ;               ;  hyperbolic sine
    fsinh, @@fsinh, 1, 1, ,\                            ;  fsinh            ;               ;  hyperbolic sine
    fch, @@fcosh, 1, 1, ,\                              ;  fch              ;               ;  hyperbolic cosine
    fcosh, @@fcosh, 1, 1, ,\                            ;  fcosh            ;               ;  hyperbolic cosine
    fshch, @@fshch, 1, 2, ,\                            ;  fshch            ;               ;  hyperbolic sine and cosine
    co.fshch, @@co.fshch, 3, 1, 's',\                   ;  co.fshch         ;               ;  hyperbolic sine and cosine
    fchsh, @@fchsh, 1, 2, ,\                            ;  fchsh            ;               ;  hyperbolic cosine and sine
    co.fchsh, @@co.fchsh, 3, 1, 's',\                   ;  co.fchsh         ;               ;  hyperbolic cosine and sine
    fsech, @@fsech, 1, 1, ,\                            ;  fsech            ;               ;  hyperbolic secant
    fcsch, @@fcosech, 1, 1, ,\                          ;  fcsch            ;               ;  hyperbolic cosecant
    fcosech, @@fcosech, 1, 1, ,\                        ;  fcosech          ;               ;  hyperbolic cosecant
    ftanh, @@ftanh, 1, 1, ,\                            ;  ftanh            ;               ;  hyperbolic tangent
    fcoth, @@fcotanh, 1, 1, ,\                          ;  fcoth            ;               ;  hyperbolic cotangent
    fcotanh, @@fcotanh, 1, 1, ,\                        ;  fcotanh          ;               ;  hyperbolic cotangent
    arsh, @@arsh, 1, 1, ,\                              ;  arsh             ;               ;  inverse hyperbolic sine
    asinh, @@arsh, 1, 1, ,\                             ;  asinh            ;               ;  inverse hyperbolic sine
    arch, @@arch, 1, 1, ,\                              ;  arch             ;               ;  inverse hyperbolic cosine
    acosh, @@arch, 1, 1, ,\                             ;  acosh            ;               ;  inverse hyperbolic cosine
    arsch, @@arsch, 1, 1, ,\                            ;  arsch            ;               ;  inverse hyperbolic secant
    asech, @@arsch, 1, 1, ,\                            ;  asech            ;               ;  inverse hyperbolic secant
    arcsh, @@arcsh, 1, 1, ,\                            ;  arcsh            ;               ;  inverse hyperbolic cosecant
    acsch, @@arcsh, 1, 1, ,\                            ;  acsch            ;               ;  inverse hyperbolic cosecant
    acosech, @@arcsh, 1, 1, ,\                          ;  acosech          ;               ;  inverse hyperbolic cosecant
    arth, @@arth, 1, 1, ,\                              ;  arth             ;               ;  inverse hyperbolic tangent
    atanh, @@arth, 1, 1, ,\                             ;  atanh            ;               ;  inverse hyperbolic tangent
    arcth, @@arcth, 1, 1, ,\                            ;  arcth            ;               ;  inverse hyperbolic cotangent
    acoth, @@arcth, 1, 1, ,\                            ;  acoth            ;               ;  inverse hyperbolic cotangent
    acotanh, @@arcth, 1, 1, ,\                          ;  acotanh          ;               ;  inverse hyperbolic cotangent
    fasinh, @@fasinh, 1, 1, ,\                          ;  fasinh           ;               ;  inverse hyperbolic sine
    facosh, @@facosh, 1, 1, ,\                          ;  facosh           ;               ;  inverse hyperbolic cosine
    fasech, @@fasech, 1, 1, ,\                          ;  fasech           ;               ;  inverse hyperbolic secant
    facsch, @@facosech, 1, 1, ,\                        ;  facsch           ;               ;  inverse hyperbolic cosecant
    facosech, @@facosech, 1, 1, ,\                      ;  facosech         ;               ;  inverse hyperbolic cosecant
    fatanh, @@fatanh, 1, 1, ,\                          ;  fatanh           ;               ;  inverse hyperbolic tangent
    facoth, @@facotanh, 1, 1, ,\                        ;  facoth           ;               ;  inverse hyperbolic cotangent
    facotanh, @@facotanh, 1, 1, ,\                      ;  facotanh         ;               ;  inverse hyperbolic cotangent
    ccovalue, @@ccovalue, 2, 2, 's',\                   ;  ccovalue         ;               ;  complex compile-time value
    crestore, @@crestore, 2, 2, 's',\                   ;  crestore         ;               ;  assign complex compile-time value
    creset, @@creset, 2, 0, 's',\                       ;  creset           ;               ;  assign complex compile-time value
    ccopy, @@ccopy, 4, 2, 's',\                         ;  ccopy            ;               ;  copy complex to complex
    cmove, @@cmove, 4, 0, 's',\                         ;  cmove            ;               ;  copy complex to complex
    cpcopy, @@cpcopy, 3, 2, 's',\                       ;  cpcopy           ;               ;  indirect copy complex to complex
    cpmove, @@cpmove, 3, 0, 's',\                       ;  cpmove           ;               ;  indirect copy complex to complex
    cxcopy, @@cxcopy, 3, 2, 's',\                       ;  cxcopy           ;               ;  copy x to complex.re and im
    cxmove, @@cxmove, 3, 0, 's',\                       ;  cxmove           ;               ;  copy x to complex.re and im
    czcopy, @@czcopy, 2, 2, 's',\                       ;  czcopy           ;               ;  copy 0 to complex.re and im
    czmove, @@czmove, 2, 0, 's',\                       ;  czmove           ;               ;  copy 0 to complex.re and im
    crrcopy, @@crrcopy, 4, 2, 's',\                     ;  crrcopy          ;               ;  copy complex.re to complex.re
    crrmove, @@crrmove, 4, 0, 's',\                     ;  crrmove          ;               ;  copy complex.re to complex.re
    cxrcopy, @@cxrcopy, 3, 2, 's',\                     ;  cxrcopy          ;               ;  copy x to complex.re
    cxrmove, @@cxrmove, 3, 0, 's',\                     ;  cxrmove          ;               ;  copy x to complex.re
    czrcopy, @@czrcopy, 2, 2, 's',\                     ;  czrcopy          ;               ;  copy 0 to complex.re
    czrmove, @@czrmove, 2, 0, 's',\                     ;  czrmove          ;               ;  copy 0 to complex.re
    ciicopy, @@ciicopy, 4, 2, 's',\                     ;  ciicopy          ;               ;  copy complex.im to complex.im
    ciimove, @@ciimove, 4, 0, 's',\                     ;  ciimove          ;               ;  copy complex.im to complex.im
    cxicopy, @@cxicopy, 3, 2, 's',\                     ;  cxicopy          ;               ;  copy x to complex.im
    cximove, @@cximove, 3, 0, 's',\                     ;  cximove          ;               ;  copy x to complex.im
    czicopy, @@czicopy, 2, 2, 's',\                     ;  czicopy          ;               ;  copy 0 to complex.im
    czimove, @@czimove, 2, 0, 's',\                     ;  czimove          ;               ;  copy 0 to complex.im
    cswap, @@cswap, 4, 2, 's',\                         ;  cswap            ;               ;  complex swap
    cswop, @@cswop, 4, 0, 's',\                         ;  cswop            ;               ;  complex swop
    cpolar, @@cpolar, 2, 2, ,\                          ;  cpolar           ;               ;  complex polar from plane
    cplane, @@cplane, 2, 2, ,\                          ;  cplane           ;               ;  complex plane from polar
    creal, @@creal, 2, 1, ,\                            ;  creal            ;               ;  real part of complex z
    cimag, @@cimag, 2, 1, ,\                            ;  cimag            ;               ;  imaginary part of complex z
    creze, @@creze, 2, 2, ,\                            ;  creze            ;               ;  real part of complex z and zero
    czeim, @@czeim, 2, 2, ,\                            ;  czeim            ;               ;  zero and imaginary part of complex z
    czero, @@czero, 2, 2, ,\                            ;  czero            ;               ;  zero
    cvoid, @@cvoid, 2, 0, ,\                            ;  cvoid            ;               ;  void
    crere, @@crere, 4, 2, ,\                            ;  crere            ;               ;  re_1 + i•re_2
    creim, @@creim, 4, 2, ,\                            ;  creim            ;               ;  re_1 + i•im_2
    cimre, @@cimre, 4, 2, ,\                            ;  cimre            ;               ;  im_1 + i•re_2
    cimim, @@cimim, 4, 2, ,\                            ;  cimim            ;               ;  im_1 + i•im_2
    cnorm, @@cnorm, 2, 1, ,\                            ;  cnorm            ;               ;  norm value of complex z
    cnorms, @@cnorms, 4, 2, ,\                          ;  cnorms           ;               ;  norm values
    cabs, @@cabs, 2, 1, ,\                              ;  cabs             ;               ;  absolute value of complex z
    cabss, @@cabss, 4, 2, ,\                            ;  cabss            ;               ;  absolute values
    carg, @@carg, 2, 1, ,\                              ;  carg             ;               ;  argument of complex z
    cargs, @@cargs, 4, 2, ,\                            ;  cargs            ;               ;  arguments
    cconj, @@cconj, 2, 2, ,\                            ;  cconj            ;               ;  complex conjugate of z
    crconj, @@crconj, 2, 2, ,\                          ;  crconj           ;               ;  complex reversed conjugate of z
    cchs, @@cchs, 2, 2, ,\                              ;  cchs             ;               ;  change sign of complex z
    cxch, @@cxch, 2, 2, ,\                              ;  cxch             ;               ;  complex exchange
    ccis, @@ccis, 1, 2, ,\                              ;  ccis             ;               ;  complex cos + i•sin
    csign, @@csign, 2, 2, ,\                            ;  csign            ;               ;  complex sign (normalized direction)
    cprojd, @@cprojd, 2, 3, ,\                          ;  cprojd           ;               ;  complex projection on the Riemann sphere
    cprojdx, @@cprojdx, 3, 3, ,\                        ;  cprojdx          ;               ;  complex projection on the Riemann sphere
    cprojr, @@cprojr, 2, 3, ,\                          ;  cprojr           ;               ;  complex projection on the Riemann sphere
    cprojrx, @@cprojrx, 3, 3, ,\                        ;  cprojrx          ;               ;  complex projection on the Riemann sphere
    caprojd, @@caprojd, 3, 2, ,\                        ;  caprojd          ;               ;  complex plane from projection on the Riemann sphere
    caprojdx, @@caprojdx, 4, 2, ,\                      ;  caprojdx         ;               ;  complex plane from projection on the Riemann sphere
    caprojr, @@caprojr, 3, 2, ,\                        ;  caprojr          ;               ;  complex plane from projection on the Riemann sphere
    caprojrx, @@caprojrx, 4, 2, ,\                      ;  caprojrx         ;               ;  complex plane from projection on the Riemann sphere
    cequ, @@cequ, 4, 'i', ,\                            ;  cequ             ;               ;  equal
    cnequ, @@cnequ, 4, 'i', ,\                          ;  cnequ            ;               ;  not equal
    creal.equ, @@creal.equ, 4, 'i', ,\                  ;  creal.equ        ;               ;  real equal
    creal.nequ, @@creal.nequ, 4, 'i', ,\                ;  creal.nequ       ;               ;  real not equal
    cimag.equ, @@cimag.equ, 4, 'i', ,\                  ;  cimag.equ        ;               ;  imaginary equal
    cimag.nequ, @@cimag.nequ, 4, 'i', ,\                ;  cimag.nequ       ;               ;  imaginary not equal
    cabs.equ, @@cabs.equ, 4, 'i', ,\                    ;  cabs.equ         ;               ;  abs equal
    cabs.nequ, @@cabs.nequ, 4, 'i', ,\                  ;  cabs.nequ        ;               ;  abs not equal
    carg.equ, @@carg.equ, 4, 'i', ,\                    ;  carg.equ         ;               ;  arg equal
    carg.nequ, @@carg.nequ, 4, 'i', ,\                  ;  carg.nequ        ;               ;  arg not equal
    cis.zero, @@cis.zero, 2, 'i', ,\                    ;  cis.zero         ;               ;  is zero
    cisn.zero, @@cisn.zero, 2, 'i', ,\                  ;  cisn.zero        ;               ;  is not zero
    cis.real, @@cis.real, 2, 'i', ,\                    ;  cis.real         ;               ;  is purely real
    cisn.real, @@cisn.real, 2, 'i', ,\                  ;  cisn.real        ;               ;  is not purely real
    cis.imag, @@cis.imag, 2, 'i', ,\                    ;  cis.imag         ;               ;  is purely imaginary
    cisn.imag, @@cisn.imag, 2, 'i', ,\                  ;  cisn.imag        ;               ;  is not purely imaginary
    cadd, @@cadd, 4, 2, ,\                              ;  cadd             ;               ;  complex addition
    cradd, @@cradd, 3, 2, ,\                            ;  cradd            ;               ;  complex addition of real number
    ciadd, @@ciadd, 3, 2, ,\                            ;  ciadd            ;               ;  complex addition of imaginary number
    cinc, @@cinc, 2, 2, ,\                              ;  cinc             ;               ;  complex addition of 1
    caddi, @@caddi, 2, 2, ,\                            ;  caddi            ;               ;  complex addition of i
    cinci, @@caddi, 2, 2, ,\                            ;  cinci            ;               ;  complex addition of i
    csub, @@csub, 4, 2, ,\                              ;  csub             ;               ;  complex subtraction
    crsub, @@crsub, 3, 2, ,\                            ;  crsub            ;               ;  complex subtraction of real number
    cisub, @@cisub, 3, 2, ,\                            ;  cisub            ;               ;  complex subtraction of imaginary number
    cdec, @@cdec, 2, 2, ,\                              ;  cdec             ;               ;  complex subtraction of 1
    csubi, @@csubi, 2, 2, ,\                            ;  csubi            ;               ;  complex subtraction of i
    cdeci, @@csubi, 2, 2, ,\                            ;  cdeci            ;               ;  complex subtraction of i
    csubr, @@csubr, 4, 2, ,\                            ;  csubr            ;               ;  reverse complex subtraction
    crsubr, @@crsubr, 3, 2, ,\                          ;  crsubr           ;               ;  reverse complex subtraction of real number
    cisubr, @@cisubr, 3, 2, ,\                          ;  cisubr           ;               ;  reverse complex subtraction of imaginary number
    cdecr, @@cdecr, 2, 2, ,\                            ;  cdecr            ;               ;  reverse complex subtraction of 1
    csubri, @@csubri, 2, 2, ,\                          ;  csubri           ;               ;  reverse complex subtraction of i
    cdecri, @@csubri, 2, 2, ,\                          ;  cdecri           ;               ;  reverse complex subtraction of i
    cmul, @@cmul, 4, 2, ,\                              ;  cmul             ;               ;  complex multiplication
    crmul, @@crmul, 3, 2, ,\                            ;  crmul            ;               ;  complex multiplication by real number
    cimul, @@cimul, 3, 2, ,\                            ;  cimul            ;               ;  complex multiplication by imaginary number
    cmuli, @@cmuli, 2, 2, ,\                            ;  cmuli            ;               ;  complex multiplication by i
    cdiv, @@cdiv, 4, 2, ,\                              ;  cdiv             ;               ;  complex division
    crdiv, @@crdiv, 3, 2, ,\                            ;  crdiv            ;               ;  complex division by real number
    cidiv, @@cidiv, 3, 2, ,\                            ;  cidiv            ;               ;  complex division by imaginary number
    cdivi, @@cdivi, 2, 2, ,\                            ;  cdivi            ;               ;  complex division by i
    cdivr, @@cdivr, 4, 2, ,\                            ;  cdivr            ;               ;  reverse complex division
    crdivr, @@crdivr, 3, 2, ,\                          ;  crdivr           ;               ;  reverse complex division by real number
    cidivr, @@cidivr, 3, 2, ,\                          ;  cidivr           ;               ;  reverse complex division by imaginary number
    cinv, @@cinv, 2, 2, ,\                              ;  cinv             ;               ;  reverse complex division by 1
    crecip, @@cinv, 2, 2, ,\                            ;  crecip           ;               ;  reverse complex division by 1
    cdivri, @@cdivri, 2, 2, ,\                          ;  cdivri           ;               ;  reverse complex division by i
    cinvi, @@cdivri, 2, 2, ,\                           ;  cinvi            ;               ;  reverse complex division by i
    crecipi, @@cdivri, 2, 2, ,\                         ;  crecipi          ;               ;  reverse complex division by i
    cexp, @@cexp, 2, 2, ,\                              ;  cexp             ;               ;  complex exponential function
    cexp2, @@cexp2, 2, 2, ,\                            ;  cexp2            ;               ;  complex 2^z
    cpow2z, @@cexp2, 2, 2, ,\                           ;  cpow2z           ;               ;  complex 2^z
    cexp10, @@cexp10, 2, 2, ,\                          ;  cexp10           ;               ;  complex 10^z
    cpow10z, @@cexp10, 2, 2, ,\                         ;  cpow10z          ;               ;  complex 10^z
    cln, @@cln, 2, 2, ,\                                ;  cln              ;               ;  complex natural logarithm
    cloge, @@cln, 2, 2, ,\                              ;  cloge            ;               ;  complex natural logarithm
    clb, @@clog2, 2, 2, ,\                              ;  clb              ;               ;  complex base-2 logarithm
    clog2, @@clog2, 2, 2, ,\                            ;  clog2            ;               ;  complex base-2 logarithm
    clg, @@clog10, 2, 2, ,\                             ;  clg              ;               ;  complex base-10 logarithm
    clog10, @@clog10, 2, 2, ,\                          ;  clog10           ;               ;  complex base-10 logarithm
    clogn, @@clogn, 3, 2, ,\                            ;  clogn            ;               ;  complex base-n logarithm
    clognr, @@clognr, 3, 2, ,\                          ;  clognr           ;               ;  reverse complex base-n logarithm
    cpow, @@cpow, 4, 2, ,\                              ;  cpow             ;               ;  complex power function
    cpowr, @@cpowr, 4, 2, ,\                            ;  cpowr            ;               ;  complex reverse power function
    cxpow, @@cxpow, 3, 2, ,\                            ;  cxpow            ;               ;  complex power function
    cpowx, @@cpowx, 3, 2, ,\                            ;  cpowx            ;               ;  complex power function
    cpown, @@cpown, 3, 2, ,\                            ;  cpown            ;               ;  complex power function
    cpow2, @@cpow2, 2, 2, ,\                            ;  cpow2            ;               ;  complex value raised to a power of 2
    csqr, @@cpow2, 2, 2, ,\                             ;  csqr             ;               ;  complex value raised to a power of 2
    cpow3, @@cpow3, 2, 2, ,\                            ;  cpow3            ;               ;  complex value raised to a power of 3
    ccube, @@cpow3, 2, 2, ,\                            ;  ccube            ;               ;  complex value raised to a power of 3
    cpow4, @@cpow4, 2, 2, ,\                            ;  cpow4            ;               ;  complex value raised to a power of 4
    croot, @@croot, 4, 2, ,\                            ;  croot            ;               ;  complex root function
    crootr, @@crootr, 4, 2, ,\                          ;  crootr           ;               ;  complex reverse root function
    crootx, @@crootx, 3, 2, ,\                          ;  crootx           ;               ;  complex root function
    crootn, @@crootn, 3, 2, ,\                          ;  crootn           ;               ;  complex root function
    crootsn, @@crootsn, 4, 2, ,\                        ;  crootsn          ;               ;  complex root function
    croot2, @@croot2, 2, 2, ,\                          ;  croot2           ;               ;  complex square root
    csqrt, @@croot2, 2, 2, ,\                           ;  csqrt            ;               ;  complex square root
    ccos, @@ccos, 2, 2, ,\                              ;  ccos             ;               ;  complex cosine
    csin, @@csin, 2, 2, ,\                              ;  csin             ;               ;  complex sine
    ccosec, @@ccosec, 2, 2, ,\                          ;  ccosec           ;               ;  complex cosecant
    ccsc, @@ccosec, 2, 2, ,\                            ;  ccsc             ;               ;  complex cosecant
    csec, @@csec, 2, 2, ,\                              ;  csec             ;               ;  complex secant
    ccotan, @@ccotan, 2, 2, ,\                          ;  ccotan           ;               ;  complex cotangent
    ccot, @@ccotan, 2, 2, ,\                            ;  ccot             ;               ;  complex cotangent
    ctan, @@ctan, 2, 2, ,\                              ;  ctan             ;               ;  complex tangent
    ccosh, @@ccosh, 2, 2, ,\                            ;  ccosh            ;               ;  complex hyperbolic cosine
    csinh, @@csinh, 2, 2, ,\                            ;  csinh            ;               ;  complex hyperbolic sine
    ccosech, @@ccosech, 2, 2, ,\                        ;  ccosech          ;               ;  complex hyperbolic cosecant
    ccsch, @@ccosech, 2, 2, ,\                          ;  ccsch            ;               ;  complex hyperbolic cosecant
    csech, @@csech, 2, 2, ,\                            ;  csech            ;               ;  complex hyperbolic secant
    ccotanh, @@ccotanh, 2, 2, ,\                        ;  ccotanh          ;               ;  complex hyperbolic cotangent
    ccoth, @@ccotanh, 2, 2, ,\                          ;  ccoth            ;               ;  complex hyperbolic cotangent
    ctanh, @@ctanh, 2, 2, ,\                            ;  ctanh            ;               ;  complex hyperbolic tangent
    cacos, @@cacos, 2, 2, ,\                            ;  cacos            ;               ;  inverse complex cosine
    casin, @@casin, 2, 2, ,\                            ;  casin            ;               ;  inverse complex sine
    cacosec, @@cacosec, 2, 2, ,\                        ;  cacosec          ;               ;  inverse complex cosecant
    cacsc, @@cacosec, 2, 2, ,\                          ;  cacsc            ;               ;  inverse complex cosecant
    casec, @@casec, 2, 2, ,\                            ;  casec            ;               ;  inverse complex secant
    cacotan, @@cacotan, 2, 2, ,\                        ;  cacotan          ;               ;  inverse complex cotangent
    cacot, @@cacotan, 2, 2, ,\                          ;  cacot            ;               ;  inverse complex cotangent
    catan, @@catan, 2, 2, ,\                            ;  catan            ;               ;  inverse complex tangent
    cacosh, @@cacosh, 2, 2, ,\                          ;  cacosh           ;               ;  inverse complex hyperbolic cosine
    casinh, @@casinh, 2, 2, ,\                          ;  casinh           ;               ;  inverse complex hyperbolic sine
    cacosech, @@cacosech, 2, 2, ,\                      ;  cacosech         ;               ;  inverse complex hyperbolic cosecant
    cacsch, @@cacosech, 2, 2, ,\                        ;  cacsch           ;               ;  inverse complex hyperbolic cosecant
    casech, @@casech, 2, 2, ,\                          ;  casech           ;               ;  inverse complex hyperbolic secant
    cacotanh, @@cacotanh, 2, 2, ,\                      ;  cacotanh         ;               ;  inverse complex hyperbolic cotangent
    cacoth, @@cacotanh, 2, 2, ,\                        ;  cacoth           ;               ;  inverse complex hyperbolic cotangent
    catanh, @@catanh, 2, 2, ,\                          ;  catanh           ;               ;  inverse complex hyperbolic tangent
    factln, @@factln, 1, 1, ,\                          ;  factln           ;               ;  natural logarithm of factorial
    fact, @@fact, 1, 1, ,\                              ;  fact             ;   x!          ;  factorial
    fact2, @@fact2, 1, 1, ,\                            ;  fact2            ;   x!!         ;  double factorial
    erf, @@ferf, 1, 1, ,\                               ;  erf              ;               ;  error function
    erfc, @@ferfc, 1, 1, ,\                             ;  erfc             ;               ;  complementary error function
    cdfnorm, @@fndtr, 1, 1, ,\                          ;  cdfnorm          ;               ;  normal distribution function
    erfinv, @@ferfi, 1, 1, ,\                           ;  erfinv           ;               ;  inverse error function
    erfcinv, @@ferfci, 1, 1, ,\                         ;  erfcinv          ;               ;  inverse complementary error function
    cdfnorminv, @@fndtri, 1, 1, ,\                      ;  cdfnorminv       ;               ;  inverse of normal distribution function
    lgamma, @@flgamma, 1, 1, ,\                         ;  lgamma           ;               ;  natural logarithm of the absolute value of gamma function
    tgamma, @@ftgamma, 1, 1, ,\                         ;  tgamma           ;               ;  gamma function
    rgamma, @@frgamma, 1, 1, ,\                         ;  rgamma           ;               ;  reciprocal gamma function
    rtgamma, @@frtgamma, 1, 1, ,\                       ;  rtgamma          ;               ;  reciprocal gamma function
    beta, @@fbeta, 2, 1, ,\                             ;  beta             ;               ;  beta function
    vcount, @@vcount, 'any', 1, ,\                      ;  vcount           ;               ;  argument count
    vcount.z, @@vcount.z, 'any', 1, ,\                  ;  vcount.z         ;               ;  argument count : x[i]  = 0
    vcount.nz, @@vcount.nz, 'any', 1, ,\                ;  vcount.nz        ;               ;  argument count : x[i] != 0
    vcount.az, @@vcount.az, 'any', 1, ,\                ;  vcount.az        ;               ;  argument count : x[i] >  0
    vcount.aez, @@vcount.aez, 'any', 1, ,\              ;  vcount.aez       ;               ;  argument count : x[i] >= 0
    vcount.bz, @@vcount.bz, 'any', 1, ,\                ;  vcount.bz        ;               ;  argument count : x[i] <  0
    vcount.bez, @@vcount.bez, 'any', 1, ,\              ;  vcount.bez       ;               ;  argument count : x[i] <= 0
    vcount.e, @@vcount.e, -2, 1, ,\                     ;  vcount.e         ;               ;  argument count : x[i]  = a
    vcount.ne, @@vcount.ne, -2, 1, ,\                   ;  vcount.ne        ;               ;  argument count : x[i] != a
    vcount.a, @@vcount.a, -2, 1, ,\                     ;  vcount.a         ;               ;  argument count : x[i] >  a
    vcount.ae, @@vcount.ae, -2, 1, ,\                   ;  vcount.ae        ;               ;  argument count : x[i] >= a
    vcount.b, @@vcount.b, -2, 1, ,\                     ;  vcount.b         ;               ;  argument count : x[i] <  a
    vcount.be, @@vcount.be, -2, 1, ,\                   ;  vcount.be        ;               ;  argument count : x[i] <= a
    varg.z, @@varg.z, -1, 0, 's',\                      ;  varg.z           ;               ;  argument filter : x[i]  = 0
    varg.nz, @@varg.nz, -1, 0, 's',\                    ;  varg.nz          ;               ;  argument filter : x[i] != 0
    varg.az, @@varg.az, -1, 0, 's',\                    ;  varg.az          ;               ;  argument filter : x[i] >  0
    varg.aez, @@varg.aez, -1, 0, 's',\                  ;  varg.aez         ;               ;  argument filter : x[i] >= 0
    varg.bz, @@varg.bz, -1, 0, 's',\                    ;  varg.bz          ;               ;  argument filter : x[i] <  0
    varg.bez, @@varg.bez, -1, 0, 's',\                  ;  varg.bez         ;               ;  argument filter : x[i] <= 0
    varg.e, @@varg.e, -2, 0, 's',\                      ;  varg.e           ;               ;  argument filter : x[i]  = a
    varg.ne, @@varg.ne, -2, 0, 's',\                    ;  varg.ne          ;               ;  argument filter : x[i] != a
    varg.a, @@varg.a, -2, 0, 's',\                      ;  varg.a           ;               ;  argument filter : x[i] >  a
    varg.ae, @@varg.ae, -2, 0, 's',\                    ;  varg.ae          ;               ;  argument filter : x[i] >= a
    varg.b, @@varg.b, -2, 0, 's',\                      ;  varg.b           ;               ;  argument filter : x[i] <  a
    varg.be, @@varg.be, -2, 0, 's',\                    ;  varg.be          ;               ;  argument filter : x[i] <= a
    vncycle, @@vncycle, -6, 1, ,\                       ;  vncycle          ;               ;  n-th cycle function
    meander, @@vncycle, -6, 1, ,\                       ;  meander          ;               ;  n-th cycle function
    vnstep, @@vnstep, -4, 1, ,\                         ;  vnstep           ;               ;  n-th step function
    vadd, @@vsum, -1, 1, ,\                             ;  vadd             ;               ;  sum of values
    vsum, @@vsum, -1, 1, ,\                             ;  vsum             ;               ;  sum of values
    vmul, @@vmul, -1, 1, ,\                             ;  vmul             ;               ;  product of values
    vmin, @@vmin, -1, 1, ,\                             ;  vmin             ;               ;  the smaller of values
    vmax, @@vmax, -1, 1, ,\                             ;  vmax             ;               ;  the larger of values
    vminmax, @@vminmax, -1, 2, ,\                       ;  vminmax          ;               ;  the smaller and the larger of values
    co.vminmax, @@co.vminmax, -3, 1, 's',\              ;  co.vminmax       ;               ;  the smaller and the larger of values
    vmaxmin, @@vmaxmin, -1, 2, ,\                       ;  vmaxmin          ;               ;  the larger and the smaller of values
    co.vmaxmin, @@co.vmaxmin, -3, 1, 's',\              ;  co.vmaxmin       ;               ;  the larger and the smaller of values
    vmin.adev, @@vmin.adev, -2, 1, ,\                   ;  vmin.adev        ;               ;  the smaller absolute deviation
    vminl.adev, @@vminl.adev, -2, 1, ,\                 ;  vminl.adev       ;               ;  the value with the smaller absolute deviation, prefer argument with a lower index
    vminh.adev, @@vminh.adev, -2, 1, ,\                 ;  vminh.adev       ;               ;  the value with the smaller absolute deviation, prefer argument with a higher index
    vmax.adev, @@vmax.adev, -2, 1, ,\                   ;  vmax.adev        ;               ;  the larger absolute deviation
    vmaxl.adev, @@vmaxl.adev, -2, 1, ,\                 ;  vmaxl.adev       ;               ;  the value with the larger absolute deviation, prefer argument with a lower index
    vmaxh.adev, @@vmaxh.adev, -2, 1, ,\                 ;  vmaxh.adev       ;               ;  the value with the larger absolute deviation, prefer argument with a higher index
    vpoly, @@vpoly, -2, 1, ,\                           ;  vpoly            ;               ;  uniform polynomial
    poly, @@vpoly, -2, 1, ,\                            ;  poly             ;               ;  uniform polynomial
    vavg, @@vmean, -1, 1, ,\                            ;  vavg             ;               ;  arithmetic average of values
    vmean, @@vmean, -1, 1, ,\                           ;  vmean            ;               ;  arithmetic average of values
    vsumsqr, @@vsumsqr, -1, 1, ,\                       ;  vsumsqr          ;               ;  sum of squares of values
    sumsqr, @@vsumsqr, -1, 1, ,\                        ;  sumsqr           ;               ;  sum of squares of values
    vnorm, @@vnorm, -1, 1, ,\                           ;  vnorm            ;               ;  Euclidean L2-norm
    norm, @@vnorm, -1, 1, ,\                            ;  norm             ;               ;  Euclidean L2-norm
    vvart, @@vvart, -1, 1, ,\                           ;  vvart            ;               ;  total variance
    vvars, @@vvars, -2, 1, ,\                           ;  vvars            ;               ;  variance (sample variance)
    vvarp, @@vvarp, -1, 1, ,\                           ;  vvarp            ;               ;  population variance
    vstd, @@vstd, -2, 1, ,\                             ;  vstd             ;               ;  standard deviation (sample standard deviation)
    vstdp, @@vstdp, -1, 1, ,\                           ;  vstdp            ;               ;  population standard deviation
    a2d, @@arc2deg, 3, 1, ,\                            ;  a2d              ;               ;  angle conversion: arc d:m:s to degrees
    a2r, @@arc2rad, 3, 1, ,\                            ;  a2r              ;               ;  angle conversion: arc d:m:s to radians
    a2g, @@arc2grad, 3, 1, ,\                           ;  a2g              ;               ;  angle conversion: arc d:m:s to grads
    a2c, @@arc2cycle, 3, 1, ,\                          ;  a2c              ;               ;  angle conversion: arc d:m:s to cycles
    d2a, @@deg2arc, 1, 3, ,\                            ;  d2a              ;               ;  angle conversion: degrees to arc d:m:s
    co.d2a, @@co.deg2arc, 4, 1, 's',\                   ;  co.d2a           ;               ;  angle conversion: degrees to arc d:m:s
    d2r, @@deg2rad, 1, 1, ,\                            ;  d2r              ;     x°        ;  angle conversion: degrees to radians
    radians, @@deg2rad, 1, 1, ,\                        ;  radians          ;     x°        ;  angle conversion: degrees to radians
    d2g, @@deg2grad, 1, 1, ,\                           ;  d2g              ;               ;  angle conversion: degrees to grads
    d2c, @@deg2cycle, 1, 1, ,\                          ;  d2c              ;               ;  angle conversion: degrees to cycles
    r2d, @@rad2deg, 1, 1, ,\                            ;  r2d              ;    °x         ;  angle conversion: radians to degrees
    degrees, @@rad2deg, 1, 1, ,\                        ;  degrees          ;    °x         ;  angle conversion: radians to degrees
    r2a, @@rad2arc, 1, 3, ,\                            ;  r2a              ;               ;  angle conversion: radians to arc d:m:s
    co.r2a, @@co.rad2arc, 4, 1, 's',\                   ;  co.r2a           ;               ;  angle conversion: radians to arc d:m:s
    r2g, @@rad2grad, 1, 1, ,\                           ;  r2g              ;   °°x         ;  angle conversion: radians to grads
    r2c, @@rad2cycle, 1, 1, ,\                          ;  r2c              ;               ;  angle conversion: radians to cycles
    g2r, @@grad2rad, 1, 1, ,\                           ;  g2r              ;     x°°       ;  angle conversion: grads to radians
    g2d, @@grad2deg, 1, 1, ,\                           ;  g2d              ;               ;  angle conversion: grads to degrees
    g2a, @@grad2arc, 1, 3, ,\                           ;  g2a              ;               ;  angle conversion: grads to arc d:m:s
    co.g2a, @@co.grad2arc, 4, 1, 's',\                  ;  co.g2a           ;               ;  angle conversion: grads to arc d:m:s
    g2c, @@grad2cycle, 1, 1, ,\                         ;  g2c              ;               ;  angle conversion: grads to cycles
    c2r, @@cycle2rad, 1, 1, ,\                          ;  c2r              ;               ;  angle conversion: cycles to radians
    c2d, @@cycle2deg, 1, 1, ,\                          ;  c2d              ;               ;  angle conversion: cycles to degrees
    c2a, @@cycle2arc, 1, 3, ,\                          ;  c2a              ;               ;  angle conversion: cycles to arc d:m:s
    co.c2a, @@co.cycle2arc, 4, 1, 's',\                 ;  co.c2a           ;               ;  angle conversion: cycles to arc d:m:s
    c2g, @@cycle2grad, 1, 1, ,\                         ;  c2g              ;               ;  angle conversion: cycles to grads
    ce2ke, @@celsius2kelvin, 1, 1, ,\                   ;  ce2ke            ;               ;  temperature conversion: celsius to kelvin
    ce2fa, @@celsius2fahrenheit, 1, 1, ,\               ;  ce2fa            ;               ;  temperature conversion: celsius to fahrenheit
    ce2ra, @@celsius2rankine, 1, 1, ,\                  ;  ce2ra            ;               ;  temperature conversion: celsius to rankine
    ce2re, @@celsius2reaumur, 1, 1, ,\                  ;  ce2re            ;               ;  temperature conversion: celsius to reaumur
    ke2ce, @@kelvin2celsius, 1, 1, ,\                   ;  ke2ce            ;               ;  temperature conversion: kelvin to celsius
    ke2fa, @@kelvin2fahrenheit, 1, 1, ,\                ;  ke2fa            ;               ;  temperature conversion: kelvin to fahrenheit
    ke2ra, @@kelvin2rankine, 1, 1, ,\                   ;  ke2ra            ;               ;  temperature conversion: kelvin to rankine
    ke2re, @@kelvin2reaumur, 1, 1, ,\                   ;  ke2re            ;               ;  temperature conversion: kelvin to reaumur
    fa2ce, @@fahrenheit2celsius, 1, 1, ,\               ;  fa2ce            ;               ;  temperature conversion: fahrenheit to celsius
    fa2ke, @@fahrenheit2kelvin, 1, 1, ,\                ;  fa2ke            ;               ;  temperature conversion: fahrenheit to kelvin
    fa2ra, @@fahrenheit2rankine, 1, 1, ,\               ;  fa2ra            ;               ;  temperature conversion: fahrenheit to rankine
    fa2re, @@fahrenheit2reaumur, 1, 1, ,\               ;  fa2re            ;               ;  temperature conversion: fahrenheit to reaumur
    ra2ce, @@rankine2celsius, 1, 1, ,\                  ;  ra2ce            ;               ;  temperature conversion: rankine to celsius
    ra2ke, @@rankine2kelvin, 1, 1, ,\                   ;  ra2ke            ;               ;  temperature conversion: rankine to kelvin
    ra2fa, @@rankine2fahrenheit, 1, 1, ,\               ;  ra2fa            ;               ;  temperature conversion: rankine to fahrenheit
    ra2re, @@rankine2reaumur, 1, 1, ,\                  ;  ra2re            ;               ;  temperature conversion: rankine to reaumur
    re2ce, @@reaumur2celsius, 1, 1, ,\                  ;  re2ce            ;               ;  temperature conversion: reaumur to celsius
    re2ke, @@reaumur2kelvin, 1, 1, ,\                   ;  re2ke            ;               ;  temperature conversion: reaumur to kelvin
    re2fa, @@reaumur2fahrenheit, 1, 1, ,\               ;  re2fa            ;               ;  temperature conversion: reaumur to fahrenheit
    re2ra, @@reaumur2rankine, 1, 1, ,\                  ;  re2ra            ;               ;  temperature conversion: reaumur to rankine
    bit, @@bit, 1, 1, ,\                                ;  bit              ;               ;  /8
    nibble, @@nibble, 1, 1, ,\                          ;  nibble           ;               ;  /2
    byte, @@byte, 1, 1, ,\                              ;  byte             ;               ;  *1
    word, @@word, 1, 1, ,\                              ;  word             ;               ;  *2
    dword, @@dword, 1, 1, ,\                            ;  dword            ;               ;  *4
    qword, @@qword, 1, 1, ,\                            ;  qword            ;               ;  *8
    nword, @@nword, 1, 1, ,\                            ;  nword            ;               ;  *8 (x64) | *4 (x32)
    tword, @@tword, 1, 1, ,\                            ;  tword            ;               ;  *10
    xword, @@xword, 1, 1, ,\                            ;  xword            ;               ;  *16
    oword, @@oword, 1, 1, ,\                            ;  oword            ;               ;  *16
    yword, @@yword, 1, 1, ,\                            ;  yword            ;               ;  *32
    zword, @@zword, 1, 1, ,\                            ;  zword            ;               ;  *64
    kibi, @@kibi, 1, 1, ,\                              ;  kibi             ;               ;  *(2^10)
    mebi, @@mebi, 1, 1, ,\                              ;  mebi             ;               ;  *(2^20)
    gibi, @@gibi, 1, 1, ,\                              ;  gibi             ;               ;  *(2^30)
    tebi, @@tebi, 1, 1, ,\                              ;  tebi             ;               ;  *(2^40)
    pebi, @@pebi, 1, 1, ,\                              ;  pebi             ;               ;  *(2^50)
    exbi, @@exbi, 1, 1, ,\                              ;  exbi             ;               ;  *(2^60)
    zebi, @@zebi, 1, 1, ,\                              ;  zebi             ;               ;  *(2^70)
    yobi, @@yobi, 1, 1, ,\                              ;  yobi             ;               ;  *(2^80)
    kibo, @@kibo, 1, 1, ,\                              ;  kibo             ;               ;  *(2^-10)
    mebo, @@mebo, 1, 1, ,\                              ;  mebo             ;               ;  *(2^-20)
    gibo, @@gibo, 1, 1, ,\                              ;  gibo             ;               ;  *(2^-30)
    tebo, @@tebo, 1, 1, ,\                              ;  tebo             ;               ;  *(2^-40)
    pebo, @@pebo, 1, 1, ,\                              ;  pebo             ;               ;  *(2^-50)
    exbo, @@exbo, 1, 1, ,\                              ;  exbo             ;               ;  *(2^-60)
    zebo, @@zebo, 1, 1, ,\                              ;  zebo             ;               ;  *(2^-70)
    yobo, @@yobo, 1, 1, ,\                              ;  yobo             ;               ;  *(2^-80)
    deca, @@deca, 1, 1, ,\                              ;  deca             ;               ;  *(10^1)
    hecto, @@hecto, 1, 1, ,\                            ;  hecto            ;               ;  *(10^2)
    kilo, @@kilo, 1, 1, ,\                              ;  kilo             ;               ;  *(10^3)
    mega, @@mega, 1, 1, ,\                              ;  mega             ;               ;  *(10^6)
    giga, @@giga, 1, 1, ,\                              ;  giga             ;               ;  *(10^9)
    tera, @@tera, 1, 1, ,\                              ;  tera             ;               ;  *(10^12)
    peta, @@peta, 1, 1, ,\                              ;  peta             ;               ;  *(10^15)
    exa, @@exa, 1, 1, ,\                                ;  exa              ;               ;  *(10^18)
    zetta, @@zetta, 1, 1, ,\                            ;  zetta            ;               ;  *(10^21)
    yotta, @@yotta, 1, 1, ,\                            ;  yotta            ;               ;  *(10^24)
    deci, @@deci, 1, 1, ,\                              ;  deci             ;               ;  *(10^-1)
    centi, @@centi, 1, 1, ,\                            ;  centi            ;               ;  *(10^-2)
    milli, @@milli, 1, 1, ,\                            ;  milli            ;               ;  *(10^-3)
    micro, @@micro, 1, 1, ,\                            ;  micro            ;               ;  *(10^-6)
    nano, @@nano, 1, 1, ,\                              ;  nano             ;               ;  *(10^-9)
    pico, @@pico, 1, 1, ,\                              ;  pico             ;               ;  *(10^-12)
    femto, @@femto, 1, 1, ,\                            ;  femto            ;               ;  *(10^-15)
    atto, @@atto, 1, 1, ,\                              ;  atto             ;               ;  *(10^-18)
    zepto, @@zepto, 1, 1, ,\                            ;  zepto            ;               ;  *(10^-21)
    yocto, @@yocto, 1, 1, 0                             ;  yocto            ;               ;  *(10^-24)

; ------------------------------------------------------------------------------

;   ':int8'             , @@.int8             , ??int8             ,  1 , -1    , 's'  ,\  ;  int8 type modifier
;   ':uint8'            , @@.uint8            , ??uint8            ,  1 , -1    , 's'  ,\  ;  uint8 type modifier
;   ':int16'            , @@.int16            , ??int16            ,  1 , -1    , 's'  ,\  ;  int16 type modifier
;   ':uint16'           , @@.uint16           , ??uint16           ,  1 , -1    , 's'  ,\  ;  uint16 type modifier
;   ':int32'            , @@.int32            , ??int32            ,  1 , -1    , 's'  ,\  ;  int32 type modifier
;   ':uint32'           , @@.uint32           , ??uint32           ,  1 , -1    , 's'  ,\  ;  uint32 type modifier

SFT @_SFT,\                                                      
    '?nop'              , @@.nop              , ??nop              ,  0 ,  0    , 's'  ,\  ;  dummy function
    '?var.double'       , @@.var.double       , ??var.double       , -1 ,  0    , 's'  ,\  ;  double variable declaration
    '?var.complex'      , @@.var.complex      , ??var.complex      , -1 ,  0    , 's'  ,\  ;  complex variable declaration
    '?var.integer'      , @@.var.integer      , ??var.integer      , -1 ,  0    , 's'  ,\  ;  integer variable declaration
    '?var.string'       , @@.var.string       , ??var.string       , -1 ,  0    , 's'  ,\  ;  string variable declaration
    '(=)'               , @@result.get        , ??result.get       ,  0 ,  1    , 's-' ,\  ;  get default result value
    '(float)'           , @@.double           , ??tfloat           ,  1 ,  1    , 's-' ,\  ;  double type modifier
    '(double)'          , @@.double           , ??tdouble          ,  1 ,  1    , 's-' ,\  ;  double type modifier
    '(int)'             , @@.int              , ??tint             ,  1 , -1    , 's-' ,\  ;  integer type modifier
    '(int64)'           , @@.int64            , ??tint64           ,  1 , -1    , 's-' ,\  ;  int64 type modifier
    '?addr.1P'          , @@.addr.1P          , ??addr.1P          ,  1 ,  1    , 's'  ,\  ;  addr
    '?addr.2P'          , @@.addr.2P          , ??addr.2P          ,  2 ,  1    , 's'  ,\  ;  addr
    '?returnv'          , @@.returnv          , ??returnv          ,  1 ,  0    , 's'  ,\  ;
    '?returnv.if.true'  , @@.returnv.if.true  , ??returnv.if.true  ,  2 ,  0    , 's'  ,\  ;
    '?returnv.if.false' , @@.returnv.if.false , ??returnv.if.false ,  2 ,  0    , 's'  ,\  ;
    '?vint'             , @@.vint             , ??vint             , -1 ,  1    , 's'  ,\  ;
    '?vfrac'            , @@.vfrac            , ??vfrac            , -1 ,  1    , 's'  ,\  ;
    '?vround'           , @@.vround           , ??vround           , -1 ,  1    , 's'  ,\  ;
    '?1D.1P.matrip'     , @@.1D.1P.matrip     , ??1D.1P.matrip     ,  1 , 'i'   , 's'  ,\  ;
    '?1D.2P.matrip'     , @@.1D.2P.matrip     , ??1D.2P.matrip     ,  2 , 'i'   , 's'  ,\  ;
    '?1D.matrip.rc'     , @@.1D.matrip.rc     , ??1D.matrip.rc     ,  2 , 'i'   , 's'  ,\  ;
    '?2D.3P.matrip'     , @@.2D.3P.matrip     , ??2D.3P.matrip     ,  3 , 'i'   , 's'  ,\  ;
    '?2D.4P.matrip'     , @@.2D.4P.matrip     , ??2D.4P.matrip     ,  4 , 'i'   , 's'  ,\  ;
    '?2D.matrip.rc'     , @@.2D.matrip.rc     , ??2D.matrip.rc     ,  4 , 'i'   , 's'  ,\  ;
    '?pow.??'           , @@.pow.??           , ??pow.??           ,  2 ,  1    , 's'  ,\  ;
    '?powr.??'          , @@.powr.??          , ??powr.??          ,  2 ,  1    , 's'  ,\  ;
    ':float'            , @@.double           , ??float            ,  1 ,  1    , 's'  ,\  ;  double type modifier
    ':double'           , @@.double           , ??double           ,  1 ,  1    , 's'  ,\  ;  double type modifier
    ':int'              , @@.int              , ??int              ,  1 , -1    , 's'  ,\  ;  integer type modifier
    ':int64'            , @@.int64            , ??int64            ,  1 , -1    , 's'  ,\  ;  int64 type modifier
    ':+'                , @@pos               , ??pos              ,  1 ,  1    , 's'  ,\  ;  positive value or zero
    ':-'                , @@neg               , ??neg              ,  1 ,  1    , 's'  ,\  ;  negative value or zero
    ':++'               , @@inc               , ??inc              ,  1 ,  1    , 's'  ,\  ;  increment
    ':--'               , @@dec               , ??dec              ,  1 ,  1    , 's'  ,\  ;  decrement
    ':2pi'              , @@.mul.2pi          , ??mul.2pi          ,  1 ,  1    , 's'  ,\  ;  *(2pi)
    ':pi'               , @@.mul.pi           , ??mul.pi           ,  1 ,  1    , 's'  ,\  ;  *(pi)
    ':pi2'              , @@.mul.pi2          , ??mul.pi2          ,  1 ,  1    , 's'  ,\  ;  *(pi/2)
    ':pi4'              , @@.mul.pi4          , ??mul.pi4          ,  1 ,  1    , 's'  ,\  ;  *(pi/4)
    ':/2pi'             , @@.div.2pi          , ??div.2pi          ,  1 ,  1    , 's'  ,\  ;  /(2pi)
    ':/pi'              , @@.div.pi           , ??div.pi           ,  1 ,  1    , 's'  ,\  ;  /(pi)
    ':/pi2'             , @@.div.pi2          , ??div.pi2          ,  1 ,  1    , 's'  ,\  ;  /(pi/2)
    ':/pi4'             , @@.div.pi4          , ??div.pi4          ,  1 ,  1    , 's'  ,\  ;  /(pi/4)
    ':\2pi'             , @@.quo.2pi          , ??quo.2pi          ,  1 ,  1    , 's'  ,\  ;  \(2pi)
    ':\pi'              , @@.quo.pi           , ??quo.pi           ,  1 ,  1    , 's'  ,\  ;  \(pi)
    ':\pi2'             , @@.quo.pi2          , ??quo.pi2          ,  1 ,  1    , 's'  ,\  ;  \(pi/2)
    ':\pi4'             , @@.quo.pi4          , ??quo.pi4          ,  1 ,  1    , 's'  ,\  ;  \(pi/4)
    ':%2pi'             , @@.mod.2pi          , ??mod.2pi          ,  1 ,  1    , 's'  ,\  ;  %(2pi)
    ':%pi'              , @@.mod.pi           , ??mod.pi           ,  1 ,  1    , 's'  ,\  ;  %(pi)
    ':%pi2'             , @@.mod.pi2          , ??mod.pi2          ,  1 ,  1    , 's'  ,\  ;  %(pi/2)
    ':%pi4'             , @@.mod.pi4          , ??mod.pi4          ,  1 ,  1    , 's'      ;  %(pi/4)

;   ':int'              , @@.int              , ??int              ,  1 , -1    , 's'  ,\  ;  integer type modifier
;   ':int64'            , @@.int64            , ??int64            ,  1 , -1    , 's'  ,\  ;  int64 type modifier

;   ':int'              , @@.int              , ??int              ,  1 , 'i'   , 's'  ,\  ;  integer type modifier
;   ':int64'            , @@.int64            , ??int64            ,  1 , 'i64' , 's'  ,\  ;  int64 type modifier

; ------------------------------------------------------------------------------
