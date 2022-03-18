NCDIR=/mnt/storage/software/libraries/gnu/netcdf-4.7.3
CC = gcc
INCLUDES = -I${NCDIR}/include
CFLAGS = -Wall -O3 -g $(INCLUDES)
LIBS = -lm -ldl -L${NCDIR}/lib -lnetcdf
objects = netcdf_test

all: $(objects)

$(objects): %: %.c 
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

.PHONY:		clean
clean:
		rm -fv *.o
                
