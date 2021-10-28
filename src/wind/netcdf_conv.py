import netCDF4
import csv
import numpy as np
import math
import os
import xarray as xr

## PARAMS
filename = "wind_ID_YEAR.nc"
filepath = os.environ['REPO_HOME']+"/../wind/nc_files/"
#filepath = os.environ['HOME']+"/fellowship/tephra2Wrapper/wind/"
outpath  = os.environ['WIND']+'/' #os.environ['HOME']+"/../zs20225/wind/gen_files/"
#outpath  = os.environ['HOME']+"/fellowship/tephra2Wrapper/wind/gen_files/"
csvfile  = "volc_holo_mody.csv"

def wind_convert(ncfp, y_index, v_index, volc):
  print(filepath)
  Levels = len(ncfp.variables['level'])
  date = ncfp.variables['time'][:]
  Lat = ncfp.variables['latitude'][1]
  Long = ncfp.variables['longitude'][1]
  Time = len(ncfp.variables['time'])

  uMatrix = np.zeros((Time, Levels))
  vMatrix = np.zeros((Time, Levels))
  DMatrix = np.zeros((Time,Levels))
  IMatrix = np.zeros((Time,Levels))

  vMatrix[:,:] = ncfp.variables['v'][:,:,1,1]
  uMatrix[:,:] = ncfp.variables['u'][:,:,1,1]
  DMatrix[:,:] = np.mod(90-np.rad2deg(np.arctan2(vMatrix[:,:],uMatrix[:,:])), 360)
  IMatrix[:,:] = np.sqrt(np.square(uMatrix[:,:])+np.square(vMatrix[:,:]))

  os.makedirs(outpath+str(volc[1]), exist_ok=True)

  tephraOut = np.zeros((Levels,3))
  Altitude = [32435,30760,29675,28180,27115,25905,23315,21630,19315,17660,15790,
              14555,13505,12585,11770,11030,10360,9160,8115,7180,6340,5570,4865,
              4205,3590,3010,2465,2205,1950,1700,1455,1220,990,760,540,325,110]

  for r in range(Time):
    for h in range(Levels):
      tephraOut[h,0] = Altitude[h]
      tephraOut[h,1] = IMatrix[r,h]
      tephraOut[h,2] = DMatrix[r,h]

    time = netCDF4.num2date(date[r], "hours since 1900-01-01 00:00:00.0", "gregorian")
    filename = str(volc[1])+"_"+str(time.year)+"_"+f"{time.month:02}"+"_"+f"{time.day:02}"+"_"+f"{time.hour:02}"+".gen"

    f = open(outpath+str(volc[1])+"/"+filename, "w")
    for h in range(Levels-1,-1,-1):
      f.write("%u\t%.1f\t%.1f\t\n" %(tephraOut[h,0], tephraOut[h,1], tephraOut[h,2]))
    f.close()

def read_csv():
  with open(csvfile, 'r', encoding="ISO-8859-1") as csv_wind_f:
    csv_wind_r = csv.reader(csv_wind_f, )
    V = []
    next(csv_wind_r)
    for row in csv_wind_r:
      row[1] = row[1].replace(" ","")
      V.append(row[1:6])
  V = np.vstack(V)
  return V

def main():
  '''
  volc[_] = [name_no_spaces, id_number, long, lat, elev]
  '''
  volc = read_csv()

  for i in range(len(volc)):
    if float(volc[i][2]) < 0:
      volc[i][2] += 360
    if (volc[i][1] == '262000'):
      for j in range(2012,2022):
        nc_file = filename.replace("YEAR", str(j))
        nc_file = nc_file.replace("ID", volc[i][1])
        if (j == 2021): # remove expver dimension
          ERA5 = xr.open_mfdataset(filepath+nc_file,combine='by_coords')
          ERA5_combine =ERA5.sel(expver=1).combine_first(ERA5.sel(expver=5))
          ERA5_combine.load()
          ERA5_combine.to_netcdf(filepath+"copy"+nc_file)
          ncfp = netCDF4.Dataset(filepath+"copy"+nc_file)
        else:
          ncfp = netCDF4.Dataset(filepath+nc_file)
        wind_convert(ncfp, j, i, volc[i])

if __name__ == '__main__':
  main()
