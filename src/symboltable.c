#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
#include <stdio.h>


static VarSymbol* SymbolTable = NULL;
static FuncSymbol* FunctionTable = NULL;
static UDType* UdTypeTable = NULL;

UDType* UDTypePut(char* typename, VarSymbol* table) {
    UDType* ret = malloc(sizeof(UDType));

    ret->typename = malloc (strlen(typename)+1);
    strcpy(ret->typename, typename);
    ret->inner_table = table;

    ret->next = UdTypeTable;
    UdTypeTable = ret;
    return ret;
}

UDType* UDTypeGet(char* typename) {
    UDType* ret;
    for (ret = UdTypeTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->typename,typename) == 0)
            return ret;
    return NULL;
}

VarSymbol* VarPut(char* name, char* typename) {
    VarSymbol* ret = malloc(sizeof(VarSymbol));

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);
    ret->typename = malloc (strlen(typename)+1);
    strcpy(ret->typename, typename);

    ret->next = SymbolTable;
    SymbolTable = ret;
    return ret;
}

VarSymbol* VarGet(char* name) {
    VarSymbol* ret;
    for (ret = SymbolTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

FuncSymbol* FunctionPut(char* name, char* typename) {
    FuncSymbol* ret = malloc(sizeof(FuncSymbol));

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);

    ret->ret_typename = malloc(strlen(typename) + 1);
    strcpy(ret->ret_typename, typename);

    ret->next = FunctionTable;
    FunctionTable = ret;
    return ret;
}


FuncSymbol* FunctionGet(char* name) {
    FuncSymbol* ret;
    for (ret = FunctionTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

void PrintVarsImpl(VarSymbol* table, const char* mode) {
    VarSymbol* current = table;
    FILE* out = fopen("Vars.txt", mode);
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n    type: %s\n", 
                current->name,
                current->typename );
        if(current->typename[0] == '$') {
            fprintf(out, "    inner_table: {\n");
            UDType* inner = UDTypeGet(current->typename);
            PrintVarsImpl(inner->inner_table, "a+");
            fprintf(out, "}\n");
        }
        fprintf(out, "}\n");
        current = current->next;
    }
    fclose(out);
}

void PrintVars() {
    PrintVarsImpl(SymbolTable, "w");
}

void PrintFunctions() {
    FuncSymbol* current = FunctionTable;
    FILE* out = fopen("Functions.txt", "w");
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n    ret_type: %s\n}\n", 
                current->name,
                current->ret_typename );
        current = current->next;
    }
    fclose(out);
}

void PrintUDTYpesImpl(UDType* table, const char* mode) {
    UDType* current = table;
    FILE* out = fopen("UDTypes.txt", mode);
    while(current != NULL ) {
        fprintf(out, "{\n    type: %s\n", 
                current->typename );
        if(current->typename[0] == '$') {
            fprintf(out, "    inner_table: {\n");
            UDType* inner = UDTypeGet(current->typename);
            PrintUDTYpesImpl(inner, "a+");
            fprintf(out, "}\n");
        }
        fprintf(out, "}\n");
        current = current->next;
    }
    fclose(out);
}

void PrintUDTypes() {
    PrintUDTYpesImpl(UdTypeTable, "w");
}