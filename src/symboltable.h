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
    VarSymbol* parameters;
    struct FuncSymbol *next;
};
typedef struct FuncSymbol FuncSymbol;

enum ASTnodeType {
    AST_NONE = 0,
    AST_VARIABLE,
    AST_MEMBER_VARIABLE,
    AST_ARRAY_ACCESS,
    AST_FUNCTION_CALL,
    AST_LITERAL,
    AST_OPERAND
};

struct ASTnode{
    char* text;
    struct ASTnode* left;
    struct ASTnode* right;

    enum ASTnodeType type;
    char* typename;
};
typedef struct ASTnode ASTnode;

ASTnode* ASTbuild(char* root, ASTnode* left, ASTnode* right, enum ASTnodeType type);

struct Expression{
    char* text;
    char* typename;

    ASTnode* ast;
};
typedef struct Expression Expression;


void PushStackFrame(char* frame);
char* LiteralToTypename(char* literal);

void VarUpdateValue(VarSymbol* var, Expression* new_value);
VarSymbol* VarPut(char* name, char* typename, bool is_const, Expression* valoare);
VarSymbol* VarGet(char* name);
VarSymbol* VarGetScoped(char* name, char* scope);
VarSymbol* VarGetMember(char* name, VarSymbol* parent_struct);

FuncSymbol* FunctionPut(char* name, char* return_type);
FuncSymbol* FunctionGet(char* name);
FuncSymbol* FunctionGetOverload(char* name);
FuncSymbol* FunctionGetCallOverload(char* name);
VarSymbol* PutFunctionParameter(char* name, char* typename);
Expression* PutFunctionCallParameter(Expression* exp);

void setupIntrinsics();
bool callIntrinsic(FuncSymbol* func);

Expression* MakeExpression(char* text, char* typename);
Expression* MergeExpression(Expression* t1, Expression* t2, char* op);

void PrintVars();
void PrintFunctions();

extern VarSymbol* VarsTable;
extern FuncSymbol* FunctionsTable;
extern VarSymbol* FunctionParamList;
extern Expression* FunctionCallParamList[32];
extern int num_param;
#endif