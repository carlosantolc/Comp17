#include <stdio.h>
#include <stdlib.h>
#include "lista.h"
extern FILE *yyin;
extern int yyparse();
extern int yydebug;
extern lista lVar;

int main(int argc, char **argv) {
	if (argc != 2) {
		printf("Uso: %s fichero\n", argv[0]);
		exit(1);
	}
	yyin = fopen(argv[1],"r");
	if (yyin == NULL) {
		printf("Error, no se puede abrir %s\n", argv[1]);
		exit(2);
	}
	//Analizador sintáctico
	yydebug = 0;
	lVar = crearLista();
	yyparse();
	borrarLista(lVar);
	fclose(yyin);
}