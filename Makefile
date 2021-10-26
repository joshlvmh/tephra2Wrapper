EXE=t2_runner
CC=mpiicc
CFLAGS=-qopenmp -std=c99 -Wall

all: $(EXE)

$(EXE): $(EXE).c
	$(CC) $(CFLAGS) $^ -o $@

clea:
	rm -f $(EXE)
