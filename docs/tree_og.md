.
|-- README.md
|-- esps
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
