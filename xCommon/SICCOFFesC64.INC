
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; external symbols (x64)
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
extrns  GetCurrentDirectory, '__imp_GetCurrentDirectoryA',\
        SetCurrentDirectory, '__imp_SetCurrentDirectoryA',\
        GetModuleFileName, '__imp_GetModuleFileNameA',\
        GetFullPathName, '__imp_GetFullPathNameA',\
        GetPrivateProfileSectionNames, '__imp_GetPrivateProfileSectionNamesA',\
        GetPrivateProfileSection, '__imp_GetPrivateProfileSectionA',\
        SetDllDirectory, '__imp_SetDllDirectoryA',\
        LoadLibrary, '__imp_LoadLibraryA',\
        LoadLibraryEx, '__imp_LoadLibraryExA',\
        FreeLibrary, '__imp_FreeLibrary',\
        GetProcAddress, '__imp_GetProcAddress',\
        CreateFile, '__imp_CreateFileA',\
        GetFileSize, '__imp_GetFileSize',\
        CompareString, '__imp_CompareStringA',\
        lstrlen, '__imp_lstrlenA',\
        lstrcpy, '__imp_lstrcpyA',\
        lstrcpyn, '__imp_lstrcpynA',\
        VirtualAlloc, '__imp_VirtualAlloc',\
        VirtualFree, '__imp_VirtualFree',\
        VirtualProtect, '__imp_VirtualProtect',\
        GetProcessHeap, '__imp_GetProcessHeap',\
        HeapAlloc, '__imp_HeapAlloc',\
        HeapReAlloc, '__imp_HeapReAlloc',\
        HeapFree, '__imp_HeapFree',\
        GetCurrentProcess, '__imp_GetCurrentProcess',\
        FlushInstructionCache, '__imp_FlushInstructionCache',\
        CloseHandle, '__imp_CloseHandle',\
        GetLastError, '__imp_GetLastError'

; IMPORT MSVCRT.DLL
extrns  setlocale, '__imp_setlocale',\
        strtol, '__imp_strtol',\
        strtod, '__imp_strtod',\
        _strtoi64, '__imp__strtoi64',\
        _strtoui64, '__imp__strtoui64',\
        strlen, '__imp_strlen',\
        strcpy, '__imp_strcpy',\
        strncpy, '__imp_strncpy',\
        strcmp, '__imp_strcmp',\
        _stricmp, '__imp__stricmp',\
        strncmp, '__imp_strncmp',\
        _strnicmp, '__imp__strnicmp',\
        wctomb, '__imp_wctomb'

; ------------------------------------------------------------------------------
