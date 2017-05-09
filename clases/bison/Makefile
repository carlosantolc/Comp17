calculadora : calculadora.tab.c lex.yy.c main.c lista.c lista.h
	gcc calculadora.tab.c lex.yy.c main.c lista.c -lfl -lm -o calculadora

calculadora.tab.c calculadora.tab.h	: calculadora.y
	bison -d -t -v calculadora.y

lex.yy.c : calculadora.l calculadora.tab.h
	flex --yylineno calculadora.l

run : prueba.txt calculadora
	./calculadora prueba.txt

clean :
	rm -f calculadora.tab.* lex.yy.c calculadora