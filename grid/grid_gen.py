import csv
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
  if (grid.cross_zn or grid.cross_eq) == '0':
    [TL_lat, TL_lon] = utm.to_latlon(grid.min_east, grid.max_north, grid.zone)
    [TR_lat, TR_lon] = utm.to_latlon(grid.max_east, grid.max_north, grid.zone)
    [BL_lat, BL_lon] = utm.to_latlon(grid.min_east, grid.min_north, grid.zone)
    [BR_lat, BR_lon] = utm.to_latlon(grid.max_east, grid.min_north, grid.zone)

    min_lat = min([TL_lat, BL_lat])
    max_lat = max([TR_lat, BR_lat])
    min_lon = min([BL_lon, BR_lon])
    max_lon = max([TL_lon, TR_lon])

  elif (grid.cross_zn and grid.cross_eq) == '1':
    [TL_lat, TL_lon] = utm.to_latlon(grid.min_east, grid.max_north, grid.zone_W)
    [TR_lat, TR_lon] = utm.to_latlon(grid.max_east, grid.max_north, grid.zone_E)
    [BL_lat, BL_lon] = utm.to_latlon(grid.min_east, grid.min_north, grid.zone_W)
    [BR_lat, BR_lon] = utm.to_latlon(grid.max_east, grid.min_north, grid.zone_E)

    min_lat = 
    m
    m
    m

  elif (grid.cross_zn == '1'):
    []
    []
    []
    []

    m
    m
    m
    m

  else:
    []
    []
    []
    []

    m
    m
    m
    m

  []
  []

  correction

  x_vec
  y_vec


def set_params(params):
  grid = Grid()
  grid.name = params[0]
  grid.id_num = params[1]
  grid.min_east = params[2]
  grid.max_east = params[3]
  grid.min_north = params[4]
  grid.max_north = params[5]
  grid.res = params[11]
  grid.vent_zone = params[10]
  grid.elevation = params[12]
  grid.cross_zn = params[13]
  grid.cross_eq = params[14]
  if (grid.cross_zn or grid.cross_eq) == '0':
    grid.zone = grid.vent_zone
  elif (grid.cross_zn and grid.cross_eq) == '1':
    grid.zone_NW = params[6]
    grid.zone_NE = params[7]
    grid.zone_SW = params[8]
    grid.zone_SE = params[9]
  elif (grid.cross_zn == '1'):
    grid.zone_W = params[6]
    grid.zone_E = params[7]
  else:
    grid.zone_N = params[6]
    grid.zone_S = params[8]
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


if __name__ == '__main__':
  main()


