#ifndef _LISTA_H
#define _LISTA_H

typedef struct listaRep *lista;

lista crearLista();
void insertarVar(lista *l, char *nombre, int valor, int type);
int consultarVar(lista l, char* nombre);
void borrarLista(lista l);

#endif