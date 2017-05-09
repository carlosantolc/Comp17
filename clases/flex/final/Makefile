scanner : lex.yy.c final.h
	gcc lex.yy.c -lfl -o scanner

lex.yy.c : final.l
	flex --yylineno final.l

clean :
	rm -f scanner lex.yy.c

run :
	./scanner < entrada.txt