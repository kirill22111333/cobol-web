#ifndef __TCP_H__
#define __TCP_H__

extern int listen_tcp(char *address);
extern int accept_tcp(int listener);

extern int connect_tcp(char *address);
extern int close_tcp(int connect);

extern int send_tcp(int connect, char *buffer, size_t size);
extern int request_tcp(int connect, char *buffer, size_t size);

#endif /* __TCP_H__ */
