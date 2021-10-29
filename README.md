# tephra2Wrapper
Helper functionality and wrapper for tephra2 simulation, pre & post processing, grid generation, wind collection.

## Usage
```
git submodule update --init --recursive
source bin/conf.sh
sbatch job_submit_tephra2
```

## Content

```
.  
|-- README.md  
|-- bin
|   `-- conf.sh: setup and environment variables
|-- docs
|   |-- tephraProb_structure.md
|   |-- tephraProb User Manual.pdf
|   `-- tree.*
|-- inputs
|   |-- volc_grids.csv: Grid generation input
|   |-- tephra_esp.csv: ESP config input
|   `-- volc_holo_mody.csv: Wind input
|-- pyenv.cfg: Python virtual environment
|-- src
|   |-- conf
|   |   `-- */*.txt: tephra2 config files  
|   |-- esps  
|   |   |-- espPlinian.py: config generation  
|   |   `-- t2.txt: tephra2 run commands  
|   |-- grid  
|   |   |-- grid_gen.py: UTM grid generation for tephra2  
|   |   `-- 262000.utm: Krakatau output  
|   |-- mpi_omp_t2_runner
|   |   |-- Makefile
|   |   |-- job_runner: SLURM submission script
|   |   |-- job_submit_tephra2: SLURM submission script
|   |   |-- t2_runner.c: MPI runner for tephra2
|   |   `-- t2_runner.out: Output of job submission
|   |-- tephra2: submodule  
|   |   `-- ..: model [1]  
|   `-- wind  
|       |-- gen_files  
|       |   `-- 262000  
|       |       `-- ..: outputs  
|       |-- job_wind.sh: array job for CDSAPI  
|       |-- nc_files
|       |   `-- 262000
|       |-- netcdf_conv.py: netCDF4 -> ASCII conversion  
|       |-- wind.py: CDSAPI [3] ERA5 script  
|       `-- wind_262000_2021.nc: output  
`-- tephraProb: submodule  
    `-- ..: pre & post processing source [2]  
```

## Implementation details

## References

[1] https://github.com/geoscience-community-codes/tephra2  
[2] https://github.com/e5k/TephraProb  
[3] https://github.com/ecmwf/cdsapi  
[4]
Degruyter, W., and Bonadonna, C. (2012), Improving on mass flow rate estimates of volcanic eruptions, Geophys. Res. Lett., 39, L16308, doi:10.1029/2012GL052566.
