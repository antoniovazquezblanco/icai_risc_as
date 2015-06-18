/* File: argument.h
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This header file contains a representation of an instruction argument.
 * Functions for argument manipulation are also provided.
 *
 */

#ifndef _H_ARGUMENT
#define _H_ARGUMENT

/* Struct that represents an instruction argument.
 * It can be a value or a symbol.
 */
typedef struct
{
	unsigned char resolved;
	short value;
	char *symbol;
} arg_t;

/* Prints the argument to stdout.
 * For debugging purposes.
 */
void argument_print(arg_t a);

/* Resolves a symbol to its value.
 * Returns 1 if resolved and 0 otherwise.
 */
unsigned char argument_resolve(arg_t *a);

#endif
