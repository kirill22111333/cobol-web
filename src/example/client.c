#include <stdio.h>
#include <string.h>

#include "../libs/tcp.h"

#define ENTRY_MESSAGE "connect"
#define EXIT "!exit"
#define BUFF 512

int main(int argc, char const *argv[])
{
    int connect = connect_net("127.0.0.1:8001");

    if (connect < 0) {
        printf("CONNECT ERROR: %d", connect);
        return -1;
    }

    char buffer[BUFF];

    send_net(connect, ENTRY_MESSAGE, sizeof(ENTRY_MESSAGE));
    request_net(connect, buffer, BUFF);

    printf("%s\n", buffer);

    while (1) {
        char *p = buffer;

        for (unsigned i = 0; (*p++ = getchar()) != '\n' && i < BUFF; ++i);
        *(p - 1) = '\0';

        send_net(connect, buffer, BUFF);
        request_net(connect, buffer, BUFF);

        if (strcmp(buffer, EXIT) == 0) {
            break;
        }

        printf("Server message: %s\n", buffer);
    }

    close_net(connect);

    return 0;
}
