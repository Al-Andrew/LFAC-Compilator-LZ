%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%

"Int"|"Float"|"Char"|"String"|"Bool" {return TK_TYPE;}

"Func" {return TK_FUNC;}
"Return" {return TK_RETURN;}

"BEGIN_GLOBAL" {return TK_BEGIN_GLOBAL;}
"END_GLOBAL" {return TK_END_GLOBAL;}

"BEGIN_DEFINITIONS" {return TK_BEGIN_DEFINITIONS;}
"END_DEFINITIONS" {return TK_END_DEFINITIONS;}

"BEGIN" {return TK_BEGIN;}
"END"  {return TK_END;}

"While" {return TK_WHILE;}
"If" {return TK_IF;}
"Else" {return TK_ELSE;}

"Var" {return TK_DECLARITON;}
"Const" {return TK_CONST_DECLARATION;}

#[_a-zA-Z][_a-zA-Z0-9]* {return TK_IDENTIFIER;}
"=" {return TK_EGAL;}
"+" {return TK_PLUS;}
"-" {return TK_MINUS;}
"==" {return TK_2EGAL;}
"&&" {retrun TK_AND;}

"-"?[0-9]+ {return TK_INT_LITERAL;}
"-"?[0-9]+.[0-9]+ {return TK_FLOAT_LITERAL;}
"True"|"False" {return TK_BOOL_LITERAL;}

\'.\' {return TK_CHAR_LITERAL;}
\".+\" {return TK_STRING_LITERAL;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

