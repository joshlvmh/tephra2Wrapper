import netCDF4

nc = netCDF4.Dataset('262000_VEI2.nc', 'r+')

nc.variables['easting'][:] = lat
nc.varaibles['northing'] = lon
