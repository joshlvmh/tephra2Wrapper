import csv
import numpy as np
from datetime import date, datetime
import math
from scipy.stats import norm
import warnings
import pytest
import os

csv_file = os.environ['INPUTS']+'/VEI2_ESP.csv'
'''
Generate .confs & select .gens
Populate T2_stor.txt with:
    ./binary .conf .utm .gen > .out
October 2021
Joshua Measure-Hughes
'''

class RUN:
  '''
  vent_easting
  vent_northing
  vent_elevation
  plume_height # ht_tmp
  alpha
  beta
  eruption_mass # mass_tmp
  max_grainsize
  min_grainsize
  median_grainsize
  std_grainsize
  eddy_const
  diffusion_coefficient
  fall_time_threshold
  lithic_density
  pumice_density
  col_steps
  part_steps
  plume_model
  '''
  def __init__(self, esp):
    self.vent_easting = esp.vent_easting
    self.vent_northing = esp.vent_northing
    self.vent_elevation = esp.vent_ht
    self.alpha = esp.alpha
    self.beta = esp.beta
    self.max_grainsize = esp.max_phi
    self.min_grainsize = esp.min_phi
    self.eddy_const = esp.eddy_const
    self.diffusion_coefficient = esp.diff_coeff
    self.fall_time_threshold = esp.ft_thresh
    self.lithic_density = esp.lithic_dens
    self.pumice_density = esp.pumice_dens
    self.col_steps = esp.col_step
    self.part_steps = esp.part_step
    self.plume_model = 2
    self.run_digits = len(str(abs(esp.nb_runs-1)))
    self.volc_id = esp.v_id

  def set_vals(self, pl_ht, er_ma, med_g, std_g, wind_f):
    self.plume_height = pl_ht
    self.eruption_mass = er_ma
    self.median_grainsize = med_g[0]
    self.std_grainsize = std_g[0]
    self.wind_file = wind_f

  def write_conf(self, seas, j, nb_sim):
    sim_digits = len(str(abs(nb_sim-1)))
    if (True): #esp.write_conf == 1):
      for k in range(nb_sim): # increase self.... to [nb_sim] - check works
        lines = ['VENT_EASTING '+str(self.vent_easting),
                 'VENT_NORTHING '+str(self.vent_northing),
                 'VENT_ELEVATION '+str(self.vent_elevation),
                 'PLUME_HEIGHT '+str(self.plume_height[k,0]),
                 'ALPHA '+str(self.alpha),
                 'BETA '+str(self.beta),
                 'ERUPTION_MASS '+str(self.eruption_mass[k,0]),
                 'MAX_GRAINSIZE '+str(self.max_grainsize),
                 'MIN_GRAINSIZE '+str(self.min_grainsize),
                 'MEDIAN_GRAINSIZE '+str(self.median_grainsize),
                 'STD_GRAINSIZE '+str(self.std_grainsize),
                 'EDDY_CONST '+str(self.eddy_const),
                 'DIFFUSION_COEFFICIENT '+str(self.diffusion_coefficient),
                 'FALL_TIME_THRESHOLD '+str(self.fall_time_threshold),
                 'LITHIC_DENSITY '+str(self.lithic_density),
                 'PUMICE_DENSITY '+str(self.pumice_density),
                 'COL_STEPS '+str(self.col_steps),
                 'PART_STEPS '+str(self.part_steps),
                 'PLUME_MODEL '+str(self.plume_model)]
        conf_file = seas+'/'+f"{j:0{self.run_digits}}"+'_'+f"{k:0{sim_digits}}"+'.txt'
        out_file  = seas+'/'+f"{j:0{self.run_digits}}"+'_'+f"{k:0{sim_digits}}"+'.out'
        with open(os.environ['CONF']+'/'+conf_file, 'w+') as f: # change to $CONF
          f.writelines('\n'.join(lines))
        self.write_t2(conf_file, out_file)

  def write_t2(self, conf_file, out_file):
    binary = '$BINARY'
    conf = '$CONF/'+conf_file # already got confs/
    wind = '$WIND/'+self.volc_id+'/'+self.wind_file
    grid = '$GRID/'+self.volc_id+'.utm'
    out  = '$OUT/'+out_file
    line = binary + ' ' + conf + ' ' + grid + ' ' + wind + ' > ' + out
    with open('t2.txt', 'a+') as f:
      f.write(line + '\n')

class ESP:
  run_nb = 0 # init this
  run_type = 'P' # needed?
  def __init__(self, esp_row):
    self.run_name = esp_row[0]
    self.out_name = esp_row[1]
    self.v_id = '262000' # update
    self.grid_pth = os.environ['GRID']
    self.wind_pth = os.environ['WIND']+'/'+self.v_id+'/'
    self.volcano_name = esp_row[4]
    self.vent_easting = float(esp_row[5])
    self.vent_northing = float(esp_row[6])
    self.vent_zone = int(esp_row[7])
    self.vent_ht = int(esp_row[8])
    self.min_ht = int(esp_row[9])
    self.max_ht = int(esp_row[10])
    self.min_mass = int(float(esp_row[11]))
    self.max_mass = int(float(esp_row[12]))
    self.min_dur = (lambda: int(esp_row[13]), lambda: 1)[esp_row[13] == 'NA']()
    self.max_dur = (lambda: int(esp_row[14]), lambda: 6)[esp_row[14] == 'NA']()
    self.constrain = int(esp_row[15])
    self.nb_wind = (lambda: int(esp_row[16]), lambda: 14172)[esp_row[16] == 'NA']()
    self.wind_start = '01-Jan-2012 00:00:00'
    self.wind_per_day = int(esp_row[18])
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
    self.min_med_phi = float(esp_row[30])
    self.max_med_phi = float(esp_row[31])
    self.min_std_phi = float(esp_row[32])
    self.max_std_phi = float(esp_row[33])
    self.min_agg = int(esp_row[34])
    self.max_agg = int(esp_row[35])
    self.max_diam = int(esp_row[36])
    self.long_lasting = int(esp_row[37])
    self.ht_sample = (lambda: int(esp_row[38]), lambda: 0)[esp_row[38] == 'NA']()
    self.mass_sample = (lambda: int(esp_row[39]), lambda: 0)[esp_row[39] == 'NA']()
    self.nb_runs = int(esp_row[40])
    self.write_conf = 1 #int(esp_row[41])
    self.write_gs = int(esp_row[42])
    self.write_fig_sep = int(esp_row[43])
    self.write_fig_all = int(esp_row[44])
    self.write_log_sep = int(esp_row[45])
    self.write_log_all = int(esp_row[46])
    self.par = (lambda: int(esp_row[47]), lambda: 0)[esp_row[47] == 'NA']()
    self.par_cpu = (lambda: int(esp_row[48]), lambda: 0)[esp_row[48] == 'NA']()
    self.eddy_const = float(esp_row[49])
    self.diff_coeff = int(esp_row[50])
    self.ft_thresh = int(esp_row[51])
    self.lithic_dens = int(esp_row[52])
    self.pumice_dens = int(esp_row[53])
    self.col_step = int(esp_row[54])
    self.part_step = int(esp_row[55])
    self.alpha = int(esp_row[56])
    self.beta = float(esp_row[57])

    self.check_vals()

  def check_vals(self):
    ## filepaths exist
    ## will this be necessary long term?
    print(self.wind_pth)
    assert(os.path.exists(self.wind_pth))
    assert(os.path.exists(self.grid_pth))
    assert(self.max_ht >= self.min_ht)
    assert(self.max_mass >= self.min_mass)
    assert(self.max_dur >= self.min_dur)
    assert(self.min_phi >= self.max_phi)
    assert(self.max_med_phi >= self.min_med_phi)
    assert(self.max_std_phi >= self.min_std_phi)
    assert(self.max_agg >= self.min_agg)
    if (self.seasonality == 1 and self.constrain_eruption_date == 1):
      self.seasonality = 0
      print("Both seasonality and constrain eruption date were set to 1. Seasonality set to 0.")

''' ----------------------------------------------------- MAIN ---------------------------------------------------------- '''

def wind_file(ordinal):
  dt = datetime.fromordinal(int(ordinal-366))
  hr = ordinal % 1
  file_string = str(dt.year)+'_'+f"{dt.month:02}"+'_'+f"{dt.day:02}"+'_'+f"{int(hr*24.0):02}"
  return file_string

def generate_confs(esp):
  d = datetime.strptime(esp.wind_start, '%d-%b-%Y %H:%M:%S')
  wind_vec_all = np.arange(date.toordinal(d)+366, (date.toordinal(d)+366+esp.nb_wind/esp.wind_per_day), 1/esp.wind_per_day)

  seas_str = ['all'];
  if (esp.seasonality == 1):
    seas_str = ['all', 'rainy', 'dry']
    m_dry = datetime.strptime(esp.wind_start_dry, '%B').month
    m_rainy = datetime.strptime(esp.wind_start_rainy, '%B').month

    if (m_rainy > m_dry):
      range_dry = np.arange(m_dry, m_rainy)
      range_rainy = np.arange(1,13)
      range_rainy = np.setdiff1d(range_rainy, range_dry)
    else:
      range_rainy = np.arange(m_rainy, m_dry)
      range_dry = np.arange(1,13)
      range_dry = np.setdiff1d(range_dry, range_rainy)

    wind_vec_rainy = np.fromiter((x for x in wind_vec_all if datetime.fromordinal(int(x-366)).month in range_rainy), dtype = wind_vec_all.dtype)
    wind_vec_dry = np.fromiter((x for x in wind_vec_all if datetime.fromordinal(int(x-366)).month in range_dry), dtype = wind_vec_all.dtype)

    ### change len() to np.size /shape
    if (esp.long_lasting == 1 and (esp.max_dur/esp.wind_per_day > len(wind_vec_dry) or esp.max_dur/esp.wind_per_day > len(wind_vec_rainy))):
      raise Exception('The eruption lasts longer than the seasons. Seasonality cannot be used in this case.')

 
  '''
  # make config and t2 output folders
  parent = '' # update?
  child = 'confs'
  path = os.path.join(parent, child)
  if not os.path.exists(path):
    os.mkdir(path)
  child = 'out'
  path = os.path.join(parent, child)
  if not os.path.exists(path):
    os.mkdir(path)'''

  ### make FIG and KML folders?

  ### Main loop
  for i in range(np.size(seas_str)):
    ### remove those don't end up using
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

    runs = [RUN(esp) for j in range(esp.nb_runs)]

    # make config output folder
    parent = os.environ['CONF'] # update?
    child = seas_str[i]
    path = os.path.join(parent, child)
    conf_path = path
    if not os.path.exists(path):
      os.mkdir(path)
    # make t2 output folder
    parent = os.environ['OUT']
    path = os.path.join(parent, child)
    if not os.path.exists(path):
      os.mkdir(path)

    if (seas_str[i] == 'all'):
      wind_vec_seas = wind_vec_all
    elif (seas_str[i] == 'dry'):
      wind_vec_seas = wind_vec_dry
    elif (seas_str[i] == 'rainy'):
      wind_vec_seas = wind_vec_rainy
    else:
      raise Exception('seas_str incorrectly set.')
      return

    for j in range(esp.nb_runs):
      ## folders per run? or if long lasting change from 0001 to 0001_1 etc?
      test_run = 0

      while (test_run == 0):
        count_tot = count_tot + 1
        dur = esp.min_dur*3600 + (esp.max_dur*3600-esp.min_dur*3600)*np.random.rand(1)

        if (esp.long_lasting == 0):
          nb_sim = 1
        else:
          nb_sim = math.ceil((dur/3600)/(24/esp.wind_per_day))

        dur_tmp = np.zeros((nb_sim, 1))

        ht_tmp    = np.zeros((nb_sim, 1))
        mer_tmp   = np.zeros((nb_sim, 1))
        mass_tmp  = np.zeros((nb_sim, 1))
        speed_tmp = np.zeros((nb_sim, 1))
        dir_tmp   = np.zeros((nb_sim, 1))

        check_seas = 0
        while (check_seas == 0):
          if (esp.constrain_eruption_date == 0):
            date_start = np.random.randint(wind_vec_seas.size)
          else:
            date_start = date.toordinal(datetime.strptime(esp.eruption_date, '%d-%b-%Y %H:%M:%S')) + 366
          date_start = wind_vec_seas[date_start]
          if (esp.long_lasting == 0):
            dur_tmp[0] = dur
          else:
            for k in range(nb_sim):
                if (k == nb_sim-1):
                  dur_tmp[k] = mod(dur, 3600*(24/esp.wind_per_day))
                else:
                  dur_tmp[k] = 3600*(24/esp.wind_per_day)

          wind_vec = np.arange(date_start, date_start+nb_sim)

          if (len(list(filter(lambda x: x in wind_vec_seas, wind_vec))) == len(list(set(wind_vec)))):
            check_seas = 1
          else:
            continue
        ## Plume height sampling
        if (esp.long_lasting == 0):
            if (esp.ht_sample == 0):
                ht_tmp[:,0] = esp.min_ht+((esp.max_ht)-(esp.min_ht))*np.random.rand(1)
            else:
                ht_tmp[:,0] = math.exp(math.log(esp.min_ht)+(math.log(esp.max_ht)-math.log(esp.min_ht))*np.random.rand(1))
        else:
            if (esp.ht_sample == 0):
                ht_tmp[:,0] = esp.min_ht+((esp.max_ht)-(esp.min_ht))*np.random.rand(nb_sim,1)
            else:
                ht_tmp[:,0] = math.exp(math.log(esp.min_ht)+(math.log(esp.max_ht)-math.log(esp.min_ht))*np.random.rand(nb_sim,1))

        ## remove this line when running
        #wind_vec[0] = int(1267)

        for k in range(nb_sim):
          W = []                    ## change ID to var
          wind_f = esp.v_id + '_' + wind_file(int(wind_vec[k]))+'.gen'
          wind_prof = open(esp.wind_pth + wind_f, 'r') # change to $WIND
          for line in wind_prof:
            W.append([f(v) for (f, v) in zip((int, float, float, lambda v: v == 'True'), line.strip().split())])
          W = np.vstack(W)
          #print(W[0][0])

          level1 = np.absolute(W[:,0]-esp.trop_height).argmin()
          level2 = np.absolute(W[:,0]-ht_tmp[k]).argmin()
          level3 = np.absolute(W[:,0]-esp.vent_ht).argmin()
          #print(level1, level2, level3, ht_tmp)

          speed_tmp[k] = W[level1-1,1]
          mer_tmp[k] = get_mer((ht_tmp[k] - esp.vent_ht), speed_tmp[k])
          with warnings.catch_warnings(): # fix this
            warnings.simplefilter("ignore", category=RuntimeWarning)
            dir_tmp[k] = np.median(W[level3-1:level2,2])

          if (esp.constrain == 0):
            if (esp.mass_sample == 0):
              mass_tmp[k] = (esp.min_mass + (esp.max_mass - esp.min_mass) * np.random.rand(1)) / (nb_sim);
             # print("MASS")
             # print(mass_tmp[k], esp.min_mass, esp.max_mass)
            else:
              mass_tmp[k] = 10 ** (math.log10(esp.min_mass) + ((math.log10(esp.max_mass)) - (math.log10(esp.min_mass))) * np.random.rand(1)) / (nb_sim+1)
          else:
            mass_tmp[k] = mer_tmp[k]*dur_tmp[k]
           # print("MASS")
           # print(mer_tmp[k], dur_tmp[k])

        if (esp.constrain_wind_dir == 1):
          if ((esp.min_wind_dir < esp.max_wind_dir) and (np.median(dir_tmp) > esp.min_wind_dir and np.median(dir_tmp) < esp.max_wind_dir)):
            test_wind = 1
          elif ((esp.min_wind_dir > esp.max_wind_dir) and ((np.median(dir_tmp) > esp.min_wind_dir and np.median(dir_tmp) <= 360) or (np.median(dir_tmp) < esp.max_wind_dir and np.median(dir_tmp) >= 0))):
            test_wind = 1
          else:
            test_wind = 0
        else:
          test_wind = 1

        if ((np.sum(mass_tmp) > esp.min_mass and np.sum(mass_tmp) < esp.max_mass and test_wind == 1) or esp.constrain == 0):
          #print("Valid run")
          test_run = 1
          count_run = count_run + 1

          gs_med  = (esp.min_med_phi + (esp.max_med_phi-esp.min_med_phi) * np.random.rand(1))
          gs_std  = (esp.min_std_phi + (esp.max_std_phi-esp.min_std_phi) * np.random.rand(1))
          gs_coef = (esp.min_agg+(esp.max_agg-esp.min_agg) * np.random.rand(1))
         # gs_pdf  = norm.pdf(np.arange(esp.max_phi,esp.min_phi+1),gs_med,gs_std)
         # gs      = [(np.arange(esp.max_phi,esp.min_phi).conj().T), gs_pdf.conj().T]
         # gs_tmp  = aggregate(gs, gs_coef, esp.max_diam)

        #  gs_cum = gs_pdf
        #  for k in range(gs_tmp.shape[0]):
        #    gs_cum[k] = np.sum(gs_tmp[0:k])/np.sum(gs_tmp)
        #  if (gs_cum == norm.cdf(gs_pdf)):
        #    print("norm.cdf works")
          #### max, min, std, and med needed for t2 new conf

          ## dont need log file or tgsd file

          ## save intermediate data to structure?

          ## write figs to file?

          runs[j].set_vals(ht_tmp, mass_tmp, gs_med, gs_std, wind_f)
          runs[j].write_conf(seas_str[i], j, nb_sim)
          print("Done: "+str(j))

          # global storage
          mass_stor_tot[j] = np.sum(mass_tmp)
          mass_stor_tot_all.append(mass_tmp)
          dur_stor_tot[j] = dur/3600
          mer_stor_tot.append(mer_tmp)
          date_stor_tot[j,:] = wind_file(wind_vec_all[1267])
          med_stor_tot[j] = gs_med
          std_stor_tot[j] = gs_std
          agg_stor_tot[j] = gs_coef
          if (esp.long_lasting == 0):
            height_stor_tot.append(np.unique(ht_tmp))
          else:
            height_stor_tot.append(ht_tmp)

          ### write figures

          ### write conf

          # dump all runs[j] into 000j.conf file
          # move specific wind file copy to 000j.txt file
       # break # while (test_run)
     # break   # for nb_runs
   # break     # for seas
  print("Finished config_gen")

def aggregate(GS, prc, max_diam):
  totgs_agg = GS
  idx_min   = np.where(GS[:][0] == max_diam)
  sum_ag    = 0

  for i in range(idx_min[0]-1,np.shape(GS[0])): #.shape[0]):
    agg = prc * GS[i][1]
    totgs_agg[i,1] = totgs_agg[i,1]-agg
    sum_ag = sum_agg + agg

  idx = np.where(GS[:][0] == -1)
  sum_ag = sum_ag / len(np.arange(idx,idx_min))

  totgs_agg[idx-1:idx_min-1, 1] = totgs_agg[idx-1:idx_min-1, 1] + sum_ag
  totgs_agg = totgs_agg[:,1]
  return totgs_agg

def get_mer(H, Vmax): # Degruyter & Bonadonna
  # constants
  g       = 9.81
  z_1     = 2.8
  R_d     = 287
  C_d     = 998
  C_s     = 1250
  theta_0 = 1300
  # entrainments
  alpha = 0.1
  beta  = 0.5
  # height of plume above vent (m)
  dummyH = H
  # atmosphere temperature profile (Woods, 1988)
  theta_a0 = 288
  P_0      = 101325
  rho_a0   = P_0/(R_d*theta_a0)
  H1       = 12000
  H2       = 20000
  tempGrad_1 = -6.5/1000
  tempGrad_2 = 0
  tempGrad_3 = 2/1000

  gprime = g * (C_s * theta_0 - C_d * theta_a0) / (C_d * theta_a0)

  G1 = pow(g, 2) / (C_d * theta_a0) * (1 + C_d / g * tempGrad_1)
  G2 = pow(g, 2) / (C_d * theta_a0) * (1 + C_d / g * tempGrad_2)
  G3 = pow(g, 2) / (C_d * theta_a0) * (1 + C_d / g * tempGrad_3)

  Gbar = G1 * np.ones(np.shape(dummyH))
  Gbar[dummyH>H1] = (G1 * H1 + G2 * (dummyH[dummyH>H1] - H1)) / dummyH[dummyH>H1]
  Gbar[dummyH>H1] = (G1 * H1 + G2 * (H2 - H1) + G3 * (dummyH[dummyH>H2] - H2)) / dummyH[dummyH>H2]
  Nbar = Gbar ** (1/2)

  Vbar = Vmax * dummyH / H1 / 2
  Vbar[dummyH>H1] = 1/dummyH[dummyH>H1] * (Vmax * H1/2 + Vmax * (dummyH[dummyH>H1]-H1) - 0.9*Vmax/(H2-H1) * (dummyH[dummyH>H1]-H1) ** 2 / 2)
  Vbar[dummyH>H2] = 1 / dummyH[dummyH>H2] * (Vmax * H1 / 2 + 0.55 * Vmax * (H2-H1) + 0.1 * Vmax * (dummyH[dummyH>H2]-H2))
  Mdot = math.pi * rho_a0 / gprime * ((pow(2,(5/2)) * pow(alpha,2) * Nbar ** 3 / z_1 ** 4) * dummyH ** 4 + (pow(beta,2) * Nbar ** 2 * Vbar/6) * dummyH ** 3)

  return Mdot
''' --------------------------------------------------------------------------------------------------------------------- '''

def read_csv():
  #csvfile = "tephra_esp.csv"
  with open(csv_file, 'r', encoding="ISO-8859-1") as csv_grid_f:
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
