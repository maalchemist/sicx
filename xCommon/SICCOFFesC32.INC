
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; external symbols (x32)
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

; IMPORT KERNEL32.DLL
extrns  GetCurrentDirectory, '__imp__GetCurrentDirectoryA@8',\
        SetCurrentDirectory, '__imp__SetCurrentDirectoryA@4',\
        GetModuleFileName, '__imp__GetModuleFileNameA@12',\
        GetFullPathName, '__imp__GetFullPathNameA@16',\
        GetPrivateProfileSectionNames, '__imp__GetPrivateProfileSectionNamesA@12',\
        GetPrivateProfileSection, '__imp__GetPrivateProfileSectionA@16',\
        SetDllDirectory, '__imp__SetDllDirectoryA@4',\
        LoadLibrary, '__imp__LoadLibraryA@4',\
        LoadLibraryEx, '__imp__LoadLibraryExA@12',\
        FreeLibrary, '__imp__FreeLibrary@4',\
        GetProcAddress, '__imp__GetProcAddress@8',\
        CreateFile, '__imp__CreateFileA@28',\
        GetFileSize, '__imp__GetFileSize@8',\
        CompareString, '__imp__CompareStringA@24',\
        lstrlen, '__imp__lstrlenA@4',\
        lstrcpy, '__imp__lstrcpyA@8',\
        lstrcpyn, '__imp__lstrcpynA@12',\
        VirtualAlloc, '__imp__VirtualAlloc@16',\
        VirtualFree, '__imp__VirtualFree@12',\
        VirtualProtect, '__imp__VirtualProtect@16',\
        GetProcessHeap, '__imp__GetProcessHeap@0',\
        HeapAlloc, '__imp__HeapAlloc@12',\
        HeapReAlloc, '__imp__HeapReAlloc@16',\
        HeapFree, '__imp__HeapFree@12',\
        GetCurrentProcess, '__imp__GetCurrentProcess@0',\
        FlushInstructionCache, '__imp__FlushInstructionCache@12',\
        CloseHandle, '__imp__CloseHandle@4',\
        GetLastError, '__imp__GetLastError@0'

; IMPORT MSVCRT.DLL
extrns  setlocale, '__imp__setlocale',\
        strtol, '__imp__strtol',\
        strtod, '__imp__strtod',\
        _strtoi64, '__imp___strtoi64',\
        _strtoui64, '__imp___strtoui64',\
        strlen, '__imp__strlen',\
        strcpy, '__imp__strcpy',\
        strncpy, '__imp__strncpy',\
        strcmp, '__imp__strcmp',\
        _stricmp, '__imp___stricmp',\
        strncmp, '__imp__strncmp',\
        _strnicmp, '__imp___strnicmp',\
        wctomb, '__imp__wctomb'

; ------------------------------------------------------------------------------
