%{
#include <stdio.h>
#include "stl.h"

int comienzo_comentario;
%}

L					[a-zA-Z]
D					[0-9]

%x comentario
%x comentario_multilinea

%%
 // Expresiones regulares

^solid									{ printf("SOLID\n"); return SOLID; }
facet[ ]+normal							{ printf("FACET NORMAL\n"); return FACET_NORMAL; }
vertex									{ printf("VERTEX\n"); return VERTEX; }
outer[ ]+loop							{ printf("OUTER_LOOP\n"); return OUTER_LOOP; }
"endloop"								{ printf("ENDLOOP\n"); return ENDLOOP; }
endfacet								{ printf("ENDFACET\n"); return ENDFACET; }
^endsolid								{ printf("ENDSOLID\n"); return ENDSOLID; }
{L}+									{ printf("ID: %s\n", yytext); return ID; }
-?{D}\.{D}{1,7}([eE][+\-]{D}{1,2})? 	{ printf("FLOAT: %s\n", yytext); return FLOAT; }

\"([^"\n]|\\\")*\"						{ printf("Cadena: %s\n",yytext); }

"//"									{ BEGIN(comentario); }
<comentario>"\n"						{ BEGIN(INITIAL); }
<comentario>[^\n]						{ }

"/*"									{ BEGIN(comentario_multilinea); comienzo_comentario = yylineno; yymore(); }
<comentario_multilinea>(.|\n)			{ yymore(); }
<comentario_multilinea>"*/"				{ printf("yytext: %s\n", yytext); BEGIN(INITIAL); }
<comentario_multilinea><<EOF>>			{ printf("Comentario abierto en línea %d sin cerrar\n", comienzo_comentario); return 0; }


"//".*									{ /* Ignorar */ }
[ \t\n\r]+								{ /* Ignorar */ }
.										{ /* Error léxico */ printf("Error léxico (línea %d): %s\n",yylineno,yytext); }
