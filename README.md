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
- {*}.csv: inputs

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


## References

[1] https://github.com/geoscience-community-codes/tephra2  
[2] https://github.com/e5k/TephraProb  
[3] https://github.com/ecmwf/cdsapi  
