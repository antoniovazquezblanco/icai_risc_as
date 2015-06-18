/* File: output.h
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the declaration of functions for data outputting.
 *
 */

#ifndef _H_OUTPUT
#define _H_OUTPUT

#include <stdio.h>

/* Enum for valid output formats.
 */
typedef enum
{
	O_VHDL,	// Output VHDL
	O_MIF,	// Output MIF
	O_BIN	// Output binary
}
output_format_t;

/* Enum for holding writer posible error status.
 */
typedef enum
{
	O_OK,		// No error
	O_FOPEN,	// Error opening file
	O_FORMAT	// Error with selecter output format
}
output_error_t;

/* Writer instance holder.
 */
typedef struct
{
	output_error_t error;	// Error status
	output_format_t format;	// Output format
	FILE *file;		// File descriptor
	char *entity;		// Entity name
}
output_t;

/* Parses a string and returns the posible format enum
 * or returns -1 in case the string is not recognized.
 */
output_format_t output_format_parse(char* string);

/* Checks if dump format is valid.
 * Returns 1 if valid and 0 otherwise.
 */
char output_format_validate(output_format_t f);

/* Create a instance of the writer.
 * Takes a filepath to write to and a format for dump.
 * Returns a valid writer instance.
 */
output_t* output_init(char* filepath, output_format_t f);

/* Dump a comment to the output file.
 * Takes as argument a C valid string.
 */
void output_write_comment(output_t* o, char* string);

/* Dumps file header.
 * It should be called before dumping any instruction.
 */
void output_write_header(output_t* o, short addrs);

/* Dump an instruction to file.
 * Takes an address and instruction coded in a 16bit unsigned integer.
 * Can also dump a comment in the same line throught the text param although it can be empty.
 */
void output_write_instruc(output_t* o, short address, short instruction, char* text);

/* Writes the foother of the file.
 * Dump instruction function cannot be called before this.
 */
void output_write_foother(output_t* o);

/* Clean instance memory allocations.
 */
void output_clean(output_t* o);

#endif
