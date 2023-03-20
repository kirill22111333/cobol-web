TARGET = server
CC = gcc
COBOL = cobol
LN = ld -m i386pe
CFLAGS = -std=c99 -m32 -lws2_32
COBOL_FLAGS = -lws2_32

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

default: build link

build: clean init build_cobol build_c

init: 
	IF NOT EXIST $(SRC_OBJ) (mkdir $(OBJ_NAME))

build_cobol:
	$(foreach file, $(LIBCOBOL),$(COBOL_BUILD) $(file) -o$(patsubst $(SRC_LIB)%.cbl, $(SRC_OBJ)%.o, $(file)) &&) echo "COBOL BUILD COMPLETE"

build_c:
	$(foreach file, $(LIBC),$(CC_BUILD) $(file) -o$(patsubst $(SRC_LIB)%.c, $(SRC_OBJ)%.o, $(file)) &&) echo "C BUILD COMPLETE"

link:
	$(LN) -r $(OBJECTS) -o $(LIB)

example:
	$(foreach file, $(EXAMPLES),$(COBOL_BUILD_EXE_FILE) $(SRC_EXAMPLE)$(file).cbl $(SRC_OBJ)lib.o -o $(SRC_EXAMPLE)$(file) &&) echo "BUILD EXAMPLES COMPLETE"

RM_OBJ_COMMAND=

ifeq ($(OS),Windows_NT)
	RM_OBJ_COMMAND = IF EXIST $(SRC_OBJ) (rmdir /s /q $(OBJ_NAME))
else
	RM_OBJ_COMMAND = IF EXIST $(SRC_OBJ) (rm -r $(OBJ_NAME))
endif

clean:
	$(RM_OBJ_COMMAND)
