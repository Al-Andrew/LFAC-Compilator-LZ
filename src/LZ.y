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
%token TK_LITERAL_INT TK_LITERAL_FLOAT TK_LITERAL_BOOL TK_LITERAL_CHAR TK_LITERAL_STRING


%type <id>typename

%right '='
%left TK_OP_EQ TK_OP_NEQ TK_OP_GE TK_OP_LE '<' '>'
%right '!'
%left TK_OP_AND TK_OP_OR
%left '+' '-'
%left '*' '/' '%'



%start program
%%

program: globals definitions main {printf("Program corect sintactic\n"); PrintFunctions(); PrintVars(); }
      | definitions main
      | globals main
      | main
      ;

globals: TK_BEGIN_GLOBAL globalsList TK_END_GLOBAL { VarSymbol* curr = VarsTable; while( curr != NULL ) { strcat(curr->stackframe, "global_"); curr = curr->next; } } 
      ;

globalsList:  varDeclaration ';' globalsList
            | varDeclaration ';'
            | constDeclaration ';' globalsList
            | constDeclaration ';'
            ;

varDeclaration: TK_KEYWORD_VAR typename TK_IDENTIFIER              { VarPut($3, $2, false); }
            | TK_KEYWORD_VAR typename TK_IDENTIFIER '=' expression { VarPut($3, $2, false); }
            ;

varAssignment: TK_IDENTIFIER '=' expression
             | TK_IDENTIFIER '[' TK_LITERAL_INT ']' '=' expression
             | TK_IDENTIFIER '.' TK_IDENTIFIER '=' expression
             ;

constDeclaration: TK_KEYWORD_CONST typename TK_IDENTIFIER '=' expression { VarPut($3, $2, true);}
            ;

definitions: TK_BEGIN_DEFINITIONS definitionsList TK_END_DEFINITIONS
           ;

definitionsList: functionDefinition definitionsList
               | userDefinedType definitionsList
               | functionDefinition
               | userDefinedType
               ;

functionDefinition: TK_KEYWORD_FUNC TK_IDENTIFIER '(' functionParametersList ')' TK_ARROW typename statementsBlock { VarSymbol* curr = VarsTable; while( curr != NULL && curr->stackframe[0] == 0 ) { strcat(curr->stackframe, $2); strcat(curr->stackframe, "_"); curr = curr->next; } FunctionPut($2); }
                  | TK_KEYWORD_FUNC TK_IDENTIFIER '('')' TK_ARROW typename statementsBlock    { VarSymbol* curr = VarsTable; while( curr != NULL && curr->stackframe[0] == 0 ) { strcat(curr->stackframe, $2); strcat(curr->stackframe, "_"); curr = curr->next; } FunctionPut($2); }
                  ;

userDefinedType: TK_KEYWORD_STRUCT TK_TYPEIDENTIFIER TK_BEGIN udVarList TK_END {  VarSymbol* curr = VarsTable; while( curr != NULL && curr->stackframe[0] == 0 ) { strcat(curr->stackframe, $2); strcat(curr->stackframe, "_"); curr = curr->next; } }
               ;

udVarList: varDeclaration ';' udVarList
         | varDeclaration ';'
         | constDeclaration ';' udVarList
         | constDeclaration ';'
         ;


functionParametersList: typename TK_IDENTIFIER ',' functionParametersList
                      | typename TK_IDENTIFIER
                      ;

functionCallParametersList: expression ',' functionCallParametersList
                          | expression
                          ;


main: TK_BEGIN_MAIN statementsList TK_END_MAIN  { VarSymbol* curr = VarsTable; while( curr != NULL && curr->stackframe[0] == 0 ) { strcat(curr->stackframe, "Main_"); curr = curr->next;  }}
    ;

statementsBlock: TK_BEGIN statementsList TK_END
               ;

statementsList: statement ';' statementsList
              | statement ';'
              ;

statement: varDeclaration
         | constDeclaration
         | varAssignment
         | expression
         | TK_KEYWORD_IF '(' expression ')' statementsBlock TK_KEYWORD_ELSE statementsBlock
         | TK_KEYWORD_IF '(' expression ')' statementsBlock
         | TK_KEYWORD_WHILE '(' expression ')' statementsBlock
         ;

typename: TK_TYPE { $$ = $1; }
      | TK_TYPEIDENTIFIER { $$ = $1; }
      | typename '[' TK_LITERAL_INT ']' { $$ = "unimplemented"; }
      ;

literal: TK_LITERAL_BOOL
       | TK_LITERAL_CHAR
       | TK_LITERAL_FLOAT
       | TK_LITERAL_INT
       | TK_LITERAL_STRING
       | '{' literalsList '}'
       ;

literalsList: literal
            | literal literalsList
            ;

expression: literal
          | TK_IDENTIFIER
          | TK_IDENTIFIER '.' TK_IDENTIFIER
          | TK_IDENTIFIER '[' TK_LITERAL_INT ']'
          | TK_IDENTIFIER '(' functionCallParametersList ')'
          | TK_IDENTIFIER '('')'
          | '(' expression ')'
          | expression '+' expression
          | expression '-' expression
          | expression '*' expression
          | expression '/' expression
          | expression '%' expression
          | '!' expression
          | expression TK_OP_AND expression
          | expression TK_OP_OR expression
          | expression TK_OP_EQ expression
          | expression TK_OP_NEQ expression
          | expression TK_OP_GE expression
          | expression '>' expression
          | expression TK_OP_LE expression
          | expression '<' expression
          ;
%% 

int yyerror(char * s) {
    printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
      yyin=fopen(argv[1],"r");
      yyparse();
}