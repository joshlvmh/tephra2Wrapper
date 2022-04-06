'''
ERA5 Dataset Wind Download for Tephra2
Input: CSV file containing volcano data
Outputs: NetCDF files containing wind data

Joshua Measure-Hughes
Created: 13-09-2021
Last Edited: 06-04-2022
'''

import numpy as np
import csv
import cdsapi
import sys
import os.path
import argparse

parser = argparse.ArgumentParser(
    description="Download Wind Data from ERA5 Dataset",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
default_csv_file = 'wind.csv'
parser.add_argument("--wind-csv", default=default_csv_file)
parser.add_argument("--year", default=1979)

# output & input paths, command line args, default args

def get_csv_coords(csv_file):
  csv_full_path = os.environ['INPUTS']+'/'+csv_file
  with open(csv_full_path, 'r', encoding="ISO-8859-1") as csv_wind_f:
    csv_wind_r = csv.reader(csv_wind_f, )
    C = []
    N = []
    for row in csv_wind_r:
      C.append(row[6:10])
      N.append(row[2])
    C = np.vstack(C)
    N = np.vstack(N)
    C = np.delete(C, (0), axis=0)
    N = np.delete(N, (0), axis=0)
    perm = [0, 2, 3, 1]
    idx = np.empty_like(perm)
    idx[perm] = np.arange(len(perm))
    C[:] = C[:, idx]
    return C.tolist(), N

def get_params():
  pro = 'reanalysis'
  f = 'netcdf'
  v = ['u_component_of_wind', 'v_component_of_wind']
  pre1 = [1, 2, 3, 5, 7, 10, 20, 30, 50, 70]
  pre2 = np.arange(100,250,25)
  pre3 = np.arange(250,800,50)
  pre4 = np.arange(775,1025,25)
  pre = [str(z) for z in np.concatenate((pre1,pre2,pre3,pre4))]
  m = [str(z) for z in np.arange(1,13)]
  d = [str(z) for z in np.arange(1,32)]
  t = ['00:00', '06:00', '12:00', '18:00']
  return pro, f, list(v), pre, m, d, list(t)

def main(args):
  y = args.year
  c = cdsapi.Client()
  NWSE, VOLC = get_csv_coords(args.wind_csv)
  pro, f, v, pre, m, d, t = get_params()
  out_path = os.path.join(os.environ['OUT'], 'wind/nc_files')
  if not os.path.exists(out_path):
    os.makedirs(out_path)
  for i in range(0, len(NWSE)):
    if os.path.exists(out_path + "/wind_{name}_{year}.nc".format(name=VOLC[i][0],year=y)) == False:
      c.retrieve(
          'reanalysis-era5-pressure-levels',
          {
            'product_type': pro,
            'format': f,
            'variable': v,
            'pressure_level': pre,
            'year': y,
            'month': m,
            'day': d,
            'time': t,
            'area': NWSE[i],
          },
          out_path+"{name}_{year}.nc".format(name=VOLC[i][0].replace(" ",""),year=y)
          )

if __name__ == '__main__':
  main(parser.parse_args())
