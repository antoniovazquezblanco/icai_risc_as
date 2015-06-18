/* File: symbol.h
 *
 * Author: Antonio Vázquez Blanco
 * Email: antoniovazquezblanco@gmail.com
 *
 * This file is part of the ICAI-RiSC-16 assembler.
 * This header file contains the declaration of functions that help to manage a symbol table.
 *
 */

#ifndef _H_SYMBOL
#define _H_SYMBOL

/* Adds a symbol to the table.
 * Takes the symbol information.
 */
void symbol_add(char* s, short addr);

/* Iterates in a table for a given symbol name.
 * Returns 0 if found and -1 if not. Address stored in the second parameter.
 */
char symbol_get_address(char* s, short* addr);

/* Free the table of symbols.
 */
void symbol_free();

#endif
