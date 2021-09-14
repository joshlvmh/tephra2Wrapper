# tephra2Wrapper
Helper functions and wrapper for tephra2 simulation

Submodules:
- tephra2 model
- TephraProb wrapper

```
git submodule update --init --recursive
sbatch job_submit_tephra2
```

wind/
- wind.py: CDSAPI [1] script
- netcdf_conv.py: NETCDF4 to .gen tephra2 text files
- job_wind.sh: array job for CDSAPI
