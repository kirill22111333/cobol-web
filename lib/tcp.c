#ifdef __LINUX__
    #include <unistd.h>
    #include <arpa/inet.h>
#elif __WIN32
    #include <winsock2.h>
#endif

#include <stddef.h>
#include <stdlib.h>

#include "tcp.h"

static int parse_address(char *address, char *ipv4, char *port);

typedef enum error_t {
    WINSOCK_ERROR       = -1,
    TCP_SOCKET_ERROR    = -2,
    SET_SOCKET_ERROR    = -3,
    PARSE_ADDRESS_ERROR = -4,
    BIND_ADDRESS_ERROR  = -5,
    LISTENER_ERROR      = -6,
    CONNECTED_ERROR     = -7,
} error_t;

extern int listen_tcp(char *address) {
    #ifdef __WIN32
        WSADATA wsa;
        if (WSAStartup(MAKEWORD(2,2), &wsa) != 0) {
            return WINSOCK_ERROR;
        }
    #endif

    int listener = socket(AF_INET, SOCK_STREAM, 0); // Using tcp protocol

    if (listener < 0) {
        return TCP_SOCKET_ERROR;
    }

    // If the socket is already defined.
    // SO_REUSEADDR used to redefine the socket.
    #ifdef __LINUX__
        if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0) {
            return SET_SOCKET_ERROR;
        }
    #else
        if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &(char){1}, sizeof(char)) < 0) {
            return SET_SOCKET_ERROR;
        }
    #endif

    // Parsing a request to get the ip and port.

    char ipv4[16];
    char port[6];

    if (parse_address(address, ipv4, port) != 0) {
        return PARSE_ADDRESS_ERROR;
    }

    struct sockaddr_in addr;

    addr.sin_family = AF_INET;
    addr.sin_port = htons(atoi(port));
    addr.sin_addr.s_addr = inet_addr(ipv4);

    if (bind(listener, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
        return BIND_ADDRESS_ERROR;
    }

    // Connection start.

    if (listen(listener, SOMAXCONN) != 0) {
        return LISTENER_ERROR;
    }

    return listener;
}

extern int accept_tcp(int listener) {
    return accept(listener, NULL, NULL);
}

extern int connect_tcp(char *address) {
    #ifdef __WIN32
        WSADATA wsa;
        if (WSAStartup(MAKEWORD(2,2), &wsa) != 0) {
            return WINSOCK_ERROR;
        }
    #endif

    int connect_socket = socket(AF_INET, SOCK_STREAM, 0); // Using tcp protocol

    if (connect_socket < 0) {
        return TCP_SOCKET_ERROR;
    }

    // Parsing a request to get the ip and port.

    char ipv4[16];
    char port[6];

    if (parse_address(address, ipv4, port) != 0) {
        return PARSE_ADDRESS_ERROR;
    }

    struct sockaddr_in addr;

    addr.sin_family = AF_INET;
    addr.sin_port = htons(atoi(port));
    addr.sin_addr.s_addr = inet_addr(ipv4);

    // Connect to socket

    if (connect(connect_socket, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
        return CONNECTED_ERROR;
    }

    return connect_socket;
}

extern int close_tcp(int connect) {
    #ifdef __LINUX__
        return close(connect);
    #elif __WIN32
        return closesocket(connect);
    #endif
}

extern int send_tcp(int connect, char *buffer, size_t size) {
    return send(connect, buffer, (int) size, 0);
}

extern int request_tcp(int connect, char *buffer, size_t size) {
    return recv(connect, buffer, (int) size, 0);
}

static int parse_address(char *address, char *ipv4, char *port) {
    size_t i = 0, j = 0;
    for (; address[i] != ':'; ++i) {
        if (address[i] == '\0') {
            return 1;
        }

        if (i >= 15) {
            return 2;
        }

        ipv4[i] = address[i];
    }

    ipv4[i] = '\0';

    for (i += 1; address[i] != '\0' && address[i] != ' '; ++i, ++j) {
        if (j >= 5) {
            return 3;
        }

        port[j] = address[i];
    }

    port[j] = '\0';

    return 0;
}
