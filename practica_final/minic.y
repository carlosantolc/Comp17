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
	//int type;
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
						//|	declarations BOOL identifier_list_boolean PYC { printf("declarations -> declarations boolean identifier_list_boolean ;\n"); }
						|	/* lambda */
						;

identifier_list 		: 	asig { printf("identifier_list -> asig\n"); }
						|	identifier_list COMMA asig { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig					:	ID { printf("asig -> ID\n"); }
						|	ID ASIGN expression { printf("asig -> ID = expression\n"); insertarVar(&lVar,$1,$3,0); }
						;

identifier_list_float	:	asig_float { printf("identifier_list_float -> asig_float\n"); }
						|	identifier_list_float COMMA asig_float { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig_float				:	ID { printf("asig_float -> ID\n"); }
						|	ID ASIGN expression { printf("asig_float -> ID = expression\n"); insertarVar(&lVar,$1,$3,1); }
						;

statement_list			:	statement_list statement { printf("statement_list -> statement_list statement\n"); }
						|	/* lambda */ { printf("statement_list -> lambda\n"); }
						;

statement 				:	ID ASIGN expression PYC { printf("statement -> ID = expression\n"); }
						//|	ID ASIGN expression_float PYC { printf("statement -> ID = expression_float\n"); }
						//|	ID ASIGN expression_boolean PYC { printf("statement -> ID = expression_boolean\n"); }
						|	LLAVEI statement_list LLAVED { printf("statement -> {statement_list}\n"); }
						|	IF PARI expression_comparacion PARD statement ELSE statement { printf("statement -> if (expression_comparacion(%s)) statement else statement\n",tipos[$3]); }
						|	IF PARI expression_comparacion PARD statement %prec NOELSE { printf("statement -> if (expression_comparacion(%s)) statement\n",tipos[$3]); }
						|	WHILE PARI expression_comparacion PARD statement { printf("statement -> while (expression_comparacion) statement\n"); }
						|	PRINT print_list PYC { printf("statement -> print print_list\n"); }
						|	READ read_list PYC { printf("statement -> read read_list\n"); }
						;

print_list				:	print_item { printf("print_list -> print_item\n"); }
						|	print_list COMMA print_item { printf("print_list -> print_list , print_item\n"); }
						;

print_item				:	expression { printf("print_item -> expression(%s)\n",tipos[$1]); }
						//|	expression_float { printf("print_item -> expression_float\n"); }
						//|	expression_boolean { printf("print_item -> expression_boolean\n"); }
						|   STRING { printf("print_item -> STRING(%s)\n",$1); }
						;

read_list				:	ID { printf("read_list -> ID(%s)\n",$1); }
						|	read_list COMMA ID { printf("read_list -> read_list , ID(%s)\n",$3); }
						;

expression_comparacion	:	expression LESS expression { printf("expr_comp(%s) -> expr(%s) < expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}}
						|	expression GREATER expression { printf("expr_comp(%s) -> expr(%s) > expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}}
						|	expression LESSEQ expression { printf("expr_comp(%s) -> expr(%s) <= expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}}
						|	expression GREATEREQ expression { printf("expr_comp(%s) -> expr(%s) >= expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}}
						|	expression NOTEQ expression { printf("expr_comp(%s) -> expr(%s) != expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}}
						|	expression EQ expression { printf("expr_comp(%s) -> expr(%s) == expr(%s)\n",tipos[$$],tipos[$1],tipos[$3]);
								if ($1 != $3) {
									$$ = 3;
								} else { $$ = 2;}}
						/*|	expression_float LESS expression_float { printf("expr_comp -> expr_float < expr_float\n"); }
						|	expression_float GREATER expression_float { printf("expr_comp -> expr_float > expr_float\n"); }
						|	expression_float LESSEQ expression_float { printf("expr_comp -> expr_float <= expr_float\n"); }
						|	expression_float GREATEREQ expression_float { printf("expr_comp -> expr_float >= expr_float\n"); }
						|	expression_float NOTEQ expression_float { printf("expr_comp -> expr_float != expr_float\n"); }
						|	expression_float EQ expression_float { printf("expr_comp -> expr_float == expr_float\n"); }*/
						//|	expression_boolean { printf("expr_comp -> expr_expr_bool\n"); }
						|	NOT expression_comparacion { printf("expr_comp -> !expr_comp\n"); $$ = $2; }
						|	PARI expression_comparacion PARD AND PARI expression_comparacion PARD { printf("expr_comp -> expr_comp && expr_comp\n");
								if ($2 != $6) {
									$$ = 3;
								} else { $$ = $2;}}
						|	PARI expression_comparacion PARD OR PARI expression_comparacion PARD { printf("expr_comp -> expr_comp || expr_comp\n");
								if ($2 != $6) {
									$$ = 3;
								} else { $$ = $2;}}
						|	TRUE  { printf("expr_comp -> TRUE\n"); $$ = 2; }
						|	FALSE { printf("expr_comp -> FALSE\n"); $$ = 2; }
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
						|	MINUSOP expression %prec UMENOS { printf("expr -> -expr\n"); $$ = $2; }
						|	PARI expression PARD { $$ = $2; printf("expr(%s) -> (expr(%s))\n",tipos[$$],tipos[$2]); }
						|	ID { printf("expr -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }
						|	NUM { $$ = 0; printf("expr(%s) -> NUM = %d\n",tipos[$$],$1); }
						|	DECIMAL { $$ = 1; printf("expr(%s) -> DECIMAL = %f\n",tipos[$$],$1); } 
						;

/*expression_float		:	expression_float PLUSOP expression_float { printf("expr_float -> expr_float + expr_float\n"); }
						|	expression_float MINUSOP expression_float { printf("expr_float -> expr_float - expr_float\n"); }
						|	expression_float MULTOP expression_float { printf("expr_float -> expr_float * expr_float\n"); }
						|	expression_float DIVOP expression_float { printf("expr_float -> expr_float / expr_float\n"); }
						|	MINUSOP expression_float %prec UMENOS { printf("expr_float -> -expr_float\n"); }
						|	PARI expression_float PARD { printf("expr_float -> (expr_float)\n"); }
						|	ID { printf("expr_float -> ID(%s)\n",$1); }
						|	DECIMAL { printf("expr_float -> DECIMAL = %f\n",$1); }*/
						;

/*expression_boolean		:	TRUE { printf("expr_bool -> true\n"); $$ = 1; }	
						|	FALSE { printf("expr_bool -> false\n"); $$ = 0; }
						//|	ID { printf("expr_bool -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }					
						;*/

%%
/* Rutinas C*/
int yyerror(const char *msg) {	
	fprintf(stderr,"%s %d\n",msg,yylineno);	
}