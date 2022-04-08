# Wind

## Wind download (ERA-5 Dataset)

Downloads wind data from ERA-5 Dataset using the Climate Data Store (CDS) API.
The script checks to see if the .nc file exists in the output location before requesting it so it can be rerun if it is interrupted.

Input:  
&nbsp;&nbsp;Location: $INPUTS/  
&nbsp;&nbsp;Format: CSV file, eg wind.csv, required column order given in example_wind.csv.  

Output:  
&nbsp;&nbsp;Location: $OUTPUTS/wind/nc_files/  
&nbsp;&nbsp;Format: VOLCID_YEAR.nc eg 262000_2012.nc  

### Local shell blocking execution:

```
python wind.py --wind-csv="volcs.csv" --year=2012
```

### Compute node non-blocking execution:
Edit the job script to specify the years and CSV filename.

#### SLURM
```
sbatch job_wind.sh
```

#### PBS

```
qsub job_wind_pbs.sh
```

## Wind conversion
Convert NetCDF wind files to ASCII files for Tephra2

```
python netcdf_conv.py
```
