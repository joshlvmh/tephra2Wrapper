# tephra2Wrapper
Helper functionality and wrapper for tephra2 simulation

## Usage
```
git submodule update --init --recursive
sbatch job_submit_tephra2
```

## Content

Submodules:
- tephra2 model [1]
- TephraProb wrapper, for reference [2]

/
- job_submit_tephra2: runs the model
- *.csv: inputs

wind/
- wind.py: CDSAPI [3] script
- netcdf_conv.py: NETCDF4 to .gen tephra2 text files
- job_wind.sh: array job for CDSAPI

grid/
- grid_gen.py: UTM grid generation for tephra2
- *.utm: outputs

esps/
- espPlinian.py: Config generation
- tephra_esp.csv: input parameters

```
.  
|__ README.md  
|__ esps  
|   |-- espPlinian.py: config generation  
|   `-- tephra_esp.csv: input parameters  
|-- grid  
|   |-- grid_gen.py: UTM grid generation for tephra2  
|   |-- krak.utm: output  
|   `-- volc_grids.csv: input  
|-- job_submit_tephra2: runs model  
|-- tephra2  
|   `-- ..: model  
|-- tephraProb  
|   `-- ..: reference  
|-- tree.sh  
|-- volc_holo_VEI.csv: input  
|-- volc_holo_mody.csv: input  
`-- wind  
    |-- gen_files  
    |   `-- 262000  
    |       `-- ..: outputs  
    |-- job_wind.sh: wind conversion submission  
    |-- netcdf_conv.py: netCDF4 -> ASCII conversion  
    |-- volc_holo_mody.csv: input  
    |-- wind.py: CDSAPI ERA5 requests  
    `-- wind_262000_2021.nc: output  
```

## References

[1] https://github.com/geoscience-community-codes/tephra2  
[2] https://github.com/e5k/TephraProb  
[3] https://github.com/ecmwf/cdsapi  
