/* File: flex.l
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains information about the instructions supported by the ICAI-RiSC-16 and information on how to compile them.
 * If a user wants to add a new instruction, it must create a size calculation callback for the instruction or choose one of the existents,
 * create a codification callback and finally add the instruction with the INSTRUCTION macro to the lexer rules section.
 *
 */

%{
#include "instruction.h"
#include "bison.tab.h"
#include <stdarg.h>
#include <stdio.h>

void yyerror(char *s, ...);

// Macro definition for LEX instruction entry...
#define INSTRUCTION(codop_t, arg0_t, arg1_t, arg2_t, arg3_t, size_callback_t, codif_callback_t, type_t)\
	yylval.instruction.addr = 0;\
	yylval.instruction.codop = codop_t;\
	yylval.instruction.arg0.resolved = 1;\
	yylval.instruction.arg0.value = arg0_t;\
	yylval.instruction.arg1.resolved = 1;\
	yylval.instruction.arg1.value = arg1_t;\
	yylval.instruction.arg2.resolved = 1;\
	yylval.instruction.arg2.value = arg2_t;\
	yylval.instruction.arg3.resolved = 1;\
	yylval.instruction.arg3.value = arg3_t;\
	yylval.instruction.size_callback = size_callback_t;\
	yylval.instruction.codif_callback = codif_callback_t;\
	return type_t;

// Macro for immediate value validation
#define IMMEDIATE_INVALID(imm) (imm < -64 || imm > 63)

// Callback for the org instruction size calculation...
char callback_size_org(short arg0, unsigned short *addr)
{
	if(arg0 < *addr)
		yyerror(".org argument is trying to move program pointer backwards in line %d...\n", yylineno);
	(*addr) = arg0;
	return 0;
}

// Callback for the space instruction size calculation...
char callback_size_space(short arg0, unsigned short *addr)
{
	if(arg0 < 1)
		yyerror(".space argument is trying to move program pointer backwards in line %d...\n", yylineno);
	(*addr) += arg0;
	return 0;
}

// Callback for a normal instruction size calculation...
char callback_size_normal(short arg0, unsigned short *addr)
{
	(*addr) += 1;
	return 0;
}

// Callback for the movi instruction size calculation...
char callback_size_movi(short arg0, unsigned short *addr)
{
	(*addr) += 2;
	return 0;
}

// Callback for the org and space instructions codification...
char callback_codif_pseudo(output_t* out, unsigned short addr, unsigned char codop, arg_t arg0, arg_t arg1, arg_t arg2, arg_t arg3, addr_callback size_callback)
{
	unsigned short content = 0;
	unsigned short i;
	short size = addr;
	size_callback(arg0.value, &size);
	for(i = addr; i < size; i++)
		output_write_instruc(out, i, content, ".org or .space op...");
	return 1;
}

// Callback for normal instructions codification...
char callback_codif_normal(output_t* out, unsigned short addr, unsigned char codop, arg_t arg0, arg_t arg1, arg_t arg2, arg_t arg3, addr_callback size_callback)
{
	short codification;
	switch(codop)
	{
	case 0:		// Arithmetic operations...
		if(arg3.value == 3 || arg3.value == 4 || arg3.value == 5)
			//Shift operations have a special encoding...
			codification = (codop << 13) | ((arg0.value & 0x7) << 10) | (0 << 7) | ((arg1.value & 0x7) << 4) | (arg3.value & 0xF);
		else
			codification = (codop << 13) | ((arg0.value & 0x7) << 10) | ((arg1.value & 0x7) << 7) | ((arg2.value & 0x7) << 4) | (arg3.value & 0xF);
		break;
	case 1:		// addi
		codification = (codop << 13) | ((arg0.value & 0x7) << 10) | ((arg2.value & 0x7) << 7) | (arg1.value & 0x7f);
		break;
	case 4:		// sw
	case 5:		// lw
		if(IMMEDIATE_INVALID(arg1.value))
		{
			fprintf(stderr, "[!] Error: Immediate out of range (%d) in lw or sw instruction...\n", arg1.value);
			return 0;
		}
		codification = (codop << 13) | ((arg0.value & 0x7) << 10) | ((arg2.value & 0x7) << 7) | (arg1.value & 0x7f) ;
		break;
	case 6:		// beq
	{
		// Calculate jump...
		short jump = 0;
		if(arg2.symbol == NULL)
			// If given as a numerical value use it...
			jump = arg2.value;
		else
			// If it is a symbol calculate the distance...
			jump = arg2.value - addr - 1;
		// Check limits...
		if(IMMEDIATE_INVALID(jump))
		{
			fprintf(stderr, "[!] Error: beq cannot jump so far...\n");
			return 0;
		}
		// Encode...
		codification = (codop << 13) | ((arg0.value & 0x7) << 10) | ((arg1.value & 0x7) << 7) | (jump & 0x7f) ;
		break;
	}
	case 7:		// jalr
		codification = (codop << 13) | ((arg0.value & 0x7) << 10) | ((arg1.value & 0x7) << 7);
		break;
	default:
		fprintf(stderr, "[!] Error: Unrecognized instruction opcode (%d)...\n", codop);
		return 0;
		break;
	}
	output_write_instruc(out, addr, codification, "normal op...");
	return 1;
}

// Callback for movi instruction codification...
char callback_codif_movi(output_t* out, unsigned short addr, unsigned char codop, arg_t arg0, arg_t arg1, arg_t arg2, arg_t arg3, addr_callback size_callback)
{
	// lui instruction...
	short codification = (3 << 13)| ((arg1.value & 0x7) << 10) | ((arg0.value >> 6) & 0x3ff);
	output_write_instruc(out, addr, codification, "movi (1)");
	// addi instruction...
	codification = (1 << 13) | ((arg1.value & 0x7) << 10) | ((arg1.value & 0x7) << 7) | (arg0.value & 0x3f);
	output_write_instruc(out, addr+1, codification, "movi (2)");
	return 1;
}

// Callback for tas instruction...
char callback_codif_tas(output_t* out, unsigned short addr, unsigned char codop, arg_t arg0, arg_t arg1, arg_t arg2, arg_t arg3, addr_callback size_callback)
{
	// Calculate jump...
	short jump = 0;
	if(arg2.symbol == NULL)
		// If given as a numerical value use it...
		jump = arg2.value;
	else
		// If it is a symbol calculate the distance...
		jump = arg2.value - addr - 1;
	// Check limits...
	if(IMMEDIATE_INVALID(jump))
	{
		fprintf(stderr, "[!] Error: beq cannot jump so far...\n");
		return 0;
	}
	// Encode...
	short codification = (codop << 13) | ((arg0.value & 0x7) << 10) | ((arg1.value & 0x7) << 7) | (jump & 0x7f);
	output_write_instruc(out, addr, codification, "tas");
	return 1;
}

%}

%option yylineno
%option noyywrap
%%
 /* II (INSTRUCTION IMMEDIATE) */
".org"		{ INSTRUCTION(0, 0, 0, 0, 0, &callback_size_org, &callback_codif_pseudo, II) }
".space"	{ INSTRUCTION(0, 0, 0, 0, 0, &callback_size_space, &callback_codif_pseudo, II) }

 /* IRR (INSTRUCTION REGISTER REGISTER) */
"sll"		{ INSTRUCTION(0, 0, 0, 0, 3, &callback_size_normal, &callback_codif_normal, IRR) }
"sra"		{ INSTRUCTION(0, 0, 0, 0, 4, &callback_size_normal, &callback_codif_normal, IRR) }
"srl"		{ INSTRUCTION(0, 0, 0, 0, 5, &callback_size_normal, &callback_codif_normal, IRR) }
"jalr"		{ INSTRUCTION(7, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IRR) }

 /* IIR (INSTRUCTION IMMEDIATE REGISTER) */
"lui"		{ INSTRUCTION(3, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IIR) }
"movi"		{ INSTRUCTION(0, 0, 0, 0, 0, &callback_size_movi, &callback_codif_movi, IIR) }

 /* IRRR (INSTRUCTION REGISTER REGISTER REGISTER) */
"nand"		{ INSTRUCTION(0, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IRRR) }
"add"		{ INSTRUCTION(0, 0, 0, 0, 1, &callback_size_normal, &callback_codif_normal, IRRR) }
"sub"		{ INSTRUCTION(0, 0, 0, 0, 2, &callback_size_normal, &callback_codif_normal, IRRR) }
"sltu"		{ INSTRUCTION(0, 0, 0, 0, 6, &callback_size_normal, &callback_codif_normal, IRRR) }

 /* IRIR (INSTRUCTION REGISTER IMMEDIATE REGISTER) */
"addi"		{ INSTRUCTION(1, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IRIR) }
"lw"		{ INSTRUCTION(5, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IRIR) }
"sw"		{ INSTRUCTION(4, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IRIR) }

 /* IRRI (INSTRUCTION REGISTER REGISTER IMMEDIATE) */
"beq"		{ INSTRUCTION(6, 0, 0, 0, 0, &callback_size_normal, &callback_codif_normal, IRRI) }
"tas"		{ INSTRUCTION(2, 0, 0, 0, 0, &callback_size_normal, &callback_codif_tas, IRRI) }

 /* Ignore spaces, tabs and carriage returns */
[ \t\r]		;

 /* Labels */
[a-zA-Z][a-zA-Z0-9_]*\:	{ yylval.string = strdup(yytext); yylval.string[strlen(yylval.string)-1]=0; return LABEL; }

 /* Registers */
\%r[0-7]	{ yylval.integer = atoi(yytext+2); return REGISTER; }

 /* Immediate */
\$[-0-9]+	{ yylval.integer = atoi(yytext+1); return IMMEDIATEV; }
\$0x[-a-fA-F0-9]+	{ yylval.integer = strtol(yytext+3, 0, 16); return IMMEDIATEV; }
\$[a-zA-Z0-9_]+		{ yylval.string = strdup(yytext+1); return IMMEDIATES; }
\$\'.\'		{ yylval.integer = yytext[2]; return IMMEDIATEV; }

 /* Comment */
\#.*		;

 /* Argument separator and line end */
[\,\n]		{ return *yytext; }

.		{ yyerror("Unrecognized character in line %d: %c\n", yylineno, *yytext); }
%%

void yyerror(char *s, ...)
{
	va_list ap;
	va_start(ap, s);
	fprintf(stderr, "[!] Error: line %d: ", yylineno);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}
