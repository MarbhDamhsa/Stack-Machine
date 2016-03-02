// The M13_main.cpp
// @topic W140110 Lab M13 demo
// @brief main driver program

//////////////////////////////////////////////////////////
//
// 1. Let's build a translator...
// "Translator" is a C++ program that takes a "program" text
// and converts it into a series of opcodes understood by the
// stack machine implemented in M13_SM_RUN.ASM.
//
//////////////////////////////////////////////////////////
//#define NDEBUG // uncomment to disable asserts
#include <cassert>   // required by assert() macro
#include <iostream>  // standard IO streams - std::cin, std::cout, std::cerr
#include <string>    // std::string object
#include <sstream>   // std::stringstream object (data type conversions)
#include <vector>    // a dynamic array
#include <cstdlib>   // for system("pause")

//////////////////////////////////////////////////////////
//
// 2. Let's add an ASM code to the project...
// Extern-declared functions and data become visible to the linker
// accross multiple .OBJ modules.
// Extern functions must be defined in a separately compiled
// translation unit, which is M13_externs.cpp in our project.
//////////////////////////////////////////////////////////
#include "M13_externs.h"

////////////////////////////////////////////////////
// Define opcodes supported by the stack machine:
////////////////////////////////////////////////////
const int COMMAND_NOP = 0;
const int COMMAND_PUSH_NUMBER = 1;
const int COMMAND_PUSH_REGISTER = 2; // ignore for now
const int COMMAND_ADD = 3;
const int COMMAND_SUB = 4;
const int COMMAND_HLT = 5;
const int COMMAND_POP = 6;
const int COMMAND_MUL = 7;

int main( int argc, char* argv[] )
{
    // temporary placeholder of a command, "push", "add", etc.:
    std::string command;

    // Dynamic array of integers that retains results of
    // first-pass through the translator - interpreting input
    // text of the stack machine "program".
    std::vector< int > dynamic_array;

    // For each "word" in input "program",
    while ( std::cin >> command ) {
        // command mnemonic is expected:
        std::cout << "\t cmd:" << command;
        assert( command.length() ); // make sure this is a real thing...

        dynamic_array.push_back( COMMAND_NOP );
        dynamic_array.push_back( COMMAND_NOP );

        if ( command == "push" ) {  //
            // A "push" command has an operand:
            std::string operand;
            std::cin >> operand;
            assert( operand.length() );
            // now decide whether it is a number or an alphabetical token
            if ( isdigit( operand[0]) ) {
                //std::cout << "\t number:" << atoi( operand.c_str() );
                std::stringstream buffer; // Create object as an internal memory buffer
                buffer << operand;        // Write text into the buffer
                int ioper;                // Create an integer representation of the operand
                buffer >> ioper;          // Read from the buffer into the integer
                std::cout << "\t number:" << ioper; // Display the result
                dynamic_array[ dynamic_array.size() - 2 ] = COMMAND_PUSH_NUMBER; // one prior to last
                dynamic_array[ dynamic_array.size() - 1 ] = ioper;               // the last element of vector
            } else {
                dynamic_array[ dynamic_array.size() - 2 ] = COMMAND_PUSH_REGISTER; // one prior to last
                std::cout << "\t alpha:" << operand;
            }
        }
        else if (command == "add") {
            // A "add" command has no operand:
            dynamic_array[dynamic_array.size() - 2] = COMMAND_ADD;
        }
        else if (command == "sub") {
            // A "sub" command has no operand:
            dynamic_array[ dynamic_array.size() - 2 ] = COMMAND_SUB;
        } else if ( command == "hlt" ) {
            // A "hlt" command has no operand:
            dynamic_array[ dynamic_array.size() - 2 ] = COMMAND_HLT;
        }
        else if (command == "pop") {
            // A "pop" command has no operand:
            dynamic_array[dynamic_array.size() - 2] = COMMAND_POP;
        }
        else if (command == "mul") {
            // A "mul" command has no operand:
            dynamic_array[dynamic_array.size() - 2] = COMMAND_MUL;
        }
        else if (command[0] == ';') {
            // If this is a comment, skip the rest of the line:
            std::getline( std::cin, command );
            std::cout << "\t comment:" << command << '\n';
            dynamic_array.pop_back(); // remove unneeded opcodes from dynamic array
            dynamic_array.pop_back();
            continue;
        } else {
            // Bad command mnemonic detected... abort...
            assert( !"*** Not a valid command!!" );
            // Add nice error processing later, for now just say goodbye:
            return 1;
        }

        std::cout << "\n";
    }// while command

    ///////////////////////////////////////////////////////////
    // Display what we have been able to translate so far:
    ///////////////////////////////////////////////////////////
    std::cout << "    dynamic_array contains:\t";
    unsigned int idx = 0;
    for ( ; idx < dynamic_array.size(); ++idx ) {
        std::cout << dynamic_array[ idx ] << ' ';
    }

    ///////////////////////////////////////////////////////////
    // The ASM stack machine is expecting a primitive array...
    // So allocate the array dynamically:
    ///////////////////////////////////////////////////////////
#define CPP_2011_STANDARD
#ifndef CPP_2011_STANDARD
    int* stack_machine_code = new int[ dynamic_array.size() ];
    assert( stack_machine_code != NULL ); // Did we get our memory allocation?

    ///////////////////////////////////////////////////////////
    // Copy opcodes from vector into array of integers:
    ///////////////////////////////////////////////////////////
    for ( idx = 0; idx < dynamic_array.size(); ++idx ) {
        stack_machine_code[ idx ] = dynamic_array[ idx ];
    }
#else
    int* stack_machine_code = dynamic_array.data();
#endif //CPP_2011_STANDARD
    std::cout << "\n";

    //////////////////////////////////////////////////////////////////////
    // Display the opcodes just before the execution by the stack machine:
    //////////////////////////////////////////////////////////////////////
    std::cout << "stack_machine_code contains:\t";
    for ( idx = 0; idx < dynamic_array.size(); ++idx ) {
        std::cout << dynamic_array[ idx ] << ' ';
    }
    std::cout << "\n";

    ///////////////////////////////////////////////////////////
    // Now call ASM stack machine and let it deal with the "prog"...
    ///////////////////////////////////////////////////////////
    int result = SM_RUN( stack_machine_code );
    //DEBUG//assert( result == 678 );
    assert( global_variable == 456 );//DEBUG

    // print the result
    std::cout << "The result is " << result << '\n';
    system("pause");
    return 0;
}
