### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - creating probability rasters for AOI including all volcanoes for four thresholds (0.1, 4, 10 and 30 cm tephra deposition)
#   log: code written on 18.03.2022, last changed on 18.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(stringr)

### load input data
# load AOI shp
setwd("~")
AOI_buff_500_km <- shapefile("AOI_buff_500_km.shp")
# create raster
ras_full <- raster(ext=extent(AOI_buff_500_km), resolution=0.1, vals=0, crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# list probability rasters
setwd("~")
prob_files <- list.files(path = ".", all.files = F)

# define output path
prob_ras_path <- "C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Post_processing/Prob_ras_AOI"

# define thresholds
thresholds <- c("001", "040", "100", "300")

### loop over all thresholds
#i=1
for(i in 1:length(thresholds)){
  # select all rasters of that volcano threshold-specific
  prob_files_threshold <- str_subset(prob_files, paste0("_", thresholds[i], "_"))
  
  # duplicate background raster
  ras_full_threshold <- ras_full
  
  # create empty stack to be filled in loop
  ras_stack <- stack()
  
  ### loop over all rasters
  #j=1
  for(j in 1:length(prob_files_threshold)){
    # load raster
    ras <- raster(prob_files_threshold[j])
    # re-project rasters to background raster
    ras <- projectRaster(ras, ras_full_threshold, method="bilinear")
    # set <= 0.0001 to 0
    values(ras)[values(ras) <= 0.0001] <- 0
    # set NA to 0
    ras[is.na(ras[])] <- 0
    #plot(ras)
    # stack raster
    ras_stack <- stack(ras_stack, ras)
    
    print(paste0("finished ", str_sub(prob_files_threshold[j], 1, -5), " (", j, "/", length(prob_files_threshold), ")"))
  } ### end loop over all rasters
  # calculate sum of stack
  ras_sum <- calc(ras_stack, sum)
  
  # write raster
  writeRaster(ras_sum, filename=file.path(prob_ras_path, paste0(str_sub(prob_files_threshold[j], 1, 5), "AOI", str_sub(prob_files_threshold[j], 12, 20), ".tif")), overwrite=T)

  print(paste0("finished all volcanoes threshold ", thresholds[i], " (", i, "/", length(thresholds), ")"))
} ### end loop over all thresholds

### done


##################################################################################################################################
### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - creating average recurrence interval (ARI) rasters for AOI including all volcanoes for four thresholds (0.1, 4, 10 and 30 cm tephra deposition)
#   log: code written on 18.03.2022, last changed on 30.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(stringr)
library(SciViews)

### load input data
# load AOI shp
setwd("~")
AOI_buff_500_km <- shapefile("AOI_buff_500_km.shp")
# create raster
ras_full <- raster(ext=extent(AOI_buff_500_km), resolution=0.1, vals=0, crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# list probability rasters
setwd("~")
prob_files <- list.files(path = ".", all.files = F)

# define output path
prob_ras_path <- "~"

# define thresholds
thresholds <- c("001", "040", "100", "300")

### loop over all thresholds
#i=1
for(i in 1:length(thresholds)){
  # select all rasters of that volcano threshold-specific
  prob_files_threshold <- str_subset(prob_files, paste0("_", thresholds[i], "_"))
  
  # duplicate background raster
  ras_full_threshold <- ras_full
  
  # create empty stack to be filled in loop
  ras_stack <- stack()
  
  ### loop over all rasters
  #j=1
  for(j in 1:length(prob_files_threshold)){
    # load raster
    ras <- raster(prob_files_threshold[j])
    # re-project rasters to background raster
    ras <- projectRaster(ras, ras_full_threshold, method="bilinear")
    # set <= 0.0001 to 0
    values(ras)[values(ras) <= 0.0001] <- 0
    # set NA to 0
    ras[is.na(ras[])] <- 0
    #plot(ras)
    # stack raster
    ras_stack <- stack(ras_stack, ras)
    
    print(paste0("finished ", str_sub(prob_files_threshold[j], 1, -5), " (", j, "/", length(prob_files_threshold), ")"))
  } ### end loop over all rasters
  # calculate sum of stack
  ras_sum <- calc(ras_stack, sum)
  # calculate ARI (formula 7 by Jenkins et al. 2012)
  ras_sum <- -1/ln(1-ras_sum)
  # set < 1 to NA
  values(ras_sum)[values(ras_sum) < 1] <- NA
  #ras_sum
  #plot(ras_sum)
  
  # write raster
  writeRaster(ras_sum, filename=file.path(prob_ras_path, paste0("ARI_AOI", str_sub(prob_files_threshold[j], 12, 20), ".tif")), overwrite=T)
  
  print(paste0("finished all volcanoes threshold ", thresholds[i], " (", i, "/", length(thresholds), ")"))
} ### end loop over all thresholds

### done


##################################################################################################################################
### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - creating number of volcanoes impacting (novi) rasters for AOI including all volcanoes for four thresholds (0.1, 4, 10 and 30 cm tephra deposition)
#   log: code written on 18.03.2022, last changed on 18.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(stringr)

### load input data
# load AOI shp
setwd("~")
AOI_buff_500_km <- shapefile("AOI_buff_500_km.shp")
# create raster
ras_full <- raster(ext=extent(AOI_buff_500_km), resolution=0.1, vals=0, crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# list probability rasters
setwd("~")
prob_files <- list.files(path=".", all.files=F)

# define output path
prob_ras_path <- "~"

# define thresholds
thresholds <- c("001", "040", "100", "300")

### loop over all thresholds
#i=1
for(i in 1:length(thresholds)){
  # select all rasters of that volcano threshold-specific
  prob_files_threshold <- str_subset(prob_files, paste0("_", thresholds[i], "_"))
  
  # duplicate background raster
  ras_full_threshold <- ras_full
  
  # create empty stack to be filled in loop
  ras_stack <- stack()
  
  ### loop over all rasters
  #j=1
  for(j in 1:length(prob_files_threshold)){
    # load raster
    ras <- raster(prob_files_threshold[j])
    # re-project rasters to background raster
    ras <- projectRaster(ras, ras_full_threshold, method="bilinear")
    # set <= 0.0001 to 0
    values(ras)[values(ras) <= 0.0001] <- 0
    # set > 0.0001 to 1
    values(ras)[values(ras) > 0.0001] <- 1
    # set NA to 0
    ras[is.na(ras[])] <- 0
    #plot(ras)
    # stack raster
    ras_stack <- stack(ras_stack, ras)
    
    print(paste0("finished ", str_sub(prob_files_threshold[j], 1, -5), " (", j, "/", length(prob_files_threshold), ")"))
  } ### end loop over all rasters
  # calculate sum of stack
  ras_sum <- calc(ras_stack, sum)
  # set < 1 to NA
  values(ras_sum)[values(ras_sum) < 1] <- NA
  
  # write raster
  writeRaster(ras_sum, filename=file.path(prob_ras_path, paste0("Novi_AOI", str_sub(prob_files_threshold[j], 12, 20), ".tif")), overwrite=T)
  
  print(paste0("finished all volcanoes threshold ", thresholds[i], " (", i, "/", length(thresholds), ")"))
} ### end loop over all thresholds

### done
