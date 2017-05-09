scanner : main.c lex.yy.c minic.h
	gcc main.c lex.yy.c -lfl -o scanner

lex.yy.c : minic.l
	flex --yylineno minic.l

clean :
	rm -f scanner lex.yy.c

run : scanner prueba.mc
	./scanner prueba.mc