import netCDF4
import numpy as np
import os

path = "../../../../../zs20225/scratch/test_run/"

netF = netCDF4.Dataset('262000_test.nc', 'w', format='NETCDF4')
netF.description = 'Test outputs from T2'

netF.createDimension('run', 10000)
netF.createDimension('easting', 111)
netF.createDimension('northing', 111)
netF.createDimension('elevation', 1)

runs = netF.createVariable('run', 'i4', ('run',))
eastings = netF.createVariable('easting', 'i4', ('easting',))
northings = netF.createVariable('northing', 'i4', ('northing',))
elev = netF.createVariable('elevation', 'i4', ('elevation',))
value = netF.createVariable('value', 'f4', ('run', 'easting', 'northing', 'elevation',))

for r in range(10000):
  fn = f"{r:04}"+'_0.out'
  fullpath = os.path.abspath(os.path.join(path, fn))
  txt = np.loadtxt(fullpath)
  runs[r] = r
  elev[0] = txt[0][2]
  for n in range(111):
    northings[n] = txt[n*111][1]
    for e in range(111):
      eastings[e] = txt[n*111 + e][0]
      value[r, e, n, 0] = txt[n*111 + e][3]
  os.remove(fullpath)


#print(netF.variables['easting'][:])
#print(netF.variables['northing'][:])
#print(netF.variables['elevation'][:])
#print(netF.variables['value'][:])

