#include <stdio.h>
#include <string.h>

#include "../libs/tcp.h"

#define EXIT "!exit"
#define WELCOME_MESSAGE "Print !exit to close connection."
#define DEFAULT_MESSAGE "This is the default message from the server."
#define BUFF 512

int main(int argc, char const *argv[])
{
    int listener = listen_net("0.0.0.0:8001");

    if (listener < 0) {
        printf("SERVER ERROR: %d", listener);
        return -1;
    }

    printf("Server is listening ...\n");

    char buffer[BUFF];

    while (1) {
        int connect = accept_net(listener);

        if (connect < 0) {
            printf("ACCEPT ERROR");
            return -2;
        }

        send_net(connect, WELCOME_MESSAGE, sizeof(WELCOME_MESSAGE));

        while (1) {
            int length = request_net(connect, buffer, BUFF);

            if (length <= 0) {
                break;
            }

            for (char *p = buffer; *p != '\0'; ++p) {
                *p = *p;
            }

            printf("Client message: %s\n", buffer);

            if (strcmp(buffer, EXIT) == 0) {
                send_net(connect, EXIT, sizeof(EXIT));
                break;
            }

            send_net(connect, DEFAULT_MESSAGE, sizeof(DEFAULT_MESSAGE));
        }

        close_net(connect);
    }
    
    return 0;
}
