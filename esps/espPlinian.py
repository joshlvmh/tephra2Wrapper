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
    read in ESP csv
    run per volcano
    '''
    esps = read_csv()
    for i in range(np.shape(esps)[0]):
        print(esps[i])
        #generate_confs(esps[i])

if __name__ == '__main__':
  main()
