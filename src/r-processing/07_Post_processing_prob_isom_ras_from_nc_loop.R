### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - create probability rasters per volcano per VEI for four thresholds (0.1, 4, 10 and 30 cm tephra deposition)
#   - create isomass rasters per volcano per VEI for five probabilities (10, 25, 50, 75 and 90%)
#   log: code written on 01.03.2022, last changed on 21.03.2022: loops over thresholds and percentiles
#   note: file i=1, j=1 did not work and was therefore not processed

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(ncdf4)
library(raster)
library(stringr)

### load input data
# load volcano table
setwd("~")
tab_volc <- read.csv("volcano_set_erup.csv")

# load model output
setwd("~/Tephra_output")
output_files_list <- list.files(path=".", all.files=F)

# define output paths
Isom_ras_path <- "~"
Prob_ras_path <- "~"

# define thresholds for probability maps: 0.1, 4, 10 and 30 cm tephra deposition which is 1, 40, 100, 300 kg/m2 area density load
thresholds <- c(1, 40, 100, 300)
thresholds_names <- c("001", "040", "100", "300")

# define percentiles for isomass maps
percentiles <- c(0.1, 0.25, 0.5, 0.75, 0.9)
percentiles_names <- c("90", "75", "50", "25", "10")

### loop over all volcanoes
#i=61 # 61 is Krakatau
#i=1
#for(i in 2:nrow(tab_volc)){ # this would run all volcanoes in once
for(i in 1:1){ # this would allow to specify certain ranges of volcanoes by the position in the table
  # extract volcano number
  volc_num <- as.character(tab_volc[i,2])
  # select all model output files for that volcano by volcano number
  volc_output_files <- str_subset(output_files_list, volc_num)
  
  ### loop over all VEIs
  #j=1
  for(j in 1:length(volc_output_files)){
    # select VEI-specific file
    volc_VEI <- volc_output_files[j]
    # create raster brick from nc
    volc_VEI_brick <- brick(volc_VEI)
    # transpose brick to get lon lat in the right order
    volc_VEI_brick <- t(volc_VEI_brick)
    # flip brick
    volc_VEI_brick <- flip(volc_VEI_brick, direction="x")
    # assign CRS
    crs(volc_VEI_brick) <- "+proj=longlat +datum=WGS84 +no_defs"
    
    ########## isomass maps
    ### loop over all percentiles
    #k=1
    for(k in 1:length(percentiles)){
      # calculate percentile
      Isom_ras_quant <- calc(volc_VEI_brick, fun=function(x) quantile(x, percentiles[k], na.rm=T))
      # write raster
      writeRaster(Isom_ras_quant, filename=file.path(Isom_ras_path, paste0("Isom_", str_sub(volc_VEI, 1, 11), "_P_", percentiles_names[k], ".tif")), overwrite=T)
    } ### end loop over all percentiles
    print(paste0("finished ", as.character(tab_volc[i,3]), "/", volc_num, " (volcano ", i, "/", nrow(tab_volc), ") ", str_sub(volc_VEI, 8, 11), " isomass maps"))
    
    ########## probability maps
    ### loop over all thresholds
    #l=1
    for(l in 1:length(thresholds)){
      # replicate brick
      this_volc_VEI_brick <- volc_VEI_brick
      # change values according to thresholds: set every cell below threshold to 0
      values(this_volc_VEI_brick)[values(this_volc_VEI_brick) < thresholds[l]] <- 0
      # change values according to thresholds: set every cell above threshold to 1
      values(this_volc_VEI_brick)[values(this_volc_VEI_brick) >= thresholds[l]] <- 1
      # sum raster brick
      Prob_ras_thre <- calc(this_volc_VEI_brick, sum)
      # divide by number of simulations to derive probability
      Prob_ras_thre <- Prob_ras_thre / nlayers(volc_VEI_brick)
      # write raster
      writeRaster(Prob_ras_thre, filename=file.path(Prob_ras_path, paste0("Prob_", str_sub(volc_VEI, 1, 11), "_", thresholds_names[l], "_kgm2"  , ".tif")), overwrite=T)
    } ### end loop over all thresholds
    print(paste0("finished ", as.character(tab_volc[i,3]), "/", volc_num, " (volcano ", i, "/", nrow(tab_volc), ") ", str_sub(volc_VEI, 8, 11), " probability maps"))
    
  } ### end loop over all VEIs
  
  print(paste0("finished ", as.character(tab_volc[i,3]), " which is ", i, " out of ", nrow(tab_volc)))
  print(paste0("                                      "))
} ### end loop over all volcanoes

### done
