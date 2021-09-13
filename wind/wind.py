import numpy as np
import csv
import cdsapi
import sys

def get_csv_coords():
  with open('volc_holo_mody.csv', 'r', encoding="ISO-8859-1") as csv_wind_f:
    csv_wind_r = csv.reader(csv_wind_f, )
    C = []
    N = []
    for row in csv_wind_r:
      C.append(row[5:9])
      N.append(row[1])
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

def main():
  y = sys.argv[1]
  c = cdsapi.Client()
  NWSE, VOLC = get_csv_coords()
  pro, f, v, pre, m, d, t = get_params()
  for i in range(0, len(NWSE)):
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
          "wind_{name}_{year}.nc".format(name=VOLC[i][0].replace(" ",""),year=y)
          )

if __name__ == '__main__':
  main()
