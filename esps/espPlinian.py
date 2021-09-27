import csv
import numpy as np

'''
Populate T2_stor.txt with:
    ./binary .conf .utm .gen .gsd > .out

    .conf contains:
        PLUME_HEIGHT
        ERUPTION_MASS
        VENT_EASTING
        VENT_NORTHING
        VENT_ELEVATION
        EDDY_CONST
        DIFFUSION_COEFFICIENT
        FALL_TIME_THRESHOLD
        LITHIC_DENSITY
        PUMICE_DENSITY
        COL_STEPS
        PART_STEPS
        PLUME_MODEL
        ALPHA
        BETA

    .gsd eg:
        -6  0.01~
        -5
        -4
        -3
        -2
        -1
        0
        1
        2
        3
        4
        5
        6
        7   0.99~
        8   1
'''

class ESP:
  run_name = ''
  out_name = ''
  grid_pth = ''
  wind_pth = ''
  volcano_name = ''
  vent_easting = 0.0
  vent_northing = 0.0
  vent_zone = 0
  vent_ht = 0
  min_ht = 0
  max_ht = 0
  min_mass = 0
  max_mass = 0
  min_dur = 0
  max_dur = 0
  constrain = 0
  nb_wind = 0
  wind_start = '01-Jan-2012 00:00:00'
  wind_per_day = 4
  seasonality = 0
  wind_start_rainy = 0
  wind_start_dry = 0
  constrain_eruption_date = 0
  


def generate_confs(esp):
  '''
  for seasonality_length:
    for nb_runs:
  '''
  ## Loop counters
  seas_str = ['all'];
  if (esp[19] == 0):
    seas_str = ['all', 'rainy', 'dry'];
    ## get wind profile for each subseason

  ### Main loop
  for i in range(np.size(seas_str)):
    print("seas_str:"+seas_str[i])
    print(esp[40])
    for j in range(int(esp[40])):
      print(j)

def convert_esp(esp):
  if esp[16] == 'NA':
    esp[16] = 0
  if esp[17] == 'NA':
    esp[17] = 'NA'
  if esp[47] == 'NA':
    esp[47] = 0
  if esp[48] == 'NA':
    esp[48] = 0

  esp[5:7] = [float(x) for x in esp[5:7]]
  esp[7:17] = [int(x) for x in esp[7:17]]
  esp[19:49] = [int(x) for x in esp[19:49]]
  esp[49] = float(esp[49])
  esp[50:57] = [int(x) for x in esp[50:57]]
  esp[57] = float(esp[57])

  return esp

def read_csv():
  csvfile = "tephra_esp.csv"
  with open(csvfile, 'r', encoding="ISO-8859-1") as csv_grid_f:
    csv_grid_r = csv.reader(csv_grid_f, )
    P = []
    next(csv_grid_r)
    for row in csv_grid_r:
      row[5] = row[5].replace(" ","")
      #P.append(row[1:6]+[float(x) for x in row[6:8]]+[int(x) for x in row[8:11]]+row[10:])
      P.append(row[1:])
  P = np.vstack(P)
  return P

def main():
  '''
  esps[_] = [run_name, out_name, grid_pth, wind_pth, volcano_name, vent_easting, vent_northing, vent_zone, vent_ht, min_ht, max_ht, min_mass, max_mass, min_dur, max_dur, constrain, nb_wind, wind_start, wind_per_day, seasonality, wind_start_rainy, wind_start_dry, constrain_eruption_date, eruption_date, constrain_wind_dir, min_wind_dir, max_wind_dir, trop_height, max_phi, min_phi, min_med_phi, max_med_phi, min_std_phi, max_std_phi, min_agg, max_agg, max_diam, long_lasting, ht_sample, mass_sample, nb_runs, write_conf, write_gs, write_fig_sep, write_fig_all, write_log_sep, write_log_all, par, par_cpu, eddy_const, diff_coeff, ft_thresh, lithic_dens, pumice_dens, col_step, part_step, alpha, beta]
  '''
  esps = read_csv()
  for i in range(np.shape(esps)[0]):
    if (i == 64):
      esp_row = convert_esp(esps[i])
      print(esps[i], esps[i].shape)
      print(esp_row, esp_row.shape)
      generate_confs(esp_row)
    #generate_confs(esps[i])

if __name__ == '__main__':
  main()
