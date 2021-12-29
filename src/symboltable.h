#ifndef LZ_SYMBOLTABLE_H
#define LZ_SYMBOLTABLE_H

struct Symbol{
    char* name; 

    struct Symbol *next;
};
typedef struct Symbol Symbol;

Symbol* SymbolPut(char* name);
Symbol* SymbolGet(char* name);

Symbol* FunctionPut(char* name);
Symbol* FunctionGet(char* name);
void PrintSymbols();
void PrintFunctions();
#endif