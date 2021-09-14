# tephra2Wrapper
Helper functionality and wrapper for tephra2 simulation

## Usage
```
git submodule update --init --recursive
sbatch job_submit_tephra2
```

## Content

Submodules:
- tephra2 model
- TephraProb wrapper

wind/
- wind.py: CDSAPI [1] script
- netcdf_conv.py: NETCDF4 to .gen tephra2 text files
- job_wind.sh: array job for CDSAPI


## References

[1] https://github.com/ecmwf/cdsapi
