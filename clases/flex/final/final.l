%{
#include <stdio.h>
#include "final.h"
%}

L					[a-zA-Z]
D					[0-9]

%x comentario

%%

main						{ printf("MAIN\n"); return MAIN; }
print						{ printf("PRINT\n"); return PRINT; }
({L}|_|$)({L}|_|$|{D})*		{ printf("ID\n"); return ID; }
{D}+						{ printf("NUM %s\n", yytext); return NUM; }
"("							{ printf("PARI\n"); return PARI; }
")"							{ printf("PARD\n"); return PARD; }
"="							{ printf("ASIGN\n"); return ASIGN; }
";"							{ printf("PYC\n"); return PYC; }
"+"							{ printf("PLUSOP\n"); return PLUSOP; }
"-"							{ printf("MINUSOP\n"); return MINUSOP; }
","							{ printf("COMMA\n"); return COMMA; }
"{"							{ printf("LLAVEI\n"); return LLAVEI; }
"}"							{ printf("LLAVED\n"); return LLAVED; }

"//"						{ BEGIN(comentario); }
<comentario>"\n"			{ BEGIN(INITIAL); }
<comentario>[^\n]			{ }

[ \t\n\r]+					{ /* Ignorar */ }
.							{ /* Error léxico */ printf("Error léxico (línea %d): %s\n",yylineno,yytext); }
