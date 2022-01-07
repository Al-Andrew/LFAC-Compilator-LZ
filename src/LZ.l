%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap

%%

"Int"|"Float"|"Char"|"String"|"Bool" { yylval.id = strdup(yytext); return TK_TYPE;}

"Struct" {return TK_KEYWORD_STRUCT;}
"Func" {return TK_KEYWORD_FUNC;}

"Var" {return TK_KEYWORD_VAR;}
"Const" {return TK_KEYWORD_CONST;}

"While" {return TK_KEYWORD_WHILE;}
"If" {return TK_KEYWORD_IF;}
"Else" {return TK_KEYWORD_ELSE;}

"BEGIN_GLOBAL" {return TK_BEGIN_GLOBAL;}
"END_GLOBAL" {return TK_END_GLOBAL;}

"BEGIN_DEFINITIONS" {return TK_BEGIN_DEFINITIONS;}
"END_DEFINITIONS" {return TK_END_DEFINITIONS;}

"BEGIN_MAIN" {return TK_BEGIN_MAIN;}
"END_MAIN" {return TK_END_MAIN;}

"BEGIN" {return TK_BEGIN;}
"END"  {return TK_END;}

"->" {return TK_ARROW;}
"&&" {return TK_OP_AND;}
"||" {return TK_OP_OR;}
"==" {return TK_OP_EQ;}
"!=" {return TK_OP_NEQ;}
">=" {return TK_OP_GE;}
"<=" {return TK_OP_LE;}


#[_a-zA-Z][_a-zA-Z0-9]* { yylval.id = strdup(yytext);  return TK_IDENTIFIER;}
$[_a-zA-Z][_a-zA-Z0-9]* { yylval.id = strdup(yytext); return TK_TYPEIDENTIFIER;}

"-"?[0-9]+              {yylval.id = strdup(yytext); return TK_LITERAL_INT;}
"-"?[0-9]+.[0-9]+       {yylval.id = strdup(yytext); return TK_LITERAL_FLOAT;}
"True"|"False"          {yylval.id = strdup(yytext); return TK_LITERAL_BOOL;}
\'.\'                   {yylval.id = strdup(yytext); return TK_LITERAL_CHAR;}
\".+\"                  {yylval.id = strdup(yytext); return TK_LITERAL_STRING;}

[ \t] ;
\n {yylineno++;}
"//".*$ {;}
. {return yytext[0];}

%%