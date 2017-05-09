scanner : main.c lex.yy.c stl.h
	gcc main.c lex.yy.c -lfl -o scanner

lex.yy.c : stl.l
	flex --yylineno stl.l

clean :
	rm -f scanner lex.yy.c

run : scanner prueba.txt
	./scanner prueba.txt
