%{
#include <stdio.h>
#include <math.h>
#include "lista.h"
extern int yylex();
int yyerror(const char* msg);
extern int yylineno;
lista lVar;
%}

%union {
	int num;
	char *str;
}

%token MAS MENOS MULT DIV PARI PARD PYC POTENCIA EQUAL
%token<num> ENT
%token<str> ID
%type<num> expr asig entrada

/* Precedencias y asociatividad de operadores */
/* left, right, nonassoc */
%left MAS MENOS
%left MULT DIV
%left POTENCIA
%nonassoc UMENOS
%locations
%%

entrada	: entrada contador asig PYC {
	printf("entrada->entrada asig (%d);\n",$3); $$ = $1+1;
	}
		| /* lambda */ { $$ = 1; printf("entrada->lambda\n"); } 
		| error PYC { printf("Error detectado en %d:%d-%d:%d\n",@1.first_line,@1.first_column,@1.last_line,@1.last_column); }		
		;

contador	: /* lambda */ { printf("Operacion %d\n",$<num>0); }
			;

asig	: ID EQUAL expr { printf("asig -> ID(%d) = expr\n",$3); insertarVar(&lVar,$1,$3); $$ = $3; }
		| expr { printf("asig->expr\n"); $$ = $1; }
		;

expr 	: expr MAS expr { printf("expr -> expr + expr\n"); $$ = $1+$3; }
		| expr MENOS expr { printf("expr -> expr - expr\n"); $$ = $1-$3; }
		| expr MULT expr { printf("expr -> expr * expr\n"); $$ = $1*$3; }
		| expr DIV expr { printf("expr -> expr / expr\n"); $$ = $1/$3; }
		| expr POTENCIA expr { printf("expr -> expr ^ expr\n"); $$ = pow ($1, $3); }
		| PARI expr PARD { printf("expr -> (E)\n"); $$ = $2; }
		| ENT { printf("expr -> ENT = %d\n",$1); $$ = $1; }
		| MENOS expr %prec UMENOS { printf("expr -> -expr\n"); $$ = -$2; }
		| ID { printf("expr -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }
		;


%%
/* Rutinas C*/
int yyerror(const char *msg) {	
	fprintf(stderr,"%s\n",msg);	
}