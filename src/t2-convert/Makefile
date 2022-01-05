##ifndef REPO_HOME
##  $(error "execute 'source ./bin/conf.sh to configure environment")
##endif
export EXE     = mpi_nc
export CC      = mpiicc
export CFLAGS  = -qopenmp -std=c99 -Wall
export CFLAGS += -restrict -Ofast -xbroadwell
export LIBS    =-L/X/netcdf-4.0/lib -lnetcdf -L/X/hdf5-1.8.9/lib -lhdf5_hl -lhdf5 -lz -lm -L/X/szip-2.1/lib -lsz

all: $(EXE)

$(EXE): $(EXE).c
	$(CC) $(CFLAGS) $(LIBS) $^ -o $@

clean:
	rm -f $(EXE)
