// TESTx.h

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

#pragma once

#include "math.h"
#include "SICx.h"

TSIC_Data sic;
TSIC_Config cfg;

double a = 2;
double b = 8;
double c = 16;
double x = 1.1;
double y = 2.2;
double z = 3.3;

double  PPP = 888;
INT_PTR III = 111;

char *expr1 = "1+2";
char r1[32];

char *expr2 = "a*x";
char r2[32];

char *expr3 = "b/y";
char r3[32];

char *expr4 = "(sin(5))^2+(cos(5))^2";
char r4[32];

char *expr5 = "UF_1P(1+a)";
char r5[32];

char *expr6 = "PTEST(PPP)";
char r6[32];

char *expr7 = "ITEST(111:int)+ITEST(III)";
char r7[32];

char *expr8 = "a=1.23; x=sin(a); y=cos(a); z=x^2+y^2";
char r8[32];

char *expr9 = "vavg(1,2,3,4,5,6,7,8,9,10)";
char r9[32];

char *exprA = "strcmp(\"asd\", \"asz\")";
char rA[32];

char *exprB = "VTEST(1,2,3,4,5,6)";
char rB[32];

char *exprC = "string ss=\"\\u0031\\x32\\063\"; strtod (ss, null); ";
char rC[32];

// user defined function
double __cdecl UF_1P (double x)
{
    double r = 2*x;
    return r;
}

// user defined function
double __cdecl PTEST (double* x)
{
    double r = *x;
    return r;
}

// user defined function
double __cdecl ITEST (INT_PTR x)
{
    double v = (double)x;
    double r = 4*v;
    return r;
}

// user defined function - variable argument count
#ifdef _WIN64
double __cdecl VTEST (double x, double x2, double x3, double x4, ...)
#else
double __cdecl VTEST (double x, ...)
#endif
{
    // get argument count (x32:ecx, x64:r13)
    int c = sic_va_count();
    if (c <= 0) return 0;

    int i = 0;
    double vs = 0;
    double v = x;
    va_list va;

    va_start (va, x);
    for (int i = 0; i < c; i++) {
        vs = vs + v;
        if (i == c) break;
        v = va_arg (va, double);
    }
    va_end (va);

    return vs;
}

//
void SIC_Create (VOID)
{
	sic_cpu_support ();

	// setup compiler
    cfg.cflags = 0;
    cfg.memory = 0;
    sic_setup (&cfg);

    // create global tables
    sic_cretab ();

    // initialize T_sic_data structures
    sic_init (&sic);

    // add user defined global functions
    sic_afun (NULL, "UF_1P", &UF_1P, 1, 0);

    // rename or duplicate global functions
    sic_refun (NULL, "power2", "pow2", FALSE); // duplicate
    sic_refun (NULL, "power4", "pow4", TRUE);  // rename
    sic_refun (NULL, "dou", "double", FALSE);  // duplicate

    // invalidate "meander" global function
    sic_invaf (NULL, "meander");

    // add user defined global variables
    sic_avarf (NULL, "b", &b);
    sic_avarf (NULL, "x", &x);
    sic_avarf (NULL, "a", &a);
    sic_avarf (NULL, "z", &z);
    sic_avarf (NULL, "c", &c);
    sic_avarf (NULL, "y", &y);

    // add user defined global constants
    sic_aconf (NULL, ".aaa", 555);
    sic_aconf (NULL, ".bbb", 0.1);

    // rename or duplicate global constants
    sic_recon (NULL, "pi", ".pi", FALSE);   // duplicate
    sic_recon (NULL, "2pi", ".2pi", TRUE);  // rename (error)
    sic_recon (NULL, "pipi", ".2pi", TRUE); // rename

    // add user defined local functions
    #ifdef _WIN64
    sic_afun (&sic, "PTEST", &PTEST, 1, 1/*0001b*/);
    sic_afun (&sic, "ITEST", &ITEST, 1, 1/*0001b*/);
    sic_afun (&sic, "VTEST", &VTEST, -1, 0);
    #else
    sic_afun (&sic, "PTEST", &PTEST, 1, 1);
    sic_afun (&sic, "ITEST", &ITEST, 1, 1);
    sic_afun (&sic, "VTEST", &VTEST, -1, 0);
    #endif

    // add user defined local variables
    sic_avarf (&sic, "__b", &b);
    sic_avarf (&sic, "__x", &x);
    sic_avarf (&sic, "__a", &a);
    sic_avarf (&sic, "__z", &z);
    sic_avarf (&sic, "__c", &c);
    sic_avarf (&sic, "__y", &y);
    sic_avari (&sic, "III", &III);

    // add user defined local constants
    sic_aconf (&sic, "_AAA", 0.1);
    sic_aconf (&sic, "_BBB", 1.2);
    sic_aconf (&sic, "_CCC", 2.3);
    sic_aconp (&sic, "PPP", &PPP);

    // pack global tables
    sic_patab (NULL);
    // pack local tables
    sic_patab (&sic);
}

//
void SIC_Free (VOID)
{
    sic_done (&sic);
    sic_fretab ();
}

// sic_compile test
void ctest_(LPCSTR e, LPSTR r)
{
    double v;
    DWORD err;

    #ifdef _WIN64
    DWORD sop = SIC_OPT_DEFAULT_X64;
    #else
    DWORD sop = SIC_OPT_DEFAULT_X32;
    #endif

    sic_compile (&sic, e, sop);
    v = sic_exec (&sic, &err);
    sprintf_s (r, 32, "=%g", v); 
}

// sic_build test
void btest_(LPCSTR e, LPSTR r)
{
    double v;
    DWORD err;

    #ifdef _WIN64
    DWORD sop = SIC_OPT_DEFAULT_X64;
    #else
    DWORD sop = SIC_OPT_DEFAULT_X32;
    #endif

    sic_build (&sic, e, sop);
    v = sic_exec (&sic, &err);
    sprintf_s (r, 32, "=%g", v); 
}

//
void SIC_Test (VOID)
{
    ctest_(expr1, r1);
    ctest_(expr2, r2);
    ctest_(expr3, r3);
    ctest_(expr4, r4);
    ctest_(expr5, r5);
    ctest_(expr6, r6);
    ctest_(expr7, r7);
    btest_(expr8, r8);
    ctest_(expr9, r9);
    ctest_(exprA, rA);
    ctest_(exprB, rB);
    btest_(exprC, rC);
}

void print_(LPCSTR e, LPCSTR r, HDC hdc, int* cy)
{
    int c = *cy;

    SetTextColor (hdc, 0xFF0000);
    TextOutA (hdc, 8, c, e, lstrlenA(e));
    SetTextColor (hdc, 0x000000);
    TextOutA (hdc, 8, c+16, r, lstrlenA(r));
    c=c+50;
    *cy=c;
}

//
void SIC_Print (HDC hdc)
{
    int cy = 0;
    HFONT nFont, oFont;

    nFont = CreateFontA (-11, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, 
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, FIXED_PITCH | FF_DONTCARE, 
        "Courier New");

    oFont = (HFONT)SelectObject (hdc, nFont);
    
    print_(expr1, r1, hdc, &cy);
    print_(expr2, r2, hdc, &cy);
    print_(expr3, r3, hdc, &cy);
    print_(expr4, r4, hdc, &cy);
    print_(expr5, r5, hdc, &cy);
    print_(expr6, r6, hdc, &cy);
    print_(expr7, r7, hdc, &cy);
    print_(expr8, r8, hdc, &cy);
    print_(expr9, r9, hdc, &cy);
    print_(exprA, rA, hdc, &cy);
    print_(exprB, rB, hdc, &cy);
    print_(exprC, rC, hdc, &cy);

    SelectObject (hdc, oFont);
    DeleteObject (nFont);
}

