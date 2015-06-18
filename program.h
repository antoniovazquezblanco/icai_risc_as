/* File: program.h
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This header file contains the functions declarations needed to manage the state of a program.
 * It keeps track of the instructions added to a program for later encoding.
 *
 */

#ifndef _H_PROGRAM
#define _H_PROGRAM

#include "instruction.h"
#include "output.h"

/* Add an instruction to the program.
 */
void program_add(instruction_t i);

/* Resolves all the symbols in the program to numerical values.
 * Returns 0 on error.
 */
unsigned char program_resolve();

/* Encodes all the instructions to binary code
 * Returns 0 on error.
 */
unsigned char program_encode(output_t* out);

/* Free all the allocated instructions
 */
void program_free();

#endif
