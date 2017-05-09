%{
#include "calculadora.tab.h"
#include <stdio.h>
#include <string.h>
%}


D		[0-9]

%%
"+"			return MAS;
"-"			return MENOS;
"*"			return MULT;
"/"			return DIV;
{D}+		{ yylval.num = atoi(yytext); return ENT; }
";"			return PYC;
"("			return PARI;
")"			return PARD;
"^"			return POTENCIA;
"="			return EQUAL;
[a-zA-Z_][a-zA-Z_0-9]*	{ yylval.str = strdup(yytext); return ID; }


[ \t\n\r]+	;
.			{ printf("Error léxico en línea %d: %s\n",yylineno,yytext); }
