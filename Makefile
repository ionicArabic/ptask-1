LIB=lib/libfiber.a
all: $(LIB) simplehttp generator reader_writer

AS=gcc -c
CC=gcc
CXX=g++
CFLAGS=-Wall -c -Iinclude -g -D__SCHEDULER_USING_BLOCKQ__

INCFILES=include/task.h      \
         include/chain.h     \
         include/sysdef.h    \
         include/spinlock.h  \
         include/timestamp.h \
         include/epoll.h

context.o: src/context.S
	$(AS) src/context.S

task.o: src/task.c $(INCFILES)
	$(CC) $(CFLAGS) -O3 src/task.c

epoll.o: src/epoll.c $(INCFILES)
	$(CC) $(CFLAGS) -O3 src/epoll.c

simplehttp.o: simplehttp.c $(INCFILES)
	$(CC) $(CFLAGS) -O2 simplehttp.c

reader_writer.o: reader_writer.c $(INCFILES)
	$(CC) $(CFLAGS) -O2 reader_writer.c

generator.o: generator.c $(INCFILES)
	$(CC) $(CFLAGS) -O2 generator.c

$(LIB): context.o task.o epoll.o
	ar rvc $(LIB) context.o task.o epoll.o

simplehttp: simplehttp.o $(LIB)
	$(CC) -o simplehttp simplehttp.o $(LIB) -lpthread

generator: generator.o $(LIB)
	$(CC) -o generator generator.o $(LIB) -lpthread

reader_writer: reader_writer.o $(LIB)
	$(CC) -o reader_writer reader_writer.o $(LIB) -lpthread

clean:
	rm -f *.o simplehttp generator reader_writer $(LIB)

install: $(LIB)
	cp $(LIB) /usr/local/lib
	cp $(INCFILES) /usr/local/include/fiber
