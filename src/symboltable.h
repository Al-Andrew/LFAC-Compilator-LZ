#ifndef LZ_SYMBOLTABLE_H
#define LZ_SYMBOLTABLE_H

#include <stdbool.h>

struct VarSymbol{
    char* name;
    char* typename;
    bool is_const;

    struct VarSymbol *next;
};
typedef struct VarSymbol VarSymbol;

struct FuncSymbol{
    char* name; 

    struct FuncSymbol *next;
};
typedef struct FuncSymbol FuncSymbol;


VarSymbol* VarPut(char* name, char* typename, bool is_const);
VarSymbol* VarGet(char* name);

FuncSymbol* FunctionPut(char* name);
FuncSymbol* FunctionGet(char* name);

void PrintVars();
void PrintFunctions();
#endif