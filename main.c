/* File: main.c
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains the entry point of the program.
 *
 */

#include "program.h"
#include "output.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* Prints the usage help for the user.
 */
void usage()
{
	printf("[?] Usage: icai_risc_as [<assmebler_file>] [-o <output_file>] [-f <format>] [-h]\n"
	       "\t<assembler_file>\t- File containig the assembler to compile. If not stdin will be used.\n"
	       "\t-o <output_file>\t- Filename for output.\n"
	       "\t-f <format>     \t- Output format (vhdl, mif, bin).\n"
	       "\t-h              \t- Show this help message.\n");

	return;
}

/* Start point for the ICAI-RiSC-16 compiler.
 * Responsible for parsing command line arguments and launching the parser.
 * Returns 0 on success and -1 otherwise.
 */
int main(int argc, char** argv)
{
	int opt;	// For argument parsing
	extern FILE* yyin;
	char* out_path = NULL;	// Output file path
	output_t* output = NULL;	// Code dumper...
	output_format_t output_format = -1;	// Format selection

	// Parse arguments...
	while((opt = getopt(argc, argv, "f:ho:")) != -1)
		switch(opt)
		{
		case 'f':	// Parse format...
			output_format = output_format_parse(optarg);
			if(!output_format_validate(output_format))
			{
				printf("[!] Invalid output format: %s...\n", optarg);
				usage();
				return 1;
			}
			break;
		case 'h':	// Show help...
			usage();
			return 0;
		case 'o':	// Set the output file...
			out_path = optarg;
			break;
		case '?':	// Unrecognized option...
			if(isprint(optopt))
				printf("[!] Unknown option `-%c'.\n", optopt);
			else
				printf("[!] Unknown option character `\\x%x'.\n", optopt);
			// No break here! Should show usage.
		default:
			usage();
			return -1;
		}

	// Did they specify an output format?
	if(!output_format_validate(output_format))
	{
		printf("[+] Using default vhdl format...\n");
		output_format = O_VHDL;
	}

	// Open output file...
	// Did they specify an output file?
	if(out_path == NULL)
	{
		char *ext[3] = {"vhd", "mif", "bin"};
		out_path = (char*)malloc(sizeof(char)*6);
		strcpy(out_path, "a.");
		strcat(out_path, ext[output_format]);
	}

	// Initialize the dumper
	output = output_init(out_path, output_format);
	if(output->error != O_OK)
	{
		output_clean(output);
		fprintf(stderr, "[!] Error: could not open %s for output...\n", out_path);
		return -2;
	}

	// The rest of arguments will be treated as input files...
	if(argc-optind > 0)
		// Parse assembler files...
		for(opt = optind; opt < argc; opt++)
		{
			// Open file...
			yyin = fopen(argv[opt], "r");
			if(yyin == NULL)
			{
				printf("[!] Error: Could not open %s for input...\n", argv[opt]);
				return -1;
			}
			else
				printf("[+] Opening file: %s\n", argv[opt]);

			// Process it...
			yyparse();

			// Clean up...
			fclose(yyin);
		}
	else
		// Or parse stdin if no file...
		yyparse();


	if(!program_resolve())
	{
		printf("[!] Error: Could not resolve symbol...\n");
		return -3;
	}

	if(!program_encode(output))
	{
		printf("[!] Error: Could not encode instruction...\n");
		return -4;
	}

	// Clean up...
	program_free();
	output_clean(output);

	return 0;
}
