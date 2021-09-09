# Posix Makefile for RunCPM

PROG1 = pushlua
PROG2 = midiloop

MFILE = Makefile

# Compiler command
CC = gcc
#CC = gcc -DDEBUG=1 -DDEBUGLOG=1

# Flags to pass to the compiler - add "-g" to include debug information
CFLAGS = -Wall -D__LINUX_ALSA__ -O3 -fPIC -Wno-unused-variable
#CFLAGS = -Wall -O0 -fPIC -Wno-unused-variable -g

# Flags to pass to the linker
LDFLAGS = -lncurses -lm -ldl -lstdc++ -lasound -lpthread

# Objects to build
OBJS1 = pushlua.o RtMidi.o lua/liblua.a
OBJS2 = midiloop.o RtMidi.o

# Lua building
LUABUILD = $(MAKE) -C lua linux
LUACLEAN = $(MAKE) -C lua clean

# Clean up program
RM = rm -f

#------------------------------------------------------------------------

all: $(PROG1) $(PROG2)

$(PROG1): pushlua.o
	$(CC) $(OBJS1) -o $(PROG1) $(LDFLAGS)
$(PROG2): midiloop.o
	$(CC) $(OBJS2) -o $(PROG2) $(LDFLAGS)

pushlua.o: pushlua.cpp $(wildcard *.h) $(MFILE)
	$(LUABUILD)
	$(CC) $(CFLAGS) -c pushlua.cpp RtMidi/RtMidi.cpp
midiloop.o: midiloop.cpp $(wildcard *.h) $(MFILE)
	$(CC) $(CFLAGS) -c midiloop.cpp RtMidi/RtMidi.cpp

rebuild: clean all

.PHONY: clean
clean:
	$(LUACLEAN)
	$(RM) *.o
	$(RM) $(PROG1) $(PROG2)
