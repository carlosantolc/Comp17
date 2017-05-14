%{
#include "minic.tab.h"
#include <stdio.h>
#include "minic.h"

int comienzo_comentario;
%}

L			[a-zA-Z]
D			[0-9]
panico		[^a-zA-Z_0-9\";,+\-*/=(){}<>!&| \t\n\r]
ok			[a-zA-Z_0-9\";,+\-*/=(){}<>! \t\n\r]

%x comentario
%x comentario_multilinea
%x cadena
%x andlogico
%x orlogico

%%

func								return FUNC;
var									return VAR;
let									return LET;
float								return FLOAT;
if									return IF;
else								return ELSE;
while								return WHILE;
print								return PRINT;
read								return READ;
bool								return BOOL;
true								return TRUE;
false								return FALSE;
({L}|_)({L}|_|{D})*					{ if (yyleng > 16) {
										printf("Error: ID con mas de 16 caracteres en línea %d: %s (%lu caracteres)\n",yylineno,yytext,yyleng);
									} else {
										yylval.str = strdup(yytext); return ID;
									} }
{D}+								{ if (atol(yytext) > 2147483648) {
											printf("Error: NUM provoca desbordamiento en línea %d: %s\n",yylineno,yytext);
									} else {
										yylval.num = atoi(yytext); return NUM;
									} }
{D}+\.{D}+							{ yylval.dec = strtof(yytext, NULL); return DECIMAL; }
"<="								return LESSEQ;
">="								return GREATEREQ;
"=="								return EQ;
"!="								return NOTEQ;
"<"									return LESS;
">"									return GREATER;
"!"									return NOT;
";"									return PYC;
","									return COMMA;
"+"									return PLUSOP;
"-"									return MINUSOP;
"*"									return MULTOP;
"/"									return DIVOP;
"="									return ASIGN;
"("									return PARI;
")"									return PARD;
"{"									return LLAVEI;
"}"									return LLAVED;

\"									{ BEGIN(cadena); yymore(); }
<cadena>\"							{ BEGIN(INITIAL); return STRING; }
<cadena>[^"\n]+						{ yymore(); }
<cadena>"\n"						{ printf("Cadena abierta en línea %d sin cerrar\n", yylineno);  BEGIN(INITIAL); }
<cadena><<EOF>>						{ printf("Cadena abierta al final del documento sin cerrar\n");  return 0; }

"&"									{ BEGIN(andlogico); yymore(); }
<andlogico>"&"						{ BEGIN(INITIAL); return AND; }
<andlogico>{ok}+					{ BEGIN(INITIAL); printf("Error léxico (línea %d): &\n",yylineno); yyless(1); }


"|"									{ BEGIN(orlogico); yymore(); }
<orlogico>"|"						{ BEGIN(INITIAL); return OR; }
<orlogico>{ok}+						{ BEGIN(INITIAL); printf("Error léxico (línea %d): |\n",yylineno); yyless(1); }

"//"								{ BEGIN(comentario); }
<comentario>"\n"					{ BEGIN(INITIAL); }
<comentario>[^\n]					{ }

"/*"										{ BEGIN(comentario_multilinea); comienzo_comentario = yylineno; yymore(); }
<comentario_multilinea>([^*]|[*]^+[^*/])*	{ yymore(); }
<comentario_multilinea>"*/"					{ BEGIN(INITIAL); }
<comentario_multilinea><<EOF>>				{ printf("Comentario abierto en línea %d sin cerrar\n", comienzo_comentario); return 0; }

[ \t\n\r]+							{ /* Ignorar espacios en blanco, tabuladores y otros delimitadores */ }
{panico}+							{ /* Error léxico */ printf("Error léxico (línea %d): %s\n",yylineno,yytext); }
