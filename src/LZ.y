%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h> 
#include "symboltable.h"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}

%union {
    char* id;
    struct Expression* exp;
}

/*Keywords*/
%token TK_KEYWORD_STRUCT TK_KEYWORD_FUNC TK_KEYWORD_VAR TK_KEYWORD_CONST TK_KEYWORD_IF TK_KEYWORD_ELSE TK_KEYWORD_WHILE
/*Blocks*/
%token TK_BEGIN_GLOBAL TK_END_GLOBAL TK_BEGIN_DEFINITIONS TK_END_DEFINITIONS TK_BEGIN TK_END TK_ARROW
%token TK_BEGIN_MAIN TK_END_MAIN
/*Types and identifiers*/
%token <id>TK_TYPE <id>TK_IDENTIFIER <id>TK_TYPEIDENTIFIER
/*Operators*/
%token TK_OP_AND TK_OP_OR TK_OP_EQ TK_OP_NEQ TK_OP_GE TK_OP_LE
/*Literals*/
%token <id>TK_LITERAL_INT <id>TK_LITERAL_FLOAT <id>TK_LITERAL_BOOL <id>TK_LITERAL_CHAR <id>TK_LITERAL_STRING


%type <id>typename
%type <id>functionParametersList
%type <id> varDeclaration
%type <id> constDeclaration
%type <exp> expression
%type <id> literal

%right '='
%left TK_OP_EQ TK_OP_NEQ TK_OP_GE TK_OP_LE '<' '>'
%right '!'
%left TK_OP_AND TK_OP_OR
%left '+' '-'
%left '*' '/' '%'



%start program
%%

program: globals definitions main {printf("Program corect sintactic\n"); PrintFunctions(); PrintVars(); }
      | definitions main {printf("Program corect sintactic\n"); PrintFunctions(); PrintVars(); }
      | globals main {printf("Program corect sintactic\n"); PrintFunctions(); PrintVars(); }
      | main {printf("Program corect sintactic\n"); PrintFunctions(); PrintVars(); }
      ;

globals: TK_BEGIN_GLOBAL globalsList TK_END_GLOBAL { PushStackFrame("global"); } 
      ;

globalsList:  varDeclaration ';' globalsList
            | varDeclaration ';'
            | constDeclaration ';' globalsList
            | constDeclaration ';'
            ;

varDeclaration: TK_KEYWORD_VAR typename TK_IDENTIFIER {
                  VarSymbol* var = VarGet($3);

                  if( var != NULL ) {
                        fprintf(stderr, "Identifier %s already defined | line: %d\n", $3, yylineno);
                        exit(1);
                  }
                  VarPut($3, $2, false, MakeExpression("", $2)); 
            }
            | TK_KEYWORD_VAR typename TK_IDENTIFIER '=' expression {
                  VarSymbol* var = VarGet($3);

                  if( var != NULL ) {
                        fprintf(stderr, "Identifier %s already defined | line: %d\n", $3, yylineno);
                        exit(1);
                  }
                  VarPut($3, $2, false, $5); 
            }
            ;

varAssignment: TK_IDENTIFIER '=' expression {
                  VarSymbol* var  = VarGet($1);
                  if( var == NULL ) {
                        fprintf(stderr, "No such variable exists: %s | line: %d\n", $1 , yylineno);
                        exit(1);
                  } else if ( strcmp(var->typename, $3->typename) != 0 ) {
                        fprintf(stderr, "Cannot assign expression of type %s to variable of type %s | line: %d\n", $3->typename, var->typename, yylineno); 
                        exit(1);
                  } else if ( var->is_const == true) {
                        fprintf(stderr, "Cannot change value of const %s | line: %d\n", var->name, yylineno);
                        exit(1);
                  }     
                  VarUpdateValue(var, $3);
             }
             | TK_IDENTIFIER '[' TK_LITERAL_INT ']' '=' expression {
                  VarSymbol* array = VarGet($1);
                  
                  if( array == NULL ) {
                        fprintf(stderr, "No such variable exists: %s | line: %d\n", $1 , yylineno);
                        exit(1);
                  }

                  int len = strlen($1) + strlen($3) + 3;
                  char* freeMe = malloc(len);
                  bzero(freeMe, len);
                  strcat(freeMe, $1);
                  strcat(freeMe, "[");
                  strcat(freeMe, $3);
                  strcat(freeMe, "]");

                  VarSymbol* elem = VarGet(freeMe);

                  if( elem == NULL ) {
                        fprintf(stderr, "Could not find element %s of %s | line : %d", $3, $1, yylineno);
                  } else if ( strcmp(elem->typename, $6->typename) != 0 ) {
                        fprintf(stderr, "Cannot assign expression of type %s to variable of type %s | line: %d\n", $6->typename, elem->typename, yylineno); 
                        exit(1);
                  }

                  free(freeMe);
                  VarUpdateValue(elem, $6);
             }
             | TK_IDENTIFIER '.' TK_IDENTIFIER '=' expression {
                  VarSymbol* parent_struct = VarGet($1);

                  if( parent_struct == NULL ) {
                        fprintf(stderr, "No such variable exists: %s | line: %d\n", $1 , yylineno);
                  } else if( strchr(parent_struct->typename, '.') != 0 ) {
                        fprintf(stderr, "Variable %s not a struct | line: %d\n", $1, yylineno);
                  }

                  VarSymbol* var = VarGetMember($3, parent_struct);

                  if( var == NULL ) {
                        fprintf(stderr, "No member %s::%s found | line: %d\n", parent_struct->typename, $3 , yylineno);
                        exit(1);
                  }

                  VarUpdateValue(var, $5);
             }
             ;

constDeclaration: TK_KEYWORD_CONST typename TK_IDENTIFIER '=' expression  {
                  VarSymbol* var = VarGet($3);

                  if( var != NULL ) {
                        fprintf(stderr, "Identifier %s already defined | line: %d\n", $3, yylineno);
                        exit(1);
                  }
                  VarPut($3, $2, true, $5); 
            }
            ;

definitions: TK_BEGIN_DEFINITIONS definitionsList TK_END_DEFINITIONS
           ;

definitionsList: functionDefinition definitionsList
               | userDefinedType definitionsList
               | functionDefinition
               | userDefinedType
               ;

functionSignature: TK_KEYWORD_FUNC TK_IDENTIFIER '(' functionParametersList ')' TK_ARROW typename { 
                        VarPut("#Return", $7, false, MakeExpression("", $7));
                        PushStackFrame($2);
                        FuncSymbol* func = FunctionGetOverload($2);

                        if( func != NULL ) {
                              fprintf(stderr, "Function with identifier %s and parameter list already defined | line: %d\n", $2, yylineno);
                              exit(1);
                        }

                        FunctionPut($2, $7);
                  }
                  | TK_KEYWORD_FUNC TK_IDENTIFIER '('')' TK_ARROW typename { 
                        VarPut("#Return", $6, false, MakeExpression("", $6));
                        PushStackFrame($2);
                        FuncSymbol* func = FunctionGetOverload($2);

                        if( func != NULL ) {
                              fprintf(stderr, "Function with identifier %s and parameter list already defined | line: %d\n", $2, yylineno);
                              exit(1);
                        }
                        
                        FunctionPut($2, $6);
                  }
                  ;

functionDefinition: functionSignature statementsBlock
                  ;

userDefinedType: TK_KEYWORD_STRUCT TK_TYPEIDENTIFIER TK_BEGIN udVarList TK_END { PushStackFrame($2); }
               ;

udVarList: varDeclaration ';' udVarList
         | varDeclaration ';'
         | constDeclaration ';' udVarList
         | constDeclaration ';'
         ;


functionParametersList: typename TK_IDENTIFIER ',' functionParametersList { VarPut($2, $1, false, MakeExpression("", $1)); PutFunctionParameter($2, $1); }
                      | typename TK_IDENTIFIER { VarPut($2, $1, false, MakeExpression("", $1)); PutFunctionParameter($2, $1); }
                      ;

functionCallParametersList: expression ',' functionCallParametersList { PutFunctionCallParameter($1); }
                          | expression { PutFunctionCallParameter($1); }
                          ;


main: TK_BEGIN_MAIN statementsList TK_END_MAIN  { PushStackFrame("#Main"); }
    ;

statementsBlock: TK_BEGIN statementsList TK_END
               ;

statementsList: statement ';' statementsList
              | statement ';'
              ;

statement: ';' // skip
         | varDeclaration
         | constDeclaration
         | varAssignment
         | expression
         | TK_KEYWORD_IF '(' expression ')' statementsBlock TK_KEYWORD_ELSE statementsBlock
         | TK_KEYWORD_IF '(' expression ')' statementsBlock
         | TK_KEYWORD_WHILE '(' expression ')' statementsBlock
         ;

typename: TK_TYPE { $$ = $1; }
      | TK_TYPEIDENTIFIER { $$ = $1; }
      | typename '[' TK_LITERAL_INT ']' {
            int len = strlen($1) + strlen($3) + 3;
            char* freeMe = malloc(len);
            bzero(freeMe, len);
            strcat(freeMe, $1);
            strcat(freeMe, "[");
            strcat(freeMe, $3);
            strcat(freeMe, "]");
            $$ = freeMe;
      }
      ;

literal: TK_LITERAL_BOOL {$$ = $1;}
       | TK_LITERAL_CHAR {$$ = $1;}
       | TK_LITERAL_FLOAT {$$ = $1;}
       | TK_LITERAL_INT {$$ = $1;}
       | TK_LITERAL_STRING {$$ = $1;}
       ;

expression: literal {
                  $$ = MakeExpression($1, LiteralToTypename($1));
                  $$->ast = ASTbuild($1, NULL, NULL, AST_LITERAL);
                  $$->ast->typename = LiteralToTypename($1);
            }
          | TK_IDENTIFIER { 
                  VarSymbol* var = VarGet($1); 
                  if(var == NULL) { 
                        fprintf(stderr, "No such variable exists: %s | line: %d\n", $1, yylineno); 
                        exit(1);
                  }
                  $$ = MakeExpression($1, var->typename);
                  $$->ast = ASTbuild($1, NULL, NULL, AST_VARIABLE);
                  $$->ast->typename = var->typename;
            }
          | TK_IDENTIFIER '.' TK_IDENTIFIER {
                  VarSymbol* var = VarGet($1); 
                  if(var == NULL) { 
                        fprintf(stderr, "No such ud variable exists: %s | line: %d\n", $1, yylineno); 
                        exit(1);
                  }
                  VarSymbol* member = VarGet($3);
                  if(member == NULL || (strncmp($1, member->stackframe, strlen($1)) == 0) ) { //daca apartine structului sau nu
                        fprintf(stderr, "No such ud variable %s has no member %s, line: %d\n", $1, $3, yylineno); 
                        exit(1);
                  }
                  int len = strlen($1) + strlen($3) + 2;
                  char* freeMe = malloc(len);
                  bzero(freeMe, len);
                  strcat(freeMe, $1);
                  strcat(freeMe, ".");
                  strcat(freeMe, $3);
                  $$ = MakeExpression(freeMe, member->typename);
                  $$->ast = ASTbuild(freeMe, NULL, NULL, AST_MEMBER_VARIABLE);
                  $$->ast->typename = member->typename;
                  free(freeMe);
          }
          | TK_IDENTIFIER '[' TK_LITERAL_INT ']' {
                  VarSymbol* var = VarGet($1); 
                  if(var == NULL) { 
                        fprintf(stderr, "No such ud variable exists: %s, line: %d\n", $1, yylineno); 
                        exit(1);
                  }
                  if( strchr(var->typename, '[') == NULL ) {
                        fprintf(stderr, "Cannot index variable of type %s", var->typename);
                        exit(1);
                  }

                  char buff[64];
                  sprintf(buff, "%.*s", (int)(strchr(var->typename,']') - strchr(var->typename,'[') - 1), strchr(var->typename,'[') + 1);
                  if( atoi($3) >= atoi(buff) ) {
                        fprintf(stderr, "Cannot acces element %s of %s:%s | line: %d\n", $3, var->name,var->typename, yylineno); 
                        exit(1);
                  }
                  int len = strlen($1) + strlen($3) + 3;
                  char* freeMe = malloc(len);
                  bzero(freeMe, len);
                  strcat(freeMe, $1);
                  strcat(freeMe, "[");
                  strcat(freeMe, $3);
                  strcat(freeMe, "]");
                  $$ = MakeExpression(freeMe, var->typename);
                  $$->ast = ASTbuild(freeMe, NULL, NULL, AST_ARRAY_ACCESS);
                  $$->ast->typename = malloc(strlen(var->typename));
                  strncpy($$->ast->typename, var->typename, strchr(var->typename, '[') - var->typename);
                  strcpy($$->typename, $$->ast->typename);

                  free(freeMe);
          }
          | TK_IDENTIFIER '(' functionCallParametersList ')' { 
                  FuncSymbol* func = FunctionGetCallOverload($1);
                  if( func == NULL ) {
                              fprintf(stderr, "No function named %s with given parameter list found found | line: %d\n", $1, yylineno);
                              exit(1);
                  }
                  callIntrinsic(func);
                  $$ = MakeExpression(func->name, func->return_type);
                  $$->ast = ASTbuild(func->name, NULL, NULL, AST_FUNCTION_CALL);
                  num_param = 0;
          }
          | TK_IDENTIFIER '('')' {
                  FuncSymbol* func = FunctionGetCallOverload($1);
                  if( func == NULL ) {
                        fprintf(stderr, "No function named %s with given parameter list found found | line: %d\n", $1, yylineno);
                        exit(1);
                  }
                  callIntrinsic(func);

                  $$ = MakeExpression(func->name, func->return_type);
                  $$->ast = ASTbuild(func->name, NULL, NULL, AST_FUNCTION_CALL);
                  $$->ast->typename = malloc(strlen(func->return_type) + 1);
                  strcpy($$->ast->typename, func->return_type);
                  num_param = 0;
          }
          | '(' expression ')' { 
                  $$ = MakeExpression($2->text, $2->typename); 
                  $$->ast = $2->ast;
          }
          | expression '+' expression { $$ = MergeExpression($1, $3, "+"); }
          | expression '-' expression { $$ = MergeExpression($1, $3, "-"); }
          | expression '*' expression { $$ = MergeExpression($1, $3, "*"); }
          | expression '/' expression { $$ = MergeExpression($1, $3, "/"); }
          | expression '%' expression { $$ = MergeExpression($1, $3, "%"); }
          | '!' expression            { $$ = MergeExpression(MakeExpression("", "Bool"), $2, "!"); }
          | expression TK_OP_AND expression { $$ = MergeExpression($1, $3, "&&"); }
          | expression TK_OP_OR expression  { $$ = MergeExpression($1, $3, "||"); }
          | expression TK_OP_EQ expression  { $$ = MergeExpression($1, $3, "=="); }
          | expression TK_OP_NEQ expression { $$ = MergeExpression($1, $3, "!="); }
          | expression TK_OP_GE expression  { $$ = MergeExpression($1, $3, ">="); }
          | expression '>' expression       { $$ = MergeExpression($1, $3, ">"); }
          | expression TK_OP_LE expression  { $$ = MergeExpression($1, $3, "<="); }
          | expression '<' expression       { $$ = MergeExpression($1, $3, "<"); }
          ;
%% 

int yyerror(char * s) {
    printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
      
      setupIntrinsics();

      yyin=fopen(argv[1],"r");
      yyparse();
}