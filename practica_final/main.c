/* Programa principal del analizador léxico */
#include "lista.h"
#include <stdio.h>
#include <stdlib.h>

// Función que iplementa lex.yy.c
extern FILE *yyin;
extern int yyparse();
extern int yydebug;
extern lista lVar;
extern int yylex();
extern char *yytext;
extern int yyleng;

int main(int argc, char *argv[]) {
	// Comrpbar que el parámetro con el nombre del fichero se ha especificado
	if (argc !=2) {
		printf("Uso: %s fichero\n",argv[0]);
		exit(1);
	}
	yyin = fopen(argv[1],"r");
	if (yyin == NULL) {
		printf("El archivo %s no se puede abrir \n",argv[1]);
		exit(2);
	}
	//Analizador sintáctico
	yydebug = 0;
	lVar = crearLista();
	yyparse();
	borrarLista(lVar);
	fclose(yyin);

}