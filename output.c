/* File: output.c
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the implementation of the functions defined in output.h.
 *
 */

#include "output.h"
#include <string.h>
#include <stdlib.h>
#include <libgen.h>

output_format_t output_format_parse(char* string)
{
	if(!strncmp(string, "vhdl", 4))
		return O_VHDL;
	else if(!strncmp(string, "mif", 3))
		return O_MIF;
	else if(!strncmp(string, "bin", 3))
		return O_BIN;
	else
		return -1;
}

char output_format_validate(output_format_t f)
{
	switch(f)
	{
	case O_VHDL:
	case O_MIF:
	case O_BIN:
		return 1;
	default:
		return 0;
	}
}

char *filename_no_ext(char* str)
{
	if (str == NULL)
		return NULL;

	// Get filename from path
	char *name = basename(str);

	// Remove extension
	char *retstr = strdup(name);
	char *lastdot = strrchr(retstr, '.');
	if (lastdot != NULL)
		*lastdot = '\0';

	// Done
	return retstr;
}


output_t* output_init(char* filepath, output_format_t f)
{
	output_t* p = (output_t*) malloc(sizeof(output_t));
	p->entity = filename_no_ext(filepath);
	p->error = O_OK;
	p->format = f;
	p->file = fopen(filepath, (f == O_BIN) ? "wb":"w");
	if(p->file == NULL)
		p->error = O_FOPEN;
	return p;
}

void output_write_comment(output_t* o, char* string)
{
	switch(o->format)
	{
	case O_VHDL:
	case O_MIF:	// Same format as VHDL...
		fprintf(o->file, "-- %s", string);
		if(string[strlen(string)-1] != '\n')
			fprintf(o->file, "\n");
		break;
	case O_BIN:
		// No support for comments...
		break;
	default:
		o->error = O_FORMAT;
		break;
	}
	return;
}

void output_write_header(output_t* o, short addrs)
{
	switch(o->format)
	{
	case O_VHDL:
		fprintf(o->file, "library ieee;\n"
				 "use ieee.std_logic_1164.all;\n"
				 "use ieee.numeric_std.all;\n\n"
				 "entity %s is\n"
				 "\tport(\n"
				 "\t\taddr\t: in std_logic_vector(15 downto 0);\n"
				 "\t\tdata\t: out std_logic_vector(15 downto 0)\n"
				 "\t);\n"
				 "end %s;\n\n"
				 "architecture behavioural of %s is\n"
				 "\ttype mem_t is array (0 to %d) of std_logic_vector(15 downto 0);\n"
				 "\tsignal memoria : mem_t:= (\n", o->entity, o->entity, o->entity, addrs);
		break;
	case O_MIF:
		fprintf(o->file, "WIDTH = 16;\n"
				 "DEPTH = %d;\n"
				 "ADDRESS_RADIX = HEX;\n"
				 "DATA_RADIX = HEX;\n\n"
				 "CONTENT BEGIN\n", addrs);
		break;
	case O_BIN:
		// No header...
		break;
	default:
		o->error = O_FORMAT;
		break;
	}
	return;
}

void output_write_instruc(output_t* o, short address, short instruction, char* text)
{
	switch(o->format)
	{
	case O_VHDL:
		fprintf(o->file, "\t\t16#%04hx# => X\"%04hx\", -- %s", address, instruction, text);
		if(text[strlen(text)-1] != '\n')
			fprintf(o->file, "\n");
		break;
	case O_MIF:
		fprintf(o->file, "%04hx\t:\t%04hx; -- %s\n", address, instruction, text);
		if(text[strlen(text)-1] != '\n')
			fprintf(o->file, "\n");
		break;
	case O_BIN:
	{
		int i;
		unsigned short padding = 0;
		for(i= ftell(o->file)/2; i < address-1; i++)
			fwrite(&padding, sizeof(unsigned short), 1, o->file);
		fwrite(&instruction, sizeof(short), 1, o->file);
		break;
	}
	default:
		o->error = O_FORMAT;
		break;
	}
	return;
}

void output_write_foother(output_t* o)
{
	switch(o->format)
	{
	case O_VHDL:
		fprintf(o->file, "\t\tothers => X\"0000\"\n"
				 "\t);\n"
				 "begin\n"
				 "\tmem_rom: process(addr, memoria)\n"
				 "\tbegin\n"
				 "\t\tdata <= memoria(to_integer(unsigned(addr)));\n"
				 "\tend process mem_rom;\n"
				 "end architecture behavioural;\n");
		break;
	case O_MIF:
		fprintf(o->file, "END;\n");
		break;
	case O_BIN:
		// No file ending...
		break;
	default:
		o->error = O_FORMAT;
		break;
	}
	return;
}

void output_clean(output_t* o)
{
	fclose(o->file);
	free(o);
	return;
}

