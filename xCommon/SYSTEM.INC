
; FASM SOURCE FILE
; http://flatassembler.net

; system macros

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

$comment fix macro comment {
$cend fix }

; ------------------------------------------------------------------------------

; be sure value is floating point
macro virtual.float value
{
  virtual at 0
    dt value
  end virtual
}

; ------------------------------------------------------------------------------

; define 32-bit float
macro dfd n, v
{
  if v eqtype 0.0
    n dd v
  else
    n dd v#.0
  end if
}

; define 64-bit float
macro dfq n, v
{
  if v eqtype 0.0
    n dq v
  else
    n dq v#.0
  end if
}

; define 80-bit float
macro dft n, v
{
  if v eqtype 0.0
    n dt v
  else
    n dt v#.0
  end if
}
; ------------------------------------------------------------------------------

macro $define [sym]
{
  common
    sym = 1
}

macro $.define [sym] {}

macro $undef [sym]
{
  common
    if defined sym
      sym = 0
    end if
}

macro $.undef [sym] {}

; ------------------------------------------------------------------------------

macro $ifused sym
{
  macro system.end \{ end if \}
  if used sym
}
$if.used fix $ifused

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
$if.def fix $ifdef

macro $ifndef sym
{
  macro system.end \{ end if \}

  local @sym
  @sym = 0
  if defined sym
    @sym = sym
  end if
  if @sym = 0
}
$if.ndef fix $ifndef

macro $if [expr]
{
  common
    macro system.end \{ end if \}
    if expr
}

macro $else { else }
$ee fix $else

macro $elseif [expr]
{
  common
    else if expr
}
$else.if fix $elseif
$elif fix $elseif
$ef fix $elseif

; ------------------------------------------------------------------------------

macro $locals [sym]
{
  common
    macro system.end \{ endl \}
    locals sym
}

; ------------------------------------------------------------------------------

macro $align v
{
  if v eq
    $ifdef _X64
      align 16
    $else
      align 8
    $end
  else
    align v
  end if
}

macro $palign v
{
  if v eq
    $ifdef _X64
      align 16
    $else
      align 8
    $end
  else
    align v
  end if
}

macro $lalign v
{
  if v eq
    $ifdef _X64
      align 16
    $else
      align 8
    $end
  else
    align v
  end if
}

; ------------------------------------------------------------------------------

macro $struct sname
{
  common
    macro system.end \{ ends \}
    struct sname
}

; ------------------------------------------------------------------------------

; procedure declaration
; <stdcall> calling convention
;
; debug string
; alignment
macro $proc pname, [arg]
{
  common
    macro system.end \{ endp \}
    $debugc pname
    $palign
    proc pname arg
}

; procedure declaration
; <stdcall> calling convention
;
; debug string
; alignment
macro $aproc pname, [arg]
{
  common
    macro system.end \{ endp \}
    $debugc pname
    $palign
    proc pname arg
}

; procedure declaration
; <stdcall> calling convention
;
; debug string
; no alignment
macro $uproc pname, [arg]
{
  common
    macro system.end \{ endp \}
    $debugc pname
    proc pname arg
}

; ------------------------------------------------------------------------------

; procedure declaration
; <cdecl> calling convention
;
; debug string
; alignment
macro $cproc pname, [arg]
{
  common
    macro system.end \{ endp \}
    $debugc pname
    $palign
    proc pname c, arg
}

; procedure declaration
; <cdecl> calling convention
;
; debug string
; alignment
macro $acproc pname, [arg]
{
  common
    macro system.end \{ endp \}
    $debugc pname
    $palign
    proc pname c, arg
}

; procedure declaration
; <cdecl> calling convention
;
; debug string
; no alignment
macro $ucproc pname, [arg]
{
  common
    macro system.end \{ endp \}
    $debugc pname
    proc pname c, arg
}

; ------------------------------------------------------------------------------

; procedure declaration
; <simple> calling convention (no parameters)
;
; debug string
; alignment
macro $sproc pname
{
  macro system.end
  \{
    pname#.size = $ - pname
    if defined pname#.enter
    pname#.enter.size = $ - pname#.enter
    end if
    end if
  \}
  $debugc pname
  if used pname
  $palign
  pname:
}

; procedure declaration
; <simple> calling convention (no parameters)
;
; debug string
; alignment
macro $asproc pname
{
  macro system.end
  \{
    pname#.size = $ - pname
    if defined pname#.enter
    pname#.enter.size = $ - pname#.enter
    end if
    end if
  \}
  $debugc pname
  if used pname
  $palign
  pname:
}

; procedure declaration
; <simple> calling convention (no parameters)
;
; debug string
; no alignment
macro $usproc pname
{
  macro system.end
  \{
    pname#.size = $ - pname
    if defined pname#.enter
    pname#.enter.size = $ - pname#.enter
    end if
    end if
  \}
  $debugc pname
  if used pname
  pname:
}

; ------------------------------------------------------------------------------

; procedure declaration
; <simple> calling convention (no parameters)
;
; debug string
; alignment
; force include in code (don't care label usage}
macro $sprocf pname
{
  macro system.end
  \{
    pname#.size = $ - pname
    if defined pname#.enter
    pname#.enter.size = $ - pname#.enter
    end if
  \}
  $debugc pname
  $palign
  pname:
}

; procedure declaration
; <simple> calling convention (no parameters)
;
; debug string
; alignment
; force include in code (don't care label usage}
macro $asprocf pname
{
  macro system.end
  \{
    pname#.size = $ - pname
    if defined pname#.enter
    pname#.enter.size = $ - pname#.enter
    end if
  \}
  $debugc pname
  $palign
  pname:
}

; procedure declaration
; <simple> calling convention (no parameters)
;
; debug string
; no alignment
; force include in code (don't care label usage}
macro $usprocf pname
{
  macro system.end
  \{
    pname#.size = $ - pname
    if defined pname#.enter
    pname#.enter.size = $ - pname#.enter
    end if
  \}

; local @@n, @@nsize
; virtual at 0
;   @@n db `pname
;   @@nsize = $ - @@n
; end virtual
; pname#.nsize = @@nsize

  $debugc pname
  pname:
}

; ------------------------------------------------------------------------------

macro $end
{
  system.end
  purge system.end
}
$endif fix $end
$ends  fix $end
$endl  fix $end
$endp  fix $end

macro $retn.endp
{
  retn
  $endp
}

; ------------------------------------------------------------------------------

; put debug string in code
; <s> is a quoted string
macro $debugs s
{
  $ifdef DEBUG_CODE
  jmp @f
  db ' [',s,'] ',0
  @@:
  $end
}

; put debug string in code
; <c> is a label
macro $debugc c
{
  $ifdef DEBUG_CODE
  if used c
    jmp @f
    db ' [',`c,'] ',0
    @@:
  end if
  $end
}

; ------------------------------------------------------------------------------

;
macro $assert c, s
{
  $if c
    display s, 13, 10
    OOPS
  $end
}

; ------------------------------------------------------------------------------

; label with debug string
; alignment
macro $label name
{
  $debugc name
  $lalign
  name:
}

; label with debug string
; alignment
macro $alabel name
{
  $debugc name
  $lalign
  name:
}

; label with debug string
; no alignment
macro $ulabel name
{
  $debugc name
  name:
}

; ------------------------------------------------------------------------------

; string of fixed length
struc fstr size, sdata
{
  local length, bytes

  label .data byte
  db sdata,0
  length = $ - .data
  bytes = size - length

  if bytes < 0
    display 'Warning: invalid size of the string',13,10
  else
    times bytes db 0
  end if

  .size = $ - .data
}

; ------------------------------------------------------------------------------

; table of strings of fixed length
; maximum item name size = 255
; maximum item count = 255
;
; fstrtab q, s1, 's1', s10, 's10' is equivalent to
;   q:
;   q.count dd 2
;   q.isize dd 4
;   q.tsize dd 8
;   q.s1 db 's1',0,0
;   q.s2 db 's10',0
;   @q.count = 2
;   @q.isize = 4
;   @q.tsize = 8

macro fstrtab tlabel, [slabel, sdata]
{
  common
    local @count, @isize, @tsize
    @count = 0
    @isize = 0
    @tsize = 0

    tlabel:
    tlabel#.count db @#tlabel#.count ; item count
    tlabel#.isize db @#tlabel#.isize ; item size
    tlabel#.tsize dw @#tlabel#.tsize ; table size

  forward ; get max string length & string count
    local @string
    virtual at 0
      @string db sdata, 0
      if $ - @string > @isize
        @isize = $ - @string
      end if
    end virtual
    @count = @count + 1

  forward ; data allocation & zero padding
    local @size
    tlabel#.#slabel#.text equ sdata
    tlabel#.#slabel db sdata, 0
    @size = $ - tlabel#.#slabel
    times @isize - @size db 0

  common
    @tsize = $ - tlabel
    @#tlabel#.count = @count
    @#tlabel#.isize = @isize
    @#tlabel#.tsize = @tsize
}

; ------------------------------------------------------------------------------
