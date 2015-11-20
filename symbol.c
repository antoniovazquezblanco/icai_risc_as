/* File: symbol.c
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the implementation of the functions described in symbol.h.
 *
 */

#include "symbol.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Struct representing a symbol.
 * Contains a pointer to the symbol name, the address in memory and a pointer to the next struct.
 * The pointer should be null if there are no more symbols in the list.
 */
struct symbol_s
{
	struct symbol_s* prev;
	char* name;
	uint16_t addr;
};

/* Symbol table.
 */
struct symbol_s *table = NULL;

/* Function that adds a symbol to the table.
 */
uint8_t symbol_add(char* s, uint16_t addr)
{
	// Alloc a new symbol...
	struct symbol_s *new = (struct symbol_s*)malloc(sizeof(struct symbol_s));
	if(new == NULL)
		// Could not alloc the struct. Return memory error...
		return 1;

	// Fill data...
	new->name = strdup(s);
	new->addr = addr;
	new->prev = table;

	// Point to the new data...
	table = new;

	// Done!
	return 0;
}

/* Search for a symbol in the table.
 */
uint8_t symbol_get_address(char* s, uint16_t* addr)
{
	struct symbol_s *i;	// For iteration
	for(i = table; i != NULL; i=i->prev)
		if(!strcmp(i->name, s))
		{
			*addr = i->addr;
			return 0;	// Match!
		}

	return 1;	// No match...
}

/* Clean up the table...
 */
void symbol_free()
{
	struct symbol_s *i = NULL;
	while(table != NULL)
	{
		i = table;				// Get the addr of this item
		table = table->prev;	// Move to next item before erasing
		free(i->name);			// Free this label
		free(i);				// Free this element
	}
	return;
}
