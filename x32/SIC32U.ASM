
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; utils

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_U:

; ------------------------------------------------------------------------------

; assign FPU control word
;
; @@..fpu.cw.assign 0x????
; ...
; @@..fpu.cw.restore

macro @@..fpu.cw.assign cw
{
        add     esp, -16
        fnstcw  word [esp + 2]                  ; save control word
        mov     word [esp], cw
        fldcw   word [esp]                      ; load control word
}

; ------------------------------------------------------------------------------

; update FPU control word

macro @@..fpu.cw.update cw
{
        mov     word [esp], cw
        fldcw   word [esp]                      ; load control word
}

; ------------------------------------------------------------------------------

; restore FPU control word and set new control word
;
; @@..fpu.cw.assign 0x????
; ...
; @@..fpu.cw.restore

macro @@..fpu.cw.restore
{
        fldcw   word [esp + 2]
        add     esp, +16
}

; ------------------------------------------------------------------------------

; convert st0 to int(st0)
macro @@..int.st0
{
        @@..fpu.cw.assign 0x0F3F                ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)
        @@..fpu.cw.restore                      ; restore control word
}

; ------------------------------------------------------------------------------

; convert st0 to frac(st0)
macro @@..frac.st0
{
        @@..fpu.cw.assign 0x0F3F                ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0                             ; st0 = x      | st1 = x
        frndint                                 ; st0 = int(x) | st1 = x
        fsubp                                   ; st0 = x - int(x) = frac(x)

        @@..fpu.cw.restore                      ; restore control word
}

; ------------------------------------------------------------------------------

; convert st0 to round(st0)
macro @@..round.st0
{
        @@..fpu.cw.assign 0x0F3F                ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
                                                ; -------------------------------------
                                                ; ST(0)        | ST(1)        | ST(2) |
                                                ; -------------------------------------
                                                ; x.y          | ?            | ?     |
        fld     st0                             ; x.y          | x.y          | ?     |
        fld     st0                             ; x.y          | x.y          | x.y   |
        frndint                                 ; x            | x.y          | x.y   |
        fsubp                                   ; 0.y          | x.y          | ?     |
        fld     st0                             ; 0.y          | 0.y          | x.y   |
        faddp                                   ; 2 * 0.y      | x.y          | ?     |
        frndint                                 ; int(2 * 0.y) | x.y          | ?     |
        fxch                                    ; x.y          | int(2 * 0.y) | ?     |
        frndint                                 ; int(x.y)     | int(2 * 0.y) | ?     |
        faddp                                   ; round(x.y)   | ?            | ?     |
                                                ; -------------------------------------
        @@..fpu.cw.restore                      ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; VOID zerosic ( LPVOID sic )
; zero sic memory
;
; -> sic : T_sic_data structure offset
$proc zerosic, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     ecx, [sic]                      ; ecx = T_sic_data structure offset
        test    ecx, ecx
        jz     .return                          ; error. null T_sic_data structure offset

   .zero.memory:
        stdcall fillchar, ecx, sizeof.T_sic_data, 0

   .return:
        ret
$endp ; zerosic

; ------------------------------------------------------------------------------

; INT taget ( LPVOID tao, LPCSTR ina, INT ins )
; find item in table
; case insensitive or case sensitive (depends on SIC_CFG_FLAG_CASE_SENSITIVE flag)
; !!! assume table items are lowercase (~SIC_CFG_FLAG_CASE_SENSITIVE) & sorted alphabetically
;
; -> tao : table offset
; -> ina : item name to search
; -> ins : item name size
;          ins < 0, assume item name zero terminated & calculate it's size
; <- eax : item index or negative value on error
; <- edx : item offset or zero on error
$proc taget, tao, ina, ins

    locals
       .ins     dd ?
       .tic     dd ?
    endl

;       mov     [tao], rcx
;       mov     [ina], rdx
;       mov     [ins], r8
;       mov     [], r9

   .enter:
        push    ebx esi edi

        xor     eax, eax                        ; eax = 0
        xor     edx, edx                        ; edx = 0

        mov     esi, [tao]                      ; esi = table offset
        test    esi, esi
        jz     .error                           ; error. null table

        mov     edx, [esi + table.header.icount]; edx = table item count
        test    edx, edx
        jz     .error                           ; error. empty table
        mov     [.tic], edx                     ; save table item count in [.tic]

;       xor     rbx, rbx
        mov     ebx, [esi + table.header.tnsize]; ebx = table item name size

        mov     edi, [ina]                      ; edi = item name offset
        test    edi, edi
        jz     .error                           ; error. null item name

        mov     edx, [ins]
        cmp     edx, eax
        jg     .begin
        je     .error                           ; error. empty item name

        xor     edx, edx                        ; get item name size
   .scan:                                       ; scan item name
;       cmp     byte [edi + edx], 0             ; until null terminating zero found
;       je     .scan.out
        cmp     byte [edi + edx], 0x20          ; until null terminating zero found
        jbe    .scan.out
        inc     edx
        cmp     edx, ebx
        jb     .scan
   .scan.out:
        test    edx, edx
        jz     .error                           ; error. empty item name

   .begin:
        mov     [.ins], edx
        cmp     edx, ebx
        jae    .error                           ; error. invalid item name size

        mov     edx, [.tic]                     ; edx = table item count
        xor     eax, eax
        xor     ebx, ebx
        xor     ecx, ecx
        add     esi, sizeof.table.header        ; esi = current item offset

;      $align
   .loop.i:
        mov     bl, byte [edi + ecx]
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jnz     @F
        ctolow  bl
    @@:
   .loop.j:
        cmp     bl, byte [esi + ecx]
        ja     .loop.j.next
        jb     .error

        push    esi                             ; save esi
        lea     edx, [eax - 1]
        sub     esi, 64
   .item:
        cmp     edx, [.tic]
        je     .item.out
        inc     edx
        add     esi, 64
        cmp     bl, byte [esi + ecx]
        je     .item
   .item.out:
        pop     esi                             ; restore esi

        inc     bh
        jmp    .loop.i.next
   .loop.j.next:
        inc     eax
        add     esi, 64
        cmp     eax, edx
        jb     .loop.j
   .loop.i.next:
        inc     ecx
        cmp     cl, bh
        jne    .error
        cmp     ecx, [.ins]
        jb     .loop.i

        cmp     byte [esi + ecx], 0
        je     .return

   .error:
        xor     edx, edx                        ; error. eax = -1, edx = 0
        lea     eax, [edx - 1]
   .return:
;       test    eax, eax
;       js     .leave
        cmp     eax, 0
        jl     .leave
        mov     edx, esi                        ; edx = item offset
   .leave:
        pop     edi esi ebx
        ret
$endp ; taget

; ------------------------------------------------------------------------------

; INT tageta ( LPVOID tao, LPVOID fia )
; find item in table by address of any table item field
; assume size of table item is 64 bytes
;
; -> tao : table offset
; -> fia : field address
; <- eax : item index or negative value on error
; <- edx : item offset or zero on error
$proc tageta, tao, fia

;       mov     [tao], rcx
;       mov     [fia], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        mov     ecx, [tao]                      ; ecx = table offset
        test    ecx, ecx
        jz     .error                           ; error. null table

    $ifdef _X64
        mov     rax, rdx                        ; rax = field address
    $else
        mov     eax, [fia]                      ; eax = field address
    $end
        sub     eax, ecx
        sub     eax, sizeof.table.header
        js     .error
        shr     eax, 6                          ; eax = eax / 64
        mov     edx, [ecx + table.header.icount]
        cmp     eax, edx                        ; eax = item index
        jae    .error
        mov     edx, eax
        shl     edx, 6                          ; edx = eax * 64
        lea     edx, [ecx + edx + sizeof.table.header]
        jmp    .leave

   .error:
        mov     eax, -1                         ; error. eax = -1, edx = 0
        xor     edx, edx

   .leave:
        ret
$endp ; tageta

; ------------------------------------------------------------------------------

; INT taset ( LPVOID tao, LPCSTR ina, LPVOID ito, INT16 fua, INT16 fuc )
; add item to the table with lowercasing (~SIC_CFG_FLAG_CASE_SENSITIVE) and sorting
;
; -> tao : table offset
; -> ina : item name
; -> ito : variable or function offset, constant value LO
; -> fua : function argument count, constant value HI
; -> fuc : function code size, constant data type
; -> fur : function return type
; <- eax : item index or negative value on error
; <- edx : table item count
$proc taset, tao, ina, ito, fua, fuc, fur

    locals
       .ecx     dd ?
       .ebx     dd ?
       .sys     dd ?
       .tic     dd ?
       .tns     dd ?
       .tit     dd ?
    endl

;       mov     [tao], rcx
;       mov     [ina], rdx
;       mov     [ito], r8
;       mov     [fua], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        mov     edx, [ina]
        mov     dl, byte [edx]
        sub     dl, '0'
        cmp     dl, 9
        ja     .begin
        jmp    .error                           ; error. first symbol of item name is a digit

   .begin:
        xor     eax, eax                        ; eax = 0
        mov     [.ebx], eax

        mov     esi, [tao]                      ; esi = table entry offset
        test    esi, esi
        jz     .error                           ; error. null table

        mov     edx, [esi + table.header.mcount]
        mov     [.tic], edx                     ; get table item max count
        mov     edx, [esi + table.header.tnsize]
        mov     [.tns], edx                     ; get table item name size
        mov     edx, [esi + table.header.titype]
        mov     [.tit], edx                     ; get table item type

        mov     edi, [ina]                      ; edi = item name offset
        test    edi, edi
        jz     .error                           ; error. null item name

   .params:                                     ; parameters test
        cmp     [.tit], 1
        je     .params.f
        cmp     [.tit], 2
        je     .params.c
        cmp     [.tit], 3
        je     .params.v
        jmp    .error                           ; invalid item type
   .params.f:                                   ; function
   .params.f.offset:                            ; function offset
        cmp     [ito], eax
        je     .error                           ; error. null function offset
        jmp    .params.out
   .params.c:                                   ; constant
        jmp    .params.out
   .params.v:                                   ; variable
   .params.v.offset:                            ; variable offset
        cmp     [ito], eax
        je     .error                           ; error. null variable offset
        jmp    .params.out
   .params.out:

        xor     ebx, ebx                        ; get name length
;       xor     rcx, rcx
        mov     ecx, [.tns]
   .scan:                                       ; scan item name
        dec     ecx                             ; until null terminating zero found or error
        js     .error                           ; error. invalid item name length
        mov     al, [edi + ebx]
        cmp     al, 0x20
        jbe    .scany
        inc     ebx
        jmp    .scan
   .scany:
        mov     [.sys], eax
        test    eax, eax
        jz     .scanz
        mov     [edi + ebx], byte 0             ; zero terminate string
   .scanz:

        cmp     ebx, 1                          ; ebx = item name length
        jne    .main
        mov     al, byte [edi]
        case    al,\
                '@', .error,\
                '.', .error,\
                '_', .error

   .main:
        mov     edi, [ina]                      ; edi = item name offset
        mov     esi, [tao]                      ; esi = table entry offset
;       xor     rcx, rcx
        mov     ecx, [esi + table.header.icount]; ecx = table item count
        xor     ebx, ebx                        ; ebx = current item index
        test    ecx, ecx
        jz     .insert
        mov     [.ecx], ecx                     ; [.ecx] = table item count
        add     esi, sizeof.table.header        ; esi = 1st item offset

   .search:
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jz     .stricmp
   .strcmp:
        cinvoke strcmp, edi, esi                ; scan table for item with name >= item name
        jmp    .strcmp.out
   .stricmp:
        cinvoke _stricmp, edi, esi              ; scan table for item with name >= item name
   .strcmp.out:
        cmp     eax, 0                          ; -> ebx - index of inserted item
        jle    .found
        add     esi, 64
        inc     ebx
        cmp     ebx, [.ecx]
        jb     .search
        jmp    .insert
   .found:
        mov     [.ebx], ebx                     ; save item index
        test    eax, eax
        jnz    .shift                           ; insert item
        cmp     [.tit], 1                       ; assign data if item already exists
        jne    .data
;       xor     rbx, rbx                        ; item is function
        mov     ebx, [.tns]
        add     esi, ebx
        cmp     [esi - 1], byte 8               ; test internal system function flag
        jne    .data.f.test
        mov     eax, [esi + 4]                  ; eax = function offset
        cmp     eax, [ito]
        je     .data.f.test
        jmp    .error                           ; error. attempt to modify internal system function offset

   .shift:
        mov     esi, [tao]                      ; esi = table entry offset
;       xor     rax, rax
        mov     eax, [esi + table.header.icount]; eax = table item count
        cmp     eax, [.tic]
        jge    .error                           ; error. item count limit exceeded
        mov     edx, eax
        shl     eax, 6                          ; eax = eax * 64

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + eax + sizeof.table.header - 4]
        add     esi, eax
        add     esi, sizeof.table.header - 4

        mov     edi, esi                        ; esi = source offset
        add     edi, 64                         ; edi = destination offset
        sub     edx, ebx                        ; edx = item count to shift
        shl     edx, 4                          ; edx = dwords to copy (count*64/04=count*16)
   .3: mov     ecx, [esi]
        mov     [edi], ecx
        sub     edi, 4
        sub     esi, 4
        dec     edx
        jnz    .3

   .insert:                                     ; ebx = item index
        mov     [.ebx], ebx                     ; save item index
        mov     esi, [tao]                      ; esi = table entry offset
;       xor     rax, rax
        mov     eax, [esi + table.header.icount]; eax = table item count
        cmp     eax, [.tic]
        jge    .error                           ; error. item count limit exceeded
        mov     edi, [ina]                      ; edi = item name offset
        shl     ebx, 6                          ; ebx = 64 * [index]

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + ebx + sizeof.table.header]
        add     esi, ebx
        add     esi, sizeof.table.header

        xor     eax, eax                        ; eax = copied char count
;       xor     rdx, rdx
        mov     edx, [.tns]                     ; edx = item name size - 1
        dec     edx
   .name:                                       ; assign item name
        mov     bl, byte [edi + eax]
        test    bl, bl
        je     .zerop
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jnz     @F
        ctolow  bl                              ; convert char to lowercase
    @@:
        mov     byte [esi + eax], bl
        inc     eax
        cmp     eax, edx
        jb     .name
        xor     bl, bl
   .zerop:                                      ; zero padding
        mov     byte [esi + eax], bl
        inc     eax
        cmp     eax, [.tns]
        jb     .zerop

   .data:
        cmp     [.tit], 1
        je     .data.f
        cmp     [.tit], 2
        je     .data.c
        cmp     [.tit], 3
        je     .data.v
        jmp    .data.out
   .data.f:                                     ; function
;       xor     rbx, rbx
        mov     ebx, [.tns]
        add     esi, ebx

   .data.f.test:
        cmp     [.sys], 0
        je     .data.f.sys.reset
   .data.f.sys.set:                             ; internal system function
        mov     [esi - 1], byte 8               ; set internal system function flag
        jmp    .data.f.params
   .data.f.sys.reset:
        mov     [esi - 1], byte 0               ; reset internal system function flag

   .data.f.params:
   .data.f.retype:                              ; set function return type
        mov     ebx, [fur]
        mov     [esi + fitem32.retype.base], bx
   .data.f.acount:                              ; set function argument count
        mov     ebx, [fua]
        mov     [esi + fitem32.acount.base], bx
   .data.f.cosize:                              ; set function code size
        mov     ebx, [fuc]
        mov     [esi + fitem32.cosize.base], bx
   .data.f.offset:                              ; set function offset
        mov     ebx, [ito]
        mov     [esi + fitem32.offset.base], ebx

        jmp    .data.out
   .data.c:                                     ; constant
;       xor     rbx, rbx
        mov     ebx, [.tns]
        add     esi, ebx

   .data.c.params:
        xor     ebx, ebx
   .data.c.cotype:                              ; set constant type
        mov     [esi + citem32.cotype.base], bx
   .data.c.datype:                              ; set constant data type
        mov     ebx, [fuc]
        mov     [esi + citem32.datype.base], bx
   .data.c.value:                               ; set constant value
        mov     ebx, dword [ito]                ; set constant value LO
        mov     [esi + citem32.value.LO.base], ebx
        mov     [esi + citem32.codata.LO.base], ebx
        mov     ebx, dword [fua]                ; set constant value HI
        mov     [esi + citem32.value.HI.base], ebx
        mov     [esi + citem32.codata.HI.base], ebx

        jmp    .data.out
   .data.v:                                     ; variable
;       xor     rbx, rbx
        mov     ebx, [.tns]
        add     esi, ebx

   .data.v.params:
        xor     ebx, ebx
   .data.v.vatype:                              ; set variable type
        mov     [esi + vitem32.vatype.base], bx
   .data.v.datype:                              ; set variable data type
        mov     ebx, [fuc]
        mov     [esi + vitem32.datype.base], bx
   .data.v.offset:                              ; set variable offset
        mov     ebx, [ito]
        mov     [esi + vitem32.offset.base], ebx
        mov     [esi + vitem32.vadata.base], ebx
    $ifdef _X32
        xor     ebx, ebx
        mov     [esi + vitem32.offset.HI.base], ebx
        mov     [esi + vitem32.vadata.HI.base], ebx
    $end

        jmp    .data.out
   .data.out:

        mov     esi, [tao]                      ; esi = table entry offset
        test    eax, eax
        jz     .success                         ; increment item count,
        inc     [esi + table.header.icount]     ; if new item was inserted
   .success:
        mov     eax, [.ebx]                     ; eax = item index
        jmp    .return
   .error:
        mov     eax, -1                         ; eax = -1 (error)
   .return:
;       xor     rdx, rdx
        mov     edx, [esi + table.header.icount]; edx = table item count
        pop     edi esi ebx
        ret
$endp ; taset

; ------------------------------------------------------------------------------

; INT tinva ( LPVOID tao, LPCSTR ina )
; invalidate table item ( item offset -> 0 )
;
; -> tao : table offset
; -> ina : item name to invalidate
; <- eax : item index or negative value on error
$proc tinva, tao, ina

;       mov     [tao], rcx
;       mov     [ina], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    edi

        stdcall taget, [tao], [ina], -1
        cmp     eax, 0
        jl     .return                          ; eax = item index

        mov     edx, eax                        ; save result
        mov     edi, [tao]                      ; edi = table offset

;       xor     rcx, rcx
        mov     ecx, [edi + table.header.titype]
        shl     eax, 6                          ; eax = 64 * [item index]
        add     edi, eax
        mov     eax, edx                        ; restore result
        add     edi, sizeof.table.header        ; edi = [table offset] + [table header size] + 64 * [item index]

        cmp     ecx, 1
        je     .fun
        cmp     ecx, 2
        je     .con
        cmp     ecx, 3
        je     .var
        mov     eax, -1
        jmp    .return

   .fun:
        mov     [edi + fitem32.offset], 0
        jmp    .return
   .con:
        mov     [edi + citem32.datype], 0
    $ifdef _X64
        mov     qword [rdi + citem64.value], -1
    $else
        mov     dword [edi + citem32.value + 0], -1
        mov     dword [edi + citem32.value + 4], -1
    $end
        jmp    .return
   .var:
        mov     [edi + vitem32.datype], 0
        mov     [edi + vitem32.offset], 0
        jmp    .return

   .return:
        pop     edi
        ret
$endp ; tinva

; ------------------------------------------------------------------------------

; INT rtaget ( LPVOID tao, LPCSTR ina, INT ins )
; find item in runtime table
; case insensitive or case sensitive (depends on SIC_CFG_FLAG_CASE_SENSITIVE flag)
;
; -> tao : table offset
; -> ina : item name to search
; -> ins : item name size
;          ins < 0, assume item name zero terminated & calculate it's size
; <- eax : item index or negative value on error
; <- edx : item offset or zero on error
$proc rtaget, tao, ina, ins

    locals
       .ins     dd ?
       .tic     dd ?
    endl

;       mov     [tao], rcx
;       mov     [ina], rdx
;       mov     [ins], r8
;       mov     [], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        xor     eax, eax                        ; eax = 0
        xor     edx, edx                        ; edx = 0

        mov     esi, [tao]                      ; esi = table offset
        test    esi, esi
        jz     .error                           ; error. null table

        mov     edx, [esi + table.header.icount]; edx = table item count
        test    edx, edx
        jz     .error                           ; error. empty table
        mov     [.tic], edx                     ; save table item count in [.tic]

;       xor     rbx, rbx
        mov     ebx, [esi + table.header.tnsize]; ebx = table item name size

        mov     edi, [ina]                      ; edi = item name offset
        test    edi, edi
        jz     .error                           ; error. null item name

        mov     edx, [ins]
        cmp     edx, eax
        jg     .begin
        je     .error                           ; error. empty item name

        xor     edx, edx                        ; get item name size
   .scan:                                       ; scan item name
        cmp     byte [edi + edx], 0             ; until null terminating zero found
        je     .scan.out
        inc     edx
        cmp     edx, ebx
        jb     .scan
   .scan.out:
        test    edx, edx
        jz     .error                           ; error. empty item name

   .begin:
        mov     [.ins], edx
        cmp     edx, ebx
        jae    .error                           ; error. invalid item name size

        xor     ebx, ebx
        add     esi, sizeof.table.header        ; esi = current item offset

   .search:
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jz     .strnicmp
   .strncmp:
        cinvoke strncmp, edi, esi, [.ins]       ; scan table for item with name = item name
        jmp    .strncmp.out
   .strnicmp:
        cinvoke _strnicmp, edi, esi, [.ins]     ; scan table for item with name = item name
   .strncmp.out:
        test    eax, eax
        jz     .match
   .search.next:
        add     esi, 64
        inc     ebx
        cmp     ebx, [.tic]
        jb     .search
        jmp    .error
   .match:
        mov     ecx, [.ins]
        cmp     byte [esi + ecx], 0
        jnz    .search.next
   .found:
        mov     eax, ebx
        jmp    .return

   .error:
        mov     eax, -1                         ; error. eax = -1, edx = 0
        xor     edx, edx
        jmp    .leave

   .return:
        mov     edx, esi                        ; edx = item offset

   .leave:
        pop     edi esi ebx
        ret
$endp ; rtaget

; ------------------------------------------------------------------------------

; INT rtaset ( LPVOID tao, LPCSTR ina, LPVOID ito, INT16 fua, INT16 fuc )
; add item to the runtime table with lowercasing (~SIC_CFG_FLAG_CASE_SENSITIVE) and no sorting
;
; -> tao : table offset
; -> ina : item name
; -> ito : variable or function offset, constant value LO
; -> fua : function argument count, constant value HI
; -> fuc : function code size, constant data type
; <- eax : item offset or zero on error
$proc rtaset, tao, ina, ito, fua, fuc

    locals
       .ecx     dd ?
       .ebx     dd ?
       .tic     dd ?
       .tns     dd ?
       .tit     dd ?
       .tio     dd ?
    endl

;       mov     [tao], rcx
;       mov     [ina], rdx
;       mov     [ito], r8
;       mov     [fua], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        xor     eax, eax                        ; eax = 0
        mov     [.ebx], eax

        mov     esi, [tao]                      ; esi = table entry offset
        test    esi, esi
        jz     .error                           ; error. null table

        mov     edx, [esi + table.header.mcount]
        mov     [.tic], edx                     ; get table item max count
        mov     edx, [esi + table.header.tnsize]
        mov     [.tns], edx                     ; get table item name size
        mov     edx, [esi + table.header.titype]
        mov     [.tit], edx                     ; get table item type

        mov     edi, [ina]                      ; edi = item name offset
        test    edi, edi
        jz     .error                           ; error. null item name

   .params:                                     ; parameters test
        cmp     [.tit], 2
        jne    .error                           ; invalid item type

        cld                                     ; get name length
;       xor     rcx, rcx
        mov     ecx, [.tns]
   .scasb:                                      ; scan item name
        dec     ecx                             ; until null terminating zero found or error
        js     .error                           ; error. invalid item name length
        scasb
        jnz    .scasb

        mov     edi, [ina]                      ; edi = item name offset
        mov     esi, [tao]                      ; esi = table entry offset
;       xor     rcx, rcx
        mov     ecx, [esi + table.header.icount]; ecx = table item count
        xor     ebx, ebx                        ; ebx = current item index
        test    ecx, ecx
        jz     .insert
        mov     [.ecx], ecx                     ; [.ecx] = table item count
        add     esi, sizeof.table.header        ; esi = 1st item offset

   .search:
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jz     .stricmp
   .strcmp:
        cinvoke strcmp, edi, esi                ; scan table for item with name = item name
        jmp    .strcmp.out
   .stricmp:
        cinvoke _stricmp, edi, esi              ; scan table for item with name = item name
   .strcmp.out:
        test    eax, eax                        ; -> ebx - index of inserted item
        jz     .found
        add     esi, 64
        inc     ebx
        cmp     ebx, [.ecx]
        jb     .search
        jmp    .insert
   .found:
        mov     [.ebx], ebx                     ; save item index
        test    eax, eax
        je     .data                            ; assign data if item already exists

   .insert:                                     ; ebx = item index
        mov     [.ebx], ebx                     ; save item index
        mov     esi, [tao]                      ; esi = table entry offset
;       xor     rax, rax
        mov     eax, [esi + table.header.icount]; eax = table item count
        cmp     eax, [.tic]
        jge    .error                           ; error. item count limit exceeded
        mov     edi, [ina]                      ; edi = item name offset
        shl     ebx, 6                          ; ebx = 64 * [index]

;       some AV-engines go crazy about lea esi, [esi...]
;       lea     esi, [esi + ebx + sizeof.table.header]
        add     esi, ebx
        add     esi, sizeof.table.header

        xor     eax, eax                        ; eax = copied char count
;       xor     rdx, rdx
        mov     edx, [.tns]                     ; edx = item name size - 1
        dec     edx
   .name:                                       ; assign item name
        mov     bl, byte [edi + eax]
        test    bl, bl
        je     .zerop
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jnz     @F
        ctolow  bl                              ; convert char to lowercase
    @@:
        mov     byte [esi + eax], bl
        inc     eax
        cmp     eax, edx
        jb     .name
        xor     bl, bl
   .zerop:                                      ; zero padding
        mov     byte [esi + eax], bl
        inc     eax
        cmp     eax, [.tns]
        jb     .zerop

   .data:
        mov     [.tio], esi                     ; save table item offset
;       xor     rbx, rbx
        mov     ebx, [.tns]
        add     esi, ebx

   .data.c.params:
        xor     ebx, ebx
   .data.c.cotype:                              ; set constant type
        mov     [esi + citem32.cotype.base], bx
   .data.c.datype:                              ; set constant data type
        mov     ebx, [fuc]
        mov     [esi + citem32.datype.base], bx
   .data.c.value:                               ; set constant value
        mov     ebx, dword [ito]                ; set constant value LO
        mov     [esi + citem32.value.LO.base], ebx
        mov     [esi + citem32.codata.LO.base], ebx
        mov     ebx, dword [fua]                ; set constant value HI
        mov     [esi + citem32.value.HI.base], ebx
        mov     [esi + citem32.codata.HI.base], ebx

        mov     esi, [tao]                      ; esi = table entry offset
        test    eax, eax
        jz     .success                         ; increment item count,
        inc     [esi + table.header.icount]     ; if new item was inserted

   .success:
        mov     eax, [.tio]                     ; eax = table item offset
        jmp    .return
   .error:
        xor     eax, eax                        ; eax = 0 (error)
   .return:
        pop     edi esi ebx
        ret
$endp ; rtaset

; ------------------------------------------------------------------------------

; INT nrtaget ( LPVOID sic, LPCSTR ina, INT ins )
; find item in any of non runtime tables
; case insensitive or case sensitive (depends on SIC_CFG_FLAG_CASE_SENSITIVE flag)
;
; -> sic : T_sic_data structure offset
; -> ina : item name to search
; -> ins : item name size
; <- eax : table id or zero on error
; <- edx : item offset or zero on error
$proc nrtaget, sic, ina, ins

    locals
       .fdata   dd ?                            ; function data segment offset
       .cdata   dd ?                            ; constant data segment offset
       .vdata   dd ?                            ; variable data segment offset
    endl

;       mov     [sic], rcx
;       mov     [ina], rdx
;       mov     [ins], r8
;       mov     [], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        cmp     [ins], 0
        jle    .error

        xor     ebx, ebx
        mov     edi, [ina]
        mov     cl, byte [edi]
        cmp     cl, '#'
        jne     @F
        dec     [ins]
        jle    .error
        inc     edi
        inc     ebx
    @@:

        mov     esi, [sic]                      ; esi = T_sic_data structure offset
        test    esi, esi
        jz     .global                          ; test global

        mov     ecx, [esi + T_sic_data.fdata]   ; ecx = function data segment offset
        mov     [.fdata], ecx                   ; [.fdata] = function data segment offset

        mov     ecx, [esi + T_sic_data.cdata]   ; ecx = constant data segment offset
        mov     [.cdata], ecx                   ; [.cdata] = constant data segment offset

        mov     ecx, [esi + T_sic_data.vdata]   ; ecx = variable data segment offset
        mov     [.vdata], ecx                   ; [.vdata] = variable data segment offset

        test    ebx, ebx
        jnz    .global                          ; test global first

   .local:
        stdcall taget, [.cdata], edi, [ins]     ; ? local named constant (constant data segment of sic structure)
        mov     eax, 1                          ; edx = table item offset value
        test    edx, edx
        jnz    .leave
        stdcall taget, [.vdata], edi, [ins]     ; ? local variable (variable data segment of sic structure)
        mov     eax, 2                          ; edx = table item offset value
        test    edx, edx
        jnz    .leave
        stdcall taget, [.fdata], edi, [ins]     ; ? local function (function data segment of sic structure)
        mov     eax, 3                          ; edx = table item offset value
        test    edx, edx
        jnz    .leave
        test    ebx, ebx
        jnz    .error

   .global:
        stdcall taget, [@_CDATA], edi, [ins]    ; ? global named constant
        mov     eax, 4                          ; edx = table item offset value
        test    edx, edx
        jnz    .leave
        stdcall taget, [@_VDATA], edi, [ins]    ; ? global variable
        mov     eax, 5                          ; edx = table item offset value
        test    edx, edx
        jnz    .leave
        stdcall taget, [@_FDATA], edi, [ins]    ; ? global function
        mov     eax, 6                          ; edx = table item offset value
        test    edx, edx
        jnz    .leave
        test    esi, esi
        jz     .error
        test    ebx, ebx
        jnz    .local                           ; test local after global

   .error:
        xor     eax, eax                        ; eax = 0 (error)
        xor     edx, edx
   .leave:
        pop     edi esi ebx
        ret
$endp ; nrtaget

; ------------------------------------------------------------------------------

; ? ctagettio ( LPVOID tao, LPVOID tio )
; search item in constant table by table.item.offset value
; assume size of table item is 64 bytes
;
; !!! don`t change eax register
;
; -> tao : table offset
; -> tio : table.item.offset value
; <- edx : item offset or zero on error
$proc ctagettio, tao, tio

;       mov     [tao], rcx
;       mov     [tio], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifndef _X64
        push    eax
        push    ebx
    $end

        mov     ecx, [tao]                      ; ecx = table offset
        test    ecx, ecx
        jz     .error                           ; error. null table

        mov     eax, [ecx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .error                           ; error. empty table

        mov     edx, [tio]
        add     ecx, sizeof.table.header        ; ecx = current item offset
   .scan:
;       mov     blb, byte [ecx + citem32.datype]
;       cmp     blb, 's'                        ; ? string
;       jne    .scan.offset
   .scan.string:
        lea     ebx, [ecx + citem32.offset]     ; ebx = table.offset address
        cmp     ebx, edx
        jne    .scan.offset
        mov     edx, ecx
        jmp    .leave
   .scan.offset:
        cmp     edx, [ebx]
        jne    .scan.next
        mov     edx, ecx
        jmp    .leave
   .scan.next:
        add     ecx, 64                         ; ecx = next item offset
        dec     eax
        jns    .scan

   .error:
        xor     edx, edx                        ; error. edx = 0

   .leave:
    $ifndef _X64
        pop     ebx
        pop     eax
    $end
        ret
$endp ; ctagettio

; ------------------------------------------------------------------------------

; ? vtagettio ( LPVOID tao, LPVOID tio )
; search item in variable table by table.item.offset value
; assume size of table item is 64 bytes
;
; !!! don`t change eax register
;
; -> tao : table offset
; -> tio : table.item.offset value
; <- edx : item offset or zero on error
$proc vtagettio, tao, tio

;       mov     [tao], rcx
;       mov     [tio], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifndef _X64
        push    eax
        push    ebx
    $end

        mov     ecx, [tao]                      ; ecx = table offset
        test    ecx, ecx
        jz     .error                           ; error. null table

        mov     eax, [ecx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .error                           ; error. empty table

        mov     edx, [tio]
        add     ecx, sizeof.table.header        ; ecx = current item offset
   .scan:
;       mov     blb, byte [ecx + vitem32.datype]
;       cmp     blb, 's'                        ; ? string
;       jne    .scan.offset
   .scan.string:
        lea     ebx, [ecx + vitem32.offset]     ; ebx = table.offset address
        cmp     ebx, edx
        jne    .scan.offset
        mov     edx, ecx
        jmp    .leave
   .scan.offset:
        cmp     edx, [ebx]
        jne    .scan.next
        mov     edx, ecx
        jmp    .leave
   .scan.next:
        add     ecx, 64                         ; ecx = next item offset
        dec     eax
        jns    .scan

   .error:
        xor     edx, edx                        ; error. edx = 0

   .leave:
    $ifndef _X64
        pop     ebx
        pop     eax
    $end
        ret
$endp ; vtagettio

; ------------------------------------------------------------------------------

; ? tagettio ( LPVOID sic, LPVOID tio )
; search item in constant and variable tables by table.item.offset value
; assume size of table item is 64 bytes
;
; !!! don`t change eax register
;
; -> sic : T_sic_data structure offset
; -> tio : table.item.offset value
; <- edx : item offset or zero on error
$proc tagettio, sic, tio

    locals
       .rdata   dd ?                            ; runtime data segment offset
       .cdata   dd ?                            ; constant data segment offset
       .vdata   dd ?                            ; variable data segment offset
    endl

;       mov     [sic], rcx
;       mov     [tio], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifndef _X64
        push    eax
    $end

        mov     ecx, [sic]                      ; ecx = T_sic_data structure offset
        test    ecx, ecx
        jz     .error                           ; error. null T_sic_data structure

        mov     eax, [ecx + T_sic_data.rdata]   ; eax = runtime data segment offset
        mov     [.rdata], eax
        mov     eax, [ecx + T_sic_data.cdata]   ; eax = constant data segment offset
        mov     [.cdata], eax
        mov     eax, [ecx + T_sic_data.vdata]   ; eax = variable data segment offset
        mov     [.vdata], eax

        stdcall ctagettio, [.rdata], [tio]
        test    edx, edx
        jnz    .leave
        stdcall vtagettio, [.vdata], [tio]
        test    edx, edx
        jnz    .leave
        stdcall vtagettio, [@_VDATA], [tio]
        test    edx, edx
        jnz    .leave

        stdcall vtagettio, [.cdata], [tio]
        test    edx, edx
        jnz    .leave
        stdcall vtagettio, [@_CDATA], [tio]
        test    edx, edx
        jnz    .leave

   .error:
        xor     edx, edx                        ; error. edx = 0

   .leave:
    $ifndef _X64
        pop     eax
    $end
        ret
$endp ; tagettio

; ------------------------------------------------------------------------------

; set system table items
; -> rdata - table offset
; <- eax   - last table item offset
$proc sysset, rdata

    macro .set.o name
    {
        mov     edx, name
        xor     eax, eax
        mov     al, 'o'
        stdcall rtaset, [rdata], edx, 0, 0, eax
    }

    macro .set.f name
    {
        mov     edx, name
        xor     eax, eax
        mov     al, 'f'
        stdcall rtaset, [rdata], edx, 0, 0, eax
    }

    macro .set.i name
    {
        mov     edx, name
        xor     eax, eax
        mov     al, 'i'
        stdcall rtaset, [rdata], edx, 0, 0, eax
    }

;       mov     [rdata], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

       .set.o   ??exit.name
;      .set.f   ??d?0.name
;      .set.i   ??i?0.name

   .return:
        ret
$endp ; tsysset

; ------------------------------------------------------------------------------

; update tables related data
$proc tupdate

    macro .fupdate fun, dst
    {
        stdcall taget, [@_FDATA], fun#.fname, fun#.nsize
        mov     dst, edx
    }

        push    eax ecx edx

       .fupdate ??nop, [??.nop]

       .fupdate ??var.double, [??.var.double]
       .fupdate ??var.complex, [??.var.complex]
       .fupdate ??var.integer, [??.var.integer]
       .fupdate ??var.string, [??.var.string]

       .fupdate @@absolute, [??.absolute]
       .fupdate @@assign, [??.assign]
       .fupdate @@reassign, [??.reassign]

       .fupdate @@addr, [??.addr]
       .fupdate ??addr.1P, [??.addr.1P]
       .fupdate ??addr.2P, [??.addr.2P]

       .fupdate @@tcarg, [??.tcarg]

       .fupdate @@pdouble, [??.pdouble]
       .fupdate @@pcomplex, [??.pcomplex]

       .fupdate @@copy, [??.copy]
       .fupdate @@copx, [??.copx]
       .fupdate @@xcopy, [??.xcopy]
       .fupdate @@swap, [??.swap]

       .fupdate @@ccopy, [??.ccopy]
       .fupdate @@cswap, [??.cswap]

       .fupdate @@cadd, [??.cadd]
       .fupdate @@csub, [??.csub]
       .fupdate @@csubr, [??.csubr]
       .fupdate @@cmul, [??.cmul]
       .fupdate @@cdiv, [??.cdiv]
       .fupdate @@cdivr, [??.cdivr]
       .fupdate @@cpow, [??.cpow]
       .fupdate @@cpowr, [??.cpowr]
       .fupdate @@croot, [??.croot]
       .fupdate @@crootr, [??.crootr]

       .fupdate @@co.chs, [??.co.chs]
       .fupdate @@co.sub, [??.co.sub]
       .fupdate @@co.rcopy, [??.co.rcopy]
       .fupdate @@co.rxcopy, [??.co.rxcopy]

       .fupdate ??vint, [??.vint]
       .fupdate @@int, [??.int]
       .fupdate @@intto, [??.intto]
       .fupdate ??vfrac, [??.vfrac]
       .fupdate @@frac, [??.frac]
       .fupdate @@fracto, [??.fracto]
       .fupdate ??vround, [??.vround]
       .fupdate @@round, [??.round]
       .fupdate @@roundto, [??.roundto]

       .fupdate ??1D.1P.matrip, [??.1D.1P.matrip]
       .fupdate ??1D.2P.matrip, [??.1D.2P.matrip]
       .fupdate ??1D.matrip.rc, [??.1D.matrip.rc]
       .fupdate ??2D.3P.matrip, [??.2D.3P.matrip]
       .fupdate ??2D.4P.matrip, [??.2D.4P.matrip]
       .fupdate ??2D.matrip.rc, [??.2D.matrip.rc]

       .fupdate @@farr, [??.farr]
       .fupdate @@barr, [??.barr]
       .fupdate @@farw, [??.farw]
       .fupdate @@barw, [??.barw]
       .fupdate @@farv, [??.farv]
       .fupdate @@barv, [??.barv]

       .fupdate @@pfarr, [??.pfarr]
       .fupdate @@pbarr, [??.pbarr]
       .fupdate @@pfarw, [??.pfarw]
       .fupdate @@pbarw, [??.pbarw]

       .fupdate @@bt, [??.bt]
       .fupdate @@btc, [??.btc]
       .fupdate @@btr, [??.btr]
       .fupdate @@bts, [??.bts]

       .fupdate @@bnot, [??.bnot]
       .fupdate @@bor, [??.bor]
       .fupdate @@bnor, [??.bnor]
       .fupdate @@born, [??.born]
       .fupdate @@bnorn, [??.bnorn]
       .fupdate @@borc, [??.borc]
       .fupdate @@bnorc, [??.bnorc]
       .fupdate @@bcor, [??.bcor]
       .fupdate @@bcorn, [??.bcorn]
       .fupdate @@bxor, [??.bxor]
       .fupdate @@bxnor, [??.bxnor]
       .fupdate @@band, [??.band]
       .fupdate @@bnand, [??.bnand]
       .fupdate @@bandn, [??.bandn]
       .fupdate @@bnandn, [??.bnandn]
       .fupdate @@breset, [??.breset]
       .fupdate @@bset, [??.bset]
       .fupdate @@shr, [??.shr]
       .fupdate @@shl, [??.shl]
       .fupdate @@sar, [??.sar]
       .fupdate @@sal, [??.sal]
       .fupdate @@ror, [??.ror]
       .fupdate @@rol, [??.rol]

       .fupdate @@ot, [??.ot]
       .fupdate @@not, [??.not]
       .fupdate @@or, [??.or]
       .fupdate @@nor, [??.nor]
       .fupdate @@xor, [??.xor]
       .fupdate @@xnor, [??.xnor]
       .fupdate @@and, [??.and]
       .fupdate @@nand, [??.nand]

       .fupdate @@if.e, [??.if.e]

       .fupdate @@fldz, [??.fldz]
       .fupdate @@fld1, [??.fld1]
       .fupdate @@setz, [??.setz]

       .fupdate @@sign, [??.sign]
;      .fupdate @@isign, [??.isign]
       .fupdate @@nzero, [??.nzero]

       .fupdate @@uplus, [??.uplus]
       .fupdate @@chs, [??.chs]
       .fupdate @@abs, [??.abs]
       .fupdate @@nabs, [??.nabs]
       .fupdate @@inv, [??.inv]
       .fupdate @@inc, [??.inc]
       .fupdate @@inc.pre, [??.inc.pre]
       .fupdate @@inc.post, [??.inc.post]
       .fupdate @@dec, [??.dec]
       .fupdate @@dec.pre, [??.dec.pre]
       .fupdate @@dec.post, [??.dec.post]
       .fupdate @@add, [??.add]
       .fupdate @@add.pos, [??.add.pos]
       .fupdate @@sub, [??.sub]
       .fupdate @@sub.neg, [??.sub.neg]
       .fupdate @@subr, [??.subr]
       .fupdate @@mul, [??.mul]
       .fupdate @@div, [??.div]
       .fupdate @@divr, [??.divr]
       .fupdate @@quo, [??.quo]
       .fupdate @@quor, [??.quor]
       .fupdate @@mod, [??.mod]
       .fupdate @@modr, [??.modr]
       .fupdate @@min, [??.min]
       .fupdate @@max, [??.max]
       .fupdate @@mean, [??.mean]
       .fupdate @@adev, [??.adev]
       .fupdate @@pow, [??.pow]
       .fupdate ??pow.??, [??.pow.??]
       .fupdate @@powr, [??.powr]
       .fupdate ??powr.??, [??.powr.??]
       .fupdate @@pow2, [??.pow2]
       .fupdate @@root, [??.root]
       .fupdate @@rootr, [??.rootr]
       .fupdate @@r2d, [??.r2d]

       .fupdate @@hypot3, [??.hypot3]

       .fupdate @@int, [??.int]
       .fupdate @@intto, [??.intto]
       .fupdate @@frac, [??.frac]
       .fupdate @@fracto, [??.fracto]
       .fupdate @@round, [??.round]
       .fupdate @@roundto, [??.roundto]

       .fupdate @@varg.z, [??.varg.z]
       .fupdate @@varg.nz, [??.varg.nz]
       .fupdate @@varg.az, [??.varg.az]
       .fupdate @@varg.aez, [??.varg.aez]
       .fupdate @@varg.bz, [??.varg.bz]
       .fupdate @@varg.bez, [??.varg.bez]
       .fupdate @@varg.e, [??.varg.e]
       .fupdate @@varg.ne, [??.varg.ne]
       .fupdate @@varg.a, [??.varg.a]
       .fupdate @@varg.ae, [??.varg.ae]
       .fupdate @@varg.b, [??.varg.b]
       .fupdate @@varg.be, [??.varg.be]

       .fupdate @@exit, [??.exit]
       .fupdate @@exit.if.true, [??.exit.if.true]
       .fupdate @@exit.if.false, [??.exit.if.false]
       .fupdate @@return, [??.return]
       .fupdate ??returnv, [??.returnv]
       .fupdate ??returnv.if.true, [??.returnv.if.true]
       .fupdate ??returnv.if.false, [??.returnv.if.false]

        pop     edx ecx eax

   .return:
        ret
$endp ; tupdate

; ------------------------------------------------------------------------------

; VOID vmalign ( LPVOID sic, INT ava )
; runtime variables memory alignment
;
; -> sic : T_sic_data structure offset
; -> ava : alignment value
$proc vmalign, sic, ava

    macro .proc.enter
    {
      $ifdef _X64
        push    rax rdx
      $else
        push    eax edx
      $end
    }

    macro .proc.leave
    {
      $ifdef _X64
        pop     rdx rax
      $else
        pop     edx eax
      $end
    }

;       mov     [sic], rcx
;       mov     [ava], rdx
;       mov     [], r8
;       mov     [], r9

       .proc.enter

        mov     ecx, [sic]
        test    ecx, ecx
        jz     .return

        mov     edx, [ecx + T_sic_data.dsize]
        add     edx, [ecx + T_sic_data.data]    ; edx = current data cursor

   .data.align.in:
        cmp     [ava], 0
        jle    .data.align.out
        cmp     [ava], 64
        jg     .data.align.out
   .data.align.begin:
        push    ecx
        mov     eax, edx
        xor     edx, edx
        mov     ecx, [ava]
        div     ecx
        sub     ecx, edx
        mov     eax, ecx
        pop     ecx
        add     [ecx + T_sic_data.dsize], eax
        sub     [ecx + T_sic_data.dspace], eax
   .data.align.out:

   .return:
       .proc.leave
        ret
$endp

; ------------------------------------------------------------------------------

; INT arun ( LPVOID sic, LPCSTR con, INT cof, INT ava )
; add|set runtime object ( con )
;
; -> sic : T_sic_data structure offset
; -> con : constant name
; -> cof : constant flags
;          ?  - undefined
;          f  - double constant
;          i  - integer constant
;          s  - string constant
;          p  - pointer constant
;          o  - offset constant
;          f1 - offset of 1 double float
;          f2 - offset of 2 double floats
;          i1 - offset of 1 integer
; -> ava : alignment value
; <- eax : item offset or zero on error
; <- edx : data offset or zero on error
$proc arun, sic, con, cof, ava

    macro .proc.enter
    {
      $ifdef _X64
        push    rsi
      $else
        push    ebx esi
      $end
    }

    macro .proc.leave
    {
      $ifdef _X64
        pop     rsi
      $else
        pop     esi ebx
      $end
    }

;       mov     [sic], rcx
;       mov     [con], rdx
;       mov     [cof], r8
;       mov     [ava], r9

       .proc.enter

        mov     ecx, [sic]
        test    ecx, ecx
        jz     .error

        mov     esi, ecx
        mov     ecx, [esi + T_sic_data.rdata]   ; ecx = runtime data segment offset
        stdcall rtaset, ecx, [con], 0, 0, [cof] ; add runtime item
        test    eax, eax
        jz     .error

        mov     edx, [esi + T_sic_data.dsize]
        add     edx, [esi + T_sic_data.data]    ; edx = current data cursor

   .data.align.in:                              ; runtime variables memory alignment
        cmp     [ava], 0
        jle    .data.align.out
        cmp     [ava], 64
        jg     .data.align.out
   .data.align.begin:
        xor     ebx, ebx
        push    eax edx
        mov     eax, edx
        xor     edx, edx
        mov     ecx, [ava]
        div     ecx
;       test    edx, edx
;       jz     .data.align.end
        sub     ecx, edx
        mov     ebx, ecx
        add     [esi + T_sic_data.dsize], ecx
        sub     [esi + T_sic_data.dspace], ecx
   .data.align.end:
        pop     edx eax
        add     edx, ebx
   .data.align.out:

        mov     ecx, [cof]
        cmp     cx, 'f1'
        je     .f1
        cmp     cx, 'i1'
        je     .i1
        cmp     cx, 'f2'
        je     .f2
        jmp    .return

   .i4:
        mov     ebx, 16
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
        mov     [rdx + 16], rcx
        mov     [rdx + 24], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
        mov     [edx + 08], ecx
        mov     [edx + 12], ecx
    $end
        jmp    .i.assign

   .i3:
        mov     ebx, 12
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
        mov     [rdx + 16], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
        mov     [edx + 08], ecx
    $end
        jmp    .i.assign

   .i2:
        mov     ebx, 08
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
    $end
        jmp    .i.assign

   .i1:
        mov     ebx, 04
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
    $else
        mov     [edx + 00], ecx
    $end

   .i.assign:
        mov     [eax + citem32.offset], edx
    $ifdef _X64
        mov     [rax + citem64.codata], rdx
    $else
        mov     dword [eax + citem32.codata + 0], edx
        mov     dword [eax + citem32.codata + 4], ecx
    $end
        add     [esi + T_sic_data.dsize], ebx
        sub     [esi + T_sic_data.dspace], ebx
        jmp    .return

   .f4:
        mov     ebx, 32
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
        mov     [rdx + 16], rcx
        mov     [rdx + 24], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
        mov     [edx + 08], ecx
        mov     [edx + 12], ecx
        mov     [edx + 16], ecx
        mov     [edx + 20], ecx
        mov     [edx + 24], ecx
        mov     [edx + 28], ecx
    $end
        jmp    .f.assign

   .f3:
        mov     ebx, 24
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
        mov     [rdx + 16], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
        mov     [edx + 08], ecx
        mov     [edx + 12], ecx
        mov     [edx + 16], ecx
        mov     [edx + 20], ecx
    $end
        jmp    .f.assign

   .f2:
        mov     ebx, 16
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
        mov     [edx + 08], ecx
        mov     [edx + 12], ecx
    $end
        jmp    .f.assign

   .f1:
        mov     ebx, 08
        cmp     [esi + T_sic_data.dspace], ebx
        jb     .error
        xor     ecx, ecx
    $ifdef _X64
        mov     [rdx + 00], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
    $end

   .f.assign:
        mov     [eax + citem32.offset], edx
    $ifdef _X64
        mov     [rax + citem64.codata], rdx
    $else
        mov     dword [eax + citem32.codata + 0], edx
        mov     dword [eax + citem32.codata + 4], ecx
    $end
        add     [esi + T_sic_data.dsize], ebx
        sub     [esi + T_sic_data.dspace], ebx
;       jmp    .return

   .return:
       .proc.leave
        ret

   .error:
        xor     eax, eax
        xor     edx, edx
       .proc.leave
        ret
$endp

; ------------------------------------------------------------------------------

; INT costr ( LPVOID sic, LPVOID sdo, INT sds )
; copy string to data segment
;
; -> sic : T_sic_data structure offset
; -> sdo : string offset
; -> sds : string size
; <- eax : data offset or zero on error
; <- ecx : data size or zero on error
$proc costr, sic, sdo, sds

;       mov     [sic], rcx
;       mov     [sdo], rdx
;       mov     [sds], r8
;       mov     [], r9

   .enter:
        pushsa  esi                             ; push & 16-byte stack align for x64

        mov     ecx, [sic]
        test    ecx, ecx
        jz     .error

        mov     edx, [sdo]
        test    edx, edx
        jz     .error

        mov     esi, ecx
    $ifdef _X64
        cmp     [rsi + T_sic_data.dspace], r8d
        jbe    .error
    $else
        mov     ecx, [sds]
        cmp     [esi + T_sic_data.dspace], ecx
        jbe    .error
    $end
        ; LPTSTR lstrcpyn ( LPTSTR, LPTSTR, INT )
    $ifdef _X64
        mov     ecx, [rsi + T_sic_data.dsize]
        add     rcx, [rsi + T_sic_data.data]    ; rcx = current data cursor
        inc     r8
;       invoke  lstrcpyn, rcx, rdx, r8
        cinvoke strncpy, rcx, rdx, r8
    $else
        mov     eax, [esi + T_sic_data.dsize]
        add     eax, [esi + T_sic_data.data]    ; eax = current data cursor
        inc     ecx
;       invoke  lstrcpyn, eax, edx, ecx
        cinvoke strncpy, eax, edx, ecx
    $end
        test    eax, eax
        jz     .error

        mov     ecx, [sds]
        mov     byte [eax + ecx], 0
        lea     edx, [ecx + 1]
        add     [esi + T_sic_data.dsize], edx
        sub     [esi + T_sic_data.dspace], edx

   .return:
        pop     esi
        ret

   .error:
        pop     esi
        xor     eax, eax
        xor     ecx, ecx
        ret
$endp

; ------------------------------------------------------------------------------

; VOID conoup ( LPVOID cto, INT_PTR off )
; update offset values in constant table
;
; -> cto : constant table offset
; -> off : offset delta value
$proc conoup, cto, off

;       mov     [cto], rcx
;       mov     [off], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    esi

        mov     ecx, [cto]                      ; ecx = table offset
        test    ecx, ecx
        jz     .leave                           ; return. null table
        mov     edx, [off]                      ; edx = delta value
        test    edx, edx
        jz     .leave                           ; return. no delta

;       xor     rax, rax
        mov     eax, [ecx + table.header.titype]; eax = table item type
        cmp     eax, 2
        jne    .leave                           ; return. non constant table
        mov     eax, [ecx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .leave                           ; return. empty table

        lea     esi, [ecx + sizeof.table.header - 64]
   .scan:
        add     esi, 64                         ; esi = table item offset
        mov     cx, [esi + citem32.datype]
        cmp     cx, 'o'
        jne    .next
   .test:
        mov     ecx, [esi + citem32.offset]
        test    ecx, ecx
        jz     .next
   .update:
        add     ecx, edx                        ; update non null values only
        mov     [esi + citem32.offset], ecx
   .next:
        dec     eax
        jnz    .scan

   .leave:
        pop     esi
        ret
$endp ; conoup

; ------------------------------------------------------------------------------

; VOID datoup ( LPVOID cto, INT_PTR off )
; update data offset values in constant table
;
; -> cto : constant table offset
; -> off : offset delta value
$proc datoup, cto, off

;       mov     [cto], rcx
;       mov     [off], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    esi

        mov     ecx, [cto]                      ; ecx = table offset
        test    ecx, ecx
        jz     .leave                           ; return. null table
        mov     edx, [off]                      ; edx = delta value
        test    edx, edx
        jz     .leave                           ; return. no delta

;       xor     rax, rax
        mov     eax, [ecx + table.header.titype]; eax = table item type
        cmp     eax, 2
        jne    .leave                           ; return. non constant table
        mov     eax, [ecx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .leave                           ; return. empty table

        lea     esi, [ecx + sizeof.table.header - 64]
   .scan:
        add     esi, 64                         ; esi = table item offset
        mov     cx, [esi + citem32.datype]
        cmp     cx, 'f1'
        je     .test
        cmp     cx, 'i1'
        je     .test
        cmp     cx, 'f2'
        je     .test
        jmp    .next
   .test:
        mov     ecx, [esi + citem32.offset]
        test    ecx, ecx
        jz     .next
   .update:
        add     ecx, edx                        ; update non null values only
        mov     [esi + citem32.offset], ecx
   .next:
        dec     eax
        jnz    .scan

   .leave:
        pop     esi
        ret
$endp ; datoup

; ------------------------------------------------------------------------------

; VOID conoze ( LPVOID cto )
; zero offset values in constant table
;
; -> cto : constant table offset
$proc conoze, cto

;       mov     [cto], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    esi

        mov     ecx, [cto]                      ; ecx = table offset
        test    ecx, ecx
        jz     .leave                           ; return. null table

;       xor     rax, rax
        mov     eax, [ecx + table.header.titype]; eax = table item type
        cmp     eax, 2
        jne    .leave                           ; return. non constant table
        mov     eax, [ecx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .leave                           ; return. empty table

        xor     edx, edx                        ; edx = 0
        lea     esi, [ecx + sizeof.table.header - 64]
   .scan:
        add     esi, 64                         ; esi = table item offset
        mov     cx, [esi + citem32.datype]
        cmp     cx, 'o'
        jne    .next
        mov     [esi + citem32.offset], edx
   .next:
        dec     eax
        jnz    .scan

   .leave:
        pop     esi
        ret
$endp ; conoze

; ------------------------------------------------------------------------------

; INT conoun ( LPVOID cto )
; get undefined items count in constant table
;
; -> cto : constant table offset
; <- eax : undefined items count
$proc conoun, cto

;       mov     [cto], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    esi

        xor     eax ,eax
        mov     ecx, [cto]                      ; ecx = table offset
        test    ecx, ecx
        jz     .leave                           ; return. null table

;       xor     rdx, rdx
        mov     edx, [ecx + table.header.titype]; edx = table item type
        cmp     edx, 2
        jne    .leave                           ; return. non constant table
        mov     edx, [ecx + table.header.icount]; edx = table item count
        test    edx, edx
        jz     .leave                           ; return. empty table

        lea     esi, [ecx + sizeof.table.header - 64]
   .scan:
        add     esi, 64                         ; esi = table item offset
        mov     cx, [esi + citem32.datype]
        cmp     cx, '?'
        jne    .next
        inc     eax
   .next:
        dec     edx
        jnz    .scan

   .leave:
        pop     esi
        ret
$endp ; conoun

; ------------------------------------------------------------------------------

; PVOID conoma ( LPVOID cto )
; get max offset value
;
; -> cto : constant table offset
; <- eax : max offset value
$proc conoma, cto

;       mov     [cto], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    esi

        xor     eax ,eax
        mov     ecx, [cto]                      ; ecx = table offset
        test    ecx, ecx
        jz     .leave                           ; return. null table

;       xor     rdx, rdx
        mov     edx, [ecx + table.header.titype]; edx = table item type
        cmp     edx, 2
        jne    .leave                           ; return. non constant table
        mov     edx, [ecx + table.header.icount]; edx = table item count
        test    edx, edx
        jz     .leave                           ; return. empty table

        lea     esi, [ecx + sizeof.table.header - 64]
   .scan:
        add     esi, 64                         ; esi = table item offset
        mov     cx, [esi + citem32.datype]
        cmp     cx, 'o'
        jne    .next
        mov     ecx, [esi + citem32.offset]
        cmp     eax, ecx
        ja     .next
        mov     eax, ecx
   .next:
        dec     edx
        jnz    .scan

   .leave:
        pop     esi
        ret
$endp ; conoma

; ------------------------------------------------------------------------------

; DWORD tapac ( LPVOID tao, DWORD tat )
; pack table ( remove invalid items, decrease and fix table size )
;
; -> tao : table offset
; -> tat : table type
;          1 - function table
;          2 - constant table
;          3 - variable table
; <- eax : table item count or zero on error
$proc tapac, tao, tat

;       mov     [tao], rcx
;       mov     [tat], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    ebx esi edi

        mov     eax, [tao]                      ; eax = table offset
        test    eax, eax
        jz     .leave                           ; skip null table

   .type.test:
        cmp     [tat], 1
        je     .type.test.out
        cmp     [tat], 2
        je     .type.test.out
        cmp     [tat], 3
        je     .type.test.out
        xor     eax, eax
        jmp    .leave
   .type.test.out:

;       xor     rcx, rcx
        mov     ecx, [eax + table.header.icount]; ecx = table item count
        test    ecx, ecx
        jz     .return                          ; skip empty table

        xor     edx, edx
;       xor     rbx, rbx
        mov     ebx, [eax + table.header.tnsize]; ebx = table item name size
        lea     esi, [eax + sizeof.table.header - 64]
   .scan:
        add     esi, 64                         ; esi = table item offset
        cmp     [tat], 1
        je     .scan.function
        cmp     [tat], 2
        je     .scan.constant                   ; assume any constant valid
        cmp     [tat], 3
        je     .scan.variable
        jmp    .invalid
   .scan.function:
        mov     edi, [esi + fitem32.offset]     ; edi = function offset
        test    edi, edi
        jnz    .valid
        jmp    .invalid
   .scan.constant:
    $ifdef _X64
   .scan.constant.x64:
        mov     rdi, [rsi + citem64.value]
        cmp     rdi, -1
        jne    .valid
        jmp    .invalid
    $else
   .scan.constant.x32:
        mov     edi, dword [esi + citem32.value + 4]
        cmp     edi, -1
        jne    .valid
        mov     edi, dword [esi + citem32.value + 0]
        cmp     edi, -1
        jne    .valid
        jmp    .invalid
    $end
;  .scan.constant.x:
;       movzx   edi, word [esi + citem32.value + 6]
;       and     edi, 0x7FF0
;       cmp     edi, 0x7FF0
;       jne    .valid
;       jmp    .invalid
   .scan.variable:
        mov     edi, [esi + vitem32.offset]     ; edi = variable offset
        test    edi, edi
        jnz    .valid
        jmp    .invalid
   .invalid:
        inc     edx
        dec     [eax + table.header.icount]     ; decrease valid item count
        jmp    .next
   .valid:
        test    edx, edx
        jz     .next                            ; edx = [invalid item count]
   .shift:
        shl     edx, 6                          ; edx = [invalid item count] * 64
        mov     edi, esi
        sub     edi, edx                        ; edi = esi - [invalid item count] * 64
        push    ecx edi
        cld
        shl     ecx, 4                          ; rcx = dwords to copy (count*64/4=count*16)
        rep     movsd
        pop     esi ecx                         ; esi = edi
        xor     edx, edx
   .next:
        dec     ecx
        jnz    .scan

        mov     esi, eax
;       xor     rdi, rdi
        mov     edi, [esi + table.header.icount]; edi = table item count
        shl     edi, 6                          ; edi = [item count] * 64
        add     edi, sizeof.table.header        ; edi = [item count] * 64 + [table header size]
        stdcall hrealloc, esi, edi              ; decrease table size
   .return:
        mov     edx, [eax + table.header.icount]; edx = table item count
        mov     [eax + table.header.mcount], edx; set maximum item count to current item count
        xor     eax, eax
        mov     eax, edx                        ; eax = table item count
   .leave:
        pop     edi esi ebx
        ret
$endp ; tapac

; ------------------------------------------------------------------------------

; DWORD funloas ( LPCSTR filename, DWORD filesize, LPCSTR section )
; load external user defined functions from inifile section
;
; <- eax : external function item count
; <- ecx : library handle

$ifdef _UDF
$proc funloas, filename, filesize, section

    locals
       .IC      dd ?
       .LIB     dd ?
       .BUFFER  dd ?
       .ID      dd ?
       .SAC     dd ? ; argument count string
       .SAF     dd ? ; argument flags string
       .SRT     dd ? ; return type string
       .SDF     dd ? ; dynamic function string
       .AC      dd ? ; argument count
       .AF      dd ? ; argument flags
       .RT      dd ? ; return type
       .PCHAR   dd ?
       .DU      db ?
       .RE      db ?
       .EX      db ?
       .IV      db ?
       .LIBname db 256 dup ?
    endl

;       mov     [filename], rcx
;       mov     [filesize], rdx
;       mov     [section], r8
;       mov     [], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        xor     eax, eax
        mov     [.IC], eax
        mov     [.LIB], eax
        mov     [.DU], al
        mov     [.RE], al
        mov     [.EX], al
        mov     [.IV], al

    $ifdef _X64
        mov     rdi, r8
    $else
        mov     edi, [section]
    $end
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax
        jz     .return
        cmp     eax, 255
        ja     .return

        ; name:000 -> name
        xor     edx, edx
   .UDF.L0:
        inc     edx
        mov     cl, byte [edi + edx - 1]
        cmp     cl, 0
        je     .UDF.LL
        cmp     cl, ':'
        je     .UDF.LT
        jmp    .UDF.L8
   .UDF.LT:
        cmp     edx, 2
        jne    .UDF.LT.main
        mov     ch, byte [edi + edx]
        cmp     ch, '\'                         ; ?:\...
        je     .UDF.L8
        cmp     ch, '/'                         ; ?:/...
        je     .UDF.L8
   .UDF.LT.main:
        dec     edx
        jmp    .UDF.LL
   .UDF.L8:
        cmp     edx, eax
        jb     .UDF.L0
   .UDF.LL:
        mov     eax, edx
        test    eax, eax
        jz     .return
        push    eax
        lea     ecx, [.LIBname]
        cinvoke strcpy, ecx, edi
        pop     eax
        mov     byte [.LIBname + eax], 0

        cmp     eax, 2
        jne    .UDF_main
        mov     ax, word [edi]
        case    ax,\
                '==', .UDF_SIC,\                ; SICx32.DLL
                '++', .UDF_DU,\                 ; duplicate
                '+-', .UDF_RE,\                 ; rename
                '-+', .UDF_EX,\                 ; exchange
                '--', .UDF_IV                   ; invalidate
        jmp    .UDF_main
   .UDF_SIC:
        invoke  LoadLibrary, S_SIC_DLL
;       invoke  LoadLibraryEx, S_SIC_DLL, 0, 0
        cmp     eax, 32
        jl     .return
        mov     [.LIB], eax
        jmp    .UDF_ALLOC
   .UDF_DU:
        mov     [.DU], al
        jmp    .UDF_ALLOC
   .UDF_RE:
        mov     [.RE], al
        jmp    .UDF_ALLOC
   .UDF_EX:
        mov     [.EX], al
        jmp    .UDF_ALLOC
   .UDF_IV:
        mov     [.IV], al
        jmp    .UDF_ALLOC

   .UDF_main:
        lea     ecx, [.LIBname]
        stdcall DLLLoad, ecx
;       lea     ecx, [.LIBname]
;       invoke  LoadLibrary, ecx
;;      invoke  LoadLibraryEx, ecx, 0, 0
        cmp     eax, 32
        jl     .return
        mov     [.LIB], eax

   .UDF_ALLOC:
        stdcall halloc, [filesize]
        mov     edi, eax
        mov     [.BUFFER], edi
   .UDF_READ:
        ; DWORD GetPrivateProfileSection ( LPCTSTR, LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSection, [section], edi, [filesize], [filename]
        test    eax, eax
        jz     .UDF_FREE
        lea     ebx, [edi - 1]
   .UDF_TEST:
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
        lea     esi, [edi - 1]

   .UDF_SCAN_name:
        inc     esi
        cmp     byte [esi], 0
        je     .UDF_TEST
        cmp     byte [esi], '='
        jne    .UDF_SCAN_name
   .UDF_SCAN_name_SET:
        mov     byte [esi], 0
        lea     eax, [esi + 1]
        mov     [.ID], eax

        mov     [.SAC], 0
        mov     [.SAF], 0
        mov     [.SRT], 0
        mov     [.SDF], 0

   .UDF_SCAN_AC:
        inc     esi
        cmp     byte [esi], 0
        je     .UDF_SET
        cmp     byte [esi], '='
        je     .UDF_SCAN_AC_SET
        cmp     byte [esi], ':'
        je     .UDF_SCAN_AC_SET
        jmp    .UDF_SCAN_AC
   .UDF_SCAN_AC_SET:
        mov     byte [esi], 0
        lea     eax, [esi + 1]
        mov     [.SAC], eax

   .UDF_SCAN_AF:
        inc     esi
        cmp     byte [esi], 0
        je     .UDF_SET
        cmp     byte [esi], '='
        je     .UDF_SCAN_AF_SET
        cmp     byte [esi], ':'
        je     .UDF_SCAN_AF_SET
        jmp    .UDF_SCAN_AF
   .UDF_SCAN_AF_SET:
        mov     byte [esi], 0
        lea     eax, [esi + 1]
        mov     [.SAF], eax

   .UDF_SCAN_RT:
        inc     esi
        cmp     byte [esi], 0
        je     .UDF_SET
        cmp     byte [esi], '='
        je     .UDF_SCAN_RT_SET
        cmp     byte [esi], ':'
        je     .UDF_SCAN_RT_SET
        jmp    .UDF_SCAN_RT
   .UDF_SCAN_RT_SET:
        mov     byte [esi], 0
        lea     eax, [esi + 1]
        mov     [.SRT], eax

   .UDF_SCAN_DF:
        inc     esi
        cmp     byte [esi], 0
        je     .UDF_SET
        cmp     byte [esi], '='
        je     .UDF_SCAN_DF_SET
        cmp     byte [esi], ':'
        je     .UDF_SCAN_DF_SET
        jmp    .UDF_SCAN_DF
   .UDF_SCAN_DF_SET:
        mov     byte [esi], 0
        lea     eax, [esi + 1]
        mov     [.SDF], eax

   .UDF_SET:
        cmp     [.DU], 0
        jnz    .UDF_SET_DU
        cmp     [.RE], 0
        jnz    .UDF_SET_RE
        cmp     [.EX], 0
        jnz    .UDF_SET_EX
        cmp     [.IV], 0
        jnz    .UDF_SET_IV
        jmp    .UDF_SET_main
   .UDF_SET_DU:
        stdcall sic_refun, NULL, edi, [.ID], 0  ; duplicate
        jmp    .UDF_TEST
   .UDF_SET_RE:
        stdcall sic_refun, NULL, edi, [.ID], 1  ; rename
        jmp    .UDF_TEST
   .UDF_SET_EX:
        stdcall sic_exfun, NULL, edi, [.ID]     ; exchange
        jmp    .UDF_TEST
   .UDF_SET_IV:
        stdcall sic_invaf, NULL, edi            ; invalidate
        jmp    .UDF_TEST
   .UDF_SET_main:
        mov     [.AC], 0
        mov     [.AF], 0
        mov     [.RT], 0
        ; long strtol ( char *nptr, char **endptr, int base )
   .UDF_SET_AC:
        cmp     [.SAC], 0
        jz     .UDF_SET_AC_OUT
        lea     edx, [.PCHAR]
        cinvoke strtol, [.SAC], edx, 10
        mov     edx, [.PCHAR]
        cmp     edx, [.SAC]
        je     .UDF_SET_AC_OUT                  ; error. no integer value
        test    eax, 0xFFFF0000
        jnz    .UDF_SET_AC_OUT                  ; error. out of range
        xor     edx, edx
        mov     dx, ax
        mov     [.AC], edx
   .UDF_SET_AC_OUT:
   .UDF_SET_AF:
        cmp     [.SAF], 0
        jz     .UDF_SET_AF_OUT
        lea     edx, [.PCHAR]
        cinvoke strtol, [.SAF], edx, 10
        mov     edx, [.PCHAR]
        cmp     edx, [.SAF]
        je     .UDF_SET_AF_OUT                  ; error. no integer value
        and     eax, 0xFF
        mov     [.AF], eax
   .UDF_SET_AF_OUT:
   .UDF_SET_RT:
        cmp     [.SRT], 0
        jz     .UDF_SET_RT_OUT
        lea     edx, [.PCHAR]
        cinvoke strtol, [.SRT], edx, 10
        mov     edx, [.PCHAR]
        cmp     edx, [.SRT]
        je     .UDF_SET_RT_OUT                  ; error. no integer value
        xor     edx, edx
        mov     dl, al
        mov     [.RT], edx
   .UDF_SET_RT_OUT:
   .UDF_SET_DF:
        mov     eax, [.SDF]
        test    eax, eax
        jz     .UDF_SET_DF_OUT
        cmp     byte [eax], 'D'
        je     .UDF_SET_DF_D
        cmp     byte [eax], 'd'
        je     .UDF_SET_DF_D
        jmp    .UDF_SET_DF_OUT
   .UDF_SET_DF_D:
        mov     al, byte [eax + 1]
        case    al,\
                0x00, .UDF_SET_DF_SET,\         ; string zero termination
                0x20, .UDF_SET_DF_SET,\         ; space
                0x0D, .UDF_SET_DF_SET,\         ; carriage return (FE:CR)
                0x0A, .UDF_SET_DF_SET,\         ; line feed (FE:LF)
                0x09, .UDF_SET_DF_SET,\         ; tabulation (FE:TAB)
                0xA0, .UDF_SET_DF_SET,\         ; no-break space
                0x08, .UDF_SET_DF_SET,\         ; backspace (FE:BS)
                 '*', .UDF_SET_DF_SET,\         ; asterisk
                 '#', .UDF_SET_DF_SET,\         ; number sign
                 ';', .UDF_SET_DF_SET           ; semicolon
        jmp    .UDF_SET_DF_OUT
   .UDF_SET_DF_SET:
        or      [.AF], 0010000000000000B        ; set dynamic function flag
   .UDF_SET_DF_OUT:

   .UDF_ADD:
;       invoke  GetProcAddress, [.LIB], edi
        invoke  GetProcAddress, [.LIB], [.ID]
        test    eax, eax
        jz     .UDF_TEST
        mov     edx, [.RT]
        and     edx, 00001111B                  ; return type mask = 0x0F (00001111)
        shl     edx, 8
        or      [.AF], edx                      ; [.AF] = function flags
;       stdcall sic_afun, NULL, [.ID], eax, [.AC], [.AF]
        stdcall sic_afun, NULL, edi, eax, [.AC], [.AF]
        cmp     eax, 0
        jl     .UDF_TEST
        inc     [.IC]
        jmp    .UDF_TEST
   .UDF_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        mov     ecx, [.LIB]
        mov     eax, [.IC]
        test    eax, eax
        jnz    .leave
        test    ecx, ecx
        jz     .leave
        invoke  FreeLibrary, ecx
        xor     eax, eax
        xor     ecx, ecx
   .leave:
        pop     edi esi ebx
        ret
$endp ; funloas
$else
$proc funloas, filename, filesize, section
        ret
$endp ; funloas
$end

; ------------------------------------------------------------------------------

; DWORD conloas ( LPCSTR filename, DWORD filesize, LPCSTR section )
; load external user defined constants from inifile section
;
; <- eax : external constant item count

$ifdef _UDF
$proc conloas, filename, filesize, section

    locals
       .IC      dd ?
       .BUFFER  dd ?
       .PCHAR   dd ?
       .FLOAT   dq ?
       .DU      db ?
       .RE      db ?
       .EX      db ?
       .IV      db ?
    endl

;       mov     [filename], rcx
;       mov     [filesize], rdx
;       mov     [section], r8
;       mov     [], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        xor     eax, eax
        mov     [.IC], eax
        mov     [.DU], al
        mov     [.RE], al
        mov     [.EX], al
        mov     [.IV], al

    $ifdef _X64
        mov     rdi, r8
    $else
        mov     edi, [section]
    $end
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax
        jz     .return

        cmp     eax, 2
        jne    .UDC_main
        mov     ax, word [edi]
        case    ax,\
                '++', .UDC_DU,\                 ; duplicate
                '+-', .UDC_RE,\                 ; rename
                '-+', .UDC_EX,\                 ; exchange
                '--', .UDC_IV                   ; invalidate
        jmp    .UDC_main
   .UDC_DU:
        mov     [.DU], al
        jmp    .UDC_ALLOC
   .UDC_RE:
        mov     [.RE], al
        jmp    .UDC_ALLOC
   .UDC_EX:
        mov     [.EX], al
        jmp    .UDC_ALLOC
   .UDC_IV:
        mov     [.IV], al
        jmp    .UDC_ALLOC

   .UDC_main:
   .UDC_ALLOC:
        stdcall halloc, [filesize]
        mov     edi, eax
        mov     [.BUFFER], edi
   .UDC_READ:
        ; DWORD GetPrivateProfileSection ( LPCTSTR, LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSection, [section], edi, [filesize], [filename]
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
        lea     esi, [edi - 1]
   .UDC_SCAN:
        inc     esi
        cmp     byte [esi], 0
        jnz    .UDC_SCAN_CHAR
        cmp     [.IV], 0
        jnz    .UDC_SET
        jmp    .UDC_TEST
   .UDC_SCAN_CHAR:
        cmp     byte [esi], '='
        jne    .UDC_SCAN
        mov     byte [esi], 0

   .UDC_SET:
        inc     esi
        cmp     [.DU], 0
        jnz    .UDC_SET_DU
        cmp     [.RE], 0
        jnz    .UDC_SET_RE
        cmp     [.EX], 0
        jnz    .UDC_SET_EX
        cmp     [.IV], 0
        jnz    .UDC_SET_IV
        jmp    .UDC_SET_main
   .UDC_SET_DU:
        stdcall sic_recon, NULL, edi, esi, 0    ; duplicate
        jmp    .UDC_TEST
   .UDC_SET_RE:
        stdcall sic_recon, NULL, edi, esi, 1    ; rename
        jmp    .UDC_TEST
   .UDC_SET_EX:
        stdcall sic_excon, NULL, edi, esi       ; exchange
        jmp    .UDC_TEST
   .UDC_SET_IV:
        stdcall sic_invac, NULL, edi            ; invalidate
        jmp    .UDC_TEST
   .UDC_SET_main:
        lea     edx, [.PCHAR]
        cinvoke strtod, esi, edx
        mov     edx, [.PCHAR]
    $ifdef _X64
        movsd   qword [.FLOAT], xmm0            ; x64
    $else
        fstp    qword [.FLOAT]                  ; x32
    $end
        cmp     esi, edx
        je     .UDC_TEST                        ; error. no floating point value
        mov     dx, word [.FLOAT + 6]
        and     dx, 0x7FF0
        cmp     dx, 0x7FF0
        je     .UDC_TEST                        ; error. invalid floating point value
   .UDC_ADD:
    $ifdef _X64
        stdcall sic_aconf, NULL, rdi, float [.FLOAT]
    $else
        stdcall sic_aconf, NULL, edi, dword [.FLOAT], dword [.FLOAT + 4]
    $end
        cmp     eax, 0
        jl     .UDC_TEST
        inc     [.IC]
        jmp    .UDC_TEST
   .UDC_FREE:
        stdcall hfree, [.BUFFER]

   .return:
;       xor     rax, rax
        mov     eax, [.IC]
        pop     edi esi ebx
        ret
$endp ; conloas
$else
$proc conloas, filename, filesize, section
        ret
$endp ; conloas
$end

; ------------------------------------------------------------------------------

; DWORD varloas ( LPCSTR filename, DWORD filesize, LPCSTR section )
; load external user defined variables from inifile section
;
; <- eax : external variable item count
; <- ecx : library handle

$ifdef _UDF
$proc varloas, filename, filesize, section

    locals
       .IC      dd ?
       .LIB     dd ?
       .BUFFER  dd ?
       .PCHAR   dd ?
       .DU      db ?
       .RE      db ?
       .EX      db ?
       .IV      db ?
       .LIBname db 256 dup ?
    endl

;       mov     [filename], rcx
;       mov     [filesize], rdx
;       mov     [section], r8
;       mov     [], r9

   .enter:
        pushsa  ebx, esi, edi                   ; push & 16-byte stack align for x64

        xor     eax, eax
        mov     [.IC], eax
        mov     [.LIB], eax
        mov     [.DU], al
        mov     [.RE], al
        mov     [.EX], al
        mov     [.IV], al

    $ifdef _X64
        mov     rdi, r8
    $else
        mov     edi, [section]
    $end
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax
        jz     .return
        cmp     eax, 255
        ja     .return

        ; name:000 -> name
        xor     edx, edx
   .UDF.L0:
        inc     edx
        mov     cl, byte [edi + edx - 1]
        cmp     cl, 0
        je     .UDF.LL
        cmp     cl, ':'
        je     .UDF.LT
        jmp    .UDF.L8
   .UDF.LT:
        cmp     edx, 2
        jne    .UDF.LT.main
        mov     ch, byte [edi + edx]
        cmp     ch, '\'                         ; ?:\...
        je     .UDF.L8
        cmp     ch, '/'                         ; ?:/...
        je     .UDF.L8
   .UDF.LT.main:
        dec     edx
        jmp    .UDF.LL
   .UDF.L8:
        cmp     edx, eax
        jb     .UDF.L0
   .UDF.LL:
        mov     eax, edx
        test    eax, eax
        jz     .return
        push    eax
        lea     ecx, [.LIBname]
        cinvoke strcpy, ecx, edi
        pop     eax
        mov     byte [.LIBname + eax], 0

        cmp     eax, 2
        jne    .UDV_main
        mov     ax, word [edi]
        case    ax,\
                '==', .UDV_SIC,\                ; SICx32.DLL
                '++', .UDV_DU,\                 ; duplicate
                '+-', .UDV_RE,\                 ; rename
                '-+', .UDV_EX,\                 ; exchange
                '--', .UDV_IV                   ; invalidate
        jmp    .UDV_main
   .UDV_SIC:
        invoke  LoadLibrary, S_SIC_DLL
;       invoke  LoadLibraryEx, S_SIC_DLL, 0, 0
        cmp     eax, 32
        jl     .return
        mov     [.LIB], eax
        jmp    .UDV_ALLOC
   .UDV_DU:
        mov     [.DU], al
        jmp    .UDV_ALLOC
   .UDV_RE:
        mov     [.RE], al
        jmp    .UDV_ALLOC
   .UDV_EX:
        mov     [.EX], al
        jmp    .UDV_ALLOC
   .UDV_IV:
        mov     [.IV], al
        jmp    .UDV_ALLOC

   .UDV_main:
        lea     ecx, [.LIBname]
        stdcall DLLLoad, ecx
;       lea     ecx, [.LIBname]
;       invoke  LoadLibrary, ecx
;;      invoke  LoadLibraryEx, ecx, 0, 0
        cmp     eax, 32
        jl     .return
        mov     [.LIB], eax

   .UDV_ALLOC:
        stdcall halloc, [filesize]
        mov     edi, eax
        mov     [.BUFFER], edi
   .UDV_READ:
        ; DWORD GetPrivateProfileSection ( LPCTSTR, LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSection, [section], edi, [filesize], [filename]
        test    eax, eax
        jz     .UDV_FREE
        lea     ebx, [edi - 1]
   .UDV_TEST:
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
        lea     esi, [edi - 1]
   .UDV_SCAN_name:
        inc     esi
        cmp     byte [esi], 0
        jnz    .UDV_SCAN_CHAR
        cmp     [.IV], 0
        jnz    .UDV_SET
        jmp    .UDV_TEST
   .UDV_SCAN_CHAR:
        cmp     byte [esi], '='
        jne    .UDV_SCAN_name
        mov     byte [esi], 0

   .UDV_SET:
        inc     esi
        cmp     [.DU], 0
        jnz    .UDV_SET_DU
        cmp     [.RE], 0
        jnz    .UDV_SET_RE
        cmp     [.EX], 0
        jnz    .UDV_SET_EX
        cmp     [.IV], 0
        jnz    .UDV_SET_IV
        jmp    .UDV_SET_main
   .UDV_SET_DU:
        stdcall sic_revar, NULL, edi, esi, 0    ; duplicate
        jmp    .UDV_TEST
   .UDV_SET_RE:
        stdcall sic_revar, NULL, edi, esi, 1    ; rename
        jmp    .UDV_TEST
   .UDV_SET_EX:
        stdcall sic_exvar, NULL, edi, esi       ; exchange
        jmp    .UDV_TEST
   .UDV_SET_IV:
        stdcall sic_invav, NULL, edi            ; invalidate
        jmp    .UDV_TEST
   .UDV_SET_main:
   .UDV_ADD:
        invoke  GetProcAddress, [.LIB], esi
        test    eax, eax
        jz     .UDV_TEST
        stdcall sic_avarf, NULL, edi, eax
        cmp     eax, 0
        jl     .UDV_TEST
        inc     [.IC]
        jmp    .UDV_TEST
   .UDV_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        mov     ecx, [.LIB]
        mov     eax, [.IC]
        test    eax, eax
        jnz    .leave
        test    ecx, ecx
        jz     .leave
        invoke  FreeLibrary, ecx
        xor     eax, eax
        xor     ecx, ecx
   .leave:
        pop     edi esi ebx
        ret
$endp ; varloas
$else
$proc varloas, filename, filesize, section
        ret
$endp ; varloas
$end

; ------------------------------------------------------------------------------

; move memory
; !!! don`t change EAX register
;
; -> edi - destination
; -> esi - source
; -> ecx - byte count to copy
$sproc momem

        cmp     ecx, 0
        jle    .return

        cld
        mov     edx, ecx
        and     edx, 3
        shr     ecx, 2
        rep     movsd
        or      ecx, edx
        jz     .return
        rep     movsb
   .return:
        retn
$endp ; momem

; ------------------------------------------------------------------------------

; copy memory
proc copymem, dst, src, size

;       mov     [dst], rcx
;       mov     [src], rdx
;       mov     [size], r8
;       mov     [], r9

   .enter:
        mov     ecx, [size]
        cmp     ecx, 0
        jle    .return

        push    esi edi

        mov     edi, [dst]
        mov     esi, [src]

        cld
        shr     ecx, 2
        rep     movsd
        mov     ecx, [size]
        and     ecx, 3
        rep     movsb

        pop     edi esi
   .return:
        ret
endp ; copymem

; ------------------------------------------------------------------------------

; get process heap
; <- eax - process heap
proc getheap

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        mov     eax, [@_HEAP]
        test    eax, eax
        jnz    .return
        invoke  GetProcessHeap
;       mov     ecx, eax
        mov     [@_HEAP], eax
   .return:
        ret
endp ; getheap

; ------------------------------------------------------------------------------

; allocate memory
; <- eax - memory
proc halloc, size

;       mov     [size], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        stdcall getheap                         ; eax = process heap
        invoke  HeapAlloc, eax, 0, [size]
   .return:
        ret
endp ; halloc

; ------------------------------------------------------------------------------

; reallocate memory (!!! safe for decreasing size only)
; <- eax - memory
proc hrealloc mem, size

   .HEAP_REALLOC_IN_PLACE_ONLY = 0x00000010

;       mov     [mem], rcx
;       mov     [size], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

;       test    rcx, rcx                        ; x64: rcx=[mem]
        cmp     [mem], 0
        jz     .return

        stdcall getheap                         ; eax = process heap
        invoke  HeapReAlloc, eax, .HEAP_REALLOC_IN_PLACE_ONLY, [mem], [size]
   .return:
        ret
endp ; hrealloc

; ------------------------------------------------------------------------------

; free memory
proc hfree, mem

;       mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

;       test    rcx, rcx                        ; x64: rcx=[mem]
        cmp     [mem], 0
        jz     .return

        stdcall getheap                         ; eax = process heap
        invoke  HeapFree, eax, 0, [mem]
   .return:
        ret
endp ; hfree

; ------------------------------------------------------------------------------

; allocate memory for code
; <- eax - memory
proc calloc, size

;       mov     [size], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        ; LPVOID VirtualAlloc ( LPVOID, SIZE_T, DWORD, DWORD )
        invoke  VirtualAlloc, 0, [size], MEM_COMMIT, PAGE_EXECUTE_READWRITE
   .return:
        ret
endp ; calloc

; ------------------------------------------------------------------------------

; reallocate memory for code
; !!! safe for decreasing size only
; <- eax - memory
proc crealloc, mem, size

;       mov     [mem], rcx
;       mov     [size], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  esi, edi                        ; push & 16-byte stack align for x64

;       test    rcx, rcx                        ; x64: rcx=[mem]
        cmp     [mem], 0
        jnz    .alloc

        xor     eax, eax
        jmp    .return
   .alloc:
        ; LPVOID VirtualAlloc ( LPVOID, SIZE_T, DWORD, DWORD )
        invoke  VirtualAlloc, [mem], [size], MEM_COMMIT, PAGE_EXECUTE_READ
;       invoke  VirtualAlloc, [mem], [size], MEM_COMMIT, PAGE_EXECUTE_READWRITE
    macro comment
    {
        invoke  VirtualAlloc, 0, [size], MEM_COMMIT, PAGE_EXECUTE_READ
;       invoke  VirtualAlloc, 0, [size], MEM_COMMIT, PAGE_EXECUTE_READWRITE
        push    eax
        mov     edi, eax
        mov     esi, [mem]
        mov     ecx, [size]
        call    momem
        stdcall cfree, [mem]
        pop     eax
    }
   .return:
        pop     edi esi
        ret
endp ; crealloc

; ------------------------------------------------------------------------------

; free memory
proc cfree, mem

;       mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

;       test    rcx, rcx                        ; x64: rcx=[mem]
        cmp     [mem], 0
        jz     .return

        ; BOOL VirtualFree ( LPVOID, SIZE_T, DWORD )
        invoke  VirtualFree, [mem], 0, MEM_RELEASE
   .return:
        ret
endp ; cfree

; ------------------------------------------------------------------------------

; fill memory with char
proc fillchar, mem, size, char

;       mov     [mem], rcx
;       mov     [size], rdx
;       mov     [char], r8
;       mov     [], r9

    $ifdef _X64
        push    rdi
        mov     rdi, rcx                        ; rdi = mem
        mov     rcx, rdx                        ; rcx = size
        mov     rax, r8                         ; rax = char
    $else
        xchg    edi, [mem]
        xchg    ecx, [size]
        xchg    eax, [char]
    $end

        test    edi, edi
        jz     .return

        shr     ecx, 1
        jnc     @F
        stosb
    @@: shr     ecx, 1
        jnc     @F
        stosw
    @@: rep     stosd

   .return:
    $ifdef _X64
        pop     rdi
    $else
        xchg    edi, [mem]
        xchg    ecx, [size]
        xchg    eax, [char]
    $end
        ret
endp ; fillchar

; ------------------------------------------------------------------------------

; float to int float
; x64 : <- rax
; x32 : <- eax:edx

proc f2f.int, f, f.HI

       .mem64   EQU esp - 8

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..int.st0
        fstp    qword [.mem64]
        mov     eax, dword [.mem64]
        mov     edx, dword [.mem64 + 4]
   .return:
        ret
endp ; f2f.int

; ------------------------------------------------------------------------------

; float to frac float
; x64 : <- rax
; x32 : <- eax:edx

proc f2f.frac, f, f.HI

       .mem64   EQU esp - 8

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..frac.st0
        fstp    qword [.mem64]
        mov     eax, dword [.mem64]
        mov     edx, dword [.mem64 + 4]
   .return:
        ret
endp ; f2f.frac

; ------------------------------------------------------------------------------

; float to round float
; x64 : <- rax
; x32 : <- eax:edx

proc f2f.round, f, f.HI

       .mem64   EQU esp - 8

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..round.st0
        fstp    qword [.mem64]
        mov     eax, dword [.mem64]
        mov     edx, dword [.mem64 + 4]
   .return:
        ret
endp ; f2f.round

; ------------------------------------------------------------------------------

; float to integer (round)
; <- eax

proc f2ir, f, f.HI

       .mem32   EQU esp - 4

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..round.st0
        fistp   dword [.mem32]
        mov     eax, [.mem32]
   .return:
        ret
endp ; f2ir

; ------------------------------------------------------------------------------

; float to integer (truncate)
; <- eax

proc f2i, f, f.HI

       .int32   EQU esp - 4

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        fistp   dword [.int32]
        mov     eax, [.int32]
   .return:
        ret
endp ; f2i

; ------------------------------------------------------------------------------

; float to integer (truncate)
; <- eax
; <- ecx : not zero for integer f

proc f2ix, f, f.HI

       .int32   EQU esp - 4

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        xor     ecx, ecx
        fld     qword [f]
        fld     st0
        fistp   dword [.int32]
        fild    dword [.int32]                  ; st0=int(double) | st1=double
        fcompp
        fnjne   @F
        inc     ecx
    @@:
        mov     eax, [.int32]
   .return:
        ret
endp ; f2ix

; ------------------------------------------------------------------------------

; float to int64 (truncate)
; <- eax:edx

proc f2i64, f, f.HI

       .int64   EQU esp - 8
       .int64LO EQU esp - 8
       .int64HI EQU esp - 4

;       mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        fistp   qword [.int64]
        mov     eax, [.int64LO]                 ; return int64
        mov     edx, [.int64HI]
   .return:
        ret
endp ; f2i64

; ------------------------------------------------------------------------------

; get proc from map (2 items in line)
; <- esi - proc offset
; <- eax - proc size
proc map_proc_x2, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 2 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     edx, [proc]
        shl     edx, 1                          ; edx = [proc] * 2
        add     edx, [mode]
        shl     edx, 2
        add     edx, [map]
   .offset:
        movzx   esi, word [edx + 0]
        test    esi, esi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   eax, word [edx + 2]
   .return:
        ret
endp ; map_proc_x2

; ------------------------------------------------------------------------------

; get proc from map (2 items in line)
; <- ecx - proc offset
proc map_proc_x2_ecx, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 2 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    ebx
        mov     ebx, [proc]
        shl     ebx, 1                          ; ebx = [proc] * 2
        add     ebx, [mode]
        shl     ebx, 2
        add     ebx, [map]
   .offset:
        movzx   ecx, word [ebx + 0]
        test    ecx, ecx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     ebx
        ret
endp ; map_proc_x2_ecx

; ------------------------------------------------------------------------------

; get proc from map (2 items in line)
; <- edx - proc offset
proc map_proc_x2_edx, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 2 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    ebx
        mov     ebx, [proc]
        shl     ebx, 1                          ; ebx = [proc] * 2
        add     ebx, [mode]
        shl     ebx, 2
        add     ebx, [map]
   .offset:
        movzx   edx, word [ebx + 0]
        test    edx, edx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rdx, r10
    $else
        add     edx, SIC_F_BASE
    $end
   .return:
        pop     ebx
        ret
endp ; map_proc_x2_edx

; ------------------------------------------------------------------------------

; get proc from map (3 items in line)
; <- esi - proc offset
; <- eax - proc size
proc map_proc_x3, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 3 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     edx, [proc]
        shl     edx, 1
        add     edx, [proc]                     ; edx = [proc] * 3
        add     edx, [mode]
        shl     edx, 2
        add     edx, [map]
   .offset:
        movzx   esi, word [edx + 0]
        test    esi, esi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   eax, word [edx + 2]
   .return:
        ret
endp ; map_proc_x3

; ------------------------------------------------------------------------------

; get proc from map (3 items in line)
; <- ecx - proc offset
proc map_proc_x3_ecx, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 3 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    ebx
        mov     ebx, [proc]
        shl     ebx, 1
        add     ebx, [proc]                     ; ebx = [proc] * 3
        add     ebx, [mode]
        shl     ebx, 2
        add     ebx, [map]
   .offset:
        movzx   ecx, word [ebx + 0]
        test    ecx, ecx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     ebx
        ret
endp ; map_proc_x3_ecx

; ------------------------------------------------------------------------------

; get proc from map (4 items in line)
; <- esi - proc offset
; <- eax - proc size
proc map_proc_x4, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 4 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     edx, [proc]
        shl     edx, 2                          ; edx = [proc] * 4
        add     edx, [mode]
        shl     edx, 2
        add     edx, [map]
   .offset:
        movzx   esi, word [edx + 0]
        test    esi, esi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   eax, word [edx + 2]
   .return:
        ret
endp ; map_proc_x4

; ------------------------------------------------------------------------------

; get proc from map (4 items in line)
; <- ecx - proc offset
proc map_proc_x4_ecx, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 4 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    ebx
        mov     ebx, [proc]
        shl     ebx, 2                          ; ebx = [proc] * 4
        add     ebx, [mode]
        shl     ebx, 2
        add     ebx, [map]
   .offset:
        movzx   ecx, word [ebx + 0]
        test    ecx, ecx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     ebx
        ret
endp ; map_proc_x4_ecx

; ------------------------------------------------------------------------------

; get proc from map (4 items in line)
; <- edx - proc offset
proc map_proc_x4_edx, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 4 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    ebx
        mov     ebx, [proc]
        shl     ebx, 2                          ; ebx = [proc] * 4
        add     ebx, [mode]
        shl     ebx, 2
        add     ebx, [map]
   .offset:
        movzx   edx, word [ebx + 0]
        test    edx, edx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rdx, r10
    $else
        add     edx, SIC_F_BASE
    $end
   .return:
        pop     ebx
        ret
endp ; map_proc_x4_edx

; ------------------------------------------------------------------------------

; get proc from map (8 items in line)
; <- esi - proc offset
; <- eax - proc size
proc map_proc_x8, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 8 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     edx, [proc]
        shl     edx, 3                          ; edx = [proc] * 8
        add     edx, [mode]
        shl     edx, 2
        add     edx, [map]
   .offset:
        movzx   esi, word [edx + 0]
        test    esi, esi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   eax, word [edx + 2]
   .return:
        ret
endp ; map_proc_x8

; ------------------------------------------------------------------------------

; get proc from map (8 items in line)
; <- ecx - proc offset
proc map_proc_x8_ecx, map, proc, mode

;       mov     [map], rcx
;       mov     [proc], rdx
;       mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 8 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    ebx
        mov     ebx, [proc]
        shl     ebx, 3                          ; ebx = [proc] * 8
        add     ebx, [mode]
        shl     ebx, 2
        add     ebx, [map]
   .offset:
        movzx   ecx, word [ebx + 0]
        test    ecx, ecx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     ebx
        ret
endp ; map_proc_x8_ecx

; ------------------------------------------------------------------------------

; get 16-byte aligned system data offset
; -> sic : T_sic_data structure offset
; <- eax - system data offset
proc system_data_?ax, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     ecx, [sic]
        mov     eax, [ecx + T_sic_data.data]    ; eax = ?unaligned data segment
        test    eax, 0xF
        jz     .return                          ; data is already aligned to 16 bytes

        xor     ecx, ecx
        sub     cl, al
        and     ecx, 0xF
        add     eax, ecx
   .return:                                     ; eax = system data offset (16-byte aligned)
        ret
endp ; system_data_?ax

; ------------------------------------------------------------------------------

; get 16-byte aligned mem
; <- ecx - 16-byte aligned mem
; <- edx - mem shift
macro c
{
proc mem_a16_?cx_?dx, mem

;       mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     ecx, [mem]
        xor     edx, edx
        test    ecx, 0xF
        jz     .return                          ; data is already aligned to 16 bytes

        sub     dl, cl
        and     edx, 0xF
        add     ecx, edx
   .return:
        ret
endp ; mem_a16_?cx_?dx
}

; ------------------------------------------------------------------------------

; get 16-byte aligned mem
; <- eax - 16-byte aligned mem
; <- edx - mem shift
macro c
{
proc mem_a16_?ax_?dx, mem

;       mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     eax, [mem]
;       mov     rax, rcx
        xor     edx, edx
        test    eax, 0xF
        jz     .return                          ; data is already aligned to 16 bytes

        sub     dl, al
        and     edx, 0xF
        add     eax, edx
   .return:
        ret
endp ; mem_a16_?ax_?dx
}

; ------------------------------------------------------------------------------

; verify object name
; -> name - object name offset
; <- eax  - name length or negative value on error
proc verify.name, name

;       mov     [name], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        mov     ecx, [name]
        or      eax, -1

   .scan:
        inc     eax
        mov     dl, byte [ecx + eax]
;       cmp     dl, 0
;       je     .return
        cmp     dl, 0x20
        jbe    .return
        mov     dh, dl
        cmp     dl, '.'
        je     .scan                            ; '.'
        cmp     dl, '_'
        je     .scan                            ; '_'
        sub     dl, '@' + 27
        add     dl, 27
        jc     .scan                            ; '@', 'A'..'Z'
        mov     dl, dh
        sub     dl, 'a' + 26
        add     dl, 26
        jc     .scan                            ; 'a'..'z'
        test    eax, eax
        jnz    .scan.digit
        jmp    .error
   .scan.digit:
        mov     dl, dh
        sub     dl, '0' + 10
        add     dl, 10
        jc     .scan                            ; '0'..'9'
   .error:
        or      eax, -1
   .return:
        ret
endp ; verify.name

; ------------------------------------------------------------------------------

; compare string case sensitive
proc CmpString, s1, s2

;       mov     [s1], rcx
;       mov     [s2], rdx
;       mov     [], r8
;       mov     [], r9

        ; LOCALE_USER_DEFAULT = 0x00000400
        ; CSTR_EQUAL          = 2

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

    $ifdef _X64
        mov     r8, rcx
        mov     r10, rdx
        invoke  CompareString, 0x00000400, 0, r8, -1, r10, -1
    $else
        invoke  CompareString, 0x00000400, 0, [s1], -1, [s2], -1
    $end
        sub     eax, 2
   .return:
        ret
endp ; CmpString

; ------------------------------------------------------------------------------

; compare string case insensitive
proc CmpiString, s1, s2

;       mov     [s1], rcx
;       mov     [s2], rdx
;       mov     [], r8
;       mov     [], r9

        ; LOCALE_USER_DEFAULT = 0x00000400
        ; NORM_IGNORECASE     = 1
        ; CSTR_EQUAL          = 2

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

    $ifdef _X64
        mov     r8, rcx
        mov     r10, rdx
        invoke  CompareString, 0x00000400, 1, r8, -1, r10, -1
    $else
        invoke  CompareString, 0x00000400, 1, [s1], -1, [s2], -1
    $end
        sub     eax, 2
   .return:
        ret
endp ; CmpiString

; ------------------------------------------------------------------------------

; set library directory
proc DLLSetDirectory, SDLL

       .CBUFFER EQU 4096

    locals
       .PATH    dd ?
       .FILE    dd ?
    endl

;       mov     [SDLL], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  esi, edi                        ; push & 16-byte stack align for x64

        mov     ecx, [SDLL]
        test    ecx, ecx                        ; test DLL name
        jnz    .main
   .empty.name:
        invoke  SetDllDirectory, ecx
        jmp    .return

   .main:
        stdcall halloc, .CBUFFER
        mov     [.PATH], eax
        mov     edi, eax
        lea     esi, [.FILE]

        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, [SDLL], .CBUFFER, edi, esi

        mov     esi, [.FILE]
        test    esi, esi
        jz     .free                            ; no filename found
        cmp     esi, edi
        jbe    .free                            ; invalid path and filename

   .invoke:
        mov     byte [esi], 0
        invoke  SetDllDirectory, edi
;       invoke  GetLastError

   .free:
        stdcall hfree, [.PATH]

   .return:
        pop     edi esi
        ret
endp ; DLLSetDirectory

; ------------------------------------------------------------------------------

; load library
proc DLLLoad, SDLL

       .CBUFFER EQU 4096

    locals
       .CDIR    dd ?
       .PATH    dd ?
       .FILE    dd ?
    endl

;       mov     [SDLL], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  esi, edi                        ; push & 16-byte stack align for x64

        stdcall halloc, .CBUFFER
        mov     [.CDIR], eax
        stdcall halloc, .CBUFFER
        mov     [.PATH], eax
        mov     edi, eax
        lea     esi, [.FILE]
        mov     [.FILE], 0

        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, [SDLL], .CBUFFER, edi, esi

        mov     esi, [.FILE]
        test    esi, esi
        jz     .free                            ; no filename found
        cmp     esi, edi
        ja     .cdir                            ; valid path and filename

   .ndir:
        invoke  LoadLibrary, [SDLL]
;       invoke  LoadLibraryEx, [SDLL], 0, 0
        mov     esi, eax
        jmp    .free

   .cdir:
        mov     byte [esi], 0
        invoke  GetCurrentDirectory, .CBUFFER, [.CDIR]
        invoke  SetCurrentDirectory, [.PATH]
        invoke  LoadLibrary, [SDLL]
;       invoke  LoadLibraryEx, [SDLL], 0, 0
        mov     esi, eax
        invoke  SetCurrentDirectory, [.CDIR]

   .free:
        stdcall hfree, [.PATH]
        stdcall hfree, [.CDIR]

   .return:
        mov     eax, esi
        pop     edi esi
        ret
endp ; DLLLoad

; ------------------------------------------------------------------------------

; free library
proc DLLFree, HDLL

;       mov     [HDLL], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

    $ifdef _X64
        invoke  FreeLibrary, rcx
    $else
        invoke  FreeLibrary, [HDLL]
    $end
        ret
endp ; DLLFree

; ------------------------------------------------------------------------------

; get proc address
proc DLLGetProc, HDLL, SPROC

;       mov     [HDLL], rcx
;       mov     [SPROC], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

    $ifdef _X64
        invoke  GetProcAddress, rcx, rdx
    $else
        invoke  GetProcAddress, [HDLL], [SPROC]
    $end
        ret
endp ; DLLGetProc

; ------------------------------------------------------------------------------

; flushes the instruction cache for the current process
; -> sic : T_sic_data structure offset
proc FlushCodeCache, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  esi, edi                        ; push & 16-byte stack align for x64

    $ifdef _X64
        mov     rdi, rcx
    $else
        mov     edi, [sic]
    $end
        invoke  GetCurrentProcess
        mov     esi, eax
        invoke  FlushInstructionCache, esi, [edi + T_sic_data.code], [edi + T_sic_data.size]
        invoke  CloseHandle, esi

   .return:
        pop     edi esi
        ret
endp ; FlushCodeCache

; ------------------------------------------------------------------------------
