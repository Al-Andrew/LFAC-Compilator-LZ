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

varDeclaration: TK_KEYWORD_VAR typename TK_IDENTIFIER              { VarPut($3, $2, false, MakeExpression("", $2)); }
            | TK_KEYWORD_VAR typename TK_IDENTIFIER '=' expression { VarPut($3, $2, false, $5  ); }
            ;

varAssignment: TK_IDENTIFIER '=' expression { //FIXME TODO: CHECK FOR CONST
                  VarSymbol* var  = VarGet($1);
                  if( var == NULL ) {
                        fprintf(stderr, "No such variable exists: %s | line: %d\n", $1 , yylineno);
                        exit(1);
                  } else if ( strcmp(var->typename, $3->typename) != 0 ) {
                        fprintf(stderr, "Cannot assign expression of type %s to variable of type %s | line: %d\n", $3->typename, var->typename, yylineno); 
                        exit(1);
                  } 
                  VarUpdateValue(var, $3);
             }
             | TK_IDENTIFIER '[' TK_LITERAL_INT ']' '=' expression {
                   //TODO
             }
             | TK_IDENTIFIER '.' TK_IDENTIFIER '=' expression {
                  VarSymbol* parent_struct = VarGet($1);
                  VarSymbol* var = VarGetMember($3, parent_struct);

                  if( var == NULL ) {
                        fprintf(stderr, "No member %s::%s found | line: %d\n", parent_struct->typename, $3 , yylineno);
                        exit(1);
                  } //FIXME TODO: TYPECHECKING

                  VarUpdateValue(var, $5);
             }
             ;

constDeclaration: TK_KEYWORD_CONST typename TK_IDENTIFIER '=' expression { VarPut($3, $2, true, $5);}
            ;

definitions: TK_BEGIN_DEFINITIONS definitionsList TK_END_DEFINITIONS
           ;

definitionsList: functionDefinition definitionsList
               | userDefinedType definitionsList
               | functionDefinition
               | userDefinedType
               ;

functionSignature: TK_KEYWORD_FUNC TK_IDENTIFIER '(' functionParametersList ')' TK_ARROW typename { VarPut("#Return", $7, false, MakeExpression("", $7)); PushStackFrame($2); FunctionPut($2, $7); }
                  | TK_KEYWORD_FUNC TK_IDENTIFIER '('')' TK_ARROW typename { VarPut("#Return", $6, false, MakeExpression("", $6)); PushStackFrame($2); FunctionPut($2, $6); }
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

functionCallParametersList: expression ',' functionCallParametersList //TODO
                          | expression
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
      } // TODO: Arrays
      ;

literal: TK_LITERAL_BOOL {$$ = $1;}
       | TK_LITERAL_CHAR {$$ = $1;}
       | TK_LITERAL_FLOAT {$$ = $1;}
       | TK_LITERAL_INT {$$ = $1;}
       | TK_LITERAL_STRING {$$ = $1;}
       | '{' literalsList '}' {$$ = "unimplemented";}//de implementat //ANCHOR - WTF IS THIS FOR?
       ;

literalsList: literal //de implementat {$$ = $1;}
            | literal literalsList //de implementat {$$ = $1;}
            ;

expression: literal {
                  $$ = MakeExpression($1, LiteralToTypename($1));
            }
          | TK_IDENTIFIER { 
                  VarSymbol* var = VarGet($1); 
                  if(var == NULL) { 
                        fprintf(stderr, "No such variable exists: %s | line: %d\n", $1, yylineno); 
                        exit(1);
                  }
                  $$ = MakeExpression($1, var->typename); 
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
                  $$ = MakeExpression(freeMe, var->typename);
                  free(freeMe);
          }
          | TK_IDENTIFIER '[' TK_LITERAL_INT ']' {
                  VarSymbol* var = VarGet($1); 
                  if(var == NULL) { 
                        fprintf(stderr, "No such ud variable exists: %s, line: %d\n", $1, yylineno); 
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
                  free(freeMe);
          }
          | TK_IDENTIFIER '(' functionCallParametersList ')' { $$ = MakeExpression("unimplemented", "unimplemented"); } //FIXME TODO: de implementat (sa treaca de lex, sa nu functioneze) 
          | TK_IDENTIFIER '('')' { $$ = MakeExpression("unimplemented", "unimplemented"); } //FIXME TODO: de implementat (sa treaca de lex, sa nu functioneze)
          | '(' expression ')' { $$ = MakeExpression($2->text, $2->typename); }
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
      yyin=fopen(argv[1],"r");
      yyparse();
}