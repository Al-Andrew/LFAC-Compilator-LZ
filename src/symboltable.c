#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
#include <stdio.h>


VarSymbol* VarsTable = NULL;
FuncSymbol* FunctionsTable = NULL;
VarSymbol* FunctionParamList = NULL;

/**========================================================================
 *                           SECTION VarSymbol Functions
 *========================================================================**/

char* LiteralToTypename(char* literal) {
    // String
    if (literal[0] == '\"')
        return "String";
    else if (literal[0] == '\'')
        return "Char";
    else if ( strcmp(literal, "True") == 0 || strcmp(literal, "False") == 0)
        return "Bool";
    else if ( strchr(literal, '.') != NULL )
        return "Float";
    return "Int";
}

Expression* MakeExpression(char* text, char* typename) {
    Expression* ret = malloc(sizeof(Expression));

    ret->text = malloc(strlen(text) + 1);
    strcpy(ret->text, text); 

    ret->typename = malloc(strlen(typename) + 1);
    strcpy(ret->typename, typename);

    return ret;
}

char* ASTeval(ASTnode* root) {
    switch (root->type)
    {
    case AST_LITERAL:
        return root->text;
        break;
    case AST_VARIABLE: {
        VarSymbol* var = VarGet(root->text);
        return var->value;
        }
        break;
    case AST_MEMBER_VARIABLE: {
        int len = strchr(root->text, '.') - root->text + 2;
        char* parent = malloc(len);
        bzero(parent, len);
        strncpy(parent, root->text, len - 2);
        len = strlen(root->text) - (strchr(root->text, '.') - root->text) + 2;
        char* member = malloc(len);
        bzero(member, len);
        strcpy(member, strchr(root->text, '.') + 1);
        VarSymbol* var = VarGetMember(member, VarGet(parent));
        return var->value;
        }
        break;
    case AST_ARRAY_ACCESS:
        return "0"; //TODO: implement arrays pls
        break;
    case AST_FUNCTION_CALL:
        return "0";
        break;
    case AST_OPERAND: {

        if( strcmp(root->text, "+") == 0 ) {   //ANCHOR Arithmetics
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            double res_val = left_val + right_val;
            char *res = malloc(strlen(left) + 3);
            if( strcmp(root->left->typename, "Int") == 0 ) {
                sprintf(res, "%d", (int)res_val);
            } else {
                sprintf(res, "%f", (float)res_val);
            }
            return res;
        } else if( strcmp(root->text, "-") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            double res_val = left_val - right_val;
            char *res = malloc(strlen(left) + 3);
            if( strcmp(root->left->typename, "Int") == 0 ) {
                sprintf(res, "%d", (int)res_val);
            } else {
                sprintf(res, "%f", (float)res_val);
            }
            return res;
        } else if( strcmp(root->text, "/") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            double res_val = left_val / right_val;
            char *res = malloc(strlen(left) + 3);
            if( strcmp(root->left->typename, "Int") == 0 ) {
                sprintf(res, "%d", (int)res_val);
            } else {
                sprintf(res, "%f", (float)res_val);
            }
            return res;
        } else if( strcmp(root->text, "*") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            double res_val = left_val * right_val;
            char *res = malloc(strlen(left) + 3);
            if( strcmp(root->left->typename, "Int") == 0 ) {
                sprintf(res, "%d", (int)res_val);
            } else {
                sprintf(res, "%f", (float)res_val);
            }
            return res;
        } else if( strcmp(root->text, "==") == 0 ) {           //ANCHOR comparison
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);

            return (strcmp(left, right) == 0)?"True":"False";
        } else if( strcmp(root->text, "!=") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);

            return (strcmp(left, right) == 0)?"False":"True";
        } else if( strcmp(root->text, ">=") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            bool res_val = left_val >= right_val;
            return res_val?"True":"False";
        } else if( strcmp(root->text, ">") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            bool res_val = left_val > right_val;
            return res_val?"True":"False";
        } else if( strcmp(root->text, "<=") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            bool res_val = left_val <= right_val;
            return res_val?"True":"False";
        } else if( strcmp(root->text, "<") == 0 ) {
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            double left_val = atof(left);
            double right_val = atof(right);
            bool res_val = left_val < right_val;
            return res_val?"True":"False";
        } else if( strcmp(root->text, "&&") == 0 ) { //ANCHOR Boolean
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            
            return (strcmp(left, "False") == 0)?"False":right;
        } else if( strcmp(root->text, "||") == 0 ) { 
            char* left = ASTeval(root->left);
            char* right = ASTeval(root->right);
            
            return (strcmp(left, "True") == 0)?"True":right;
        } else if( strcmp(root->text, "!") == 0 ) {
            char* right = ASTeval(root->right);

            return (strcmp(right, "True") == 0)?"False":"True";
        }

        break;
    }
    default:
        return "0";
        break;
    }
    return "0";
}

ASTnode* ASTbuild(char* root, ASTnode* left, ASTnode* right, enum ASTnodeType type) {
    ASTnode* ret = malloc(sizeof(ASTnode));

    ret->text = malloc(strlen(root) + 1);
    strcpy(ret->text, root);

    ret->left = left;
    ret->right = right;

    ret->type = type;

    return ret;
}

Expression* MergeExpression(Expression* t1, Expression* t2, char* op) {
    Expression* ret = malloc(sizeof(Expression));


    int len = strlen(t1->text) + strlen(t2->text) + strlen(op) + 3;
    ret->text = malloc(len);
    bzero(ret->text, len);
    strcpy(ret->text, t1->text);
    strcat(ret->text, " ");
    strcat(ret->text, op);
    strcat(ret->text, " ");
    strcat(ret->text, t2->text);
    //FIXME TODO: TYPECHECKING

    ret->typename = malloc(strlen(t1->typename) + 1);
    strcpy(ret->typename, t1->typename);

    ret->ast = ASTbuild(op, t1->ast, t2->ast, AST_OPERAND);
    ret->ast->typename = malloc(strlen(t1->typename) + 1);
    strcpy(ret->ast->typename, t1->typename);

    return ret;
}

void PushStackFrame(char* frame) {
    VarSymbol* curr = VarsTable;
    while( curr != NULL ) { 
        if( curr->stackframe[0] != 0 ) {
            curr = curr->next;
            continue;
        }
        strcat(curr->stackframe, frame);
        strcat(curr->stackframe, "_");
        curr = curr->next;
    }
}

VarSymbol* VarPut(char* name, char* typename, bool is_const, Expression* value) {
    VarSymbol* ret = malloc(sizeof(VarSymbol));
    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);

    ret->typename = malloc (strlen(typename)+1);
    strcpy(ret->typename, typename);

    if( ret->typename[0] == '$' ) {
        VarSymbol* curr;
        for (curr = VarsTable; curr != NULL; curr = curr->next) {
            if(strncmp(curr->stackframe, typename, strlen(typename)) == 0 ) {
                if( strlen(curr->stackframe) == strlen(typename) + 1 ) {
                    char* vl = curr->value == NULL?"":curr->value;
                    VarSymbol* latest = VarPut(curr->name, curr->typename, curr->is_const, MakeExpression(vl, curr->typename));
                    strcat(latest->stackframe, curr->stackframe);
                    strcat(latest->stackframe, name);
                    strcat(latest->stackframe, "_");
                }
            }
        }
    }


    ret->is_const = is_const;


    //FIXME TODO: Typechecking
    if( (value == NULL) || (value->text[0] == 0) )
        ret->value == "";
    else {
        ret->value = ASTeval(value->ast);
    }

    ret->next = VarsTable;
    VarsTable = ret;
    return ret;
}

void VarUpdateValue(VarSymbol* var, Expression* new_value) {
    var->value = ASTeval(new_value->ast);
}

VarSymbol* VarGet(char* name) {
    VarSymbol* ret;
    for (ret = VarsTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

VarSymbol* VarGetMember(char* name, VarSymbol* parent_struct) {
    VarSymbol* ret;
    for (ret = VarsTable; ret != NULL; ret = ret->next)
        if ((strcmp (ret->name,name) == 0)) {
            if (strncmp(ret->stackframe, parent_struct->typename, strlen(parent_struct->typename)) == 0)
                if ( strncmp(ret->stackframe + strlen(parent_struct->typename) + 1,
                 parent_struct->name, strlen(parent_struct->name)) == 0 )

                    return ret;
        }
    return NULL;
}

void PrintVars() {
    VarSymbol* current = VarsTable;
    FILE* out = fopen("Vars.txt", "w");
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n    typename: %s\n    is_const: %s\n    stackframe: %s\n    value: %s\n}\n", 
                current->name,
                current->typename,
                current->is_const?"true":"false",
                current->stackframe,
                current->value);
        current = current->next;
    }
}

/**========================================================================
 *                           SECTION FuncSymbol Functions
 *========================================================================**/

VarSymbol* PutFunctionParameter(char* name, char* typename) {
    VarSymbol* ret = malloc(sizeof(VarSymbol));

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);

    ret->typename = malloc(strlen(typename) + 1);
    strcpy(ret->typename, typename);

    ret->next = FunctionParamList;
    FunctionParamList = ret;
    return ret;
}

FuncSymbol* FunctionPut(char* name, char* return_type) {
    FuncSymbol* ret = malloc(sizeof(FuncSymbol));
    ret->parameters = FunctionParamList;
    FunctionParamList = NULL;

    ret->name = malloc (strlen(name)+1);
    strcpy(ret->name, name);

    ret->return_type = malloc(strlen(return_type) + 1);
    strcpy(ret->return_type, return_type);

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
        fprintf(out, "{\n    name: %s\n    return_type: %s\n}\n", 
                current->name,
                current->return_type);
        current = current->next;
    }
}