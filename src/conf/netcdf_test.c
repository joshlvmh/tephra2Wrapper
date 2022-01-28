#include <netcdf.h>
#include <math.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
void netCDF4_output(float easting, float northing, float mass, int index);

int main(int argc, char *argv[]) {

  int i;

  for (i = 0; i < 9; i++ )
  {
    float mass = (float)i / 10;
    netCDF4_output(i%3*2, (i%3) * 2*2, mass*2, i);
  }
  return 0;
}
#define NDIMS 3
#define UNITS "units"
#define EASTING "UTM easting"
#define NORTHING "UTM northing"

#define ERRCODE 2
#define ERR(e) {printf("Error on line %d: %s\n", __LINE__, nc_strerror(e)); exit(ERRCODE);}

#include <unistd.h>

void netCDF4_output(float easting, float northing, float mass, int index)
{
  // TODO
  char * wind_file = "19_12_2011_0800"; // set
  char * net_file = "262000_VEI2.nc"; // set

  int dim_xy = sqrt(9); // assumes square grid
  int easting_indx = index % dim_xy;
  int northing_indx = index / dim_xy; // could be the other way around
  int run_index = 1;

  int ncid, easting_dimid, northing_dimid, easting_varid, northing_varid, mass_varid, wind_varid;
  int run_dimid;
  int dimids[NDIMS];

  int retval;

  if (access(net_file, F_OK) == 0)
  {
    if ((retval = nc_open(net_file, NC_WRITE, &ncid)))
      ERR(retval);
  }
  else
  {
    if ((retval = nc_create(net_file, NC_NETCDF4|NC_NOCLOBBER, &ncid)))
      ERR(retval);
    if ((retval = nc_def_dim(ncid, "easting", dim_xy, &easting_dimid)))
      ERR(retval);
    if ((retval = nc_def_dim(ncid, "northing", dim_xy, &northing_dimid)))
      ERR(retval);
    if ((retval = nc_def_dim(ncid, "run", 10, &run_dimid)))
      ERR(retval);

    // coord vars
    if ((retval = nc_def_var(ncid, "easting", NC_FLOAT, 1, &easting_dimid, &easting_varid)))
      ERR(retval);
    if ((retval = nc_def_var(ncid, "northing", NC_FLOAT, 1, &northing_dimid, &northing_varid)))
      ERR(retval);

    // unit attributes to coord vars
    if ((retval = nc_put_att_text(ncid, easting_varid, UNITS, strlen(EASTING), EASTING)))
      ERR(retval);
    if ((retval = nc_put_att_text(ncid, northing_varid, UNITS, strlen(NORTHING), NORTHING)))
      ERR(retval);

    dimids[0] = easting_dimid;
    dimids[1] = northing_dimid;
    dimids[2] = run_dimid;

    if ((retval = nc_def_var(ncid, "mass", NC_FLOAT, NDIMS, dimids, &mass_varid)))
      ERR(retval);
    if ((retval = nc_def_var(ncid, "wind", NC_STRING, NDIMS, dimids, &wind_varid))) // change to timeval?
      ERR(retval);

    if ((retval = nc_enddef(ncid)))
      ERR(retval);
  }

  const size_t index_vec[NDIMS] = {easting_indx, northing_indx, run_index};

  // set easting and northing values
  if ((retval = nc_put_var1_float(ncid, easting_varid, index_vec, &easting)))
    ERR(retval);
  if ((retval = nc_put_var1_float(ncid, northing_varid, index_vec, &northing)))
    ERR(retval);

  if ((retval = nc_put_var1(ncid, mass_varid, index_vec, &mass)))
    ERR(retval);
  if ((retval = nc_put_var1(ncid, wind_varid, index_vec, &wind_file)))
    ERR(retval);

  if ((retval = nc_close(ncid)))
    ERR(retval);
}
/**********************/
