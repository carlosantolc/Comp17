program					: 	func id ( ) { declarations statement_list }
						;

declarations			: 	declarations var identifier_list;
						|	declarations let identifier_list;
						| 	declarations float identifier_list_float;
						|	declarations boolean identifier_list_boolean;
						;

identifier_list 		: 	asig
						|	identifier_list , asig
						;

asig					:	asig
						|	id = expression
						;

identifier_list_float	:	asig_float
						|	identifier_list_float , asig_float
						;

asig_float				:	id
						|	id = expression_float
						;

identifier_list_boolean	:	asig_boolean
						|	identifier_list_boolean , asig_boolean
						;

asig_boolean			:	id
						|	id = expression_boolean
						;

statement_list			:	statement_list statement
						|	λ
						;

statement 				:	id = expression ;
						|	id = expression_float ;
						|	id = expression_boolean ;
						|	{ statement_list }
						|	if ( expression_comparacion ) statement else statement
						|	if ( expression_comparacion ) statement
						|	while ( expression_comparacion ) statement
						|	print print_list ;
						|	read read_list ;
						;

print_list				:	print_item
						|	print_list , print_item
						;

print_item				:	expression
						|	expression_float
						|	expression_boolean
						;

read_list				:	id
						|	read_list , id
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
						|	expression_comparacion AND expression_comparacion { printf("expr_comp -> expr_comp && expr_comp\n"); }
						|	expression_comparacion OR expression_comparacion { printf("expr_comp -> expr_comp || expr_comp\n"); }
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

expression_boolean		:	TRUE { printf("expr_bool -> true\n"); $$ = 1}	
						|	FALSE { printf("expr_bool -> false\n"); $$ = 0}
						|	ID { printf("expr_bool -> ID(%s)\n",$1); $$ = consultarVar(lVar,$1); }					
						;