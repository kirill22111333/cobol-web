TARGET = server
CC = gcc
COBOL = cobc

ifeq ($(OS),Windows_NT)
	LN = ld -m i386pe
	COBOL_FLAGS = -lws2_32
	CFLAGS = -std=c99 -m32 -lws2_32
	MAKE_OBJ_COMMAND = IF NOT EXIST $(SRC_OBJ) (mkdir $(OBJ_NAME))
	RM_OBJ_COMMAND = IF EXIST $(SRC_OBJ) (rmdir /s /q $(OBJ_NAME))
else
	LN = ld
	COBOL_FLAGS=
	CFLAGS = -std=c99
	ifeq (,$(wildcard $(SRC_OBJ)))
		MAKE_OBJ_COMMAND = mkdir $(OBJ_NAME)
		RM_OBJ_COMMAND = rm -r $(OBJ_NAME)
	endif
endif

OBJ_NAME = obj
SRC_OBJ = ./$(OBJ_NAME)/
SRC_LIB = ./lib/
SRC_EXAMPLE = ./examples/

CC_BUILD = $(CC) $(CFLAGS) -c
COBOL_BUILD = $(COBOL) $(COBOL_FLAGS) -c
COBOL_BUILD_EXE_FILE = $(COBOL) $(COBOL_FLAGS) -x

LIBC = $(wildcard $(SRC_LIB)*.c)
LIBCOBOL = $(wildcard $(SRC_LIB)*.cbl)
OBJECTS = $(wildcard $(SRC_OBJ)*.o)

LIB = $(SRC_OBJ)lib.o

EXAMPLES=
EXAMPLES += send-text/main
EXAMPLES += html-files/main
EXAMPLES += tcp/client
EXAMPLES += tcp/server
EXAMPLES += 404-page/main
EXAMPLES += header-customization/main
EXAMPLES += http-method/main
EXAMPLES += http-method/post
EXAMPLES += http-method/get
EXAMPLES += http-public/main
EXAMPLES += cookie/main
EXAMPLES += cookie-sessions/main
EXAMPLES += downloads/main

default: build link

build: clean init build_cobol build_c

init: 
	$(MAKE_OBJ_COMMAND)

build_cobol:
	$(foreach file, $(LIBCOBOL),$(COBOL_BUILD) $(file) -o$(patsubst $(SRC_LIB)%.cbl, $(SRC_OBJ)%.o, $(file)) &&) echo "COBOL BUILD COMPLETE"

build_c:
	$(foreach file, $(LIBC),$(CC_BUILD) $(file) -o$(patsubst $(SRC_LIB)%.c, $(SRC_OBJ)%.o, $(file)) &&) echo "C BUILD COMPLETE"

link:
	$(LN) -r $(OBJECTS) -o $(LIB)

example:
	$(foreach file, $(EXAMPLES),$(COBOL_BUILD_EXE_FILE) $(SRC_EXAMPLE)$(file).cbl $(SRC_OBJ)lib.o -o $(SRC_EXAMPLE)$(file) &&) echo "BUILD EXAMPLES COMPLETE"

clean:
	$(RM_OBJ_COMMAND)
