/* File: program.c
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the implementation of the functions described in program.h.
 *
 */

#include "program.h"
#include "symbol.h"
#include <stdlib.h>
#include <stdio.h>

/* Struct to hold a vector of instuctions.
 */
struct program_s
{
	struct program_s *next;
	instruction_t instruction;
};

/* Highest addr found.
 */
unsigned short addr_max;

/* I don't like globals but I have no other option...
 * This is a table that keeps track of the added instructions...
 */
struct program_s *table_prog = NULL;

void program_add(instruction_t i)
{
	if(table_prog == NULL)
	{
		table_prog = (struct program_s*)malloc(sizeof(struct program_s));
		table_prog->instruction = i;
		table_prog->next = NULL;
		addr_max = i.addr;
		return;
	}

	// Table is not empty...
	struct program_s *p;	// For iterating...
	for(p = table_prog; p->next != NULL; p=p->next);	// Find the last existing entry...
	p->next = (struct program_s*)malloc(sizeof(struct program_s));	// Allocate one more...
	p = p->next;	// Move to the allocated entry...
	p->instruction = i;	// Fill it with info...
	p->next = NULL;

	// Check for max addr...
	unsigned short this_addr = i.addr;
	i.size_callback(i.arg0.value, &this_addr);
	addr_max = (addr_max > this_addr) ? addr_max : this_addr;

	return;	// Done...
}

unsigned char program_resolve()
{
	unsigned char r = 1;
	struct program_s *p;
	for(p = table_prog; p != NULL; p=p->next)
		r &= instruction_resolve(&(p->instruction));
	return r;
}

unsigned char program_encode(output_t* out)
{
	// Write header...
	output_write_header(out, addr_max);

	// Encode and dump instructions...
	unsigned char r = 1;
	struct program_s *p;
	for(p = table_prog; p != NULL; p=p->next)
		r &= instruction_encode(&(p->instruction), out);

	// Write the foother...
	output_write_foother(out);
	return r;
}

void program_free()
{
	// Clean program symbols...
	symbol_free();

	// Clean allocated table...
	struct program_s *i = NULL;
	while(table_prog != NULL)
	{
		i = table_prog;	// Get the addr of this item
		table_prog = table_prog->next;	// Move to next item before erasing
		free(i);	// Free this element
	}
	return;
}
