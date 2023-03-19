TARGET = server
CC = gcc
COBOL = cobol
LN = ld -m i386pe
CFLAGS = -std=c99 -m32 -lws2_32
COBOL_FLAGS = -lws2_32

SRC_OBJ = ./obj/
SRC_LIB = ./lib/
SRC_EXAMPLE = ./examples/

CC_BUILD = $(CC) $(CFLAGS) -c
COBOL_BUILD = $(COBOL) $(COBOL_FLAGS) -c
COBOL_BUILD_EXE_FILE = $(COBOL) $(COBOL_FLAGS) -x

OBJECT_TCP = $(SRC_OBJ)tcp.o
OBJECT_HTTP = $(SRC_OBJ)http.o
OBJECT_HTTP_HANDLE = $(SRC_OBJ)handle_http.o
OBJECT_HTTP_DEFINE = $(SRC_OBJ)define_http.o
OBJECT_HTTP_SENDHTML = $(SRC_OBJ)sendhtml.o
LIB = $(SRC_OBJ)lib.o

COBOL_HTTP = $(SRC_LIB)http.cbl -o $(OBJECT_HTTP)
COBOL_HTTP_HANDLE = $(SRC_LIB)handle_http.cbl -o $(OBJECT_HTTP_HANDLE)
COBOL_HTTP_DEFINE = $(SRC_LIB)define_http.cbl -o $(OBJECT_HTTP_DEFINE)
COBOL_HTTP_SENDHTML = $(SRC_LIB)sendhtml.cbl -o $(OBJECT_HTTP_SENDHTML)

TCP_BUILD = $(SRC_LIB)tcp.c -o $(SRC_OBJ)tcp.o

OBJECTS = $(OBJECT_TCP) $(OBJECT_HTTP) $(OBJECT_HTTP_HANDLE) $(OBJECT_HTTP_DEFINE) $(OBJECT_HTTP_SENDHTML)

EXAMPLE_HTML_FILES = $(SRC_EXAMPLE)html-files/main.cbl $(SRC_OBJ)lib.o -o $(SRC_EXAMPLE)html-files/main
EXAMPLE_TCP_CLIENT = $(SRC_EXAMPLE)tcp/client.cbl $(SRC_OBJ)lib.o -o $(SRC_EXAMPLE)tcp/client
EXAMPLE_TCP_SERVER = $(SRC_EXAMPLE)tcp/server.cbl $(SRC_OBJ)lib.o -o $(SRC_EXAMPLE)tcp/server

default: init build link

init: 
	IF NOT EXIST ./obj (mkdir obj)

build:
	$(CC_BUILD) $(TCP_BUILD)
	$(COBOL_BUILD) $(COBOL_HTTP)
	$(COBOL_BUILD) $(COBOL_HTTP_HANDLE)
	$(COBOL_BUILD) $(COBOL_HTTP_DEFINE)
	$(COBOL_BUILD) $(COBOL_HTTP_SENDHTML)

link:
	$(LN) -r $(OBJECTS) -o $(LIB)

example:
	$(COBOL_BUILD_EXE_FILE) $(EXAMPLE_HTML_FILES)
	$(COBOL_BUILD_EXE_FILE) $(EXAMPLE_TCP_CLIENT)
	$(COBOL_BUILD_EXE_FILE) $(EXAMPLE_TCP_SERVER)

clean:
	rm -r $(SRC_OBJ)*.o
	rm -r $(TARGET).exe
