minic : minic.tab.c lex.yy.c main.c lista.c lista.h
	gcc minic.tab.c lex.yy.c main.c lista.c -lfl -lm -o minic

minic.tab.c minic.tab.h	: minic.y
	bison -d -t -v minic.y

lex.yy.c : minic.l minic.tab.h
	flex --yylineno minic.l

run : prueba.mc minic
	./minic prueba.mc

clean :
	rm -f minic.tab.* minic.output lex.yy.c minic