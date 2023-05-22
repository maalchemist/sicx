unit msvcrt;

// msvcrt interface unit

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}

interface

{.$IFDEF SIC_STATIC}

type
  {$IFDEF CPUX64}
  size_t = Int64;
  {$ELSE}
  size_t = Integer;
  {$ENDIF}

  {$IFDEF VER_D4L}
  UInt64 = packed record
    LO : Cardinal;
    HI : Cardinal;
  end;
  {$ENDIF}

  PPAnsiChar = ^PAnsiChar;

{$EXTERNALSYM setlocale}
function setlocale (Category: Integer; const Locale: PAnsiChar): PAnsiChar; cdecl;

{$EXTERNALSYM strtol}
function strtol (value: PAnsiChar; endPtr: PPAnsiChar; base: Integer): Integer; cdecl;

{$EXTERNALSYM strtod}
function strtod (value: PAnsiChar; endPtr: PPAnsiChar): Double; cdecl;

{$EXTERNALSYM _strtoi64}
function _strtoi64 (value: PAnsiChar; endPtr: PPAnsiChar; base: Integer): Int64; cdecl;

{$EXTERNALSYM _strtoui64}
function _strtoui64 (value: PAnsiChar; endPtr: PPAnsiChar; base: Integer): UInt64; cdecl;

{$EXTERNALSYM strlen}
function strlen (str: PAnsiChar): size_t; cdecl;

{$EXTERNALSYM strcpy}
function strcpy (dest, src: PAnsiChar): PAnsiChar; cdecl;

{$EXTERNALSYM strncpy}
function strncpy (dest, src: PAnsiChar; count: size_t): PAnsiChar; cdecl;

{$EXTERNALSYM strcmp}
function strcmp (string1, string2: PAnsiChar): Integer; cdecl;

{$EXTERNALSYM _stricmp}
function _stricmp (string1, string2: PAnsiChar): Integer; cdecl;

{$EXTERNALSYM strncmp}
function strncmp (string1, string2: PAnsiChar; count: size_t): Integer; cdecl;

{$EXTERNALSYM _strnicmp}
function _strnicmp (string1, string2: PAnsiChar; count: size_t): Integer; cdecl;

{$EXTERNALSYM wctomb}
function wctomb (mb: PAnsiChar; const wc: WideChar): Integer; cdecl;

// stdlib.h
//
// int __cdecl _set_error_mode(_In_ int _Mode);
//
// Argument values for _set_error_mode().
// #define _OUT_TO_DEFAULT 0
// #define _OUT_TO_STDERR  1
// #define _OUT_TO_MSGBOX  2
// #define _REPORT_ERRMODE 3

{$EXTERNALSYM _set_error_mode}
function _set_error_mode (AMode: Integer): Integer; cdecl;

// assert.h
//
// void __cdecl _assert(_In_z_ const char * _Message, _In_z_ const char *_File, _In_ unsigned _Line);
// void __cdecl _wassert(_In_z_ const wchar_t * _Message, _In_z_ const wchar_t *_File, _In_ unsigned _Line);

{$EXTERNALSYM _assert}
procedure _assert (const AMessage: PAnsiChar; const AFile: PAnsiChar; ALine: Cardinal); cdecl;

{$EXTERNALSYM _wassert}
procedure _wassert (const AMessage: PWideChar; const AFile: PWideChar; ALine: Cardinal); cdecl;

{.$ENDIF}

implementation

{.$IFDEF SIC_STATIC}

const
  msvcrt_dll = 'msvcrt.dll';

function setlocale; external msvcrt_dll name 'setlocale';
function strtol; external msvcrt_dll name 'strtol';
function strtod; external msvcrt_dll name 'strtod';
function _strtoi64; external msvcrt_dll name '_strtoi64';
function _strtoui64; external msvcrt_dll name '_strtoui64';
function strlen; external msvcrt_dll name 'strlen';
function strcpy; external msvcrt_dll name 'strcpy';
function strncpy; external msvcrt_dll name 'strncpy';
function strcmp; external msvcrt_dll name 'strcmp';
function _stricmp; external msvcrt_dll name '_stricmp';
function strncmp; external msvcrt_dll name 'strncmp';
function _strnicmp; external msvcrt_dll name '_strnicmp';
function wctomb; external msvcrt_dll name 'wctomb';
procedure _assert; external msvcrt_dll name '_assert';
procedure _wassert; external msvcrt_dll name '_wassert';
function _set_error_mode; external msvcrt_dll name '_set_error_mode';

{.$ENDIF}

end.

