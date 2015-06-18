/* File: instruction.h
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This header file contains a representation of a program instruction. It also contains helper functions for unifying instruction encoding.
 *
 */

#ifndef _H_INSTRUCTION
#define _H_INSTRUCTION

#include <stdio.h>
#include "argument.h"
#include "output.h"

/* Instruction adress callback function type definition...
 */
typedef char (*addr_callback)(short arg0, unsigned short *addr);

/* Instruction codification callback function type definition...
 * Should return 0 on error.
 */
typedef char (*encod_callback)(output_t* out, unsigned short addr, unsigned char codop, arg_t arg0, arg_t arg1, arg_t arg2, arg_t arg3, addr_callback size_callback);

/* Struct that represents any valid instruction.
 * Includes fields for type of codification, opcode and arguments.
 */
typedef struct
{
	unsigned short addr;
	unsigned char codop;
	arg_t arg0;
	arg_t arg1;
	arg_t arg2;
	arg_t arg3;
	addr_callback size_callback;
	encod_callback codif_callback;
} instruction_t;

/* Prints an instruction to stdout.
 * For debugging purposes.
 */
void instruction_print(instruction_t i);

/* Resolves instruction symbols to values.
 * Returns 0 on error.
 */
unsigned char instruction_resolve(instruction_t *i);

/* Encode an instruction.
 * Returns 0 on error.
 */
unsigned char instruction_encode(instruction_t *i, output_t* out);

#endif
