#include "lista.h"
#include <stdlib.h>
#include <string.h>

struct listaRep {
	char *nombre;
	int type;
	int valor;
	float valorFloat;
	struct listaRep *sig;
};

lista crearLista() {
	return NULL;
}

struct listaRep * buscarNodo(lista l, char *nombre) {
	struct listaRep *aux = l;
	while (aux != NULL) {
		if ( !strcmp(aux->nombre,nombre) ) { // ( strcmp(aux->nombre,nombre) == 0 ) {}
			return aux;
		}
		aux = aux->sig;
	}
	return NULL;
}

void insertarVar(lista *l, char *nombre, int valor, int type) {
	struct listaRep *aux = buscarNodo(*l,nombre);
	if(aux != NULL) {
		if (type == 0) {
			aux->valor = valor;
		} else if (type == 2) {
			aux->valorFloat = valor;
		}
	} else {
		// Nueva variable
		aux = (struct listaRep *)malloc(sizeof(struct listaRep));
		aux->nombre = nombre;
		aux->type = type;
		if (type == 2) {
			aux->valorFloat = valor;
		} else {
			aux->valor = valor;
		}
		aux->sig = *l;
		*l = aux;
	}
}


int consultarVar(lista l, char* nombre) {
	struct listaRep *aux = buscarNodo(l,nombre);
	if(aux != NULL) {
		return aux->type;	
	} else {
		return -1;
	}
}


void borrarLista(lista l) {
	struct listaRep *aux = l;
	while (aux != NULL) {
		free(aux->nombre);
		aux = aux->sig;
		free(l);
		l = aux;
	}
}