CC = gcc
wininstaller:	CC = x86_64-w64-mingw32-gcc
graph:	CC = ncc -ncgcc -ncld -ncspp -ncfabs
LEX = flex
YACC = bison
CFLAGS = -g3
YFLAGS = -d
LDFLAGS = -lfl
wininstaller:	LDFLAGS =
EXECUTABLE = icai_risc_as
FLEX = $(wildcard *.l)
BISON = $(wildcard *.y)
SRCS = $(wildcard *.c)
SRCS += $(BISON:.y=.tab.c)
SRCS += $(FLEX:.l=.c)
OBJS = $(SRCS:.c=.o)
SRC_GEN = $(BISON:.y=.tab.c)
SRC_GEN += $(BISON:.y=.tab.h)
SRC_GEN += $(FLEX:.l=.c)


.PHONY = all clean install wininstaller graph

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJS)
	$(CC) $^ -o $@ -g3 $(LDFLAGS)

%.tab.c:	%.y
	$(YACC) $(YFLAGS) $<

clean:
	rm -rf $(EXECUTABLE)* $(OBJS) $(SRC_GEN) *.i *.nccout a.vhd a.bin a.mif calls.png

install: all
	cp $(EXECUTABLE) /usr/bin/$(EXECUTABLE)

test: all
	./$(EXECUTABLE) test.asm

debug:	all
	gdb ./$(EXECUTABLE)

wininstaller:	all
	mv $(EXECUTABLE) $(EXECUTABLE).exe
	cd nsis; makensis installer.nsi; cd ..
	mv nsis/icai_risc_as_v*.exe .

graph:	all
	gengraph.py -i "getopt strncmp strcmp strcat strcpy strdup strrchr strlen strtol atoi printf fopen fwrite fprintf vfprintf ferror fread fclose clearerr malloc free yyrealloc yy_get_previous_state yy_try_NUL_trans yy_get_next_buffer yy_create_buffer yyensure_buffer_stack yy_fatal_error yydestruct yyrestart yy_load_buffer_state _IO_getc __errno_location __builtin_memcpy __builtin_va_start __ctype_b_loc __xpg_basename" icai_risc_as.nccout main | dot -Grankdir=LR -Tpng -o calls.png
