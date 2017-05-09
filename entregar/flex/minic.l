%{
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

func								{ printf("FUNC\n"); return FUNC; }
var									{ printf("VAR\n"); return VAR; }
let									{ printf("LET\n"); return LET; }
float								{ printf("FLOAT\n"); return FLOAT; }
if									{ printf("IF\n"); return IF; }
else								{ printf("ELSE\n"); return ELSE; }
while								{ printf("WHILE\n"); return WHILE; }
print								{ printf("PRINT\n"); return PRINT; }
read								{ printf("READ\n"); return READ; }
bool								{ printf("BOOL\n"); return BOOL; }
true								{ printf("TRUE\n"); return TRUE; }
false								{ printf("FALSE\n"); return FALSE; }
({L}|_)({L}|_|{D})*					{ if (yyleng > 16) {
										printf("Error: ID con mas de 16 caracteres en línea %d: %s (%lu caracteres)\n",yylineno,yytext,yyleng);
									} else {
										if (yyleng == 1) {
											printf("ID %s (%lu caracter)\n",yytext,yyleng);
										} else {
											printf("ID %s (%lu caracteres)\n",yytext,yyleng);
										}
									} return ID; }
{D}+								{ if (atol(yytext) > 2147483648) {
											printf("Error: NUM provoca desbordamiento en línea %d: %s\n",yylineno,yytext);
									} else {
										printf("NUM %s\n",yytext);
									} return NUM; }
{D}+\.{D}+							{ printf("DECIMAL %s\n",yytext); return DECIMAL; }
"<="								{ printf("LESSEQ %s\n",yytext); return LESSEQ; }
">="								{ printf("GREATEREQ %s\n",yytext); return GREATEREQ; }
"=="								{ printf("EQ %s\n",yytext); return EQ; }
"!="								{ printf("NOTEQ %s\n",yytext); return NOTEQ; }
"<"									{ printf("LESS %s\n",yytext); return LESS; }
">"									{ printf("GREATER %s\n",yytext); return GREATER; }
"!"									{ printf("NOT %s\n",yytext); return NOT; }
";"									{ printf("PYC\n"); return PYC; }
","									{ printf("COMMA\n"); return COMMA; }
"+"									{ printf("PLUSOP\n"); return PLUSOP; }
"-"									{ printf("MINUSOP\n"); return MINUSOP; }
"*"									{ printf("MULTOP\n"); return MULTOP; }
"/"									{ printf("DIVOP\n"); return DIVOP; }
"="									{ printf("ASIGN\n"); return ASIGN; }
"("									{ printf("PARI\n"); return PARI; }
")"									{ printf("PARD\n"); return PARD; }
"{"									{ printf("LLAVEI\n"); return LLAVEI; }
"}"									{ printf("LLAVED\n"); return LLAVED; }

\"									{ BEGIN(cadena); yymore(); }
<cadena>\"							{ BEGIN(INITIAL); printf("STRING: %s\n", yytext); return STRING; }
<cadena>[^"\n]+						{ yymore(); }
<cadena>"\n"						{ printf("Cadena abierta en línea %d sin cerrar\n", yylineno);  BEGIN(INITIAL); }
<cadena><<EOF>>						{ printf("Cadena abierta al final del documento sin cerrar\n");  return 0; }

"&"									{ BEGIN(andlogico); yymore(); }
<andlogico>"&"						{ BEGIN(INITIAL); printf("AND %s\n", yytext); return AND; }
<andlogico>{ok}+					{ BEGIN(INITIAL); printf("Error léxico (línea %d): &\n",yylineno); yyless(1); }


"|"									{ BEGIN(orlogico); yymore(); }
<orlogico>"|"						{ BEGIN(INITIAL); printf("OR %s\n", yytext); return OR; }
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
