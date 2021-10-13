# tephra2Wrapper
Helper functionality and wrapper for tephra2 simulation

## Usage
```
git submodule update --init --recursive
sbatch job_submit_tephra2
```

## Content

```
.  
|-- README.md  
|-- esps  
|   |-- espPlinian.py: config generation [4]  
|   `-- tephra_esp.csv: input parameters  
|-- grid  
|   |-- grid_gen.py: UTM grid generation for tephra2  
|   |-- krak.utm: output  
|   `-- volc_grids.csv: input  
|-- job_submit_tephra2: runs the model  
|-- tephra2: submodule  
|   `-- ..: model [1]  
|-- tephraProb: submodule  
|   `-- ..: for reference [2]  
|-- volc_holo_VEI.csv: input  
|-- volc_holo_mody.csv: input  
`-- wind  
    |-- gen_files  
    |   `-- 262000  
    |       `-- ..: outputs  
    |-- job_wind.sh: array job for CDSAPI  
    |-- netcdf_conv.py: netCDF4 -> ASCII conversion  
    |-- volc_holo_mody.csv: input  
    |-- wind.py: CDSAPI [3] ERA5 script  
    `-- wind_262000_2021.nc: output  
```

## References

[1] https://github.com/geoscience-community-codes/tephra2  
[2] https://github.com/e5k/TephraProb  
[3] https://github.com/ecmwf/cdsapi  

[4]
Degruyter, W., and Bonadonna, C. (2012), Improving on mass flow rate estimates of volcanic eruptions, Geophys. Res. Lett., 39, L16308, doi:10.1029/2012GL052566.
