// M13_externs.h
// @topic W140120 Lab M13 demo
// @brief extern function prototypes

#ifndef _M13_EXTERNS_H_INCLUDED_
#define _M13_EXTERNS_H_INCLUDED_

#include <iostream>

extern "C" int global_variable;
extern "C" int __stdcall SM_RUN( int* );     // Defined in M13_SM_RUN.ASM
extern "C" char* __stdcall NEWARRAY( size_t ); // Defined in M13_externs.cpp
extern "C" void __stdcall OUTPUTSZ( char* );   // Defined in M13_externs.cpp
extern "C" void __stdcall OUTPUTINT( int );   // Defined in M13_externs.cpp

#endif // _M13_EXTERNS_H_INCLUDED_
