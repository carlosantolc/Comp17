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
	float dec;
	char *str;
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ STRING PYC COMMA PLUSOP MINUSOP MULTOP DIVOP ASIGN PARI PARD LLAVEI LLAVED BOOL TRUE FALSE FLOAT LESS LESSEQ GREATER GREATEREQ EQ NOTEQ AND OR NOT
%token<num> NUM
%token<str> ID
%token<dec> DECIMAL
%type<num> expression_boolean expression_float expression read_list print_item print_list
//%type<num> expression_boolean expression_float expression expression_comparacion identifier_list_float asig_float identifier_list_boolean asig_boolean statement_list statement print_list print_item read_list asig identifier_list declarations program

/* Precedencias y asociatividad de operadores */
/* left, right, nonassoc */
%left PLUSOP MINUSOP
%left MULTOP DIVOP
%nonassoc UMENOS
%locations
%%

program					: 	FUNC ID PARI PARD LLAVEI declarations statement_list LLAVED { printf("program -> func id ( ) {declarations statement_list }\n"); }
						;

declarations			: 	declarations VAR identifier_list PYC { printf("declarations -> declarations var identifier_list ;\n"); }
						|	declarations LET identifier_list PYC { printf("declarations -> declarations let identifier_list ;\n"); }
						| 	declarations FLOAT identifier_list_float PYC { printf("declarations -> declarations float identifier_list_float ;\n"); }
						|	declarations BOOL identifier_list_boolean PYC { printf("declarations -> declarations boolean identifier_list_boolean ;\n"); }
						|	/* lambda */
						;

identifier_list 		: 	asig { printf("identifier_list -> asig\n"); }
						|	identifier_list COMMA asig { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig					:	ID { printf("asig -> ID\n"); }
						|	ID ASIGN expression { printf("asig -> ID = expression\n"); }
						;

identifier_list_float	:	asig_float { printf("identifier_list_float -> asig_float\n"); }
						|	identifier_list_float COMMA asig_float { printf("identifier_list_float -> identifier_list_boolean , asig_float\n"); }
						;

asig_float				:	ID { printf("asig_float -> ID\n"); }
						|	ID ASIGN expression_float { printf("asig_float -> ID = expression_float\n"); }
						;

identifier_list_boolean	:	asig_boolean { printf("identifier_list_boolean -> asig_boolean\n"); }
						|	identifier_list_boolean COMMA asig_boolean { printf("identifier_list_boolean -> identifier_list_boolean , asig_boolean\n"); }
						;

asig_boolean			:	ID { printf("asig_boolean -> ID\n"); }
						|	ID ASIGN expression_boolean { printf("asig_boolean -> ID = expression_boolean\n"); }
						;

statement_list			:	statement_list statement { printf("statement_list -> statement_list statement\n"); }
						|	/* lambda */ { printf("statement_list -> lambda\n"); }
						;

statement 				:	ID ASIGN expression PYC { printf("statement -> ID = expression\n"); }
						|	ID ASIGN expression_float PYC { printf("statement -> ID = expression_float\n"); }
						|	ID ASIGN expression_boolean PYC { printf("statement -> ID = expression_boolean\n"); }
						|	LLAVEI statement_list LLAVED { printf("statement -> {statement_list}\n"); }
						|	IF PARI expression_comparacion PARD statement ELSE statement { printf("statement -> if (expression_comparacion) statement else statement\n"); }
						|	IF PARI expression_comparacion PARD statement { printf("statement -> if (expression_comparacion) statement\n"); }
						|	WHILE PARI expression_comparacion PARD statement { printf("statement -> while (expression_comparacion) statement\n"); }
						|	PRINT print_list PYC { printf("statement -> print print_list\n"); }
						|	READ read_list PYC { printf("statement -> read read_list\n"); }
						;

print_list				:	print_item { printf("print_list -> print_item\n"); $$ = $1; }
						|	print_list COMMA print_item { printf("print_list -> print_list , print_item\n"); $$ = $1; }
						;

print_item				:	expression { printf("print_item -> expression\n"); $$ = $1; }
						|	expression_float { printf("print_item -> expression_float\n"); $$ = $1; }
						|	expression_boolean { printf("print_item -> expression_boolean\n"); $$ = $1; }
						|   STRING { printf("print_item -> expression_boolean\n"); }
						;

read_list				:	ID { printf("read_list -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }
						|	read_list COMMA ID { printf("read_list -> read_list , ID(%s)\n",$3); $$ = consultarVar(lVar,$3); }
						;

expression_comparacion	:	expression LESS expression { printf("expr_comp -> expr < expr\n"); }
						|	expression GREATER expression { printf("expr_comp -> expr > expr\n"); }
						|	expression LESSEQ expression { printf("expr_comp -> expr <= expr\n"); }
						|	expression GREATEREQ expression { printf("expr_comp -> expr >= expr\n"); }
						|	expression NOTEQ expression { printf("expr_comp -> expr != expr\n"); }
						|	expression EQ expression { printf("expr_comp -> expr == expr\n"); }
						|	expression_float LESS expression_float { printf("expr_comp -> expr_float < expr_float\n"); }
						|	expression_float GREATER expression_float { printf("expr_comp -> expr_float > expr_float\n"); }
						|	expression_float LESSEQ expression_float { printf("expr_comp -> expr_float <= expr_float\n"); }
						|	expression_float GREATEREQ expression_float { printf("expr_comp -> expr_float >= expr_float\n"); }
						|	expression_float NOTEQ expression_float { printf("expr_comp -> expr_float != expr_float\n"); }
						|	expression_float EQ expression_float { printf("expr_comp -> expr_float == expr_float\n"); }
						|	expression_boolean { printf("expr_comp -> expr_expr_bool\n"); }
						|	NOT expression_comparacion { printf("expr_comp -> !expr_comp\n"); }
						|	PARI expression_comparacion PARD AND PARI expression_comparacion PARD { printf("expr_comp -> expr_comp && expr_comp\n"); }
						|	PARI expression_comparacion PARD OR PARI expression_comparacion PARD { printf("expr_comp -> expr_comp || expr_comp\n"); }
						;

expression 				:	expression PLUSOP expression { printf("expr -> expr + expr\n"); $$ = $1+$3; }
						|	expression MINUSOP expression { printf("expr -> expr - expr\n"); $$ = $1-$3; }
						|	expression MULTOP expression { printf("expr -> expr * expr\n"); $$ = $1*$3; }
						|	expression DIVOP expression { printf("expr -> expr / expr\n"); $$ = $1/$3; }
						|	MINUSOP expression %prec UMENOS { printf("expr -> -expr\n"); $$ = -$2; }
						|	PARI expression PARD { printf("expr -> (expr)\n"); $$ = $2; }
						|	ID { printf("expr -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }
						|	NUM { printf("expr -> NUM = %d\n",$1); $$ = $1; }
						;

expression_float		:	expression_float PLUSOP expression_float { printf("expr_float -> expr_float + expr_float\n"); $$ = $1+$3; }
						|	expression_float MINUSOP expression_float { printf("expr_float -> expr_float - expr_float\n"); $$ = $1-$3; }
						|	expression_float MULTOP expression_float { printf("expr_float -> expr_float * expr_float\n"); $$ = $1*$3; }
						|	expression_float DIVOP expression_float { printf("expr_float -> expr_float / expr_float\n"); $$ = $1/$3; }
						|	MINUSOP expression_float %prec UMENOS { printf("expr_float -> -expr_float\n"); $$ = -$2; }
						|	PARI expression_float PARD { printf("expr_float -> (expr_float)\n"); $$ = $2; }
						|	ID { printf("expr_float -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }
						|	DECIMAL { printf("expr_float -> DECIMAL = %f\n",$1); $$ = $1; }
						;

expression_boolean		:	TRUE { printf("expr_bool -> true\n"); $$ = 1; }	
						|	FALSE { printf("expr_bool -> false\n"); $$ = 0; }
						|	ID { printf("expr_bool -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }					
						;

%%
/* Rutinas C*/
int yyerror(const char *msg) {	
	fprintf(stderr,"%s\n",msg);	
}