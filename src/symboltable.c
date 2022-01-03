#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
#include <stdio.h>


VarSymbol* VarsTable = NULL;
FuncSymbol* FunctionsTable = NULL;

/**========================================================================
 *                           SECTION VarSymbol Functions
 *========================================================================**/

VarSymbol* VarPut(char* name, char* typename, bool is_const) {
    VarSymbol* ret = malloc(sizeof(VarSymbol));

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);
    ret->typename = malloc (strlen(typename)+1);
    strcpy(ret->typename, typename);

    ret->member_of = NULL;
    ret->is_const = is_const;


    ret->next = VarsTable;
    VarsTable = ret;
    return ret;
}

VarSymbol* VarGet(char* name) {
    VarSymbol* ret;
    for (ret = VarsTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

void PrintVars() {
    VarSymbol* current = VarsTable;
    FILE* out = fopen("Vars.txt", "w");
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n    typename: %s\n    is_const: %s\n    stackframe: %s\n}\n", 
                current->name,
                current->typename,
                current->is_const?"true":"false",
                current->stackframe );
        current = current->next;
    }
}

/**========================================================================
 *                           SECTION FuncSymbol Functions
 *========================================================================**/

FuncSymbol* FunctionPut(char* name) {
    FuncSymbol* ret = malloc(sizeof(FuncSymbol));

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);
    ret->next = FunctionsTable;
    FunctionsTable = ret;
    return ret;
}

FuncSymbol* FunctionGet(char* name) {
    FuncSymbol* ret;
    for (ret = FunctionsTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

void PrintFunctions() {
    FuncSymbol* current = FunctionsTable;
    FILE* out = fopen("Functions.txt", "w");
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n}\n", 
                current->name );
        current = current->next;
    }
}