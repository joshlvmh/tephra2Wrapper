#export TEPHRA = ./tephra2/tephra2_2020
#export WIND   = ./wind/gen_files
#export GRID   = ./grid/utms/
#export CONF   = ./esps/confs
#export OUT    = ./post/
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh to configure environment")
endif

export EXE     = t2_runner
export CC      = mpiicc
export CFLAGS  = -qopenmp #-std=c11 -Wall
export CFLAGS += -restrict -Ofast -xbroadwell -Wall

all: $(EXE)

$(EXE): $(EXE).c
	$(CC) $(CFLAGS) $^ -o $@

clea:
	rm -f $(EXE)
