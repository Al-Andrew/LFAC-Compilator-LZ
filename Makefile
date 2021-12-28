LZ: folders lex yac
	gcc temp/lex.yy.c temp/y.tab.c -o build/LZ

clean: 
	rm -rf build/ temp/

folders:
	-mkdir build 2> /dev/null
	-mkdir temp 2> /dev/null

yac:
	yacc -d src/LZ.y 
	mv y.tab.* temp/

lex:
	flex src/LZ.l
	mv lex.yy.c temp/

