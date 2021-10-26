import csv
import utm
import numpy as np
# PARAMS
'''
name = name
min_east
max_east
min_north
max_north
res
vent_zone
elevation
cross_zn
cross_eq
zone
zone_W
zone_E
zone_N
zone_S
zone_NW
zone_NE
zone_SW
zone_SE
'''
csvfile = 'volc_grids.csv'

class Grid:
  name = ''
  id_num = 0
  min_east = 0
  max_east = 0
  min_north = 0
  max_north = 0
  res = 0
  vent_zone = 0
  elevation = 0
  cross_zn = 0
  cross_eq = 0
  zone = 0
  zone_W = 0
  zone_E = 0
  zone_N = 0
  zone_S = 0
  zone_NW = 0
  zone_NE = 0
  zone_SW = 0
  zone_SE = 0

def create_grid(grid):
  if (grid.cross_zn or grid.cross_eq) == 0:
    [TL_lat, TL_lon] = utm.to_latlon(grid.min_east, grid.max_north, abs(grid.zone), northern=True if grid.zone > 0 else False)
    [TR_lat, TR_lon] = utm.to_latlon(grid.max_east, grid.max_north, abs(grid.zone), northern=True if grid.zone > 0 else False)
    [BL_lat, BL_lon] = utm.to_latlon(grid.min_east, grid.min_north, abs(grid.zone), northern=True if grid.zone > 0 else False)
    [BR_lat, BR_lon] = utm.to_latlon(grid.max_east, grid.min_north, abs(grid.zone), northern=True if grid.zone > 0 else False)

    min_lat = min([TL_lat, BL_lat])
    max_lat = max([TR_lat, BR_lat])
    min_lon = min([BL_lon, BR_lon])
    max_lon = max([TL_lon, TR_lon])

  elif (grid.cross_zn and grid.cross_eq) == 1:
    [TL_lat, TL_lon] = utm.to_latlon(grid.min_east, grid.max_north, abs(grid.zone_NW), northern=True if grid.zone_NW > 0 else False)
    [TR_lat, TR_lon] = utm.to_latlon(grid.max_east, grid.max_north, abs(grid.zone_NE), northern=True if grid.zone_NE > 0 else False)
    [BL_lat, BL_lon] = utm.to_latlon(grid.min_east, grid.min_north, abs(grid.zone_SW), northern=True if grid.zone_SW > 0 else False)
    [BR_lat, BR_lon] = utm.to_latlon(grid.max_east, grid.min_north, abs(grid.zone_SE), northern=True if grid.zone_SE > 0 else False)

    min_lat = min([TL_lat, BL_lat])
    max_lat = max([TR_lat, BR_lat])
    min_lon = min([BL_lon, BR_lon])
    max_lon = max([TL_lon, TR_lon])

  elif (grid.cross_zn == 1):
    [TL_lat, TL_lon] = utm.to_latlon(grid.min_east, grid.max_north, abs(grid.zone_W), northern=True if grid.zone_W > 0 else False)
    [TR_lat, TR_lon] = utm.to_latlon(grid.max_east, grid.max_north, abs(grid.zone_E), northern=True if grid.zone_E > 0 else False)
    [BL_lat, BL_lon] = utm.to_latlon(grid.min_east, grid.min_north, abs(grid.zone_W), northern=True if grid.zone_W > 0 else False)
    [BR_lat, BR_lon] = utm.to_latlon(grid.max_east, grid.min_north, abs(grid.zone_E), northern=True if grid.zone_E > 0 else False)

    min_lat = min([TL_lat, BL_lat])
    max_lat = max([TR_lat, BR_lat])
    min_lon = min([BL_lon, BR_lon])
    max_lon = max([TL_lon, TR_lon])

  else:
    [TL_lat, TL_lon] = utm.to_latlon(grid.min_east, grid.max_north, abs(grid.zone_N), northern=True if grid.zone_N > 0 else False)
    [TR_lat, TR_lon] = utm.to_latlon(grid.max_east, grid.max_north, abs(grid.zone_N), northern=True if grid.zone_N > 0 else False)
    [BL_lat, BL_lon] = utm.to_latlon(grid.min_east, grid.min_north, abs(grid.zone_S), northern=True if grid.zone_S > 0 else False)
    [BR_lat, BR_lon] = utm.to_latlon(grid.max_east, grid.min_north, abs(grid.zone_S), northern=True if grid.zone_S > 0 else False)

    min_lat = min([TL_lat, BL_lat])
    max_lat = max([TR_lat, BR_lat])
    min_lon = min([BL_lon, BR_lon])
    max_lon = max([TL_lon, TR_lon])

  [min_e, min_n, n, l] = utm.from_latlon(min_lat, min_lon, force_zone_number=abs(grid.vent_zone)) #, northern=False)
  [max_e, max_n, n, l] = utm.from_latlon(max_lat, max_lon, force_zone_number=abs(grid.vent_zone)) #, northern=False)

  if grid.cross_eq == 1:
      if grid.vent_zone < 0:
          max_n = max_n + 1e7
      else:
          min_n = -(1e7-min_n)

  x_vec = np.arange(min_e, max_e, grid.res)
  y_vec = np.arange(min_n, max_n, grid.res)
  print("x,y: ")
  #print(x_vec)
  #print(y_vec)

  [utmx, utmy] = np.meshgrid(x_vec, y_vec, indexing='xy')
  utmy = np.flipud(utmy)

  print(utmx.size)
  print(utmy.size)

  utm_g = fill_matrix(utmx, utmy, grid)
  print("------------UTM--------------")
  print(utm_g)
  file_utm = open('krak.utm', 'w')
  np.savetxt(file_utm, utm_g, fmt='%d')
  #for i in range(utm_g.shape[0]):
  #  np.savetxt(file_utm, utm_g[i,:])
  file_utm.close()
  #write_matrix(grid, lat, lon, utm, utmx, utmy, dat)

def fill_matrix(utmx, utmy, grid):
  col = utmx.shape[1] #np.shape(utmx, 1)
  lin = utmx.shape[0] #np.shape(utmx, 0)
  print(lin, col)

  utm_g = np.zeros((np.size(utmy),3))
  utm_g[:,2] = np.ones((np.size(utmy)))*grid.elevation

  j = 0
  for i in range(1,lin+1):
    utm_g[j:i*col,0] = np.ndarray.round(np.squeeze(utmx[i-1,:]))
    utm_g[j:i*col,1] = np.ndarray.round(np.squeeze(utmy[i-1,:]))
    j = i*col

  print(111*111)
  print(utm_g.shape)
  return utm_g

def set_params(params):
  grid = Grid()
  grid.name = params[0]
  grid.id_num = params[1]
  grid.min_east = float(params[2])
  grid.max_east = float(params[3])
  grid.min_north = float(params[4])
  grid.max_north = float(params[5])
  grid.res = float(params[11])
  grid.vent_zone = int(params[10])
  grid.elevation = int(params[12])
  grid.cross_zn = int(params[13])
  grid.cross_eq = int(params[14])
  if (grid.cross_zn or grid.cross_eq) == 0:
    grid.zone = grid.vent_zone
  elif (grid.cross_zn and grid.cross_eq) == 1:
    grid.zone_NW = int(params[6])
    grid.zone_NE = int(params[7])
    grid.zone_SW = int(params[8])
    grid.zone_SE = int(params[9])
  elif (grid.cross_zn == 1):
    grid.zone_W = int(params[6])
    grid.zone_E = int(params[7])
  elif (grid.cross_eq == 1):
    grid.zone_N = int(params[6])
    grid.zone_S = int(params[8])
  return grid

def read_csv():
  with open(csvfile, 'r', encoding="ISO-8859-1") as csv_grid_f:
    csv_grid_r = csv.reader(csv_grid_f, )
    P = []
    next(csv_grid_r)
    for row in csv_grid_r:
      row[1] = row[1].replace(" ","")
      P.append(row[1:14]+row[15:17])
  P = np.vstack(P)
  return P

def main():
  '''
  params[_] = [name_no_spaces, id_number, min_easting, max_easting, min_northing, max_northing, NW_zone, NE_zone, SW_zone, SE_zone, vent_zone, resolution, mean_elevation, zone_crossing, equator_crossing]
  '''
  params = read_csv()
  grid = set_params(params[64])
  attrs = vars(grid)
  print(', '.join("%s: %s" % item for item in attrs.items()))
  #print(grid)
  print(params[64])
  create_grid(grid)


if __name__ == '__main__':
  main()


