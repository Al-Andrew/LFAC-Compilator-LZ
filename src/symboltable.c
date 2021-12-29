#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
#include <stdio.h>


static Symbol* SymbolTable = NULL;
static Symbol* FunctionTable = NULL;

static Symbol* Put(Symbol** table, char* name) {
    Symbol* ret = malloc(sizeof(Symbol));

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);
    ret->next = *table;
    *table = ret;
    return ret;
}


static Symbol* Get(Symbol** table, char* name) {
    Symbol* ret;
    for (ret = *table; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

void Print(Symbol** table, char* filename) {
    Symbol* current = *table;
    FILE* out = fopen(filename, "w");
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n}\n", 
                current->name );
        current = current->next;
    }
}

Symbol* SymbolPut(char* name) {
    return Put(&SymbolTable, name);
}
Symbol* SymbolGet(char* name) {
    return Get(&SymbolTable, name);
}

Symbol* FunctionPut(char* name) {
    return Put(&FunctionTable, name);
}
Symbol* FunctionGet(char* name) {
    return Get(&FunctionTable, name);
}
void PrintSymbols() {
    Print(&SymbolTable, "Symbols.txt");
}
void PrintFunctions() {
    Print(&FunctionTable, "Functions.txt");
}