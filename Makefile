parse:
	yacc -d LZ.y	

lex:
	flex LZ.l

LZ: parse lex
	gcc lex.yy.c y.tab.c -o LZ
