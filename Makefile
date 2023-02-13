TARGET = Server
CC = gcc
LN = ld
CFLAGS = -Wall -std=c99 -lws2_32

PREF_SRC = ./src/
PREF_OBJ = ./obj/
PREF_LIB = $(PREF_SRC)libs/

HEADERS = $(PREF_LIB)tcp.h $(PREF_LIB)hashmap.h
SOURCES = $(PREF_LIB)tcp.c $(PREF_LIB)hashmap.c
OBJECTS = $(PREF_OBJ)tcp.o $(PREF_OBJ)hashmap.o

BUILD = $(CC) $(CFLAGS) -c

TCP_BUILD = $(PREF_LIB)tcp.c -o $(PREF_OBJ)tcp.o
HASHMAP_BUILD = $(PREF_LIB)hashmap.c -o $(PREF_OBJ)hashmap.o

default: init build link

init: 
	mkdir obj

build: $(HEADERS) $(SOURCES)
	$(BUILD) $(TCP_BUILD)
	$(BUILD) $(HASHMAP_BUILD)

link: $(OBJECTS)
	$(LN) -r $(OBJECTS) -o $(PREF_OBJ)lib.o

clean:
	rm -r $(PREF_OBJ)*.o
	rm -r $(TARGET).exe
