/* File: instruction.c
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the implementation of functions described in instruction.h.
 *
 */

#include "instruction.h"
#include <stdio.h>

void instruction_print(instruction_t i)
{
	printf("(instr op(%x)\n", i.codop);
	argument_print(i.arg0);
	argument_print(i.arg1);
	argument_print(i.arg2);
	argument_print(i.arg3);
	printf(")\n");
}

unsigned char instruction_resolve(instruction_t *i)
{
	unsigned char r = 1;
	r &= argument_resolve(&(i->arg0));
	r &= argument_resolve(&(i->arg1));
	r &= argument_resolve(&(i->arg2));
	r &= argument_resolve(&(i->arg3));
	return r;
}

unsigned char instruction_encode(instruction_t *i, output_t* out)
{
	return i->codif_callback(out, i->addr, i->codop, i->arg0, i->arg1, i->arg2, i->arg3, i->size_callback);
}
