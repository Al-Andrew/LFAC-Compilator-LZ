%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}

%token TK_TYPE TK_FUNC TK_IDENTIFIER TK_DECLARATION TK_CONST_DECLARATION 
%token TK_BEGIN_GLOBAL TK_END_GLOBAL TK_BEGIN_DEFINITIONS TK_END_DEFINITIONS TK_BEGIN TK_END
%token TK_PLUS TK_MINUS TK_AND TK_2EGAL TK_EGAL
%token TK_INT_LITERAL TK_FLOAT_LITERAL TK_BOOL_LITERAL TK_CHAR_LITERAL TK_STRING_LITERAL
%token TK_WHILE TK_IF

%start program
%%
progr: globals definitions main { printf("program corect sintactic\n"); }
        ;

globals: TK_BEGIN_GLOBAL globals_list TK_END_GLOBAL
	   ;
       
globals_list: declaratie ';' globals_list 
            | declaratie ';'
            ;

declaratie: TK_DECLARATION TK_TYPE TK_IDENTIFIER {/*adauga TK_IDENTIFIER in lista de variabile?*/;} 
            TK_CONST_DECLARATION TK_TYPE TK_IDENTIFIER {/*adauga identifier in lista de constante*/;}
           ;

definitions: TK_BEGIN_DEFINITIONS definitions_list TK_END_DEFINITIONS
            ;

definitions_list:  func_definition ';' definitions_list
                | func_definition
                ;

func_definition: TK_FUNC TK_IDENTIFIER '(' param_list ')' "->" TK_TYPE statement_block {/*adaugam functia la lista de functii*/;}
            ;

param_list: param 
            | param_list ','  param 
            ;
            
param: TK_TYPE TK_IDENTIFIER
      ;
      

statement_block: TK_BEGIN statement_list TK_END  
                ;

statement_list:  statement ';' 
                | statement_list statement ';' 
                ;

statement: TK_IDENTIFIER TK_EGAL expression
         | expression
         ;
        
lista_apel : NR
           | lista_apel ',' NR
           ;


%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 