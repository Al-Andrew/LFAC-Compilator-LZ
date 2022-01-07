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
%type <id>functionDefinition
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

varDeclaration: TK_KEYWORD_VAR typename TK_IDENTIFIER              { VarPut($3, $2, false, NULL); }
            | TK_KEYWORD_VAR typename TK_IDENTIFIER '=' expression { VarPut($3, $2, false, $5  ); }
            ;                                                      

varAssignment: TK_IDENTIFIER '=' expression {
                  VarSymbol* var  = VarGet($1);
                  if( var == NULL ) {
                        fprintf(stderr, "No such variable exists: %s | line: %d", $1 , yylineno);
                  } else if ( strcmp(var->typename, $3->typename) != 0 ) {
                        fprintf(stderr, "Cannot assign expression of type %s to variable of type %s | line: %d", $3->typename, var->typename, yylineno); 
                  } 
                  VarUpdateValue(var, $3);
             }
             | TK_IDENTIFIER '[' TK_LITERAL_INT ']' '=' expression {
                   //TODO
             }
             | TK_IDENTIFIER '.' TK_IDENTIFIER '=' expression {
                  VarSymbol* var = VarGetMember($3, $1);
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

functionDefinition: TK_KEYWORD_FUNC TK_IDENTIFIER '(' functionParametersList ')' TK_ARROW typename statementsBlock { PushStackFrame($2); FunctionPut($2, $7, $4); }
                  | TK_KEYWORD_FUNC TK_IDENTIFIER '('')' TK_ARROW typename statementsBlock    { PushStackFrame($2); FunctionPut($2, $6, " "); }
                  ;

userDefinedType: TK_KEYWORD_STRUCT TK_TYPEIDENTIFIER TK_BEGIN udVarList TK_END { PushStackFrame($2); }
               ;

udVarList: varDeclaration ';' udVarList
         | varDeclaration ';'
         | constDeclaration ';' udVarList
         | constDeclaration ';'
         ;


functionParametersList: typename TK_IDENTIFIER ',' functionParametersList {char* s = (char*)malloc(strlen($1) + strlen($2) + strlen($4) + 4);
                                                                              strcpy(s, $1);
                                                                              strcat(s, " ");
                                                                              strcat(s, $2);
                                                                              strcat(s, " ");
                                                                              strcat(s, $4);
                                                                              strcat(s, " ");
                                                                              $$ = s;}
                      | typename TK_IDENTIFIER {char* s = (char*)malloc(strlen($1) + strlen($2) +3);
                                                                              strcpy(s, $1);
                                                                              strcat(s, " ");
                                                                              strcat(s, $2);
                                                                              strcat(s, " ");
                                                                              $$ = s;}
                      ;

functionCallParametersList: expression ',' functionCallParametersList //de implementat
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
       | '{' literalsList '}' {$$ = "unimplemented";}//de implementat
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
                        fprintf(stderr, "No such variable exists: %s, line: %d", $1, yylineno); 
                        exit(1);
                  }
                  $$ = MakeExpression($1, var->typename); 
            }
          | TK_IDENTIFIER '.' TK_IDENTIFIER {
                  VarSymbol* var = VarGet($1); 
                  if(var == NULL) { 
                        fprintf(stderr, "No such ud variable exists: %s, line: %d", $1, yylineno); 
                        exit(1);
                  }
                  VarSymbol* member = VarGet($3);
                  if(member == NULL || (strncmp($1, member->stackframe, strlen($1)) == 0) ) { //daca apartine structului sau nu
                        fprintf(stderr, "No such ud variable %s has no member %s, line: %d", $1, $3, yylineno); 
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
                        fprintf(stderr, "No such ud variable exists: %s, line: %d", $1, yylineno); 
                        exit(1);
                  }
                  char buff[64];
                  sprintf(buff, "%.*s", (int)(strchr(var->typename,']') - strchr(var->typename,'[') - 1), strchr(var->typename,'[') + 1);
                  if( atoi($3) >= atoi(buff) ) {
                        fprintf(stderr, "Cannot acces element %s of %s:%s | line: %d", $3, var->name,var->typename, yylineno); 
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