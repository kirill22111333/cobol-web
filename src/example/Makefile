CLIENT_TARGET = client
SERVER_TARGET = server
HASHMAP_TARGET = hashmap

CC = gcc
CFLAGS = -Wall -std=c99 -lws2_32

SRC_EXAMPLE = ./
SRC_OBJ = ../../obj/
SRC_LIB = ../libs/

HEADERS = $(SRC_LIB)tcp.h $(SRC_LIB)hashmap.h

TCP_LIB = $(SRC_OBJ)tcp.o
HASHMAP_LIB = $(SRC_OBJ)hashmap.o

default: hashmap_build client_build server_build

hashmap_build: $(HASHMAP_LIB)
	$(CC) $(SRC_EXAMPLE)$(HASHMAP_TARGET).c $(HASHMAP_LIB) -o $(HASHMAP_TARGET) $(CFLAGS)

client_build: $(TCP_LIB)
	$(CC) $(SRC_EXAMPLE)$(CLIENT_TARGET).c $(TCP_LIB) -o $(CLIENT_TARGET) $(CFLAGS)

server_build: $(TCP_LIB)
	$(CC) $(SRC_EXAMPLE)$(SERVER_TARGET).c $(TCP_LIB) -o $(SERVER_TARGET) $(CFLAGS)
