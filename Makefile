LZ: folders lex yac
	gcc temp/lex.yy.c temp/y.tab.c src/symboltable.c -I src/ -o build/LZ

clean: 
	rm -rf build/ temp/ Functions.txt Vars.txt proiect.zip

example: LZ
	./build/LZ ./tests/units/.example.lz

test: LZ
	./test.sh

update: LZ
	./test.sh update

zip:
	zip proiect.zip src/ examples/ Makefile 

folders:
	-mkdir build 2> /dev/null
	-mkdir temp 2> /dev/null

yac:
	yacc -d src/LZ.y 
	mv y.tab.* temp/

lex:
	flex src/LZ.l
	mv lex.yy.c temp/

