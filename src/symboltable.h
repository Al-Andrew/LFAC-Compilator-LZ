#ifndef LZ_SYMBOLTABLE_H
#define LZ_SYMBOLTABLE_H

#include <stdbool.h>

#define LZ_MAX_STACKFRAME_LEN 255

struct VarSymbol{
    char* value;
    char* name;
    char* typename;
    char stackframe[LZ_MAX_STACKFRAME_LEN];
    bool is_const;

    struct VarSymbol *next;
};
typedef struct VarSymbol VarSymbol;

struct FuncSymbol{
    char* name; 
    char* return_type;
    char parameters[10001];
    struct FuncSymbol *next;
};
typedef struct FuncSymbol FuncSymbol;


struct Expression{
    char* text;
    char* typename;
};
typedef struct Expression Expression;


void PushStackFrame(char* frame);
char* LiteralToTypename(char* literal);

void VarUpdateValue(VarSymbol* var, Expression* new_value);
VarSymbol* VarPut(char* name, char* typename, bool is_const, Expression* valoare);
VarSymbol* VarGet(char* name);
VarSymbol* VarGetMember(char* name, VarSymbol* parent_struct);

FuncSymbol* FunctionPut(char* name, char* return_type, char* parameters);
FuncSymbol* FunctionGet(char* name);

Expression* MakeExpression(char* text, char* typename);
Expression* MergeExpression(Expression* t1, Expression* t2, char* op);

void PrintVars();
void PrintFunctions();

extern VarSymbol* VarsTable;
extern FuncSymbol* FunctionsTable;
#endif