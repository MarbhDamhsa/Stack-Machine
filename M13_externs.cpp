// M13_externs.cpp
// @topic W140130 Lab M13 demo
// @brief extern function implementations

#include "M13_externs.h"

// Declare a global variable with external C linkage:
extern "C" int global_variable = 123;

// Function dynamically allocates array of characters of the specified size
extern "C" char* __stdcall NEWARRAY( size_t size_ )
{
    return new char[ size_ ];
}

extern "C" void __stdcall OUTPUTSZ( char* str_ )
{
    std::cout << str_;
}

extern "C" void __stdcall OUTPUTINT( int int_ )
{
    std::cout << int_;
}
