#ifndef LZ_SYMBOLTABLE_H
#define LZ_SYMBOLTABLE_H

struct VarSymbol{
    char* name; 
    char* typename;

    struct VarSymbol* next;
};
typedef struct VarSymbol VarSymbol;


struct FuncSymbol{
    char* name; 
    char* ret_typename;

    struct FuncSymbol *next;
};
typedef struct FuncSymbol FuncSymbol;


struct UDType {
    char* typename;

    struct VarSymbol* inner_table;
    struct UDType* next;
};
typedef struct UDType UDType;


UDType* UDTypePut(char* typename, VarSymbol* table);
UDType* UDTypeGet(char* typename);


VarSymbol* VarPut(char* name, char* typename);
VarSymbol* VarGet(char* name);

FuncSymbol* FunctionPut(char* name, char* typename);
FuncSymbol* FunctionGet(char* name);
void PrintVars();
void PrintFunctions();
void PrintUDTypes();
#endif