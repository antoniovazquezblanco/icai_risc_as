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

#include <stdint.h>

/* Adds a symbol to the table.
 * Takes the symbol information.
 * Returns 0 if stored or 1 in case no enought memory is available.
 */
uint8_t symbol_add(char* s, uint16_t addr);

/* Iterates in a table for a given symbol name.
 * Returns 0 if found and 1 if not. Address stored in the second parameter.
 */
uint8_t symbol_get_address(char* s, uint16_t* addr);

/* Free the table of symbols.
 */
void symbol_free();

#endif
