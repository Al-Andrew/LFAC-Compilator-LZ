LZ: folders lex yac
	gcc temp/lex.yy.c temp/y.tab.c src/symboltable.c -I src/ -o build/LZ

clean: 
	rm -rf build/ temp/ Functions.txt Vars.txt proiect.zip

zip:
	zip proiect.zip src/ examples/ Makefile 

run: LZ
	./build/LZ ./examples/example.lz

folders:
	-mkdir build 2> /dev/null
	-mkdir temp 2> /dev/null

yac:
	yacc -d src/LZ.y 
	mv y.tab.* temp/

lex:
	flex src/LZ.l
	mv lex.yy.c temp/

