/* File: bison.y
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This file contains information about the syntax of the instructions supported by the ICAI-RiSC-16.
 *
 */

%{
#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "instruction.h"
#include "program.h"

extern int yylineno;
unsigned short addr = 0;
%}

/* Union */
%union {
	char *string;
	int integer;
	instruction_t instruction;
	arg_t arg;
}

/* Tokens */
%token <instruction> II IRR IIR IRRR IRIR IRRI
%token <string> LABEL
%token <integer> REGISTER
%token <integer> IMMEDIATEV
%token <string> IMMEDIATES

/* Types */
%type <instruction> instr
%type <arg> imm

%%

program:
	program line '\n'
	| program '\n'		/* Empty line or comment... */
	|
	;

line:	statement
	| label
	| label statement
	;

label:
	LABEL	{ symbol_add($1, addr); free($1); }
	;

statement:
	instr	{ $1.addr = addr; program_add($1); $1.size_callback($1.arg0.value, &addr); }
	;

instr:
	II imm			{ $1.arg0 = $2; $<instruction>$ = $1; }
	| IIR imm ',' reg	{ $1.arg0 = $2; $1.arg1 = $<arg>4; $<instruction>$ = $1; }
	| IRR reg ',' reg	{ $1.arg0 = $<arg>2; $1.arg1 = $<arg>4; $<instruction>$ = $1; }
	| IRRR reg ',' reg ',' reg	{ $1.arg0 = $<arg>2; $1.arg1 = $<arg>4; $1.arg2 = $<arg>6; $<instruction>$ = $1; }
	| IRIR reg ',' imm ',' reg	{ $1.arg0 = $<arg>2; $1.arg1 = $<arg>4; $1.arg2 = $<arg>6; $<instruction>$ = $1; }
	| IRRI reg ',' reg ',' imm	{ $1.arg0 = $<arg>2; $1.arg1 = $<arg>4; $1.arg2 = $<arg>6; $<instruction>$ = $1; }
	;

reg:
	REGISTER	{ $<arg>$.value = $1; $<arg>$.resolved = 1; }
	;

imm:
	IMMEDIATEV	{ $<arg>$.value = $1; $<arg>$.resolved = 1; }
	| IMMEDIATES	{ $<arg>$.symbol = strdup($<string>1); free($<string>1); $<arg>$.resolved = 0; }
	;

%%
