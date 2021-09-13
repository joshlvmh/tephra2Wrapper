import netCDF4
import csv
import numpy as np
import math

## PARAMS
filename = "wind_NAME_YEAR.nc"
filepath = "../../zs20225/wind/nc_files/"
outpath  = "../../zs20225/wind/gen_files/"
t_count  = 4 # how many times per day

'''
years = 10
ts_p_d = 4
res = 0.25
numVolc = 145

VOLC = # read in CSV file for names, remove spaces?
Volcs  %f  %s   %f  %f   %f,  41, HeaderLines, 1  // skips first line then reads 41 lines
      num name lat long elev
if volc[v][

STEPS:
  read in CSV to get lat, long, elev, name

  add to matrix [4,#vol] , +360 to all Longs -ve

  get correct .nc file -> require loop for each year for next steps

  Levels = length(ncread(levels)) <- should result in 37
        = len(nc.varaiables['level'])

  date(1:len(nc(time))(1464)) = nc(time)
  date[0:len(nc.variables['time'])] = nc.variables['time'][:]
  Lat = nc(lat) <- this will be 3 varaibles -> should this change to a single point, middle one?
  Long = ''

  Time = length(date) // 1464

  uMatrix = zeros(Time, Levels)  // [1464,37]
  for levels:h:
    uwnd_all_temp = ncread(wfu, 'u', [int16((VolcLong-Long[0])/res) int16((Lat[0]-VolcLat)/res) h 1], [1 1 1 len(time)], [1 1 1 1])
    nc.variables['u'][0:1464,h,0,0].shape = (1464,)
    uwnd_all_tmp = squeese(uwnd_all_tmp) -> goes to [time] gets rid of all dimensions of 1
    uMatrix(0:len(unwnd),h) = uwnd
  repeat for V

  Dmatrix = [Time,Levels]
  Imatrix = [Time,Levels]

  for levels:h:
    D[:,h] = mod(90-atan2d(vMatrix[:,h],uMat[:,h]), 360)
    I[:,h] = sqrt(uMat[:,h]^2+vMat[:,h]^2)

  mkdir VNUM

  tephraOut = [h,3]

  Alt = [32435...110]
  Year = [2012..2021]

  for len(Dmat):r :
    for levels:h:
      tephOut[h,0] = Alt[h]
      tephOut[h,1] = IMat[r,h]
      tephOut[h,2] = DMat[r,h]

    filename = hr_day_month_year.gen

    open(filename)

    for h:level -1 -> reverse order:
      fprintf(filename, '%u\t%.1f\t%.1f\t\n', TephOut[h,:])

    close(filename)
    '''

def wind_convert(ncfp, y_index, v_index, volc):
  Levels = len(ncfp.variables['level'])
  date = ncfp.variables['time'][:]
  Lat = ncfp.variables['latitude'][1]
  Long = ncfp.variables['longitude'][1]
  Time = len(ncfp.variables['time'])

  uMatrix = np.zeros((Time, Levels))
  vMatrix = np.zeros((Time, Levels))
  for h in range(Levels):
    uMatrix[0:Time,h] = ncfp.variables['u'][0:Time, h, 1, 1]
    vMatrix[0:Time,h] = ncfp.variables['v'][0:Time, h, 1, 1]

  #vMatrix = ncfp.variables['v'][0:Time,0:Levels,1,1]

  DMatrix = np.zeros((Time,Levels))
  IMatrix = np.zeros((Time,Levels))

  for h in range(Levels):
    DMatrix[:,h] = np.mod(90-np.rad2deg(np.arctan2(vMatrix[:,h],uMatrix[:,h])), 360)
    IMatrix[:,h] = np.sqrt(np.square(uMatrix[:,h])+np.square(vMatrix[:,h]))

  # mkdir volc[0]

  tephraOut = np.zeros((Levels,3))
  Altitude = [32435,30760,29675,28180,27115,25905,23315,21630,19315,17660,15790,14555,13505,12585,11770,11030,10360,9160,8115,7180,6340,5570,4865,4205,3590,3010,2465,2205,1950,1700,1455,1220,990,760,540,325,110]

  for r in range(Time):
    for h in range(Levels):
      tephraOut[h,0] = Altitude[h]
      tephraOut[h,1] = IMatrix[r,h]
      tephraOut[h,2] = DMatrix[r,h]

    month = math.ceil(((r/t_count)) - (12*((math.ceil(r/t_count/12))-1)))
    time = math.ceil(((r-(((math.ceil(r/t_count))-1)*t_count))-1)*(24/t_count))
    day = ((math.ceil(r/t_count) % 31 )+1) # doesnt account for different length months
    filename = str(volc[0])+"_"+str(y_index)+"_"+f"{month:02}"+"_"+f"{day:02}"+"_"+f"{time:02}"+".gen"
    print(filename)

    f = open(filename, "w")
    for h in range(Levels-1,-1,-1):
      f.write("%u\t%.1f\t%.1f\t\n" %(tephraOut[h,0], tephraOut[h,1], tephraOut[h,2]))
      #print("%u\t%.2f\t%.1f\n", tephraOut[h,0], tephraOut[h,1], tephraOut[h,2])
    f.close()

def read_csv():
  with open('volc_holo_mody.csv', 'r', encoding="ISO-8859-1") as csv_wind_f:
    csv_wind_r = csv.reader(csv_wind_f, )
    V = []
    next(csv_wind_r)
    for row in csv_wind_r:
      row[1] = row[1].replace(" ","")
      V.append(row[1:5])
  V = np.vstack(V)
  return V

def main():
  '''
  volc = [name_no_spaces, long, lat, elev] * num volcs
  '''
  volc = read_csv()
  print("-----------------")

  for i in range(0,1):#len(volc)):
    print(volc[0][1])
    if float(volc[i][1]) < 0:
      volc[i][1] += 360
    for j in range(2012,2013):#2022):
      nc_file = filename.replace("YEAR", str(j))
      nc_file = nc_file.replace("NAME", volc[0][0])
      ncfp = netCDF4.Dataset(nc_file)## filepath+nc_file)
      ncfp = netCDF4.Dataset('download.nc')
      #print(volc)
      wind_convert(ncfp, j, i, volc[49]) #volc[i]

if __name__ == '__main__':
  main()
