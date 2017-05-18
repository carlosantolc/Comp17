%{
#include <stdio.h>
#include <math.h>
#include "lista.h"
extern int yylex();
int yyerror(const char* msg);
extern int yylineno;
lista lVar;
#define TYPE_INT 0
#define TYPE_FLOAT 1
#define TYPE_BOOLEAN 2
#define TYPE_ERROR 3
char *tipos[4] = {"entero","float","boolean","error"};
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
%nonassoc NOT
%locations
%define parse.error verbose
%%

program					: 	FUNC ID PARI PARD LLAVEI declarations statement_list LLAVED { printf("program -> func id ( ) {declarations statement_list }\n"); }
						;

declarations			: 	declarations VAR identifier_list PYC { printf("declarations -> declarations var identifier_list ;\n"); }
						|	declarations LET identifier_list PYC { printf("declarations -> declarations let identifier_list ;\n"); }
						| 	declarations FLOAT identifier_list_float PYC { printf("declarations -> declarations float identifier_list_float ;\n"); }
						|	/* lambda */
						;

identifier_list 		: 	asig { printf("identifier_list -> asig\n"); }
						|	identifier_list COMMA asig { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig					:	ID { printf("asig -> ID\n"); }
						|	ID ASIGN expression { printf("asig -> ID = expression(%s)\n",tipos[0]); insertarVar(&lVar,$1,$3,0); }
						;

identifier_list_float	:	asig_float { printf("identifier_list_float -> asig_float\n"); }
						|	identifier_list_float COMMA asig_float { printf("identifier_list_float -> identifier_list_float , asig_float\n"); }
						;

asig_float				:	ID { printf("asig_float -> ID\n"); }
						|	ID ASIGN expression { printf("asig_float -> ID = expression(%s)\n",tipos[1]); insertarVar(&lVar,$1,$3,1); }
						;

statement_list			:	statement_list statement { printf("statement_list -> statement_list statement\n"); }
						|	/* lambda */ { printf("statement_list -> lambda\n"); }
						;

statement 				:	ID ASIGN expression PYC { printf("statement -> ID = expression\n"); }
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

read_list				:	ID { printf("read_list -> ID(%s)\n",$1); }
						|	read_list COMMA ID { printf("read_list -> read_list , ID(%s)\n",$3); }
						;

expression_comparacion	:	expression LESS expression { 
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}
								printf("expr_comp(%s) -> expr(%s) < expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression GREATER expression { 
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}
								printf("expr_comp(%s) -> expr(%s) > expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression LESSEQ expression {
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}
								printf("expr_comp(%s) -> expr(%s) <= expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression GREATEREQ expression {
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}
								printf("expr_comp(%s) -> expr(%s) >= expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression NOTEQ expression { 
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}
								printf("expr_comp(%s) -> expr(%s) != expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression EQ expression {
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}
								printf("expr_comp(%s) -> expr(%s) == expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);}
						|	NOT expression_comparacion { $$ = $2; printf("expr_comp(%s) -> !expr_comp(%s)\n",tipos[$$],tipos[$2]); }
						|	PARI expression_comparacion PARD AND PARI expression_comparacion PARD {
								if ($2 != $6) {
									$$ = 3;
								} else { $$ = $2; }
								printf("expr_comp(%s) -> (expr_comp(%s)) && (expr_comp(%s))\n",tipos[$$],tipos[$2],tipos[$6]); }
						|	PARI expression_comparacion PARD OR PARI expression_comparacion PARD {
								if ($2 != $6) {
									$$ = 3;
								} else { $$ = $2; }
								printf("expr_comp(%s) -> (expr_comp(%s)) || (expr_comp(%s))\n",tipos[$$],tipos[$2],tipos[$6]); }
						|	TRUE  { $$ = 2; printf("expr_comp(%s) -> TRUE\n", tipos[$$]); }
						|	FALSE { $$ = 2; printf("expr_comp(%s) -> FALSE\n", tipos[$$]); }
						;

expression 				:	expression PLUSOP expression {
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = $1;}
							 	printf("expr(%s) -> expr(%s) + expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression MINUSOP expression { 
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = $1;}
								printf("expr(%s) -> expr(%s) - expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression MULTOP expression {
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = $1;}
							 	printf("expr(%s) -> expr(%s) * expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	expression DIVOP expression {
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = $1;}
								printf("expr(%s) -> expr(%s) / expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]); }
						|	MINUSOP expression %prec UMENOS { $$ = $2; printf("expr(%s) -> -expr(%s)\n",tipos[$$],tipos[$2]); }
						|	PARI expression PARD { $$ = $2; printf("expr(%s) -> (expr(%s))\n",tipos[$$],tipos[$2]); }
						|	ID { $$ = consultarVar(lVar,$1); printf("expr(%s) -> ID(%s)\n",tipos[$$],$1); }
						|	NUM { $$ = 0; printf("expr(%s) -> NUM = %d\n",tipos[$$],$1); }
						|	DECIMAL { $$ = 1; printf("expr(%s) -> DECIMAL = %f\n",tipos[$$],$1); } 
						;

%%
/* Rutinas C*/
int yyerror(const char *msg) {	
	fprintf(stderr,"%s %d\n",msg,yylineno);	
}