### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - creating probability rasters per volcano for four thresholds (0.1, 4, 10 and 30 cm tephra deposition)
#   log: code written on 17.03.2022, last changed on 30.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(stringr)

### load input data
# volcano table
setwd("~")
tab_volc <- read.csv("volcano_set_erup.csv")

# list probability rasters
setwd("~")
prob_files <- list.files(path=".", all.files=F)

# define output path
prob_ras_path <- "~"

# define thresholds
thresholds <- c("001", "040", "100", "300")

### loop over all volcanoes
#i=1
#for(i in 1:1){
for(i in 1:nrow(tab_volc)){
  # extract volcano number
  volc_num <- as.character(tab_volc[i,2])
  
  # extract annual VEI-specific eruption probabilities
  annual_probs <- c(tab_volc[i,4], tab_volc[i,5], tab_volc[i,6], tab_volc[i,7], tab_volc[i,8], tab_volc[i,9])
  
  # select all rasters of that volcano by volcano number
  prob_files_volc <- str_subset(prob_files, volc_num)
  
  ### loop over all thresholds
  #j=1
  for(j in 1:length(thresholds)){
    # select all rasters of that volcano threshold-specific
    prob_files_volc_threshold <- str_subset(prob_files_volc, paste0("_", thresholds[j], "_"))
    
    # load and multiply rasters with probability value
    ras_VEI2 <- raster(prob_files_volc_threshold[1]) * annual_probs[1]
    ras_VEI3 <- raster(prob_files_volc_threshold[2]) * annual_probs[2]
    ras_VEI4 <- raster(prob_files_volc_threshold[3]) * annual_probs[3]
    ras_VEI5 <- raster(prob_files_volc_threshold[4]) * annual_probs[4]
    ras_VEI6 <- raster(prob_files_volc_threshold[5]) * annual_probs[5]
    ras_VEI7 <- raster(prob_files_volc_threshold[6]) * annual_probs[6]
    
    # stack rasters
    ras_stack <- stack(ras_VEI2, ras_VEI3, ras_VEI4, ras_VEI5, ras_VEI6, ras_VEI7)
    # calculate sum of stack
    ras_sum <- calc(ras_stack, sum)
    
    ## check
    #ras_001_sum
    #plot(ras_001_sum)
    ## max and min average recurrence intervals
    #1/maxValue(ras_001_sum)
    #1/minValue(ras_001_sum)
    
    # write raster
    writeRaster(ras_sum, filename=file.path(prob_ras_path, paste0(str_sub(prob_files_volc[j], 1, 12), str_sub(prob_files_volc[j], 18, 25), ".tif")), overwrite=T)

    print(paste0("finished ", as.character(tab_volc[i,3]), "/", volc_num, " (", i, "/", nrow(tab_volc), "), threshold ", thresholds[j], " (", j, "/", length(thresholds), ")"))
  } ### end loop over all thresholds
  
} ### end loop over all volcanoes

### done

