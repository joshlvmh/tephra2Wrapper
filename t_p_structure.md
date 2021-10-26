# tephraProb structure

```
.                                       | Referenced in
|-- TephraProb_wrapper.m                | -----------------------------
|-- tephraProb.m                        | ??
`-- CODE/                               | -
    |-- aggregate.m                     | runProb.m ; runProb_vulc.m
    |-- archiveFiles.m                  | tephraProb.m
    |-- cdsapi-0.2.5/                   | -
    |   `-- [1]                         | -
    |-- check_project.m                 | runProb.m ; runProb_vulc.m
    |-- conf_grid.m                     | tephraProb.m
    |-- conf_points.m                   | tephraProb.m
    |-- dependencies/                   | -
    |   |-- WindRose.m                  | dwind/analyze_wind.m
    |   |-- errorbar_x.m                | gvp/gvp.m ; dwind/analyze_wind.m
    |   |-- freezeColors.m              | ??
    |   |-- get_mer.m                   | runProb.m
    |   |-- googleearth/                | -
    |   |   |-- [2]                     | -
    |   |-- htmlTableToCell.m           | gvp/gvp.m
    |   |-- linspecer.m                 | plot_hazCurves.m ; dwind/analyze_wind.m
    |   |-- ll2utm.m                    | conf_points.m ; conf_grid.m
    |   |-- makescale.m                 | plot_google_map.m ; plot_osm_map.m
    |   |-- plot_google_map.m           | conf_points.m ; plotMap.m ; conf_grid.m ; makescale.m ; plot_osm_map.m
    |   |-- plot_osm_map.m              | ??
    |   `-- utm2ll.m                    | 
    |-- display_figure.m
    |-- dwind/
    |   |-- analyze_wind.m
    |   |-- dwind.m
    |   |-- installAPI.m
    |   |-- process_wind.m
    |   `-- writeAPI.m
    |-- ecmwf-api-client-python/
    |   `-- [3] 
    |-- exportASCII.m
    |-- get_prefs.m
    |-- gvp/
    |   `-- gvp.m
    |-- load_grid.m
    |-- load_run.m
    |-- misc/
    |   `-- logo.png
    |-- month.m
    |-- normpdf.m
    |-- plotMap.m
    |-- plt_hazCurves.m
    |-- probability_maker.m
    |-- process_T2.m
    |-- runProb.m
    |-- runProv_vulc.m
    |-- runT2.m
    |-- saveAllMaps.m
    |-- set_display.m
    |-- VAR/
    |   |-- new_props.mat
    |   |-- prefs.mat
    |   |-- prefs_default.mat
    |   |-- tephraProb.mat
    |   `-- tephraProb_vulc.mat
    |-- writeDEM.m
    `-- writeIt.m

```

## References
[1] https://github.com/ecmwf/cdsapi
[2] https://code.google.com/archive/p/googleearthtoolbox/
[3] https://github.com/ecmwf/ecmwf-api-client
