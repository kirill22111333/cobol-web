#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tcp.h"
#include "http.h"
#include "hashmap.h"

typedef struct HTTP {
    char *host;
    int len;
    int cap;
    void(**funcs)(int, HTTPreq*);
    map_t *tab; 
} HTTP;

static HTTPreq _new_request(void);
static void _parse_request(HTTPreq *request, char *buffer, size_t size);
static void _null_request(HTTPreq *request);
static int _switch_http(HTTP *http, int connect, HTTPreq *request);
static void _page404_http(int connect);

extern HTTP *new_http(char *address) {
	HTTP *http = (HTTP*)malloc(sizeof(HTTP));
	http->cap = 1000;
	http->len = 0;
	http->host = (char*)malloc(sizeof(char)*strlen(address)+1);
	strcpy(http->host, address);
	http->tab = hashmap_new();
	http->funcs = (void(**)(int, HTTPreq*))malloc(http->cap * (sizeof (void(*)(int, HTTPreq*))));
	return http;
}

extern void free_http(HTTP *http) {
    hashmap_free(http->tab);
    free(http->host);
    free(http->funcs);
    free(http);
}

extern void handle_http(HTTP *http, char *path, void(*handle)(int, HTTPreq*)) {
    hashmap_put(http->tab, path, http->len);
    http->funcs[http->len] = handle;
    http->len += 1;
    
    if (http->len == http->cap) {
        http->cap <<= 1;
        http->funcs = (void(**)(int, HTTPreq*))realloc(http->funcs, http->cap * (sizeof (void(*)(int, HTTPreq*))));
    }
}

extern int listen_http(HTTP *http) {
    int listener = listen_tcp(http->host);

    if (listener < 0) {
        return 1;
    }

    while (1) {
        int connect = accept_tcp(listener);

        if (connect < 0) {
            continue;
        }

        HTTPreq req = _new_request();

        while (1) {
            char buffer[BUFSIZ] = {0};
            int n = request_tcp(connect, buffer, BUFSIZ);

            if (n < 0) {
                break;
            }

            _parse_request(&req, buffer, n);

            if (n != BUFSIZ) {
                break;
            }
        }

        _switch_http(http, connect, &req);

        close_tcp(connect);
    }

    close_tcp(listener);
    return 0;
}

extern void parsehtml_http(int conn, char *filename) {
    char buffer[BUFSIZ] = "HTTP/1.1 200 OK\nContent-type: text/html\n\n";
    size_t readsize = strlen(buffer);
    send_tcp(conn, buffer, readsize);

    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        return;
    } 

    while ((readsize = fread(buffer, sizeof(char), BUFSIZ, file)) != 0) {
        send_tcp(conn, buffer, readsize);
    }

    fclose(file);
}

static HTTPreq _new_request(void) {
    return (HTTPreq) {
        .method = {0},
        .path = {0},
        .proto = {0},
        .state = 0,
        .index = 0
    };
}

static void _parse_request(HTTPreq *request, char *buffer, size_t size) {
    printf("%s\n", buffer);

    for (size_t i = 0; i < size; ++i) {
        switch (request->state) {
            case 0:
                if (buffer[i] == ' ' || request->index == METHOD_SIZE - 1) {
                    request->method[request->index] = '\0';
                    _null_request(request);
                    continue;
                }
                request->method[request->index] = buffer[i];
                break;

            case 1:
                if (buffer[i] == ' ' || request->index == PATH_SIZE - 1) {
                    request->path[request->index] = '\0';
                    _null_request(request);
                    continue;
                }
                request->path[request->index] = buffer[i];
                break;

            case 2:
                if (buffer[i] == '\n' || request->index == PROTO_SIZE - 1) {
                    request->proto[request->index] = '\0';
                    _null_request(request);
                    continue;
                }
                request->proto[request->index] = buffer[i];
                break;
            
            default:
                return;
        }

        request->index += 1;
    }
}

static void _null_request(HTTPreq *request) {
    request->state += 1;
    request->index = 0;
}

static int _switch_http(HTTP *http, int connect, HTTPreq *request) {
    int index;
    int error;

    error = hashmap_get(http->tab, request->path, (void**)(&index));

    printf("INDEX VALUE: %d; ERROR VALUE: %d\n", index, error);
    
    if (error != 0) {
        _page404_http(connect);
        return 1;
    }

    http->funcs[index](connect, request);
    return 0;
}

static void _page404_http(int connect) {
    char *header = "HTTP/1.1 404 Not Found\n\nnot found";
    size_t headsize = strlen(header);
    send_tcp(connect, header, headsize);
}
