#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>
#include <netcdf.h>

#define NDIMS 3
#define DIMSIZE 10

#define ERR printf("error");
#define NUM_SLABS 3

int main() {
  int mpi_size, mpi_rank;
  MPI_Comm comm = MPI_COMM_WORLD;
  MPI_Info info = MPI_INFO_NULL;
  int ncid, v1id, dimids[NDIMS];
  int res, err;
   
  MPI_Init(NULL,NULL);
  MPI_Comm_size(MPI_COMM_WORLD, &mpi_size);
  MPI_Comm_rank(MPI_COMM_WORLD, &mpi_rank);

  char *file_name = "hello.nc";
   
  if ((res = nc_create_par(file_name, NC_NETCDF4, comm, info, &ncid))) ERR;
   
  if (nc_def_dim(ncid, "d1", DIMSIZE, dimids)) ERR;
  if (nc_def_dim(ncid, "d2", DIMSIZE, &dimids[1])) ERR;
  if (nc_def_dim(ncid, "d3", NUM_SLABS, &dimids[2])) ERR;
   
  if ((res = nc_def_var(ncid, "v1", NC_INT, NDIMS, dimids, &v1id))) ERR;
   
  //    ... use collective I/O
  err = nc_var_par_access(ncid, v1id, NC_COLLECTIVE); ERR

  if ((res = nc_enddef(ncid))) ERR;
       
     // ...
         
  if ((res = nc_close(ncid))) ERR;

  return EXIT_SUCCESS;
}
