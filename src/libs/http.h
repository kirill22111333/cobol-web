#ifndef HTTP_H
#define HTTP_H

#define METHOD_SIZE 16
#define PATH_SIZE 2048
#define PROTO_SIZE  16

typedef struct HTTPreq {
    char method[METHOD_SIZE];
    char path[PATH_SIZE];
    char proto[PROTO_SIZE];
    int state;
    size_t index;
} HTTPreq;

typedef struct HTTP HTTP;

extern HTTP *new_http(char *address);
extern void free_http(HTTP *http);

extern void handle_http(HTTP *http, char *path, void(*)(int, HTTPreq*));
extern int listen_http(HTTP *http);

extern void parsehtml_http(int conn, char *filename);

#endif