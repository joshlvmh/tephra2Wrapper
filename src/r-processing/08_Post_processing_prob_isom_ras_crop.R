### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - cropping of all probability rasters (per volcano per VEI for four thresholds) to circular 500 km buffer
#   - cropping of all isomass rasters (per volcano per VEI for five probabilities) to circular 500 km buffer
#   log: code written on 22.03.2022, last changed on 22.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(stringr)
library(rgeos)

### load input data
# volcano data
setwd("~")
tab_volc <- read.csv("volcano_set_wind.csv")

### probability rasters
# list files in folders
setwd("~")
prob_files <- list.files(path=".", all.files=F)

# define output path
prob_ras_path <- "~"

### loop over all rasters
#i=1
for(i in 1:length(prob_files)){
  # load raster
  ras <- raster(prob_files[i])
  # check name
  name <- prob_files[i]
  
  # extract volcano location
  this_volc <- tab_volc[is.element(tab_volc$Volcano.Number, str_sub(name, 6, 11)),]
  xy <- this_volc[,c(4, 5)]
  volc_location <- SpatialPointsDataFrame(coords=xy, data=this_volc, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
  # create 500 km buffer
  volc_buff <- as(gBuffer(volc_location, width=5), "SpatialPolygonsDataFrame")
  
  ## plot to check
  #plot(ras)
  #plot(volc_buff, col="transparent", border="red", lwd=2, add=T)
  
  # crop raster
  ras <- mask(ras, volc_buff)
  
  ## plot to check
  #plot(ras)
  #plot(volc_buff, col="transparent", border="red", lwd=2, add=T)
  
  # write raster
  writeRaster(ras, filename=file.path(prob_ras_path, name), overwrite=T)
  
  print(paste0("finished ", str_sub(name, 1, -5), "(", i, "/", length(prob_files), ")"))

} ### end loop over all rasters

### done probability rasters

##########

### isomass rasters
# list files in folders
setwd("~")
isom_files <- list.files(path = ".", all.files = F)

# define output path
isom_ras_path <- "~"

### loop over all rasters
#i=1
for(i in 1:length(isom_files)){
  # load raster
  ras <- raster(isom_files[i])
  # check name
  name <- isom_files[i]
  
  # extract volcano location
  this_volc <- tab_volc[is.element(tab_volc$Volcano.Number, str_sub(name, 6, 11)),]
  xy <- this_volc[,c(4, 5)]
  volc_location <- SpatialPointsDataFrame(coords=xy, data=this_volc, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
  # create 500 km buffer
  volc_buff <- as(gBuffer(volc_location, width=5), "SpatialPolygonsDataFrame")
  
  ## plot to check
  #plot(ras)
  #plot(volc_buff, col="transparent", border="red", lwd=2, add=T)
  
  # crop raster
  ras <- mask(ras, volc_buff)
  
  ## plot to check
  #plot(ras)
  #plot(volc_buff, col="transparent", border="red", lwd=2, add=T)
  
  # write raster
  writeRaster(ras, filename=file.path(isom_ras_path, name), overwrite=T)
  
  print(paste0("finished ", str_sub(name, 1, -5), "(", i, "/", length(isom_files), ")"))
  
} ### end loop over all rasters

### done isomass rasters
