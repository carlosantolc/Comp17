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
%type<num> fact base term expr

%%

entrada	: expr PYC { printf("entrada -> expr (%d);\n", $1); }
		| expr PYC entrada { printf("entrada -> expr;entrada (%d)\n", $1); }
		| asig PYC { printf("entrada -> asig;\n"); }
		| asig PYC entrada { printf("entrada -> asig; entrada\n"); }
		;

asig	: ID EQUAL expr { printf("asig -> ID(%s) = expr\n",$1); insertarVar(&lVar,$1,$3); }
		;

expr 	: expr MAS term { printf("expr -> expr + term\n"); $$ = $1+$3; }
		| expr MENOS term { printf("expr -> expr - term\n"); $$ = $1-$3; }
		| term { printf("expr -> term\n"); $$ = $1; }
		;

term	: term MULT base { printf("term -> term * base\n"); $$ = $1*$3; }
		| term DIV base { printf("term -> term / base\n"); $$ = $1/$3; }
		| base { printf("term -> base\n"); $$ = $1; }
		;

base 	: base POTENCIA fact { printf("base -> base ^ fact\n"); $$ = pow ($1, $3); }
		| fact { printf("base -> fact\n"); $$ = $1; }
		;

fact	: PARI expr PARD { printf("fact -> (E)\n"); $$ = $2; }
		| ENT { printf("fact -> ENT = %d\n",$1); $$ = $1; }
		| MENOS fact { printf("fact -> -fact\n"); $$ = -$2; }
		| ID { printf("fact -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }
		;


%%
/* Rutinas C*/
int yyerror(const char *msg) {	
	fprintf(stderr,"%s\n",msg);	
}