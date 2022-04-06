# Wind

## Wind download (ERA-5 Dataset)

Downloads wind data from ERA-5 Dataset using the Climate Data Store (CDS) API.
The script checks to see if the .nc file exists in the output location before requesting it so it can be rerun if it is interrupted.

Input:
  Location: $INPUTS/
  Format: CSV file, eg volc_wind.csv, example given in example_wind.csv
Output: 
  Location: $OUTPUTS/wind/nc_files/
  Format: VOLCID_YEAR.nc eg 262000_2012.nc

### Local:

```
python wind.py [YEAR] --csv-file="volcs.csv"
```

### Slurm:
Edit the job script to specify the years and CSV filename.

```
sbatch job_wind.sh
```

### PBS
Edit the job script to specify the years and CSV filename.

```
qsub job_wind_pbs.sh
```

## Wind conversion

### Local:

```
python netcdf_conv.py
```
