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
- TephraProb wrapper [2]

wind/
- wind.py: CDSAPI [3] script
- netcdf_conv.py: NETCDF4 to .gen tephra2 text files
- job_wind.sh: array job for CDSAPI


## References

[1] https://github.com/geoscience-community-codes/tephra2  
[2] https://github.com/e5k/TephraProb  
[3] https://github.com/ecmwf/cdsapi  


## TODO

[1] Check grid/ for cross_eq,cross_zn combinations
[2] Check wind for 2021 - fewer, expver [1 5]
