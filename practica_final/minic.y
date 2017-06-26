%{
#include <stdio.h>
#include <math.h>
#include "lista.h"
extern int yylex();
int yyerror(const char* msg);
extern int yylineno;
lista lVar;
#define TYPE_INT_VAR 0
#define TYPE_INT_LET 1
#define TYPE_FLOAT 2
#define TYPE_BOOLEAN 3
#define TYPE_ERROR 4
char *tipos[5] = {"entero_var","entero_let","float","boolean","error"};
%}

%union {
	int type;
	int num;
	float dec;
	char *str;
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ PYC COMMA PLUSOP MINUSOP MULTOP DIVOP ASIGN PARI PARD LLAVEI LLAVED BOOL TRUE FALSE FLOAT LESS LESSEQ GREATER GREATEREQ EQ NOTEQ AND OR NOT
%token<num> NUM
%token<str> ID
%token<str> STRING
%token<dec> DECIMAL
%type<type> expression expression_comparacion

/* Precedencias y asociatividad de operadores */
/* left, right, nonassoc */
%left PLUSOP MINUSOP
%left MULTOP DIVOP
%nonassoc UMENOS
%nonassoc NOELSE
%nonassoc ELSE
%left PARI PARD
%left AND OR
%nonassoc NOT
%locations
%define parse.error verbose
%%

program					: 	FUNC ID PARI PARD LLAVEI declarations statement_list LLAVED { printf("program -> func id ( ) {declarations statement_list }\n"); }
						;

declarations			: 	declarations VAR identifier_list_var PYC { printf("declarations -> declarations var identifier_list ;\n"); }
						|	declarations LET identifier_list_let PYC { printf("declarations -> declarations let identifier_list ;\n"); }
						| 	declarations FLOAT identifier_list_float PYC { printf("declarations -> declarations float identifier_list_float ;\n"); }
						|	/* lambda */
						;

identifier_list_var		: 	asig_var { printf("identifier_list -> asig\n"); }
						|	identifier_list_var COMMA asig_var { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig_var				:	ID { printf("asig -> ID\n"); insertarVar(&lVar,$1,0,0); }
						|	ID ASIGN expression { printf("asig -> ID = expression(%s)\n",tipos[0]); insertarVar(&lVar,$1,$3,0); }
						;

identifier_list_let		: 	asig_let { printf("identifier_list -> asig\n"); }
						|	identifier_list_let COMMA asig_let { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig_let				:	ID { printf("asig -> ID\n"); insertarVar(&lVar,$1,0,1); }
						|	ID ASIGN expression { printf("asig -> ID = expression(%s)\n",tipos[0]); insertarVar(&lVar,$1,$3,1); }
						;

identifier_list_float	:	asig_float { printf("identifier_list_float -> asig_float\n"); }
						|	identifier_list_float COMMA asig_float { printf("identifier_list_float -> identifier_list_float , asig_float\n"); }
						;

asig_float				:	ID { printf("asig_float -> ID\n"); insertarVar(&lVar,$1,0.0,2); }
						|	ID ASIGN expression { printf("asig_float -> ID = expression(%s)\n",tipos[1]); insertarVar(&lVar,$1,$3,2); }
						;

statement_list			:	statement_list statement { printf("statement_list -> statement_list statement\n"); }
						|	/* lambda */ { printf("statement_list -> lambda\n"); }
						;

statement 				:	ID ASIGN expression PYC {
								if (consultarVar(lVar,$1) == -1) {
									printf("statement -> ID(%s) = expression | ERROR -> ID NO DECLARADO\n",$1);
								} else if (consultarVar(lVar,$1) == 1) {
									printf("statement -> ID(%s) = expression | ERROR -> ID NO VARIABLE\n",$1);
								} else {
									printf("statement -> ID(%s) = expression\n",$1); }
								}
						|	LLAVEI statement_list LLAVED { printf("statement -> {statement_list}\n"); }
						|	IF PARI expression_comparacion PARD statement ELSE statement { printf("statement -> if (expression_comparacion(%s)) statement else statement\n",tipos[$3]); }
						|	IF PARI expression_comparacion PARD statement %prec NOELSE { printf("statement -> if (expression_comparacion(%s)) statement\n",tipos[$3]); }
						|	WHILE PARI expression_comparacion PARD statement { printf("statement -> while (expression_comparacion(%s)) statement\n",tipos[$3]); }
						|	PRINT print_list PYC { printf("statement -> print print_list\n"); }
						|	READ read_list PYC { printf("statement -> read read_list\n"); }
						;

print_list				:	print_item { printf("print_list -> print_item\n"); }
						|	print_list COMMA print_item { printf("print_list -> print_list , print_item\n"); }
						;

print_item				:	expression { printf("print_item -> expression(%s)\n",tipos[$1]); }
						|   STRING { printf("print_item -> STRING(%s)\n",$1); }
						;

read_list				:	ID {
								if (consultarVar(lVar,$1) == -1) {
									printf("read_list -> ID(%s) | ERROR -> ID NO DECLARADO EN LINEA %d\n",$1,yylineno);
								} else if (consultarVar(lVar,$1) == 1) {
									printf("read_list -> ID(%s) | ERROR -> ID NO VARIABLE EN LINEA %d\n",$1,yylineno);
								} else {
									printf("read_list -> ID(%s)\n",$1); }
								}
						|	read_list COMMA ID { printf("read_list -> read_list , ID(%s)\n",$3); }
						;

expression_comparacion	:	expression LESS expression { 
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = 3;}
								printf("expr_comp(%s) -> expr(%s) < expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression GREATER expression { 
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = 3;}
								printf("expr_comp(%s) -> expr(%s) > expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression LESSEQ expression {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = 3;}
								printf("expr_comp(%s) -> expr(%s) <= expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression GREATEREQ expression {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = 3;}
								printf("expr_comp(%s) -> expr(%s) >= expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression NOTEQ expression { 
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = 3;}
								printf("expr_comp(%s) -> expr(%s) != expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression EQ expression {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = 3;}
								printf("expr_comp(%s) -> expr(%s) == expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);}
						|	NOT expression_comparacion { $$ = $2; printf("expr_comp(%s) -> !expr_comp(%s)\n",tipos[$$],tipos[$2]); }
						|	expression_comparacion AND expression_comparacion {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = $1; }
								printf("expr_comp(%s) -> expr_comp(%s) && expr_comp(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression_comparacion OR expression_comparacion {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = $1; }
								printf("expr_comp(%s) -> expr_comp(%s) || expr_comp(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	PARI expression_comparacion PARD { $$ = $2; printf("expr_comp(%s) -> (expr_comp(%s))\n",tipos[$$],tipos[$2]); }
						|	TRUE  { $$ = 3; printf("expr_comp(%s) -> TRUE\n", tipos[$$]); }
						|	FALSE { $$ = 3; printf("expr_comp(%s) -> FALSE\n", tipos[$$]); }
						;

expression 				:	expression PLUSOP expression {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = $1;}
							 	printf("expr(%s) -> expr(%s) + expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression MINUSOP expression { 
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = $1;}
								printf("expr(%s) -> expr(%s) - expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression MULTOP expression {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = $1;}
							 	printf("expr(%s) -> expr(%s) * expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression DIVOP expression {
								if ($1 != $3) {
									$$ = 4;
								} else { $$ = $1;}
								printf("expr(%s) -> expr(%s) / expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	MINUSOP expression %prec UMENOS { $$ = $2; printf("expr(%s) -> -expr(%s)\n",tipos[$$],tipos[$2]); }
						|	PARI expression PARD { $$ = $2; printf("expr(%s) -> (expr(%s))\n",tipos[$$],tipos[$2]); }
						|	ID {
								$$ = consultarVar(lVar,$1);
								if ($$ == -1) {
									$$ = 4;
									printf("expr(%s) -> ID(%s) ERROR -> ID NO DECLARADO\n",tipos[$$],$1);
								} else {
									printf("expr(%s) -> ID(%s)\n",tipos[$$],$1); }
								}
						|	NUM { $$ = 0; printf("expr(%s) -> NUM = %d\n",tipos[$$],$1); }
						|	DECIMAL { $$ = 2; printf("expr(%s) -> DECIMAL = %f\n",tipos[$$],$1); } 
						;

%%
/* Rutinas C*/
int yyerror(const char *msg) {	
	fprintf(stderr,"%s %d\n",msg,yylineno);	
}