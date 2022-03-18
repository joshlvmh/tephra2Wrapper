### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
### Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
### post-processing of Tephra2 nc output files
### 01.03.2022

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries (potentially install first)
#install.packages("ncdf4")
#install.packages("raster")
#install.packages("stringr")
library(ncdf4)
library(raster)
library(stringr)

### load input data
# load AOI shp
setwd("C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/AOI_shp")
AOI_buff_500_km <- shapefile("AOI_buff_500_km.shp")
AOI_buff_500_km
# create raster
ras_full <- raster(ext=extent(AOI_buff_500_km), resolution=0.1, vals=NA, crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
ras_full
# load land shp
land <- shapefile("ne_10m_land.shp")
land_AOI <- crop(land, extent(AOI_buff_500_km))
land_AOI
# plot to check
plot(ras_full)
plot(land_AOI, col="grey", border="transparent", add=T)
plot(AOI_buff_500_km, col="transparent", border="black", add=T)

# load volcano data
setwd("C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data")
tab_volc <- read.csv("volcano_set_erup.csv")
tab_volc
head(tab_volc)
class(tab_volc)

# load model output
setwd("C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Post_processing/Output")
output_files_list <- list.files(path = ".", all.files = F)
output_files_list

### loop over all volcanoes
#i=61 # 61 is Krakatau
#for(i in 1:nrow(tab_volc)){
for(i in 61:61){
  volc_num <- as.character(tab_volc[i,2])
  volc_num
  # select all model output files for that volcano by volcano number
  volc_output_files <- str_subset(output_files_list, volc_num) # to be checked when more output files will be available
  volc_output_files

  ### loop over all VEIs
  #j=1
  for(j in 1:length(volc_output_files)){
    volc_VEI <- volc_output_files[j]
    volc_VEI
    # create raster brick from nc
    volc_VEI_brick <- brick(volc_VEI)
    volc_VEI_brick
    
    # calculate mean - apart from mean we could essentially do everything here, I will specify
    ras_mean <- calc(volc_VEI_brick, mean)
    ras_mean
    
    # set <= 0.01 to NA
    values(ras_mean)[values(ras_mean) <= 0.01] <- NA
    ras_mean
    
    ###
    # loop over threshold values
    ###
    
    # re-project to full background raster
    ras_mean <- projectRaster(ras_mean, ras_full, method="bilinear")
    ras_mean
    
    ## write out raster
    path_ras <- "C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Post_processing/Volc_VEI_ras"
    writeRaster(ras_mean, filename=file.path(path_ras, paste0(str_sub(volc_VEI, 1, 11), "_mean", ".tif")), overwrite=T)
    
    ### create volcano and VEI specific png - just for visualization
    path_png <- "C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Post_processing/Volc_VEI_png"
    png(filename=file.path(path_png, paste0(str_sub(volc_VEI, 1, 11), "_mean", ".png")), width=2000, height=1000, res=150)
    par(mar=c(2, 2, 2, 2), xpd=T)
    plot(ras_mean, asp=0.92)
    plot(land_AOI, col="grey", border="transparent", add=T)
    plot(ras_mean, asp=0.92, add=T)
    title(paste0(as.character(tab_volc[i,3]), "_", str_sub(volc_VEI, 1, 11), "_mean"), line=1)
    text(179.3, 4, "Tephra deposition [kg/m2]", srt=90)
    dev.off()
    
    ### loop over all layers in raster brick - so for this is just to visualize, might not even be necessary if we work primarily wiht the brick
    #k=1
    for(k in 1:nlayers(volc_VEI_brick)){
      ras <- volc_VEI_brick[[k]]
      ras
      plot(ras)
      # set <= 0.01 to NA
      # (Turns out that the model predict tiny values all over the grid which is no realistic representation of the plume.
      # Therefore, a cutoff was set at 0.01 kg/m2. This is 1/100 of our smallest threshold value and corresponds to 0.001 cm
      # isopach depth. This should be justifiable but should be discussed with Susanna.)
      values(ras)[values(ras) <= 0.01] <- NA
      ras
      hist(ras) # We should check with Susanna if such a bi-modal value distribution is realistic.
      plot(ras)
      
      ###
      # loop over threshold values
      ###
      
      # re-project to full background raster
      ras <- projectRaster(ras, ras_full, method="bilinear")
      ras
      
      ###### create individual pngs  - just for visualization (not run - this would create a png of every individual model run)
      ###path_png <- "C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Post_processing/Indi_png"
      ###png(filename=file.path(path_png, paste0(str_sub(volc_VEI, 1, 11), "_", k, ".png")), width=2000, height=1000, res=150)
      ###par(mar=c(2, 2, 2, 2), xpd=T)
      ###plot(ras, asp=0.92)
      ###plot(land_AOI, col="grey", border="transparent", add=T)
      ###plot(ras, asp=0.92, add=T)
      ###title(paste0(as.character(tab_volc[i,3]), "_", str_sub(volc_VEI, 1, 11), "_", k), line=1)
      ###text(179.3, 4, "Tephra deposition [kg/m2]", srt=90)
      ###dev.off()
      
      print(paste0("finished ", as.character(tab_volc[i,3]), " which is ", i, " out of ", nrow(tab_volc), " ", str_sub(volc_VEI, 8, 11), " layer ", k))
    } ### end loop over all layers in raster brick
    
    print(paste0("finished ", as.character(tab_volc[i,3]), " which is ", i, " out of ", nrow(tab_volc), " ", str_sub(volc_VEI, 8, 11)))
  } ### end loop over all VEIs
  
  print(paste0("finished ", as.character(tab_volc[i,3]), " which is ", i, " out of ", nrow(tab_volc)))
} ### end loop over all volcanoes

### done
