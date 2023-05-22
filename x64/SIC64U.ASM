
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
        add     rsp, -16
        fnstcw  word [rsp + 2]                  ; save control word
        mov     word [rsp], cw
        fldcw   word [rsp]                      ; load control word
}

; ------------------------------------------------------------------------------

; update FPU control word

macro @@..fpu.cw.update cw
{
        mov     word [rsp], cw
        fldcw   word [rsp]                      ; load control word
}

; ------------------------------------------------------------------------------

; restore FPU control word and set new control word
;
; @@..fpu.cw.assign 0x????
; ...
; @@..fpu.cw.restore

macro @@..fpu.cw.restore
{
        fldcw   word [rsp + 2]
        add     rsp, +16
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

;       mov     rcx, [sic]                      ; rcx = T_sic_data structure offset
        test    rcx, rcx
        jz     .return                          ; error. null T_sic_data structure offset

   .zero.memory:
        stdcall fillchar, rcx, sizeof.T_sic_data, 0

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
; <- rax : item index or negative value on error
; <- rdx : item offset or zero on error
$proc taget, tao, ina, ins

    locals
       .ins     dq ?
       .tic     dq ?
    endl

        mov     [tao], rcx
        mov     [ina], rdx
        mov     [ins], r8
;       mov     [], r9

   .enter:
        push    rbx rsi rdi

        xor     rax, rax                        ; rax = 0
        xor     rdx, rdx                        ; rdx = 0

        mov     rsi, [tao]                      ; rsi = table offset
        test    rsi, rsi
        jz     .error                           ; error. null table

        mov     edx, [rsi + table.header.icount]; edx = table item count
        test    edx, edx
        jz     .error                           ; error. empty table
        mov     [.tic], rdx                     ; save table item count in [.tic]

        xor     rbx, rbx
        mov     ebx, [rsi + table.header.tnsize]; ebx = table item name size

        mov     rdi, [ina]                      ; rdi = item name offset
        test    rdi, rdi
        jz     .error                           ; error. null item name

        mov     rdx, [ins]
        cmp     rdx, rax
        jg     .begin
        je     .error                           ; error. empty item name

        xor     rdx, rdx                        ; get item name size
   .scan:                                       ; scan item name
;       cmp     byte [rdi + rdx], 0             ; until null terminating zero found
;       je     .scan.out
        cmp     byte [rdi + rdx], 0x20          ; until null terminating zero found
        jbe    .scan.out
        inc     rdx
        cmp     rdx, rbx
        jb     .scan
   .scan.out:
        test    rdx, rdx
        jz     .error                           ; error. empty item name

   .begin:
        mov     [.ins], rdx
        cmp     rdx, rbx
        jae    .error                           ; error. invalid item name size

        mov     rdx, [.tic]                     ; rdx = table item count
        xor     rax, rax
        xor     rbx, rbx
        xor     rcx, rcx
        add     rsi, sizeof.table.header        ; rsi = current item offset

;      $align
   .loop.i:
        mov     bl, byte [rdi + rcx]
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jnz     @F
        ctolow  bl
    @@:
   .loop.j:
        cmp     bl, byte [rsi + rcx]
        ja     .loop.j.next
        jb     .error

        push    rsi                             ; save rsi
        lea     rdx, [rax - 1]
        sub     rsi, 64
   .item:
        cmp     rdx, [.tic]
        je     .item.out
        inc     rdx
        add     rsi, 64
        cmp     bl, byte [rsi + rcx]
        je     .item
   .item.out:
        pop     rsi                             ; restore rsi

        inc     bh
        jmp    .loop.i.next
   .loop.j.next:
        inc     rax
        add     rsi, 64
        cmp     rax, rdx
        jb     .loop.j
   .loop.i.next:
        inc     rcx
        cmp     cl, bh
        jne    .error
        cmp     rcx, [.ins]
        jb     .loop.i

        cmp     byte [rsi + rcx], 0
        je     .return

   .error:
        xor     rdx, rdx                        ; error. rax = -1, rdx = 0
        lea     rax, [rdx - 1]
   .return:
;       test    rax, rax
;       js     .leave
        cmp     rax, 0
        jl     .leave
        mov     rdx, rsi                        ; rdx = item offset
   .leave:
        pop     rdi rsi rbx
        ret
$endp ; taget

; ------------------------------------------------------------------------------

; INT tageta ( LPVOID tao, LPVOID fia )
; find item in table by address of any table item field
; assume size of table item is 64 bytes
;
; -> tao : table offset
; -> fia : field address
; <- rax : item index or negative value on error
; <- rdx : item offset or zero on error
$proc tageta, tao, fia

;       mov     [tao], rcx
;       mov     [fia], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
;       mov     rcx, [tao]                      ; rcx = table offset
        test    rcx, rcx
        jz     .error                           ; error. null table

    $ifdef _X64
        mov     rax, rdx                        ; rax = field address
    $else
        mov     eax, [fia]                      ; eax = field address
    $end
        sub     rax, rcx
        sub     rax, sizeof.table.header
        js     .error
        shr     rax, 6                          ; rax = rax / 64
        mov     edx, [rcx + table.header.icount]
        cmp     rax, rdx                        ; rax = item index
        jae    .error
        mov     rdx, rax
        shl     rdx, 6                          ; rdx = rax * 64
        lea     rdx, [rcx + rdx + sizeof.table.header]
        jmp    .leave

   .error:
        mov     rax, -1                         ; error. rax = -1, rdx = 0
        xor     rdx, rdx

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
; <- rax : item index or negative value on error
; <- rdx : table item count
$proc taset, tao, ina, ito, fua, fuc, fur

    locals
       .ecx     dq ?
       .ebx     dq ?
       .sys     dd ?
       .tic     dd ?
       .tns     dd ?
       .tit     dd ?
    endl

        mov     [tao], rcx
        mov     [ina], rdx
        mov     [ito], r8
        mov     [fua], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

;       mov     rdx, [ina]
        mov     dl, byte [rdx]
        sub     dl, '0'
        cmp     dl, 9
        ja     .begin
        jmp    .error                           ; error. first symbol of item name is a digit

   .begin:
        xor     rax, rax                        ; rax = 0
        mov     [.ebx], rax

        mov     rsi, [tao]                      ; rsi = table entry offset
        test    rsi, rsi
        jz     .error                           ; error. null table

        mov     edx, [rsi + table.header.mcount]
        mov     [.tic], edx                     ; get table item max count
        mov     edx, [rsi + table.header.tnsize]
        mov     [.tns], edx                     ; get table item name size
        mov     edx, [rsi + table.header.titype]
        mov     [.tit], edx                     ; get table item type

        mov     rdi, [ina]                      ; rdi = item name offset
        test    rdi, rdi
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
        cmp     [ito], rax
        je     .error                           ; error. null function offset
        jmp    .params.out
   .params.c:                                   ; constant
        jmp    .params.out
   .params.v:                                   ; variable
   .params.v.offset:                            ; variable offset
        cmp     [ito], rax
        je     .error                           ; error. null variable offset
        jmp    .params.out
   .params.out:

        xor     rbx, rbx                        ; get name length
        xor     rcx, rcx
        mov     ecx, [.tns]
   .scan:                                       ; scan item name
        dec     rcx                             ; until null terminating zero found or error
        js     .error                           ; error. invalid item name length
        mov     al, [rdi + rbx]
        cmp     al, 0x20
        jbe    .scany
        inc     rbx
        jmp    .scan
   .scany:
        mov     [.sys], eax
        test    eax, eax
        jz     .scanz
        mov     [rdi + rbx], byte 0             ; zero terminate string
   .scanz:

        cmp     rbx, 1                          ; rbx = item name length
        jne    .main
        mov     al, byte [rdi]
        case    al,\
                '@', .error,\
                '.', .error,\
                '_', .error

   .main:
        mov     rdi, [ina]                      ; rdi = item name offset
        mov     rsi, [tao]                      ; rsi = table entry offset
        xor     rcx, rcx
        mov     ecx, [rsi + table.header.icount]; rcx = table item count
        xor     rbx, rbx                        ; rbx = current item index
        test    rcx, rcx
        jz     .insert
        mov     [.ecx], rcx                     ; [.ecx] = table item count
        add     rsi, sizeof.table.header        ; rsi = 1st item offset

   .search:
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jz     .stricmp
   .strcmp:
        cinvoke strcmp, rdi, rsi                ; scan table for item with name >= item name
        jmp    .strcmp.out
   .stricmp:
        cinvoke _stricmp, rdi, rsi              ; scan table for item with name >= item name
   .strcmp.out:
        cmp     eax, 0                          ; -> ebx - index of inserted item
        jle    .found
        add     rsi, 64
        inc     rbx
        cmp     rbx, [.ecx]
        jb     .search
        jmp    .insert
   .found:
        mov     [.ebx], rbx                     ; save item index
        test    eax, eax
        jnz    .shift                           ; insert item
        cmp     [.tit], 1                       ; assign data if item already exists
        jne    .data
        xor     rbx, rbx                        ; item is function
        mov     ebx, [.tns]
        add     rsi, rbx
        cmp     [rsi - 1], byte 8               ; test internal system function flag
        jne    .data.f.test
        mov     rax, [rsi + 4]                  ; rax = function offset
        cmp     rax, [ito]
        je     .data.f.test
        jmp    .error                           ; error. attempt to modify internal system function offset

   .shift:
        mov     rsi, [tao]                      ; rsi = table entry offset
        xor     rax, rax
        mov     eax, [rsi + table.header.icount]; rax = table item count
        cmp     eax, [.tic]
        jge    .error                           ; error. item count limit exceeded
        mov     rdx, rax
        shl     rax, 6                          ; rax = rax * 64

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + rax + sizeof.table.header - 8]
        add     rsi, rax
        add     rsi, sizeof.table.header - 8

        mov     rdi, rsi                        ; rsi = source offset
        add     rdi, 64                         ; rdi = destination offset
        sub     rdx, rbx                        ; rdx = item count to shift
        shl     rdx, 3                          ; rdx = qwords to copy (count*64/08=count*08)
   .3: mov     rcx, [rsi]
        mov     [rdi], rcx
        sub     rdi, 8
        sub     rsi, 8
        dec     rdx
        jnz    .3

   .insert:                                     ; rbx = item index
        mov     [.ebx], rbx                     ; save item index
        mov     rsi, [tao]                      ; rsi = table entry offset
        xor     rax, rax
        mov     eax, [rsi + table.header.icount]; eax = table item count
        cmp     eax, [.tic]
        jge    .error                           ; error. item count limit exceeded
        mov     rdi, [ina]                      ; rdi = item name offset
        shl     rbx, 6                          ; rbx = 64 * [index]

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + rbx + sizeof.table.header]
        add     rsi, rbx
        add     rsi, sizeof.table.header

        xor     rax, rax                        ; rax = copied char count
        xor     rdx, rdx
        mov     edx, [.tns]                     ; edx = item name size - 1
        dec     rdx
   .name:                                       ; assign item name
        mov     bl, byte [rdi + rax]
        test    bl, bl
        je     .zerop
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jnz     @F
        ctolow  bl                              ; convert char to lowercase
    @@:
        mov     byte [rsi + rax], bl
        inc     rax
        cmp     rax, rdx
        jb     .name
        xor     bl, bl
   .zerop:                                      ; zero padding
        mov     byte [rsi + rax], bl
        inc     rax
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
        xor     rbx, rbx
        mov     ebx, [.tns]
        add     rsi, rbx

   .data.f.test:
        cmp     [.sys], 0
        je     .data.f.sys.reset
   .data.f.sys.set:                             ; internal system function
        mov     [rsi - 1], byte 8               ; set internal system function flag
        jmp    .data.f.params
   .data.f.sys.reset:
        mov     [rsi - 1], byte 0               ; reset internal system function flag

   .data.f.params:
   .data.f.retype:                              ; set function return type
        mov     rbx, [fur]
        mov     [rsi + fitem64.retype.base], bx
   .data.f.acount:                              ; set function argument count
        mov     rbx, [fua]
        mov     [rsi + fitem64.acount.base], bx
   .data.f.cosize:                              ; set function code size
        mov     rbx, [fuc]
        mov     [rsi + fitem64.cosize.base], bx
   .data.f.offset:                              ; set function offset
        mov     rbx, [ito]
        mov     [rsi + fitem64.offset.base], rbx

        jmp    .data.out
   .data.c:                                     ; constant
        xor     rbx, rbx
        mov     ebx, [.tns]
        add     rsi, rbx

   .data.c.params:
        xor     rbx, rbx
   .data.c.cotype:                              ; set constant type
        mov     [rsi + citem64.cotype.base], bx
   .data.c.datype:                              ; set constant data type
        mov     rbx, [fuc]
        mov     [rsi + citem64.datype.base], bx
   .data.c.value:                               ; set constant value
        mov     ebx, dword [ito]                ; set constant value LO
        mov     [rsi + citem64.value.LO.base], ebx
        mov     [rsi + citem64.codata.LO.base], ebx
        mov     ebx, dword [fua]                ; set constant value HI
        mov     [rsi + citem64.value.HI.base], ebx
        mov     [rsi + citem64.codata.HI.base], ebx

        jmp    .data.out
   .data.v:                                     ; variable
        xor     rbx, rbx
        mov     ebx, [.tns]
        add     rsi, rbx

   .data.v.params:
        xor     rbx, rbx
   .data.v.vatype:                              ; set variable type
        mov     [rsi + vitem64.vatype.base], bx
   .data.v.datype:                              ; set variable data type
        mov     rbx, [fuc]
        mov     [rsi + vitem64.datype.base], bx
   .data.v.offset:                              ; set variable offset
        mov     rbx, [ito]
        mov     [rsi + vitem64.offset.base], rbx
        mov     [rsi + vitem64.vadata.base], rbx
    $ifdef _X32
        xor     ebx, ebx
        mov     [esi + vitem32.offset.HI.base], ebx
        mov     [esi + vitem32.vadata.HI.base], ebx
    $end

        jmp    .data.out
   .data.out:

        mov     rsi, [tao]                      ; rsi = table entry offset
        test    rax, rax
        jz     .success                         ; increment item count,
        inc     [rsi + table.header.icount]     ; if new item was inserted
   .success:
        mov     rax, [.ebx]                     ; rax = item index
        jmp    .return
   .error:
        mov     rax, -1                         ; rax = -1 (error)
   .return:
        xor     rdx, rdx
        mov     edx, [rsi + table.header.icount]; rdx = table item count
        pop     rdi rsi rbx
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

        mov     [tao], rcx
        mov     [ina], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    rdi

        stdcall taget, [tao], [ina], -1
        cmp     eax, 0
        jl     .return                          ; eax = item index

        mov     rdx, rax                        ; save result
        mov     rdi, [tao]                      ; rdi = table offset

        xor     rcx, rcx
        mov     ecx, [rdi + table.header.titype]
        shl     rax, 6                          ; rax = 64 * [item index]
        add     rdi, rax
        mov     rax, rdx                        ; restore result
        add     rdi, sizeof.table.header        ; rdi = [table offset] + [table header size] + 64 * [item index]

        cmp     ecx, 1
        je     .fun
        cmp     ecx, 2
        je     .con
        cmp     ecx, 3
        je     .var
        mov     rax, -1
        jmp    .return

   .fun:
        mov     [rdi + fitem64.offset], 0
        jmp    .return
   .con:
        mov     [rdi + citem64.datype], 0
    $ifdef _X64
        mov     qword [rdi + citem64.value], -1
    $else
        mov     dword [edi + citem32.value + 0], -1
        mov     dword [edi + citem32.value + 4], -1
    $end
        jmp    .return
   .var:
        mov     [rdi + vitem64.datype], 0
        mov     [rdi + vitem64.offset], 0
        jmp    .return

   .return:
        pop     rdi
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
; <- rax : item index or negative value on error
; <- rdx : item offset or zero on error
$proc rtaget, tao, ina, ins

    locals
       .ins     dq ?
       .tic     dq ?
    endl

        mov     [tao], rcx
        mov     [ina], rdx
        mov     [ins], r8
;       mov     [], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        xor     rax, rax                        ; rax = 0
        xor     rdx, rdx                        ; rdx = 0

        mov     rsi, [tao]                      ; rsi = table offset
        test    rsi, rsi
        jz     .error                           ; error. null table

        mov     edx, [rsi + table.header.icount]; rdx = table item count
        test    edx, edx
        jz     .error                           ; error. empty table
        mov     [.tic], rdx                     ; save table item count in [.tic]

        xor     rbx, rbx
        mov     ebx, [rsi + table.header.tnsize]; rbx = table item name size

        mov     rdi, [ina]                      ; rdi = item name offset
        test    rdi, rdi
        jz     .error                           ; error. null item name

        mov     rdx, [ins]
        cmp     rdx, rax
        jg     .begin
        je     .error                           ; error. empty item name

        xor     rdx, rdx                        ; get item name size
   .scan:                                       ; scan item name
        cmp     byte [rdi + rdx], 0             ; until null terminating zero found
        je     .scan.out
        inc     rdx
        cmp     rdx, rbx
        jb     .scan
   .scan.out:
        test    rdx, rdx
        jz     .error                           ; error. empty item name

   .begin:
        mov     [.ins], rdx
        cmp     rdx, rbx
        jae    .error                           ; error. invalid item name size

        xor     rbx, rbx
        add     rsi, sizeof.table.header        ; rsi = current item offset

   .search:
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jz     .strnicmp
   .strncmp:
        cinvoke strncmp, rdi, rsi, [.ins]       ; scan table for item with name = item name
        jmp    .strncmp.out
   .strnicmp:
        cinvoke _strnicmp, rdi, rsi, [.ins]     ; scan table for item with name = item name
   .strncmp.out:
        test    eax, eax
        jz     .match
   .search.next:
        add     rsi, 64
        inc     rbx
        cmp     rbx, [.tic]
        jb     .search
        jmp    .error
   .match:
        mov     rcx, [.ins]
        cmp     byte [rsi + rcx], 0
        jnz    .search.next
   .found:
        mov     rax, rbx
        jmp    .return

   .error:
        mov     rax, -1                         ; error. rax = -1, rdx = 0
        xor     rdx, rdx
        jmp    .leave

   .return:
        mov     rdx, rsi                        ; rdx = item offset

   .leave:
        pop     rdi rsi rbx
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
; <- rax : item offset or zero on error
$proc rtaset, tao, ina, ito, fua, fuc

    locals
       .ecx     dq ?
       .ebx     dq ?
       .tic     dd ?
       .tns     dd ?
       .tit     dd ?
       .tio     dq ?
    endl

        mov     [tao], rcx
        mov     [ina], rdx
        mov     [ito], r8
        mov     [fua], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        xor     rax, rax                        ; rax = 0
        mov     [.ebx], rax

        mov     rsi, [tao]                      ; rsi = table entry offset
        test    rsi, rsi
        jz     .error                           ; error. null table

        mov     edx, [rsi + table.header.mcount]
        mov     [.tic], edx                     ; get table item max count
        mov     edx, [rsi + table.header.tnsize]
        mov     [.tns], edx                     ; get table item name size
        mov     edx, [rsi + table.header.titype]
        mov     [.tit], edx                     ; get table item type

        mov     rdi, [ina]                      ; rdi = item name offset
        test    rdi, rdi
        jz     .error                           ; error. null item name

   .params:                                     ; parameters test
        cmp     [.tit], 2
        jne    .error                           ; invalid item type

        cld                                     ; get name length
        xor     rcx, rcx
        mov     ecx, [.tns]
   .scasb:                                      ; scan item name
        dec     rcx                             ; until null terminating zero found or error
        js     .error                           ; error. invalid item name length
        scasb
        jnz    .scasb

        mov     rdi, [ina]                      ; rdi = item name offset
        mov     rsi, [tao]                      ; rsi = table entry offset
        xor     rcx, rcx
        mov     ecx, [rsi + table.header.icount]; ecx = table item count
        xor     rbx, rbx                        ; rbx = current item index
        test    rcx, rcx
        jz     .insert
        mov     [.ecx], rcx                     ; [.ecx] = table item count
        add     rsi, sizeof.table.header        ; rsi = 1st item offset

   .search:
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jz     .stricmp
   .strcmp:
        cinvoke strcmp, rdi, rsi                ; scan table for item with name = item name
        jmp    .strcmp.out
   .stricmp:
        cinvoke _stricmp, rdi, rsi              ; scan table for item with name = item name
   .strcmp.out:
        test    eax, eax                        ; -> rbx - index of inserted item
        jz     .found
        add     rsi, 64
        inc     rbx
        cmp     rbx, [.ecx]
        jb     .search
        jmp    .insert
   .found:
        mov     [.ebx], rbx                     ; save item index
        test    rax, rax
        je     .data                            ; assign data if item already exists

   .insert:                                     ; rbx = item index
        mov     [.ebx], rbx                     ; save item index
        mov     rsi, [tao]                      ; rsi = table entry offset
        xor     rax, rax
        mov     eax, [rsi + table.header.icount]; rax = table item count
        cmp     eax, [.tic]
        jge    .error                           ; error. item count limit exceeded
        mov     rdi, [ina]                      ; rdi = item name offset
        shl     rbx, 6                          ; rbx = 64 * [index]

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + rbx + sizeof.table.header]
        add     rsi, rbx
        add     rsi, sizeof.table.header

        xor     rax, rax                        ; rax = copied char count
        xor     rdx, rdx
        mov     edx, [.tns]                     ; edx = item name size - 1
        dec     rdx
   .name:                                       ; assign item name
        mov     bl, byte [rdi + rax]
        test    bl, bl
        je     .zerop
        test    [@_CFG.cflags], SIC_CFG_FLAG_CASE_SENSITIVE
        jnz     @F
        ctolow  bl                              ; convert char to lowercase
    @@:
        mov     byte [rsi + rax], bl
        inc     rax
        cmp     rax, rdx
        jb     .name
        xor     bl, bl
   .zerop:                                      ; zero padding
        mov     byte [rsi + rax], bl
        inc     rax
        cmp     eax, [.tns]
        jb     .zerop

   .data:
        mov     [.tio], rsi                     ; save table item offset
;       xor     rbx, rbx
        mov     ebx, [.tns]
        add     rsi, rbx

   .data.c.params:
        xor     rbx, rbx
   .data.c.cotype:                              ; set constant type
        mov     [rsi + citem64.cotype.base], bx
   .data.c.datype:                              ; set constant data type
        mov     rbx, [fuc]
        mov     [rsi + citem64.datype.base], bx
   .data.c.value:                               ; set constant value
        mov     ebx, dword [ito]                ; set constant value LO
        mov     [rsi + citem64.value.LO.base], ebx
        mov     [rsi + citem64.codata.LO.base], ebx
        mov     ebx, dword [fua]                ; set constant value HI
        mov     [rsi + citem64.value.HI.base], ebx
        mov     [rsi + citem64.codata.HI.base], ebx

        mov     rsi, [tao]                      ; rsi = table entry offset
        test    rax, rax
        jz     .success                         ; increment item count,
        inc     [rsi + table.header.icount]     ; if new item was inserted

   .success:
        mov     rax, [.tio]                     ; rax = table item offset
        jmp    .return
   .error:
        xor     rax, rax                        ; rax = 0 (error)
   .return:
        pop     rdi rsi rbx
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
; <- rax : table id or zero on error
; <- rdx : item offset or zero on error
$proc nrtaget, sic, ina, ins

    locals
       .fdata   dq ?                            ; function data segment offset
       .cdata   dq ?                            ; constant data segment offset
       .vdata   dq ?                            ; variable data segment offset
    endl

        mov     [sic], rcx
        mov     [ina], rdx
        mov     [ins], r8
;       mov     [], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        cmp     [ins], 0
        jle    .error

        xor     rbx, rbx
        mov     rdi, [ina]
        mov     cl, byte [rdi]
        cmp     cl, '#'
        jne     @F
        dec     [ins]
        jle    .error
        inc     rdi
        inc     rbx
    @@:

        mov     rsi, [sic]                      ; rsi = T_sic_data structure offset
        test    rsi, rsi
        jz     .global                          ; test global

        mov     rcx, [rsi + T_sic_data.fdata]   ; rcx = function data segment offset
        mov     [.fdata], rcx                   ; [.fdata] = function data segment offset

        mov     rcx, [rsi + T_sic_data.cdata]   ; rcx = constant data segment offset
        mov     [.cdata], rcx                   ; [.cdata] = constant data segment offset

        mov     rcx, [rsi + T_sic_data.vdata]   ; rcx = variable data segment offset
        mov     [.vdata], rcx                   ; [.vdata] = variable data segment offset

        test    rbx, rbx
        jnz    .global                          ; test global first

   .local:
        stdcall taget, [.cdata], rdi, [ins]     ; ? local named constant (constant data segment of sic structure)
        mov     rax, 1                          ; rdx = table item offset value
        test    rdx, rdx
        jnz    .leave
        stdcall taget, [.vdata], rdi, [ins]     ; ? local variable (variable data segment of sic structure)
        mov     rax, 2                          ; rdx = table item offset value
        test    rdx, rdx
        jnz    .leave
        stdcall taget, [.fdata], rdi, [ins]     ; ? local function (function data segment of sic structure)
        mov     rax, 3                          ; rdx = table item offset value
        test    rdx, rdx
        jnz    .leave
        test    rbx, rbx
        jnz    .error

   .global:
        stdcall taget, [@_CDATA], rdi, [ins]    ; ? global named constant
        mov     rax, 4                          ; rdx = table item offset value
        test    rdx, rdx
        jnz    .leave
        stdcall taget, [@_VDATA], rdi, [ins]    ; ? global variable
        mov     rax, 5                          ; rdx = table item offset value
        test    rdx, rdx
        jnz    .leave
        stdcall taget, [@_FDATA], rdi, [ins]    ; ? global function
        mov     rax, 6                          ; rdx = table item offset value
        test    rdx, rdx
        jnz    .leave
        test    rsi, rsi
        jz     .error
        test    rbx, rbx
        jnz    .local                           ; test local after global

   .error:
        xor     rax, rax                        ; rax = 0 (error)
        xor     rdx, rdx
   .leave:
        pop     rdi rsi rbx
        ret
$endp ; nrtaget

; ------------------------------------------------------------------------------

; ? ctagettio ( LPVOID tao, LPVOID tio )
; search item in constant table by table.item.offset value
; assume size of table item is 64 bytes
;
; !!! don`t change rax register
;
; -> tao : table offset
; -> tio : table.item.offset value
; <- rdx : item offset or zero on error
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

;       mov     rcx, [tao]                      ; rcx = table offset
        test    rcx, rcx
        jz     .error                           ; error. null table

        mov     r8d, [rcx + table.header.icount]; r8d = table item count
        test    r8d, r8d
        jz     .error                           ; error. empty table

;       mov     rdx, [tio]
        add     rcx, sizeof.table.header        ; rcx = current item offset
   .scan:
;       mov     r9b, byte [rcx + citem64.datype]
;       cmp     r9b, 's'                        ; ? string
;       jne    .scan.offset
   .scan.string:
        lea     r9q, [rcx + citem64.offset]     ; r9q = table.offset address
        cmp     r9q, rdx
        jne    .scan.offset
        mov     rdx, rcx
        jmp    .leave
   .scan.offset:
        cmp     rdx, [r9q]
        jne    .scan.next
        mov     rdx, rcx
        jmp    .leave
   .scan.next:
        add     rcx, 64                         ; rcx = next item offset
        dec     r8d
        jns    .scan

   .error:
        xor     rdx, rdx                        ; error. rdx = 0

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
; !!! don`t change rax register
;
; -> tao : table offset
; -> tio : table.item.offset value
; <- rdx : item offset or zero on error
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

;       mov     rcx, [tao]                      ; rcx = table offset
        test    rcx, rcx
        jz     .error                           ; error. null table

        mov     r8d, [rcx + table.header.icount]; r8d = table item count
        test    r8d, r8d
        jz     .error                           ; error. empty table

;       mov     rdx, [tio]
        add     rcx, sizeof.table.header        ; rcx = current item offset
   .scan:
;       mov     r9b, byte [rcx + vitem64.datype]
;       cmp     r9b, 's'                        ; ? string
;       jne    .scan.offset
   .scan.string:
        lea     r9q, [rcx + vitem64.offset]     ; r9q = table.offset address
        cmp     r9q, rdx
        jne    .scan.offset
        mov     rdx, rcx
        jmp    .leave
   .scan.offset:
        cmp     rdx, [r9q]
        jne    .scan.next
        mov     rdx, rcx
        jmp    .leave
   .scan.next:
        add     rcx, 64                         ; rcx = next item offset
        dec     r8d
        jns    .scan

   .error:
        xor     rdx, rdx                        ; error. rdx = 0

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
; !!! don`t change rax register
;
; -> sic : T_sic_data structure offset
; -> tio : table.item.offset value
; <- rdx : item offset or zero on error
$proc tagettio, sic, tio

    locals
       .rdata   dq ?                            ; runtime data segment offset
       .cdata   dq ?                            ; constant data segment offset
       .vdata   dq ?                            ; variable data segment offset
    endl

        mov     [sic], rcx
        mov     [tio], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
    $ifndef _X64
        push    eax
    $end

;       mov     rcx, [sic]                      ; rcx = T_sic_data structure offset
        test    rcx, rcx
        jz     .error                           ; error. null T_sic_data structure

        mov     r10, [rcx + T_sic_data.rdata]   ; r10 = runtime data segment offset
        mov     [.rdata], r10
        mov     r10, [rcx + T_sic_data.cdata]   ; r10 = constant data segment offset
        mov     [.cdata], r10
        mov     r10, [rcx + T_sic_data.vdata]   ; r10 = variable data segment offset
        mov     [.vdata], r10

        stdcall ctagettio, [.rdata], [tio]
        test    rdx, rdx
        jnz    .leave
        stdcall vtagettio, [.vdata], [tio]
        test    rdx, rdx
        jnz    .leave
        stdcall vtagettio, [@_VDATA], [tio]
        test    rdx, rdx
        jnz    .leave

        stdcall ctagettio, [.cdata], [tio]
        test    rdx, rdx
        jnz    .leave
        stdcall vtagettio, [@_CDATA], [tio]
        test    rdx, rdx
        jnz    .leave

   .error:
        xor     rdx, rdx                        ; error. rdx = 0

   .leave:
    $ifndef _X64
        pop     eax
    $end
        ret
$endp ; tagettio

; ------------------------------------------------------------------------------

; set system table items
; -> rdata - table offset
; <- rax   - last table item offset
$proc sysset, rdata

    macro .set.o name
    {
        mov     rdx, name
        xor     rax, rax
        mov     al, 'o'
        stdcall rtaset, [rdata], rdx, 0, 0, rax
    }

    macro .set.f name
    {
        mov     rdx, name
        xor     rax, rax
        mov     al, 'f'
        stdcall rtaset, [rdata], rdx, 0, 0, rax
    }

    macro .set.i name
    {
        mov     rdx, name
        xor     rax, rax
        mov     al, 'i'
        stdcall rtaset, [rdata], rdx, 0, 0, rax
    }

        mov     [rdata], rcx
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
        mov     dst, rdx
    }

        push    rax rcx rdx

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

        pop     rdx rcx rax

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
        mov     [ava], rdx
;       mov     [], r8
;       mov     [], r9

       .proc.enter

;       mov     rcx, [sic]
        test    rcx, rcx
        jz     .return

        mov     edx, [rcx + T_sic_data.dsize]
        add     rdx, [rcx + T_sic_data.data]    ; rdx = current data cursor

   .data.align.in:
        cmp     [ava], 0
        jle    .data.align.out
        cmp     [ava], 64
        jg     .data.align.out
   .data.align.begin:
        push    rcx
        mov     rax, rdx
        xor     rdx, rdx
        mov     rcx, [ava]
        div     rcx
        sub     rcx, rdx
        mov     rax, rcx
        pop     rcx
        add     [rcx + T_sic_data.dsize], eax
        sub     [rcx + T_sic_data.dspace], eax
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
; <- rax : item offset or zero on error
; <- rdx : data offset or zero on error
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
        mov     [cof], r8
        mov     [ava], r9

       .proc.enter

;       mov     rcx, [sic]
        test    rcx, rcx
        jz     .error

        mov     rsi, rcx
        mov     rcx, [rsi + T_sic_data.rdata]   ; rcx = runtime data segment offset
        stdcall rtaset, rcx, rdx, 0, 0, [cof]   ; add runtime item
        test    rax, rax
        jz     .error

        mov     edx, [rsi + T_sic_data.dsize]
        add     rdx, [rsi + T_sic_data.data]    ; rdx = current data cursor

   .data.align.in:                              ; runtime variables memory alignment
        cmp     [ava], 0
        jle    .data.align.out
        cmp     [ava], 64
        jg     .data.align.out
   .data.align.begin:
        xor     r9q, r9q
        push    rax rdx
        mov     rax, rdx
        xor     rdx, rdx
        mov     rcx, [ava]
        div     rcx
;       test    rdx, rdx
;       jz     .data.align.end
        sub     rcx, rdx
        mov     r9q, rcx
        add     [rsi + T_sic_data.dsize], ecx
        sub     [rsi + T_sic_data.dspace], ecx
   .data.align.end:
        pop     rdx rax
        add     rdx, r9q
   .data.align.out:

        mov     rcx, [cof]
        cmp     cx, 'f1'
        je     .f1
        cmp     cx, 'i1'
        je     .i1
        cmp     cx, 'f2'
        je     .f2
        jmp    .return

   .i4:
        mov     r9d, 32
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
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
        mov     r9d, 24
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
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
        mov     r9d, 16
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
    $ifdef _X64
        mov     [rdx + 00], rcx
        mov     [rdx + 08], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
    $end
        jmp    .i.assign

   .i1:
        mov     r9d, 08
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
    $ifdef _X64
        mov     [rdx + 00], rcx
    $else
        mov     [edx + 00], ecx
    $end

   .i.assign:
        mov     [rax + citem64.offset], rdx
    $ifdef _X64
        mov     [rax + citem64.codata], rdx
    $else
        mov     dword [eax + citem32.codata + 0], edx
        mov     dword [eax + citem32.codata + 4], ecx
    $end
        add     [rsi + T_sic_data.dsize], r9d
        sub     [rsi + T_sic_data.dspace], r9d
        jmp    .return

   .f4:
        mov     r9d, 32
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
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
        mov     r9d, 24
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
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
        mov     r9d, 16
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
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
        mov     r9d, 08
        cmp     [rsi + T_sic_data.dspace], r9d
        jb     .error
        xor     rcx, rcx
    $ifdef _X64
        mov     [rdx + 00], rcx
    $else
        mov     [edx + 00], ecx
        mov     [edx + 04], ecx
    $end

   .f.assign:
        mov     [rax + citem64.offset], rdx
    $ifdef _X64
        mov     [rax + citem64.codata], rdx
    $else
        mov     dword [eax + citem32.codata + 0], edx
        mov     dword [eax + citem32.codata + 4], ecx
    $end
        add     [rsi + T_sic_data.dsize], r9d
        sub     [rsi + T_sic_data.dspace], r9d
;       jmp    .return

   .return:
       .proc.leave
        ret

   .error:
        xor     rax, rax
        xor     rdx, rdx
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
; <- rax : data offset or zero on error
; <- rcx : data size or zero on error
$proc costr, sic, sdo, sds

;       mov     [sic], rcx
;       mov     [sdo], rdx
        mov     [sds], r8
;       mov     [], r9

   .enter:
        pushsa  rsi                             ; push & 16-byte stack align for x64

;       mov     rcx, [sic]
        test    rcx, rcx
        jz     .error

;       mov     rdx, [sdo]
        test    rdx, rdx
        jz     .error

        mov     rsi, rcx
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
        test    rax, rax
        jz     .error

        mov     rcx, [sds]
        mov     byte [rax + rcx], 0
        lea     rdx, [rcx + 1]
        add     [rsi + T_sic_data.dsize], edx
        sub     [rsi + T_sic_data.dspace], edx

   .return:
        pop     rsi
        ret

   .error:
        pop     rsi
        xor     rax, rax
        xor     rcx, rcx
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
;       push    r10

;       mov     rcx, [cto]                      ; rcx = table offset
        test    rcx, rcx
        jz     .leave                           ; return. null table
;       mov     rdx, [off]                      ; rdx = delta value
        test    rdx, rdx
        jz     .leave                           ; return. no delta

;       xor     rax, rax
        mov     eax, [rcx + table.header.titype]; eax = table item type
        cmp     eax, 2
        jne    .leave                           ; return. non constant table
        mov     eax, [rcx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .leave                           ; return. empty table

        lea     r10, [rcx + sizeof.table.header - 64]
   .scan:
        add     r10, 64                         ; r10 = table item offset
        mov     cx, [r10 + citem64.datype]
        cmp     cx, 'o'
        jne    .next
   .test:
        mov     rcx, [r10 + citem64.offset]
        test    rcx, rcx
        jz     .next
   .update:
        add     rcx, rdx                        ; update non null values only
        mov     [r10 + citem64.offset], rcx
   .next:
        dec     rax
        jnz    .scan

   .leave:
;       pop     r10
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
;       push    r10

;       mov     rcx, [cto]                      ; rcx = table offset
        test    rcx, rcx
        jz     .leave                           ; return. null table
;       mov     rdx, [off]                      ; rdx = delta value
        test    rdx, rdx
        jz     .leave                           ; return. no delta

;       xor     rax, rax
        mov     eax, [rcx + table.header.titype]; eax = table item type
        cmp     eax, 2
        jne    .leave                           ; return. non constant table
        mov     eax, [rcx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .leave                           ; return. empty table

        lea     r10, [rcx + sizeof.table.header - 64]
   .scan:
        add     r10, 64                         ; r10 = table item offset
        mov     cx, [r10 + citem64.datype]
        cmp     cx, 'f1'
        je     .test
        cmp     cx, 'i1'
        je     .test
        cmp     cx, 'f2'
        je     .test
        jmp    .next
   .test:
        mov     rcx, [r10 + citem64.offset]
        test    rcx, rcx
        jz     .next
   .update:
        add     rcx, rdx                        ; update non null values only
        mov     [r10 + citem64.offset], rcx
   .next:
        dec     rax
        jnz    .scan

   .leave:
;       pop     r10
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
;       push    r10

;       mov     rcx, [cto]                      ; rcx = table offset
        test    rcx, rcx
        jz     .leave                           ; return. null table

        xor     rax, rax
        mov     eax, [rcx + table.header.titype]; eax = table item type
        cmp     eax, 2
        jne    .leave                           ; return. non constant table
        mov     eax, [rcx + table.header.icount]; eax = table item count
        test    eax, eax
        jz     .leave                           ; return. empty table

        xor     rdx, rdx                        ; rdx = 0
        lea     r10, [rcx + sizeof.table.header - 64]
   .scan:
        add     r10, 64                         ; r10 = table item offset
        mov     cx, [r10 + citem64.datype]
        cmp     cx, 'o'
        jne    .next
        mov     [r10 + citem64.offset], rdx
   .next:
        dec     rax
        jnz    .scan

   .leave:
;       pop     r10
        ret
$endp ; conoze

; ------------------------------------------------------------------------------

; INT conoun ( LPVOID cto )
; get undefined items count in constant table
;
; -> cto : constant table offset
; <- rax : undefined items count
$proc conoun, cto

;       mov     [cto], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
;       push    r10

        xor     rax ,rax
;       mov     rcx, [cto]                      ; rcx = table offset
        test    rcx, rcx
        jz     .leave                           ; return. null table

        xor     rdx, rdx
        mov     edx, [rcx + table.header.titype]; rdx = table item type
        cmp     edx, 2
        jne    .leave                           ; return. non constant table
        mov     edx, [rcx + table.header.icount]; rdx = table item count
        test    edx, edx
        jz     .leave                           ; return. empty table

        lea     r10, [rcx + sizeof.table.header - 64]
   .scan:
        add     r10, 64                         ; r10 = table item offset
        mov     cx, [r10 + citem64.datype]
        cmp     cx, '?'
        jne    .next
        inc     rax
   .next:
        dec     rdx
        jnz    .scan

   .leave:
;       pop     r10
        ret
$endp ; conoun

; ------------------------------------------------------------------------------

; PVOID conoma ( LPVOID cto )
; get max offset value
;
; -> cto : constant table offset
; <- rax : max offset value
$proc conoma, cto

;       mov     [cto], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
;       push    r10

        xor     rax ,rax
;       mov     rcx, [cto]                      ; rcx = table offset
        test    rcx, rcx
        jz     .leave                           ; return. null table

        xor     rdx, rdx
        mov     edx, [rcx + table.header.titype]; rdx = table item type
        cmp     edx, 2
        jne    .leave                           ; return. non constant table
        mov     edx, [rcx + table.header.icount]; rdx = table item count
        test    edx, edx
        jz     .leave                           ; return. empty table

        lea     r10, [rcx + sizeof.table.header - 64]
   .scan:
        add     r10, 64                         ; r10 = table item offset
        mov     cx, [r10 + citem64.datype]
        cmp     cx, 'o'
        jne    .next
        mov     rcx, [r10 + citem64.offset]
        cmp     rax, rcx
        ja     .next
        mov     rax, rcx
   .next:
        dec     rdx
        jnz    .scan

   .leave:
;       pop     r10
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

        mov     [tao], rcx
        mov     [tat], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    rbx rsi rdi

        mov     rax, [tao]                      ; eax = table offset
        test    rax, rax
        jz     .leave                           ; skip null table

   .type.test:
        cmp     [tat], 1
        je     .type.test.out
        cmp     [tat], 2
        je     .type.test.out
        cmp     [tat], 3
        je     .type.test.out
        xor     rax, rax
        jmp    .leave
   .type.test.out:

        xor     rcx, rcx
        mov     ecx, [rax + table.header.icount]; ecx = table item count
        test    ecx, ecx
        jz     .return                          ; skip empty table

        xor     rdx, rdx
        xor     rbx, rbx
        mov     ebx, [rax + table.header.tnsize]; ebx = table item name size
        lea     rsi, [rax + sizeof.table.header - 64]
   .scan:
        add     rsi, 64                         ; rsi = table item offset
        cmp     [tat], 1
        je     .scan.function
        cmp     [tat], 2
        je     .scan.constant                   ; assume any constant valid
        cmp     [tat], 3
        je     .scan.variable
        jmp    .invalid
   .scan.function:
        mov     rdi, [rsi + fitem64.offset]     ; rdi = function offset
        test    rdi, rdi
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
;       movzx   rdi, word [rsi + citem64.value + 6]
;       and     rdi, 0x7FF0
;       cmp     rdi, 0x7FF0
;       jne    .valid
;       jmp    .invalid
   .scan.variable:
        mov     rdi, [rsi + vitem64.offset]     ; rdi = variable offset
        test    rdi, rdi
        jnz    .valid
        jmp    .invalid
   .invalid:
        inc     rdx
        dec     [rax + table.header.icount]     ; decrease valid item count
        jmp    .next
   .valid:
        test    rdx, rdx
        jz     .next                            ; rdx = [invalid item count]
   .shift:
        shl     rdx, 6                          ; rdx = [invalid item count] * 64
        mov     rdi, rsi
        sub     rdi, rdx                        ; rdi = rsi - [invalid item count] * 64
        push    rcx rdi
        cld
        shl     rcx, 4                          ; rcx = dwords to copy (count*64/4=count*16)
        rep     movsd
        pop     rsi rcx                         ; rsi = rdi
        xor     rdx, rdx
   .next:
        dec     rcx
        jnz    .scan

        mov     rsi, rax
        xor     rdi, rdi
        mov     edi, [rsi + table.header.icount]; edi = table item count
        shl     rdi, 6                          ; rdi = [item count] * 64
        add     rdi, sizeof.table.header        ; rdi = [item count] * 64 + [table header size]
        stdcall hrealloc, rsi, rdi              ; decrease table size
   .return:
        mov     edx, [rax + table.header.icount]; edx = table item count
        mov     [rax + table.header.mcount], edx; set maximum item count to current item count
        xor     rax, rax
        mov     eax, edx                        ; eax = table item count
   .leave:
        pop     rdi rsi rbx
        ret
$endp ; tapac

; ------------------------------------------------------------------------------

; DWORD funloas ( LPCSTR filename, DWORD filesize, LPCSTR section )
; load external user defined functions from inifile section
;
; <- eax : external function item count
; <- rcx : library handle

$ifdef _UDF
$proc funloas, filename, filesize, section

    locals
       .IC      dd ?
       .LIB     dq ?
       .BUFFER  dq ?
       .ID      dq ?
       .SAC     dq ? ; argument count string
       .SAF     dq ? ; argument flags string
       .SRT     dq ? ; return type string
       .SDF     dq ? ; dynamic function string
       .AC      dq ? ; argument count
       .AF      dq ? ; argument flags
       .RT      dq ? ; return type
       .PCHAR   dq ?
       .DU      db ?
       .RE      db ?
       .EX      db ?
       .IV      db ?
       .LIBname db 256 dup ?
    endl

        mov     [filename], rcx
        mov     [filesize], rdx
        mov     [section], r8
;       mov     [], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        xor     rax, rax
        mov     [.IC], eax
        mov     [.LIB], rax
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
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .return
        cmp     eax, 255
        ja     .return

        ; name:000 -> name
        xor     rdx, rdx
   .UDF.L0:
        inc     rdx
        mov     cl, byte [rdi + rdx - 1]
        cmp     cl, 0
        je     .UDF.LL
        cmp     cl, ':'
        je     .UDF.LT
        jmp    .UDF.L8
   .UDF.LT:
        cmp     rdx, 2
        jne    .UDF.LT.main
        mov     ch, byte [rdi + rdx]
        cmp     ch, '\'                         ; ?:\...
        je     .UDF.L8
        cmp     ch, '/'                         ; ?:/...
        je     .UDF.L8
   .UDF.LT.main:
        dec     rdx
        jmp    .UDF.LL
   .UDF.L8:
        cmp     edx, eax
        jb     .UDF.L0
   .UDF.LL:
        mov     eax, edx
        test    eax, eax
        jz     .return
        push    rax
        lea     rcx, [.LIBname]
        cinvoke strcpy, rcx, rdi
        pop     rax
        mov     byte [.LIBname + rax], 0

        cmp     eax, 2
        jne    .UDF_main
        mov     ax, word [rdi]
        case    ax,\
                '==', .UDF_SIC,\                ; SICx64.DLL
                '++', .UDF_DU,\                 ; duplicate
                '+-', .UDF_RE,\                 ; rename
                '-+', .UDF_EX,\                 ; exchange
                '--', .UDF_IV                   ; invalidate
        jmp    .UDF_main
   .UDF_SIC:
        invoke  LoadLibrary, S_SIC_DLL
;       invoke  LoadLibraryEx, S_SIC_DLL, 0, 0
        cmp     rax, 32
        jl     .return
        mov     [.LIB], rax
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
        lea     rcx, [.LIBname]
        stdcall DLLLoad, rcx
;       lea     rcx, [.LIBname]
;       invoke  LoadLibrary, rcx
;;      invoke  LoadLibraryEx, rcx, 0, 0
        cmp     rax, 32
        jl     .return
        mov     [.LIB], rax

   .UDF_ALLOC:
        stdcall halloc, [filesize]
        mov     rdi, rax
        mov     [.BUFFER], rdi
   .UDF_READ:
        ; DWORD GetPrivateProfileSection ( LPCTSTR, LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSection, [section], rdi, [filesize], [filename]
        test    eax, eax
        jz     .UDF_FREE
        lea     rbx, [rdi - 1]
   .UDF_TEST:
        lea     rdi, [rbx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .UDF_FREE

        xor     rdx, rdx
        mov     edx, eax
        lea     rbx, [rdi + rdx]
        cmp     byte [rdi], '*'                 ; skip commented item
        je     .UDF_TEST
        cmp     byte [rdi], '#'                 ; skip commented item
        je     .UDF_TEST
        cmp     byte [rdi], ';'                 ; skip commented item
        je     .UDF_TEST
        lea     rsi, [rdi - 1]

   .UDF_SCAN_name:
        inc     rsi
        cmp     byte [rsi], 0
        je     .UDF_TEST
        cmp     byte [rsi], '='
        jne    .UDF_SCAN_name
   .UDF_SCAN_name_SET:
        mov     byte [rsi], 0
        lea     rax, [rsi + 1]
        mov     [.ID], rax

        mov     [.SAC], 0
        mov     [.SAF], 0
        mov     [.SRT], 0
        mov     [.SDF], 0

   .UDF_SCAN_AC:
        inc     rsi
        cmp     byte [rsi], 0
        je     .UDF_SET
        cmp     byte [rsi], '='
        je     .UDF_SCAN_AC_SET
        cmp     byte [rsi], ':'
        je     .UDF_SCAN_AC_SET
        jmp    .UDF_SCAN_AC
   .UDF_SCAN_AC_SET:
        mov     byte [rsi], 0
        lea     rax, [rsi + 1]
        mov     [.SAC], rax

   .UDF_SCAN_AF:
        inc     rsi
        cmp     byte [rsi], 0
        je     .UDF_SET
        cmp     byte [rsi], '='
        je     .UDF_SCAN_AF_SET
        cmp     byte [rsi], ':'
        je     .UDF_SCAN_AF_SET
        jmp    .UDF_SCAN_AF
   .UDF_SCAN_AF_SET:
        mov     byte [rsi], 0
        lea     rax, [rsi + 1]
        mov     [.SAF], rax

   .UDF_SCAN_RT:
        inc     rsi
        cmp     byte [rsi], 0
        je     .UDF_SET
        cmp     byte [rsi], '='
        je     .UDF_SCAN_RT_SET
        cmp     byte [rsi], ':'
        je     .UDF_SCAN_RT_SET
        jmp    .UDF_SCAN_RT
   .UDF_SCAN_RT_SET:
        mov     byte [rsi], 0
        lea     rax, [rsi + 1]
        mov     [.SRT], rax

   .UDF_SCAN_DF:
        inc     rsi
        cmp     byte [rsi], 0
        je     .UDF_SET
        cmp     byte [rsi], '='
        je     .UDF_SCAN_DF_SET
        cmp     byte [rsi], ':'
        je     .UDF_SCAN_DF_SET
        jmp    .UDF_SCAN_DF
   .UDF_SCAN_DF_SET:
        mov     byte [rsi], 0
        lea     rax, [rsi + 1]
        mov     [.SDF], rax

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
        stdcall sic_refun, NULL, rdi, [.ID], 0  ; duplicate
        jmp    .UDF_TEST
   .UDF_SET_RE:
        stdcall sic_refun, NULL, rdi, [.ID], 1  ; rename
        jmp    .UDF_TEST
   .UDF_SET_EX:
        stdcall sic_exfun, NULL, rdi, [.ID]     ; exchange
        jmp    .UDF_TEST
   .UDF_SET_IV:
        stdcall sic_invaf, NULL, rdi            ; invalidate
        jmp    .UDF_TEST
   .UDF_SET_main:
        mov     [.AC], 0
        mov     [.AF], 0
        mov     [.RT], 0
        ; long strtol ( char *nptr, char **endptr, int base )
   .UDF_SET_AC:
        cmp     [.SAC], 0
        jz     .UDF_SET_AC_OUT
        lea     rdx, [.PCHAR]
        cinvoke strtol, [.SAC], rdx, 10
        mov     rdx, [.PCHAR]
        cmp     rdx, [.SAC]
        je     .UDF_SET_AC_OUT                  ; error. no integer value
        test    eax, 0xFFFF0000
        jnz    .UDF_SET_AC_OUT                  ; error. out of range
        xor     rdx, rdx
        mov     dx, ax
        mov     [.AC], rdx
   .UDF_SET_AC_OUT:
   .UDF_SET_AF:
        cmp     [.SAF], 0
        jz     .UDF_SET_AF_OUT
        lea     rdx, [.PCHAR]
        cinvoke strtol, [.SAF], rdx, 02
        mov     rdx, [.PCHAR]
        cmp     rdx, [.SAF]
        je     .UDF_SET_AF_OUT                  ; error. no integer value
        and     rax, 0xFF
        mov     [.AF], rax
   .UDF_SET_AF_OUT:
   .UDF_SET_RT:
        cmp     [.SRT], 0
        jz     .UDF_SET_RT_OUT
        lea     rdx, [.PCHAR]
        cinvoke strtol, [.SRT], rdx, 10
        mov     rdx, [.PCHAR]
        cmp     rdx, [.SRT]
        je     .UDF_SET_RT_OUT                  ; error. no integer value
        xor     rdx, rdx
        mov     dl, al
        mov     [.RT], rdx
   .UDF_SET_RT_OUT:
   .UDF_SET_DF:
        mov     rax, [.SDF]
        test    rax, rax
        jz     .UDF_SET_DF_OUT
        cmp     byte [rax], 'D'
        je     .UDF_SET_DF_D
        cmp     byte [rax], 'd'
        je     .UDF_SET_DF_D
        jmp    .UDF_SET_DF_OUT
   .UDF_SET_DF_D:
        mov     al, byte [rax + 1]
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
;       invoke  GetProcAddress, [.LIB], rdi
        invoke  GetProcAddress, [.LIB], [.ID]
        test    rax, rax
        jz     .UDF_TEST
        mov     rdx, [.RT]
        and     rdx, 00001111B                  ; return type mask = 0x0F (00001111)
        shl     rdx, 8
        or      [.AF], rdx                      ; [.AF] = function flags
;       stdcall sic_afun, NULL, [.ID], rax, [.AC], [.AF]
        stdcall sic_afun, NULL, rdi, rax, [.AC], [.AF]
        cmp     rax, 0
        jl     .UDF_TEST
        inc     [.IC]
        jmp    .UDF_TEST
   .UDF_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        mov     rcx, [.LIB]
        mov     eax, [.IC]
        test    eax, eax
        jnz    .leave
        test    rcx, rcx
        jz     .leave
        invoke  FreeLibrary, rcx
        xor     rax, rax
        xor     rcx, rcx
   .leave:
        pop     rdi rsi rbx
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
       .BUFFER  dq ?
       .PCHAR   dq ?
       .FLOAT   dq ?
       .DU      db ?
       .RE      db ?
       .EX      db ?
       .IV      db ?
    endl

        mov     [filename], rcx
        mov     [filesize], rdx
        mov     [section], r8
;       mov     [], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        xor     rax, rax
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
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .return

        cmp     eax, 2
        jne    .UDC_main
        mov     ax, word [rdi]
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
        mov     rdi, rax
        mov     [.BUFFER], rdi
   .UDC_READ:
        ; DWORD GetPrivateProfileSection ( LPCTSTR, LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSection, [section], rdi, [filesize], [filename]
        test    eax, eax
        jz     .UDC_FREE
        lea     rbx, [rdi - 1]
   .UDC_TEST:
        lea     rdi, [rbx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .UDC_FREE

        xor     rdx, rdx
        mov     edx, eax
        lea     rbx, [rdi + rdx]
        cmp     byte [rdi], '*'                 ; skip commented item
        je     .UDC_TEST
        cmp     byte [rdi], '#'                 ; skip commented item
        je     .UDC_TEST
        cmp     byte [rdi], ';'                 ; skip commented item
        je     .UDC_TEST
        lea     rsi, [rdi - 1]
   .UDC_SCAN:
        inc     rsi
        cmp     byte [rsi], 0
        jnz    .UDC_SCAN_CHAR
        cmp     [.IV], 0
        jnz    .UDC_SET
        jmp    .UDC_TEST
   .UDC_SCAN_CHAR:
        cmp     byte [rsi], '='
        jne    .UDC_SCAN
        mov     byte [rsi], 0

   .UDC_SET:
        inc     rsi
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
        stdcall sic_recon, NULL, rdi, rsi, 0    ; duplicate
        jmp    .UDC_TEST
   .UDC_SET_RE:
        stdcall sic_recon, NULL, rdi, rsi, 1    ; rename
        jmp    .UDC_TEST
   .UDC_SET_EX:
        stdcall sic_excon, NULL, rdi, rsi       ; exchange
        jmp    .UDC_TEST
   .UDC_SET_IV:
        stdcall sic_invac, NULL, rdi            ; invalidate
        jmp    .UDC_TEST
   .UDC_SET_main:
        lea     rdx, [.PCHAR]
        cinvoke strtod, rsi, rdx
        mov     rdx, [.PCHAR]
    $ifdef _X64
        movsd   qword [.FLOAT], xmm0            ; x64
    $else
        fstp    qword [.FLOAT]                  ; x32
    $end
        cmp     rsi, rdx
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
        cmp     rax, 0
        jl     .UDC_TEST
        inc     [.IC]
        jmp    .UDC_TEST
   .UDC_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        xor     rax, rax
        mov     eax, [.IC]
        pop     rdi rsi rbx
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
; <- rcx : library handle

$ifdef _UDF
$proc varloas, filename, filesize, section

    locals
       .IC      dd ?
       .LIB     dq ?
       .BUFFER  dq ?
       .PCHAR   dq ?
       .DU      db ?
       .RE      db ?
       .EX      db ?
       .IV      db ?
       .LIBname db 256 dup ?
    endl

        mov     [filename], rcx
        mov     [filesize], rdx
        mov     [section], r8
;       mov     [], r9

   .enter:
        pushsa  rbx, rsi, rdi                   ; push & 16-byte stack align for x64

        xor     rax, rax
        mov     [.IC], eax
        mov     [.LIB], rax
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
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .return
        cmp     eax, 255
        ja     .return

        ; name:000 -> name
        xor     rdx, rdx
   .UDF.L0:
        inc     rdx
        mov     cl, byte [rdi + rdx - 1]
        cmp     cl, 0
        je     .UDF.LL
        cmp     cl, ':'
        je     .UDF.LT
        jmp    .UDF.L8
   .UDF.LT:
        cmp     rdx, 2
        jne    .UDF.LT.main
        mov     ch, byte [rdi + rdx]
        cmp     ch, '\'                         ; ?:\...
        je     .UDF.L8
        cmp     ch, '/'                         ; ?:/...
        je     .UDF.L8
   .UDF.LT.main:
        dec     rdx
        jmp    .UDF.LL
   .UDF.L8:
        cmp     edx, eax
        jb     .UDF.L0
   .UDF.LL:
        mov     eax, edx
        test    eax, eax
        jz     .return
        push    rax
        lea     rcx, [.LIBname]
        cinvoke strcpy, rcx, rdi
        pop     rax
        mov     byte [.LIBname + rax], 0

        cmp     eax, 2
        jne    .UDV_main
        mov     ax, word [rdi]
        case    ax,\
                '==', .UDV_SIC,\                ; SICx64.DLL
                '++', .UDV_DU,\                 ; duplicate
                '+-', .UDV_RE,\                 ; rename
                '-+', .UDV_EX,\                 ; exchange
                '--', .UDV_IV                   ; invalidate
        jmp    .UDV_main
   .UDV_SIC:
        invoke  LoadLibrary, S_SIC_DLL
;       invoke  LoadLibraryEx, S_SIC_DLL, 0, 0
        cmp     rax, 32
        jl     .return
        mov     [.LIB], rax
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
        lea     rcx, [.LIBname]
        stdcall DLLLoad, rcx
;       lea     rcx, [.LIBname]
;       invoke  LoadLibrary, rcx
;;      invoke  LoadLibraryEx, rcx, 0, 0
        cmp     rax, 32
        jl     .return
        mov     [.LIB], rax

   .UDV_ALLOC:
        stdcall halloc, [filesize]
        mov     rdi, rax
        mov     [.BUFFER], rdi
   .UDV_READ:
        ; DWORD GetPrivateProfileSection ( LPCTSTR, LPTSTR, DWORD, LPCTSTR )
        invoke  GetPrivateProfileSection, [section], rdi, [filesize], [filename]
        test    eax, eax
        jz     .UDV_FREE
        lea     rbx, [rdi - 1]
   .UDV_TEST:
        lea     rdi, [rbx + 1]
        ; int lstrlen ( LPCTSTR )
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax
        jz     .UDV_FREE

        xor     rdx, rdx
        mov     edx, eax
        lea     rbx, [rdi + rdx]
        cmp     byte [rdi], '*'                 ; skip commented item
        je     .UDV_TEST
        cmp     byte [rdi], '#'                 ; skip commented item
        je     .UDV_TEST
        cmp     byte [rdi], ';'                 ; skip commented item
        je     .UDV_TEST
        lea     rsi, [rdi - 1]
   .UDV_SCAN_name:
        inc     rsi
        cmp     byte [rsi], 0
        jnz    .UDV_SCAN_CHAR
        cmp     [.IV], 0
        jnz    .UDV_SET
        jmp    .UDV_TEST
   .UDV_SCAN_CHAR:
        cmp     byte [rsi], '='
        jne    .UDV_SCAN_name
        mov     byte [rsi], 0

   .UDV_SET:
        inc     rsi
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
        stdcall sic_revar, NULL, rdi, rsi, 0    ; duplicate
        jmp    .UDV_TEST
   .UDV_SET_RE:
        stdcall sic_revar, NULL, rdi, rsi, 1    ; rename
        jmp    .UDV_TEST
   .UDV_SET_EX:
        stdcall sic_exvar, NULL, rdi, rsi       ; exchange
        jmp    .UDV_TEST
   .UDV_SET_IV:
        stdcall sic_invav, NULL, rdi            ; invalidate
        jmp    .UDV_TEST
   .UDV_SET_main:
   .UDV_ADD:
        invoke  GetProcAddress, [.LIB], rsi
        test    rax, rax
        jz     .UDV_TEST
        stdcall sic_avarf, NULL, rdi, rax
        cmp     rax, 0
        jl     .UDV_TEST
        inc     [.IC]
        jmp    .UDV_TEST
   .UDV_FREE:
        stdcall hfree, [.BUFFER]

   .return:
        mov     rcx, [.LIB]
        mov     eax, [.IC]
        test    eax, eax
        jnz    .leave
        test    rcx, rcx
        jz     .leave
        invoke  FreeLibrary, rcx
        xor     rax, rax
        xor     rcx, rcx
   .leave:
        pop     rdi rsi rbx
        ret
$endp ; varloas
$else
$proc varloas, filename, filesize, section
        ret
$endp ; varloas
$end

; ------------------------------------------------------------------------------

; move memory
; !!! don`t change RAX register
;
; -> rdi - destination
; -> rsi - source
; -> rcx - byte count to copy
$sproc momem

        cmp     rcx, 0
        jle    .return

        cld
        mov     rdx, rcx
        and     rdx, 3
        shr     rcx, 2
        rep     movsd
        or      rcx, rdx
        jz     .return
        rep     movsb
   .return:
        retn
$endp ; momem

; ------------------------------------------------------------------------------

; copy memory
proc copymem, dst, src, size

        mov     [dst], rcx
        mov     [src], rdx
        mov     [size], r8
;       mov     [], r9

   .enter:
        mov     rcx, [size]
        cmp     rcx, 0
        jle    .return

        push    rsi rdi

        mov     rdi, [dst]
        mov     rsi, [src]

        cld
        shr     rcx, 2
        rep     movsd
        mov     rcx, [size]
        and     rcx, 3
        rep     movsb

        pop     rdi rsi
   .return:
        ret
endp ; copymem

; ------------------------------------------------------------------------------

; get process heap
; <- rcx - process heap
proc getheap

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        mov     rcx, [@_HEAP]
        test    rcx, rcx
        jnz    .return
        invoke  GetProcessHeap
        mov     rcx, rax
        mov     [@_HEAP], rax
   .return:
        ret
endp ; getheap

; ------------------------------------------------------------------------------

; allocate memory
; <- rax - memory
proc halloc, size

        mov     [size], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        stdcall getheap                         ; rcx = process heap
        invoke  HeapAlloc, rcx, 0, [size]
   .return:
        ret
endp ; halloc

; ------------------------------------------------------------------------------

; reallocate memory (!!! safe for decreasing size only)
; <- rax - memory
proc hrealloc mem, size

   .HEAP_REALLOC_IN_PLACE_ONLY = 0x00000010

        mov     [mem], rcx
        mov     [size], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        test    rcx, rcx                        ; x64: rcx=[mem]
;       cmp     [mem], 0
        jz     .return

        stdcall getheap                         ; rcx = process heap
        invoke  HeapReAlloc, rcx, .HEAP_REALLOC_IN_PLACE_ONLY, [mem], [size]
   .return:
        ret
endp ; hrealloc

; ------------------------------------------------------------------------------

; free memory
proc hfree, mem

        mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        test    rcx, rcx                        ; x64: rcx=[mem]
;       cmp     [mem], 0
        jz     .return

        stdcall getheap                         ; rcx = process heap
        invoke  HeapFree, rcx, 0, [mem]
   .return:
        ret
endp ; hfree

; ------------------------------------------------------------------------------

; allocate memory for code
; <- rax - memory
proc calloc, size

        mov     [size], rcx
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
; <- rax - memory
proc crealloc, mem, size

        mov     [mem], rcx
        mov     [size], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  rsi, rdi                        ; push & 16-byte stack align for x64

        test    rcx, rcx                        ; x64: rcx=[mem]
;       cmp     [mem], 0
        jnz    .alloc

        xor     rax, rax
        jmp    .return
   .alloc:
        ; LPVOID VirtualAlloc ( LPVOID, SIZE_T, DWORD, DWORD )
        invoke  VirtualAlloc, [mem], [size], MEM_COMMIT, PAGE_EXECUTE_READ
;       invoke  VirtualAlloc, [mem], [size], MEM_COMMIT, PAGE_EXECUTE_READWRITE
    macro comment
    {
        invoke  VirtualAlloc, 0, [size], MEM_COMMIT, PAGE_EXECUTE_READ
;       invoke  VirtualAlloc, 0, [size], MEM_COMMIT, PAGE_EXECUTE_READWRITE
        push    rax
        mov     rdi, rax
        mov     rsi, [mem]
        mov     rcx, [size]
        call    momem
        stdcall cfree, [mem]
        pop     rax
    }
   .return:
        pop     rdi rsi
        ret
endp ; crealloc

; ------------------------------------------------------------------------------

; free memory
proc cfree, mem

        mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa                                  ; push & 16-byte stack align for x64

        test    rcx, rcx                        ; x64: rcx=[mem]
;       cmp     [mem], 0
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

        test    rdi, rdi
        jz     .return

        shr     rcx, 1
        jnc     @F
        stosb
    @@: shr     rcx, 1
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

proc f2f.int, f; f.HI

       .mem64   EQU rsp - 8

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..int.st0
        fstp    qword [.mem64]
        mov     rax, qword [.mem64]
;       mov     edx, dword [.mem64 + 4]
   .return:
        ret
endp ; f2f.int

; ------------------------------------------------------------------------------

; float to frac float
; x64 : <- rax
; x32 : <- eax:edx

proc f2f.frac, f; f.HI

       .mem64   EQU rsp - 8

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..frac.st0
        fstp    qword [.mem64]
        mov     rax, qword [.mem64]
;       mov     edx, dword [.mem64 + 4]
   .return:
        ret
endp ; f2f.frac

; ------------------------------------------------------------------------------

; float to round float
; x64 : <- rax
; x32 : <- eax:edx

proc f2f.round, f; f.HI

       .mem64   EQU rsp - 8

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..round.st0
        fstp    qword [.mem64]
        mov     rax, qword [.mem64]
;       mov     edx, dword [.mem64 + 4]
   .return:
        ret
endp ; f2f.round

; ------------------------------------------------------------------------------

; float to integer (round)
; <- rax

proc f2ir, f; f.HI

       .mem64   EQU rsp - 8

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        @@..round.st0
        fistp   qword [.mem64]
        mov     rax, [.mem64]
   .return:
        ret
endp ; f2ir

; ------------------------------------------------------------------------------

; float to integer (truncate)
; <- rax

proc f2i, f; f.HI

       .int64   EQU rsp - 8

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        fistp   qword [.int64]
        mov     rax, [.int64]
   .return:
        ret
endp ; f2i

; ------------------------------------------------------------------------------

; float to integer (truncate)
; <- rax
; <- rcx : not zero for integer f

proc f2ix, f; f.HI

       .int64   EQU rsp - 8

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        xor     rcx, rcx
        fld     qword [f]
        fld     st0
        fistp   qword [.int64]
        fild    qword [.int64]                  ; st0=int(double) | st1=double
        fcompp
        fnjne   @F
        inc     rcx
    @@:
        mov     rax, [.int64]
   .return:
        ret
endp ; f2ix

; ------------------------------------------------------------------------------

; float to int64 (truncate)
; <- rax:___

proc f2i64, f; f.HI

       .int64   EQU rsp - 8
       .int64LO EQU rsp - 8
       .int64HI EQU rsp - 4

        mov     [f], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        fld     qword [f]
        fistp   qword [.int64]
        mov     rax, [.int64]                   ; return int64
;       mov     edx, [.int64HI]
   .return:
        ret
endp ; f2i64

; ------------------------------------------------------------------------------

; get proc from map (2 items in line)
; <- rsi - proc offset
; <- rax - proc size
proc map_proc_x2, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 2 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     rdx, [proc]
        shl     rdx, 1                          ; rdx = [proc] * 2
        add     rdx, [mode]
        shl     rdx, 2
        add     rdx, [map]
   .offset:
        movzx   rsi, word [rdx + 0]
        test    rsi, rsi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   rax, word [rdx + 2]
   .return:
        ret
endp ; map_proc_x2

; ------------------------------------------------------------------------------

; get proc from map (2 items in line)
; <- rcx - proc offset
proc map_proc_x2_rcx, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 2 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    rbx
        mov     rbx, [proc]
        shl     rbx, 1                          ; rbx = [proc] * 2
        add     rbx, [mode]
        shl     rbx, 2
        add     rbx, [map]
   .offset:
        movzx   rcx, word [rbx + 0]
        test    rcx, rcx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     rbx
        ret
endp ; map_proc_x2_rcx

; ------------------------------------------------------------------------------

; get proc from map (2 items in line)
; <- rdx - proc offset
proc map_proc_x2_rdx, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 2 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    rbx
        mov     rbx, [proc]
        shl     rbx, 1                          ; rbx = [proc] * 2
        add     rbx, [mode]
        shl     rbx, 2
        add     rbx, [map]
   .offset:
        movzx   rdx, word [rbx + 0]
        test    rdx, rdx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rdx, r10
    $else
        add     edx, SIC_F_BASE
    $end
   .return:
        pop     rbx
        ret
endp ; map_proc_x2_rdx

; ------------------------------------------------------------------------------

; get proc from map (3 items in line)
; <- rsi - proc offset
; <- rax - proc size
proc map_proc_x3, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 3 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     rdx, [proc]
        shl     rdx, 1
        add     rdx, [proc]                     ; rdx = [proc] * 3
        add     rdx, [mode]
        shl     rdx, 2
        add     rdx, [map]
   .offset:
        movzx   rsi, word [rdx + 0]
        test    rsi, rsi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   rax, word [rdx + 2]
   .return:
        ret
endp ; map_proc_x3

; ------------------------------------------------------------------------------

; get proc from map (3 items in line)
; <- rcx - proc offset
proc map_proc_x3_rcx, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 3 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    rbx
        mov     rbx, [proc]
        shl     rbx, 1
        add     rbx, [proc]                     ; rbx = [proc] * 3
        add     rbx, [mode]
        shl     rbx, 2
        add     rbx, [map]
   .offset:
        movzx   rcx, word [rbx + 0]
        test    rcx, rcx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     rbx
        ret
endp ; map_proc_x3_rcx

; ------------------------------------------------------------------------------

; get proc from map (4 items in line)
; <- rsi - proc offset
; <- rax - proc size
proc map_proc_x4, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 4 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     rdx, [proc]
        shl     rdx, 2                          ; rdx = [proc] * 4
        add     rdx, [mode]
        shl     rdx, 2
        add     rdx, [map]
   .offset:
        movzx   rsi, word [rdx + 0]
        test    rsi, rsi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   rax, word [rdx + 2]
   .return:
        ret
endp ; map_proc_x4

; ------------------------------------------------------------------------------

; get proc from map (4 items in line)
; <- rcx - proc offset
proc map_proc_x4_rcx, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 4 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    rbx
        mov     rbx, [proc]
        shl     rbx, 2                          ; rbx = [proc] * 4
        add     rbx, [mode]
        shl     rbx, 2
        add     rbx, [map]
   .offset:
        movzx   rcx, word [rbx + 0]
        test    rcx, rcx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     rbx
        ret
endp ; map_proc_x4_rcx

; ------------------------------------------------------------------------------

; get proc from map (4 items in line)
; <- rdx - proc offset
proc map_proc_x4_rdx, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 4 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    rbx
        mov     rbx, [proc]
        shl     rbx, 2                          ; rbx = [proc] * 4
        add     rbx, [mode]
        shl     rbx, 2
        add     rbx, [map]
   .offset:
        movzx   rdx, word [rbx + 0]
        test    rdx, rdx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rdx, r10
    $else
        add     edx, SIC_F_BASE
    $end
   .return:
        pop     rbx
        ret
endp ; map_proc_x4_rdx

; ------------------------------------------------------------------------------

; get proc from map (8 items in line)
; <- rsi - proc offset
; <- rax - proc size
proc map_proc_x8, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 8 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        mov     rdx, [proc]
        shl     rdx, 3                          ; rdx = [proc] * 8
        add     rdx, [mode]
        shl     rdx, 2
        add     rdx, [map]
   .offset:
        movzx   rsi, word [rdx + 0]
        test    rsi, rsi
        jz     .size
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rsi, r10
    $else
        add     esi, SIC_F_BASE
    $end
   .size:
        movzx   rax, word [rdx + 2]
   .return:
        ret
endp ; map_proc_x8

; ------------------------------------------------------------------------------

; get proc from map (8 items in line)
; <- rcx - proc offset
proc map_proc_x8_rcx, map, proc, mode

        mov     [map], rcx
        mov     [proc], rdx
        mov     [mode], r8
;       mov     [], r9

        ; data offset = 4 * ([proc] * 8 + [mode])
        ; data : proc offset : 2 bytes
        ;        proc size   : 2 bytes
        ;                    : 4 bytes
        push    rbx
        mov     rbx, [proc]
        shl     rbx, 3                          ; rbx = [proc] * 8
        add     rbx, [mode]
        shl     rbx, 2
        add     rbx, [map]
   .offset:
        movzx   rcx, word [rbx + 0]
        test    rcx, rcx
        jz     .return
    $ifdef _X64
        mov     r10, SIC_F_BASE
        add     rcx, r10
    $else
        add     ecx, SIC_F_BASE
    $end
   .return:
        pop     rbx
        ret
endp ; map_proc_x8_rcx

; ------------------------------------------------------------------------------

; get 16-byte aligned system data offset
; -> sic : T_sic_data structure offset
; <- rax - system data offset
proc system_data_?ax, sic

;       mov     [sic], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

;       mov     rcx, [sic]
        mov     rax, [rcx + T_sic_data.data]    ; rax = ?unaligned data segment
        test    rax, 0xF
        jz     .return                          ; data is already aligned to 16 bytes

        xor     rcx, rcx
        sub     cl, al
        and     rcx, 0xF
        add     rax, rcx
   .return:                                     ; rax = system data offset (16-byte aligned)
        ret
endp ; system_data_?ax

; ------------------------------------------------------------------------------

; get 16-byte aligned mem
; <- rcx - 16-byte aligned mem
; <- rdx - mem shift
macro c
{
proc mem_a16_?cx_?dx, mem

;       mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

;       mov     rcx, [mem]
        xor     rdx, rdx
        test    rcx, 0xF
        jz     .return                          ; data is already aligned to 16 bytes

        sub     dl, cl
        and     rdx, 0xF
        add     rcx, rdx
   .return:
        ret
endp ; mem_a16_?cx_?dx
}

; ------------------------------------------------------------------------------

; get 16-byte aligned mem
; <- rax - 16-byte aligned mem
; <- rdx - mem shift
macro c
{
proc mem_a16_?ax_?dx, mem

;       mov     [mem], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

;       mov     rcx, [mem]
        mov     rax, rcx
        xor     rdx, rdx
        test    rax, 0xF
        jz     .return                          ; data is already aligned to 16 bytes

        sub     dl, al
        and     rdx, 0xF
        add     rax, rdx
   .return:
        ret
endp ; mem_a16_?ax_?dx
}

; ------------------------------------------------------------------------------

; verify object name
; -> name - object name offset
; <- rax  - name length or negative value on error
proc verify.name, name

;       mov     [name], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

;       mov     rcx, [name]
        or      rax, -1

   .scan:
        inc     rax
        mov     dl, byte [rcx + rax]
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
        test    rax, rax
        jnz    .scan.digit
        jmp    .error
   .scan.digit:
        mov     dl, dh
        sub     dl, '0' + 10
        add     dl, 10
        jc     .scan                            ; '0'..'9'
   .error:
        or      rax, -1
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
        sub     rax, 2
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
        sub     rax, 2
   .return:
        ret
endp ; CmpiString

; ------------------------------------------------------------------------------

; set library directory
proc DLLSetDirectory, SDLL

       .CBUFFER EQU 4096

    locals
       .PATH    dq ?
       .FILE    dq ?
    endl

        mov     [SDLL], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  rsi, rdi                        ; push & 16-byte stack align for x64

;       mov     rcx, [SDLL]
        test    rcx, rcx                        ; test DLL name
        jnz    .main
   .empty.name:
        invoke  SetDllDirectory, rcx
        jmp    .return

   .main:
        stdcall halloc, .CBUFFER
        mov     [.PATH], rax
        mov     rdi, rax
        lea     rsi, [.FILE]

        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, [SDLL], .CBUFFER, rdi, rsi

        mov     rsi, [.FILE]
        test    rsi, rsi
        jz     .free                            ; no filename found
        cmp     rsi, rdi
        jbe    .free                            ; invalid path and filename

   .invoke:
        mov     byte [rsi], 0
        invoke  SetDllDirectory, rdi
;       invoke  GetLastError

   .free:
        stdcall hfree, [.PATH]

   .return:
        pop     rdi rsi
        ret
endp ; DLLSetDirectory

; ------------------------------------------------------------------------------

; load library
proc DLLLoad, SDLL

       .CBUFFER EQU 4096

    locals
       .CDIR    dq ?
       .PATH    dq ?
       .FILE    dq ?
    endl

        mov     [SDLL], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        pushsa  rsi, rdi                        ; push & 16-byte stack align for x64

        stdcall halloc, .CBUFFER
        mov     [.CDIR], rax
        stdcall halloc, .CBUFFER
        mov     [.PATH], rax
        mov     rdi, rax
        lea     rsi, [.FILE]
        mov     [.FILE], 0

        ; DWORD GetFullPathName ( LPCTSTR, DWORD, LPTSTR, LPTSTR )
        invoke  GetFullPathName, [SDLL], .CBUFFER, rdi, rsi

        mov     rsi, [.FILE]
        test    rsi, rsi
        jz     .free                            ; no filename found
        cmp     rsi, rdi
        ja     .cdir                            ; valid path and filename

   .ndir:
        invoke  LoadLibrary, [SDLL]
;       invoke  LoadLibraryEx, [SDLL], 0, 0
        mov     rsi, rax
        jmp    .free

   .cdir:
        mov     byte [rsi], 0
        invoke  GetCurrentDirectory, .CBUFFER, [.CDIR]
        invoke  SetCurrentDirectory, [.PATH]
        invoke  LoadLibrary, [SDLL]
;       invoke  LoadLibraryEx, [SDLL], 0, 0
        mov     rsi, rax
        invoke  SetCurrentDirectory, [.CDIR]

   .free:
        stdcall hfree, [.PATH]
        stdcall hfree, [.CDIR]

   .return:
        mov     rax, rsi
        pop     rdi rsi
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
        pushsa  rsi, rdi                        ; push & 16-byte stack align for x64

    $ifdef _X64
        mov     rdi, rcx
    $else
        mov     edi, [sic]
    $end
        invoke  GetCurrentProcess
        mov     rsi, rax
        invoke  FlushInstructionCache, rsi, [rdi + T_sic_data.code], [rdi + T_sic_data.size]
        invoke  CloseHandle, rsi

   .return:
        pop     rdi rsi
        ret
endp ; FlushCodeCache

; ------------------------------------------------------------------------------
