import csv
import numpy as np
from datetime import date, datetime

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
  run_nb = 0 # init this
  run_type = 'P'
  def __init__(self, esp_row):
    self.run_name = esp_row[0]
    self.out_name = esp_row[1]
    self.grid_pth = esp_row[2] # path to volc_id.utm
    self.wind_pth = '../wind/gen_files/262000/' #esp_row[3] # path to volc_id/.gen files
    self.volcano_name = esp_row[4]
    self.vent_easting = float(esp_row[5])
    self.vent_northing = float(esp_row[6])
    self.vent_zone = int(esp_row[7])
    self.vent_ht = int(esp_row[8])
    self.min_ht = int(esp_row[9])
    self.max_ht = int(esp_row[10])
    self.min_mass = int(esp_row[11])
    self.max_mass = int(esp_row[12])
    self.min_dur = int(esp_row[13])
    self.max_dur = int(esp_row[14])
    self.constrain = int(esp_row[15])
    self.nb_wind = (lambda: esp_row[16], lambda: 14196)[esp_row[16] == 'NA']()
    self.wind_start = '01-Jan-2012 00:00:00'
    self.wind_per_day = 4
    self.seasonality = int(esp_row[19])
    self.wind_start_rainy = int(esp_row[20])
    self.wind_start_dry = int(esp_row[21])
    self.constrain_eruption_date = int(esp_row[22])
    self.eruption_date = int(esp_row[23])
    self.constrain_wind_dir = int(esp_row[24])
    self.min_wind_dir = int(esp_row[25])
    self.max_wind_dir = int(esp_row[26])
    self.trop_height = int(esp_row[27])
    self.max_phi = int(esp_row[28])
    self.min_phi = int(esp_row[29])
    self.min_med_phi = int(esp_row[30])
    self.max_med_phi = int(esp_row[31])
    self.min_std_phi = int(esp_row[32])
    self.max_std_phi = int(esp_row[33])
    self.min_agg = int(esp_row[34])
    self.max_agg = int(esp_row[35])
    self.max_diam = int(esp_row[36])
    self.long_lasting = int(esp_row[37])
    self.ht_sample = int(esp_row[38])
    self.mass_sample = int(esp_row[39])
    self.nb_runs = int(esp_row[40])
    self.write_conf = int(esp_row[41])
    self.write_gs = int(esp_row[42])
    self.write_fig_sep = int(esp_row[43])
    self.write_fig_all = int(esp_row[44])
    self.write_log_sep = int(esp_row[45])
    self.write_log_all = int(esp_row[46])
    self.par = (lambda: esp_row[47], lambda: 0)[esp_row[47] == 'NA']()
    self.par_cpu = (lambda: esp_row[48], lambda: 0)[esp_row[48] == 'NA']()
    self.eddy_const = float(esp_row[49])
    self.diff_coefff = int(esp_row[50])
    self.ft_thresh = int(esp_row[51])
    self.lithic_dens = int(esp_row[52])
    self.pumice_dens = int(esp_row[53])
    self.col_step = int(esp_row[54])
    self.part_step = int(esp_row[55])
    self.alpha = int(esp_row[56])
    self.beta = float(esp_row[57])

''' ----------------------------------------------------- MAIN ---------------------------------------------------------- '''

def wind_file(ordinal):
  dt = datetime.fromordinal(int(ordinal-366))
  hr = ordinal % 1
  file_string = str(dt.year)+'_'+f"{dt.month:02}"+'_'+f"{dt.day:02}"+'_'+f"{int(hr*24.0):02}"
  return file_string

def generate_confs(esp):
  '''
  for seasonality_length:
    for nb_runs:
  '''
  d = datetime.strptime(esp.wind_start, '%d-%b-%Y %H:%M:%S')
  wind_vec_all = np.arange(date.toordinal(d)+366, (date.toordinal(d)+366+esp.nb_wind/esp.wind_per_day), 1/esp.wind_per_day)

  ## Loop counters
  seas_str = ['all'];
  if (esp.seasonality == 1):
    seas_str = ['all', 'rainy', 'dry'];
    ## get wind profile for each subseason, seperate function
  #wind_vec_all = ((wind_vec_all-(date.toordinal(d)+366))*esp.wind_per_day)+1  #### [1, 2, 3 ... 14196] ??? can optimise a lot if seasonality == 0
  #### change so format is ['2012_10_19_18'... or similar for wind file names]

  wind_vec = 12
  wind_prof = open(esp.wind_pth+'262000_'+wind_file(wind_vec_all[wind_vec])+'.gen', 'r')
  print(wind_prof)
  for line in wind_prof:
    print([f(v) for (f, v) in zip((int, float, float, lambda v: v == 'True'), line.strip().split())])
  # create structured array to hold these different datatypes
  '''
  ### Main loop
  for i in range(np.size(seas_str)):
    mass_stor_tot     = np.zeros((esp.nb_runs, 1))
    mass_stor_tot_all = []
    height_stor_tot   = []
    dur_stor_tot      = np.zeros((esp.nb_runs, 1))
    mer_stor_tot      = []
    date_stor_tot     = np.zeros((esp.nb_runs, 6))
    med_stor_tot      = np.zeros((esp.nb_runs, 1))
    std_stor_tot      = np.zeros((esp.nb_runs, 1))
    agg_stor_tot      = np.zeros((esp.nb_runs, 1))

    count_tot = 0
    count_run = 0

    #### make output folders

    wind_vec_seas = wind_vec_all  ### modify for other seasons if needed

    for j in range(esp.nb_runs):
      ## out folders for each
      ## write_conf, write_fig_sep == 0

      test_run = 0

      while (test_run == 0):
        count_tot++
        dur = esp.min_dur*3600 + (esp.max_dur*3600-esp.min_dur*3600)*np.random.rand(1)

        ### long_lasting == 0
        nb_sim = 1

        dur_tmp = np.zeros((nb_sim, 1))

        ht_tmp    = np.zeros((nb_sim, 1))
        mer_tmp   = np.zeros((nb_sim, 1))
        mass_tmp  = np.zeros((nb_sim, 1))
        speed_tmp = np.zeros((nb_sim, 1))
        dir_tmp   = np.zeros((nb_sim, 1))

        check_seas = 0
        while (check_seas == 0):
          ## constrain_eruption_date == 0
          date_start = wind_vec_seas(np.random.randint(len(wind_vec_seas)))
          ## long_lasting == 0
          dur_tmp[0] = dur
          wind_vec = [date_start] #(date_start:(date_start+nb_sim-1))

          if (len(unique(intersect(wind_vec_seas, wind_vec))) == len(unique(wind_vec)):
            check_seas = 1
          else:
            continue
        ## long_lasting == 0, ht_sample == 0
        ht_tmp[:,0] = esp.min_ht+((esp.max_ht)-(esp.min_ht))*np.random.rand(1)

        ## nb_sim == 1 so no loop
        wind_prof = load(esp.wind_path+'262000_'+wind_file(wind_vec_all[wind_vec])+'.gen', 'r')
        
      continue
'''
''' --------------------------------------------------------------------------------------------------------------------- '''

def read_csv():
  csvfile = "tephra_esp.csv"
  with open(csvfile, 'r', encoding="ISO-8859-1") as csv_grid_f:
    csv_grid_r = csv.reader(csv_grid_f, )
    P = []
    next(csv_grid_r)
    for row in csv_grid_r:
      row[5] = row[5].replace(" ","")
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
      esp_i = ESP(esps[i])
     # esp_row = convert_esp(esps[i])
      print(esps[i], esps[i].shape)
      print(esp_i, esp_i.nb_wind)
      generate_confs(esp_i)
    #generate_confs(esps[i])

if __name__ == '__main__':
  main()
