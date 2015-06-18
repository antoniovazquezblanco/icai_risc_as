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
	struct symbol_s* next;
	char* name;
	short addr;
	/* Defined?, declared?, mem/rom? */
};

/* Symbol table.
 * I don't like global variables but I have no other option...
 */
struct symbol_s *table = NULL;

/* Function that adds a symbol to the table.
 */
void symbol_add(char* s, short addr)
{
	if(table == NULL)
	{
		// Table was empty. Add the first item...
		table = (struct symbol_s*)malloc(sizeof(struct symbol_s));
		table->name = strdup(s);
		table->addr = addr;
		table->next = NULL;
		return;
	}

	// Table is not empty...
	struct symbol_s *i;	// For iterating...
	for(i = table; i->next != NULL; i=i->next);	// Find the last existing symbol...
	i->next = (struct symbol_s*)malloc(sizeof(struct symbol_s));	// Allocate one more symbol...
	i = i->next;	// Move to the allocated symbol...
	i->name = strdup(s);	// Fill it with info...
	i->addr = addr;
	i->next = NULL;
	return; // Done...
}

/* Search for a symbol in the table.
 */
char symbol_get_address(char* s, short* addr)
{
	struct symbol_s *i;	// For iteration
	for(i = table; i != NULL; i=i->next)
		if(!strcmp(i->name, s))
		{
			*addr = i->addr;
			return 0;	// Match!
		}

	return -1;	// No match...
}

/* Clean up the table...
 */
void symbol_free()
{
	struct symbol_s *i = NULL;
	while(table != NULL)
	{
		i = table;	// Get the addr of this item
		table = table->next;	// Move to next item before erasing
		free(i->name);	// Free this label
		free(i);	// Free this element
	}
	return;
}
