export TEPHRA = ./tephra2/tephra2_2020
export WIND   = ./wind/gen_files
export GRID   = ./grid/utms/
export CONF   = ./esps/confs
export OUT    = ./post/

export EXE    = t2_runner
export CC     = mpiicc
export CFLAGS = -qopenmp -std=c99 -Wall

all: $(EXE)

$(EXE): $(EXE).c
	$(CC) $(CFLAGS) $^ -o $@

clea:
	rm -f $(EXE)
