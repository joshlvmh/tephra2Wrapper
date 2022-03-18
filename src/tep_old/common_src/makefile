CC = icc
INCLUDES =
CFLAGS = -Wall -O3 -qopt-report=5 $(INCLUDES)
LIBS = -lm libgc.a -ldl
deps = ../common_src/parameters.h ../common_src/common_structures.h

tephra2_calc.o:	tephra2_calc.c $(deps)
		$(CC) $(CFLAGS) -c tephra2_calc.c $(LIBS)

.PHONY:		clean
clean:
		rm -fv *.o
                
##		icc -Ofast -qopenmp -xbroadwell -restrict -qopt-report=5 -qopt-report-phase=vec -std=c99 -Wall $^ -o $@
