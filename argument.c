/* File: argument.c
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the implementation of the functions described in argument.h.
 *
 */

#include "argument.h"
#include "symbol.h"
#include <stdio.h>

void argument_print(arg_t a)
{
	printf("[arg resolved(%x) val(%x) sym(%s)]\n", a.resolved, a.value, a.symbol);
}

unsigned char argument_resolve(arg_t *a)
{
	if(!a->resolved)
		a->resolved = !symbol_get_address(a->symbol, &(a->value));

	if(!a->resolved)
		printf("[!] Undefined symbol: %s\n", a->symbol);

	return a->resolved;
}
