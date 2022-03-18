import netCDF4
import csv
import numpy as np
import math
import os
import xarray as xr
from matplotlib import pyplot as plt
import geopandas as gpd
import shapefile
import pandas as pd

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

def add_netcdf(nc, area):
  return area

def define_area():
  shapes = gpd.read_file("aoi/AOI_buff_500_km.shp")
  shapes.plot()
  print(shapes.geometry.head())
  shp2csv("aoi/AOI_buff_500_km.shp")
  BV_border = pd.read_csv('aoi/AOI_buff_500_km_pnts.csv', sep=',',skiprows = range(0, 1))
  BV_border.columns=["lon", "lat"]
  BV_border["lon"]=BV_border["lon"].apply(lambda x: x.replace("(", "")).apply(pd.to_numeric,1)
  BV_border["lat"]=BV_border["lat"].apply(lambda x: x.replace(")", "")).apply(pd.to_numeric,1)
  BV_border.head()
  BV_border.lon
  BV_border.append(BV_border, ignore_index=True)
  print(BV_border.head())
  print(BV_border)
  X = []
  return X

def shp2csv(shp_file):
  '''Outputs a csv file based on input shapefile vertices'''
  out = os.path.splitext(shp_file)[0]+'_pnts.csv'
  with open(out, 'w') as csv:
    with shapefile.Reader(shp_file) as sf:
      for shp_rec in sf.shapeRecords():
        csv.write('{}\n'.format(shp_rec.record))
        for pnt in shp_rec.shape.points:
          csv.write('{}\n'.format(pnt))

def output_netcdf():
  return

def main():
  '''
  thresholds[_] = [.......]
  '''
 # thresholds = read_csv()
  area = define_area()

'''
  for root, dirs, files in os.walk(os.getcwd()):
    for file in files:
      if file.endswith('.nc'):
        print(os.path.join(root, file))
'''
'''
  for i in range(len(volc)):
    if float(volc[i][2]) < 0:
      volc[i][2] += 360
    #if (volc[i][1] == '262000'): #comment out
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
    print('Done: '+str(i+1)+'/'+str(len(volc)))
'''

if __name__ == '__main__':
  main()
