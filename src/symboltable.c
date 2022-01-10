#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
#include <stdio.h>


VarSymbol* VarsTable = NULL;
FuncSymbol* FunctionsTable = NULL;
VarSymbol* FunctionParamList = NULL;
Expression* FunctionCallParamList[32];
int num_param = 0;
extern int yylineno;

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
        return var->value == NULL? "0":var->value;
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
        return var->value == NULL? "0":var->value;
        }
        break;
    case AST_ARRAY_ACCESS: {
        VarSymbol* elem = VarGet(root->text);

        return elem->value;
        }
        break;
    case AST_FUNCTION_CALL: {
        char* freeMe = malloc(strlen(root->text)+2);
        bzero(freeMe, strlen(root->text)+2);
        strcat(freeMe, root->text);
        strcat(freeMe, "_");
        VarSymbol* retval = VarGetScoped("#Return", freeMe);
        free(freeMe);
        return retval->value;
        }
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

            if( right_val == 0.0 ) {
                fprintf(stderr, "Cannot divide by 0. | line: %d\n", yylineno);
                exit(1);
            }

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

    ret->typename = malloc(strlen(t1->typename) + 1);
    strcpy(ret->typename, t1->typename);
    
    if( strchr( "+-/*", op[0]) != NULL ) {
        if( strcmp(t1->typename, t2->typename) != 0 ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
        if( (strcmp(t1->typename, "Int") != 0) && (strcmp(t1->typename, "Float") != 0) ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
    } else if ( (strcmp(op, "==") == 0) || (strcmp(op, "!=") == 0) ) {
        if( strcmp(t1->typename, t2->typename) != 0 ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
        free(ret->typename);
        ret->typename = "Bool";
    } else if( (strcmp(op, ">=") == 0) || (strcmp(op, ">") == 0) || (strcmp(op, "<=") == 0) || (strcmp(op, "<") == 0)) {
        if( strcmp(t1->typename, t2->typename) != 0 ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
        if( (strcmp(t1->typename, "Int") != 0) && (strcmp(t1->typename, "Float") != 0) ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
        ret->typename = "Bool";
    } else if( (strcmp(op, "&&") == 0) || (strcmp(op, "||") == 0) || (strcmp(op, "!") == 0) ) {
        if( strcmp(t1->typename, t2->typename) != 0 ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
        if( (strcmp(t1->typename, "Bool") != 0) ) {
            fprintf(stderr, "Could not apply operator %s on %s and %s | line: %d\n", op, t1->typename, t2->typename, yylineno);
            exit(1);
        }
    }

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

    if( ret->typename[0] == '$' ) { //Add Struct members to the var table
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
    } else if ( strchr(typename, '[') != NULL ) { //Add array elements to the var table
        char buff[64]; 
        sprintf(buff, "%.*s", (int)(strchr(ret->typename,']') - strchr(ret->typename,'[') - 1), strchr(ret->typename,'[') + 1);
        int size = atoi(buff);
        char namebuff[256];
        char typenamebuff[256];
        sprintf(typenamebuff, "%.*s", (int)(strchr(ret->typename,'[') - ret->typename),ret->typename);

        for(int i = 0 ; i < size ; ++i ) {
            sprintf(namebuff, "%s[%d]", name, i);
            VarPut(namebuff, typenamebuff, false, MakeExpression("", typenamebuff));
            bzero(namebuff, 256);
        }
    }



    ret->is_const = is_const;

    if( strcmp(ret->typename, value->typename) != 0 ) {
        fprintf(stderr, "Cannot assign value %s of type %s to %s of type %s | line: %d\n", ASTeval(value->ast), value->typename, ret->name, ret->typename, yylineno);
        exit(1);
    }


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

    if( strcmp(var->typename, new_value->typename) != 0 ) {
        fprintf(stderr, "Cannot assign value %s of type %s to %s of type %s | line: %d\n", ASTeval(new_value->ast), new_value->typename, var->name, var->typename, yylineno);
        exit(1);
    }
    

    var->value = ASTeval(new_value->ast);
}

VarSymbol* VarGet(char* name) {
    VarSymbol* ret;
    for (ret = VarsTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0)
            return ret;
    return NULL;
}

VarSymbol* VarGetScoped(char* name, char* scope) {
    VarSymbol* ret;
    for (ret = VarsTable; ret != NULL; ret = ret->next)
        if ((strcmp (ret->name,name) == 0) && (strcmp (ret->stackframe,scope) == 0) )
            return ret;
    return NULL;
}

VarSymbol* VarGetMember(char* name, VarSymbol* parent_struct) {
    VarSymbol* ret;
    for (ret = VarsTable; ret != NULL; ret = ret->next)
        if ((strcmp (ret->name,name) == 0)) {
            if (strncmp(ret->stackframe, parent_struct->typename, strlen(parent_struct->typename)) == 0) {
                char* freeMe = malloc(strlen(parent_struct->name) + 2);
                bzero(freeMe, strlen(parent_struct->name) + 2);
                strcat(freeMe, parent_struct->name);
                strcat(freeMe, "_");
                if ( strcmp(ret->stackframe + strlen(parent_struct->typename) + 1,
                 freeMe) == 0 ) {
                    free(freeMe);
                    return ret;
                }
                free(freeMe);
            }
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

Expression* PutFunctionCallParameter(Expression* exp) {
    FunctionCallParamList[num_param++] = exp;
    return exp;
}

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

FuncSymbol* FunctionGetOverload(char* name) {
    FuncSymbol* ret;
    bool diff = false;
    for (ret = FunctionsTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0) {
            VarSymbol* c1;
            VarSymbol* c2;
            for (c1 = FunctionParamList, c2 = ret->parameters; (c1 != NULL) && (c2 != NULL); c1 = c1->next, c2 = c2->next) {
                if ( strncmp( c1->typename,c2->typename, strlen(c1->typename)) == 0 )
                    continue; 
                else {
                    diff = true;
                    break;
                }
            }
            if(!diff) { return ret; };
        }
    return NULL;
}

FuncSymbol* FunctionGetCallOverload(char* name) {
    FuncSymbol* ret;
    bool diff = false;
    for (ret = FunctionsTable; ret != NULL; ret = ret->next)
        if (strcmp (ret->name,name) == 0) {
            VarSymbol* c1;
            Expression* c2;
            int np = num_param;
            for (c1 = ret->parameters, c2 = FunctionCallParamList[--np];
                 (c1 != NULL) && (c2 != NULL);
                  c1 = c1->next, c2 = FunctionCallParamList[--np]) {

                if ( strncmp( c1->typename,c2->typename, strlen(c1->typename)) == 0 )
                    continue; 
                else {
                    diff = true;
                    break;
                }
            }
            if(!diff) { return ret; };
        }
    return NULL;
}



void PrintFunctions() {
    FuncSymbol* current = FunctionsTable;
    FILE* out = fopen("Functions.txt", "w");
    while(current != NULL ) {
        fprintf(out, "{\n    name: %s\n    return_type: %s\n    params: ", 
                current->name,
                current->return_type);
        for(VarSymbol* curr = current->parameters ; curr != NULL ; curr = curr->next ) {
            fprintf(out, "%s ", curr->typename );
        }
        fprintf(out, "\n}\n");


        current = current->next;
    }
}

bool callIntrinsic(FuncSymbol* func) {
    if( (strcmp(func->name, "#PrintI") == 0) || (strcmp(func->name, "#PrintF") == 0) 
     || (strcmp(func->name, "#PrintC") == 0) || (strcmp(func->name, "#PrintS") == 0)) {
        printf("%s", ASTeval(FunctionCallParamList[num_param-1]->ast));
        return true;
    } else if ((strcmp(func->name, "#PrintNL") == 0)) {
        printf("\n");
        return true;
    }
    return false;
}

void setupIntrinsics() {
    FunctionPut("#PrintI", "Int");
    FunctionsTable->parameters = malloc(sizeof(VarSymbol));
    FunctionsTable->parameters->name = "i";
    FunctionsTable->parameters->typename = "Int";
    FunctionPut("#PrintF", "Int");
    FunctionsTable->parameters = malloc(sizeof(VarSymbol));
    FunctionsTable->parameters->name = "f";
    FunctionsTable->parameters->typename = "Float";
    FunctionPut("#PrintC", "Int");
    FunctionsTable->parameters = malloc(sizeof(VarSymbol));
    FunctionsTable->parameters->name = "c";
    FunctionsTable->parameters->typename = "Char";
    FunctionPut("#PrintS", "Int");
    FunctionsTable->parameters = malloc(sizeof(VarSymbol));
    FunctionsTable->parameters->name = "s";
    FunctionsTable->parameters->typename = "String";
    FunctionPut("#PrintNL", "Int");
    FunctionsTable->parameters = NULL;
}