### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
#   Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
#   post-processing of Tephra2 nc output files:
#   - conversion of nc-files to RasterBrick objects
#   - cropping of RasterBricks to 500 km radial zone around volcanoes
#   - saving of processed RasterBricks
#   log: code written on 23.03.2022, last changed on 23.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(ncdf4)
library(raster)
library(stringr)
library(rgeos)

### load input data
# volcano data
setwd("~")
tab_volc <- read.csv("volcano_set_wind.csv")

# model output
setwd("D:/Tephra_output")
output_files <- list.files(path=".", all.files=F)

# define output paths
ras_path <- "D:/Tephra_output_brick_crop"

### loop over all output files
#i=1
#for(i in 841:841){
for(i in 1:length(output_files)){
  # check name
  name <- output_files[i]
  # create raster brick from nc
  ras_brick <- brick(output_files[i])
  # transpose brick to get lon lat in the right order
  ras_brick <- t(ras_brick)
  # flip brick
  ras_brick <- flip(ras_brick, direction="x")
  # assign CRS
  crs(ras_brick) <- "+proj=longlat +datum=WGS84 +no_defs"
  
  # extract volcano location
  this_volc <- tab_volc[is.element(tab_volc$Volcano.Number, str_sub(name, 1, 6)),]
  xy <- this_volc[,c(4, 5)]
  ### if-condition accounting for not previously excluded volcanoes (model was run for more, some were excluded later due to lacking data on VEI-specific eruption probabilities)
  if(nrow(xy)==1){
    volc_location <- SpatialPointsDataFrame(coords=xy, data=this_volc, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
    # create 500 km buffer
    volc_buff <- as(gBuffer(volc_location, width=5), "SpatialPolygonsDataFrame")
    
    ## plot to check
    #plot(ras_brick[[1]])
    #plot(volc_buff, col="transparent", border="red", lwd=2, add=T)
    
    # crop raster
    ras_brick <- mask(ras_brick, volc_buff)
    
    ## plot to check
    #plot(ras_brick[[1]])
    #plot(volc_buff, col="transparent", border="red", lwd=2, add=T)
    
    # write raster
    rgdal::setCPLConfigOption("GDAL_PAM_ENABLED", "FALSE") # inhibit creation of aux file
    writeRaster(ras_brick, filename=file.path(ras_path, paste0(str_sub(name, 1, 11), ".tif")), overwrite=T)
    
    print(paste0("finished ", str_sub(name, 1, -4), "(", i, "/", length(output_files), ")"))
  } ### end if-condition accounting for not previously excluded volcanoes
  
  ### if-condition accounting for previously excluded volcanoes (model was run for more, some were excluded later due to lacking data on VEI-specific eruption probabilities)
  if(nrow(xy)==0){
    print(paste0("finished ", str_sub(name, 1, -4), "(", i, "/", length(output_files), ") - this volcano was excluded"))
  } ### end if-condition accounting for previously excluded volcanoes
  
} ### end loop over all output files

### done

#### load and check
#setwd("C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Post_processing/Model_output_brick_crop")
#ras_brick_check <- brick("250010_VEI2.tif")
#ras_brick_check
#ras_brick_check[[1]]
#plot(ras_brick_check[[1]])
