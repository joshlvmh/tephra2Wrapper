### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
### Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
### create table with grid parameters for Tephra2/TephraProb modelling
### 14.09.2021

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(rgdal)
library(rgeos)

# set working directory
setwd("$REPO_HOME/inputs/")

# load AOI shp
AOI <- shapefile("AOI.shp") # only needed for plotting
AOI
AOI_buff_500_km <- shapefile("AOI_buff_500_km.shp") # needed for cropping of land vector and bathymetry raster, also needed for plotting
AOI_buff_500_km
extent(AOI_buff_500_km)
# xmin: 87.52166 
# xmax: 178.1652 
# ymin: -20.64415 
# ymax: 28.40833 

# load land data
land <- shapefile("ne_10m_land.shp") # only needed for plotting
land
land_crop <- crop(land, extent(AOI_buff_500_km))
land_crop
#plot(land_crop)

# load bathymetry raster
bathy <- raster("Global_Bathymetry.tif") # needed for calculation of mean elevation per volcano buffer zone
bathy <- crop(bathy, extent(AOI_buff_500_km))
bathy
plot(bathy)
# set all values <0 to 0 to retain in fact only sub-aerial elevation
bathy[bathy < 0] <- 0
bathy
hist(bathy)
plot(bathy)

# read csv
tab_input <- read.csv("volc_holo_mody.csv")
tab_input
head(tab_input)
class(tab_input)

### construct empty matrix for grid parameters per volcano
tab_output <- matrix(NA, nrow=nrow(tab_input), ncol=16)
colnames(tab_output) <- c("volcano_name",
                          "volcano_number",
                          "min_easting",
                          "max_easting",
                          "min_northing",
                          "max_northing",
                          "NW_zone",
                          "NE_zone",
                          "SW_zone",
                          "SE_zone",
                          "vent_zone",
                          "resolution",
                          "mean_elevation",
                          "grid_name",
                          "zone_crossing",
                          "equator_crossing")
head(tab_output)
class(tab_output)
ncol(tab_output)
nrow(tab_output)

### loop over all volcanoes
#i=1
for(i in 1:nrow(tab_input)){
  # select volcano
  record <- tab_input[i,]
  record
  
  # volcano name
  volcano_name <- tab_input[i,3]
  volcano_name
  volcano_name <- gsub("([^A-Za-z0-9])+", "", x=volcano_name)
  volcano_name
  
  # volcano number
  volcano_number <- tab_input[i,2]
  volcano_number
  volcano_number <- gsub("([^A-Za-z0-9])+", "", x=volcano_number)
  volcano_number
  
  # extract coordinates
  lon <- tab_input[i,4]
  lon
  lat <- tab_input[i,5]
  lat
  
  ########## create buffer
  ### convert to SpatialPointsDataFrame
  xy <- record[,c(4,5)]
  xy
  record_spat <- SpatialPointsDataFrame(coords=xy, data=record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  record_spat
  #plot(record_spat)
  ### create 500 km buffer
  #volc_buff <- as(buffer(record_spat, width=500000, dissolve=T), "SpatialPolygonsDataFrame")
  volc_buff <- as(gBuffer(record_spat, width=5), "SpatialPolygonsDataFrame")
  volc_buff
  # plot just to check
  plot(land_crop, col="grey", border="transparent")
  plot(AOI, col="transparent", border="red", add=T)
  plot(AOI_buff_500_km, col="transparent", border="blue", add=T)
  plot(volc_buff, col="transparent", border="black", lwd=2, add=T)
  plot(record_spat, add=T)
  
  ###### just to check for correct buffer size in ArcMap
  #### create 500 km buffer
  ###volc_buff_a <- as(buffer(record_spat, width=500000, dissolve=T), "SpatialPolygonsDataFrame")
  ###volc_buff_b <- as(gBuffer(record_spat, width=5), "SpatialPolygonsDataFrame")
  ###writeOGR(volc_buff_a, ".", "volc_buff_a", driver="ESRI Shapefile", overwrite=T)
  ###writeOGR(volc_buff_b, ".", "volc_buff_b", driver="ESRI Shapefile", overwrite=T)
  ###writeOGR(record_spat, ".", "record_spat", driver="ESRI Shapefile", overwrite=T)
  
  ### bathymetry data
  bathy_crop <- crop(bathy, extent(volc_buff))
  bathy_crop
  ### if-else-condition for the case of no terrestrial area in the zone (relevant for small island volcanoes e.g., in the Mariana Islands)
  if(is.na(minValue(bathy_crop))){
    mean_elevation <- 0
  } else {
    mean_elevation <- round(mean(getValues(bathy_crop), na.rm=T))
    mean_elevation
  } ### end if-else-condition for the case of no terrestrial area in the zone
  
  ### grid extent
  N_lon_lat <- ymax(volc_buff)
  S_lon_lat <- ymin(volc_buff)
  E_lon_lat <- xmax(volc_buff)
  W_lon_lat <- xmin(volc_buff)
  # check
  N_lon_lat
  S_lon_lat
  E_lon_lat 
  W_lon_lat 
  
  ##########
  ### vent
  # define coordinates
  lon <- lon
  lat <- lat
  # change record
  vent_record <- record
  vent_record[4] <- lon
  vent_record[5] <- lat
  vent_record
  # UTM zone
  vent_zone <- floor((lon + 180) / 6) + 1 # from here: https://stackoverflow.com/questions/9186496/determining-utm-zone-to-convert-from-longitude-latitude
  vent_zone
  # for visual check of UTM zones: https://de.wikipedia.org/wiki/UTM-Koordinatensystem#/media/Datei:Utm-zones.jpg
  # convert to SpatialPointsDataFrame
  vent_xy <- data.frame(matrix(nrow=1, data=c(lon,lat)))
  vent_xy
  vent_spat <- SpatialPointsDataFrame(coords=vent_xy, data=vent_record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  vent_spat
  class(vent_spat)
  # reproject to UTM
  ### if-else-condition for southern hemisphere
  if(lat<0){
    vent_point <- spTransform(vent_spat, CRS(paste0("+proj=utm +zone=", vent_zone, " +south ellps=WGS84")))
  } else {
    vent_point <- spTransform(vent_spat, CRS(paste0("+proj=utm +zone=", vent_zone, " ellps=WGS84")))
  } ### end if-else-condition for southern hemisphere
  vent_point
  class(vent_point)
  coordinates(vent_point)
  # extract easting and northing
  vent_easting <- coordinates(vent_point)[1]
  vent_easting
  vent_northing <- coordinates(vent_point)[2]
  vent_northing
  # change UTM zone for table
  ### if-else-condition for southern hemisphere
  if(lat<0){
    vent_zone <- vent_zone * -1
  } else {
    vent_zone <- vent_zone
  } ### end if-else-condition for southern hemisphere
  vent_zone
  
  ##########
  ### define coordinates of grid extent northeast (NE), northwest (NW), southeast (SE), southwest (SW) one after another
  
  ##########
  ### NE
  # define coordinates
  lon <- E_lon_lat
  lat <- N_lon_lat
  # change record
  NE_record <- record
  NE_record[4] <- lon
  NE_record[5] <- lat
  NE_record
  # UTM zone
  NE_zone <- floor((lon + 180) / 6) + 1 # from here: https://stackoverflow.com/questions/9186496/determining-utm-zone-to-convert-from-longitude-latitude
  NE_zone
  # for visual check of UTM zones: https://de.wikipedia.org/wiki/UTM-Koordinatensystem#/media/Datei:Utm-zones.jpg
  # convert to SpatialPointsDataFrame
  NE_xy <- data.frame(matrix(nrow=1, data=c(lon,lat)))
  NE_xy
  NE_spat <- SpatialPointsDataFrame(coords=NE_xy, data=NE_record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  NE_spat
  class(NE_spat)
  # reproject to UTM
  ### if-else-condition for southern hemisphere
  if(lat<0){
    NE_point <- spTransform(NE_spat, CRS(paste0("+proj=utm +zone=", NE_zone, " +south ellps=WGS84")))
  } else {
    NE_point <- spTransform(NE_spat, CRS(paste0("+proj=utm +zone=", NE_zone, " ellps=WGS84")))
  } ### end if-else-condition for southern hemisphere
  NE_point
  class(NE_point)
  coordinates(NE_point)
  # extract easting and northing
  NE_easting <- coordinates(NE_point)[1]
  NE_easting
  NE_northing <- coordinates(NE_point)[2]
  NE_northing
  # change UTM zone for table
  ### if-else-condition for southern hemisphere
  if(lat<0){
    NE_zone <- NE_zone * -1
  } else {
    NE_zone <- NE_zone
  } ### end if-else-condition for southern hemisphere
  NE_zone
  
  ##########
  ### NW
  # define coordinates
  lon <- W_lon_lat
  lat <- N_lon_lat
  # change record
  NW_record <- record
  NW_record[4] <- lon
  NW_record[5] <- lat
  NW_record
  # UTM zone
  NW_zone <- floor((lon + 180) / 6) + 1 # from here: https://stackoverflow.com/questions/9186496/determining-utm-zone-to-convert-from-longitude-latitude
  NW_zone
  # for visual check of UTM zones: https://de.wikipedia.org/wiki/UTM-Koordinatensystem#/media/Datei:Utm-zones.jpg
  # convert to SpatialPointsDataFrame
  NW_xy <- data.frame(matrix(nrow=1, data=c(lon,lat)))
  NW_xy
  NW_spat <- SpatialPointsDataFrame(coords=NW_xy, data=NW_record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  NW_spat
  class(NW_spat)
  # reproject to UTM
  ### if-else-condition for southern hemisphere
  if(lat<0){
    NW_point <- spTransform(NW_spat, CRS(paste0("+proj=utm +zone=", NW_zone, " +south ellps=WGS84")))
  } else {
    NW_point <- spTransform(NW_spat, CRS(paste0("+proj=utm +zone=", NW_zone, " ellps=WGS84")))
  } ### end if-else-condition for southern hemisphere
  NW_point
  class(NW_point)
  coordinates(NW_point)
  # extract easting and northing
  NW_easting <- coordinates(NW_point)[1]
  NW_easting
  NW_northing <- coordinates(NW_point)[2]
  NW_northing
  # change UTM zone for table
  ### if-else-condition for southern hemisphere
  if(lat<0){
    NW_zone <- NW_zone * -1
  } else {
    NW_zone <- NW_zone
  } ### end if-else-condition for southern hemisphere
  NW_zone
  
  ##########
  ### SW
  # define coordinates
  lon <- W_lon_lat
  lat <- S_lon_lat
  # change record
  SW_record <- record
  SW_record[4] <- lon
  SW_record[5] <- lat
  SW_record
  # UTM zone
  SW_zone <- floor((lon + 180) / 6) + 1 # from here: https://stackoverflow.com/questions/9186496/determining-utm-zone-to-convert-from-longitude-latitude
  SW_zone
  # for visual check of UTM zones: https://de.wikipedia.org/wiki/UTM-Koordinatensystem#/media/Datei:Utm-zones.jpg
  # convert to SpatialPointsDataFrame
  SW_xy <- data.frame(matrix(nrow=1, data=c(lon,lat)))
  SW_xy
  SW_spat <- SpatialPointsDataFrame(coords=SW_xy, data=SW_record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  SW_spat
  class(SW_spat)
  # reproject to UTM
  ### if-else-condition for southern hemisphere
  if(lat<0){
    SW_point <- spTransform(SW_spat, CRS(paste0("+proj=utm +zone=", SW_zone, " +south ellps=WGS84")))
  } else {
    SW_point <- spTransform(SW_spat, CRS(paste0("+proj=utm +zone=", SW_zone, " ellps=WGS84")))
  } ### end if-else-condition for southern hemisphere
  SW_point
  class(SW_point)
  coordinates(SW_point)
  # extract easting and northing
  SW_easting <- coordinates(SW_point)[1]
  SW_easting
  SW_northing <- coordinates(SW_point)[2]
  SW_northing
  # change UTM zone for table
  ### if-else-condition for southern hemisphere
  if(lat<0){
    SW_zone <- SW_zone * -1
  } else {
    SW_zone <- SW_zone
  } ### end if-else-condition for southern hemisphere
  SW_zone
  
  ##########
  ### SE
  # define coordinates
  lon <- E_lon_lat
  lat <- S_lon_lat
  # change record
  SE_record <- record
  SE_record[4] <- lon
  SE_record[5] <- lat
  SE_record
  # UTM zone
  SE_zone <- floor((lon + 180) / 6) + 1 # from here: https://stackoverflow.com/questions/9186496/determining-utm-zone-to-convert-from-longitude-latitude
  SE_zone
  # for visual check of UTM zones: https://de.wikipedia.org/wiki/UTM-Koordinatensystem#/media/Datei:Utm-zones.jpg
  # convert to SpatialPointsDataFrame
  SE_xy <- data.frame(matrix(nrow=1, data=c(lon,lat)))
  SE_xy
  SE_spat <- SpatialPointsDataFrame(coords=SE_xy, data=SE_record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  SE_spat
  class(SE_spat)
  # reproject to UTM
  ### if-else-condition for southern hemisphere
  if(lat<0){
    SE_point <- spTransform(SE_spat, CRS(paste0("+proj=utm +zone=", SE_zone, " +south ellps=WGS84")))
  } else {
    SE_point <- spTransform(SE_spat, CRS(paste0("+proj=utm +zone=", SE_zone, " ellps=WGS84")))
  } ### end if-else-condition for southern hemisphere
  SE_point
  class(SE_point)
  coordinates(SE_point)
  # extract easting and northing
  SE_easting <- coordinates(SE_point)[1]
  SE_easting
  SE_northing <- coordinates(SE_point)[2]
  SE_northing
  # change UTM zone for table
  ### if-else-condition for southern hemisphere
  if(lat<0){
    SE_zone <- SE_zone * -1
  } else {
    SE_zone <- SE_zone
  } ### end if-else-condition for southern hemisphere
  SE_zone
  
  ##########
  # check
  vent_zone
  vent_easting
  vent_northing
  NE_zone
  NE_easting
  NE_northing
  NW_zone
  NW_easting
  NW_northing
  SE_zone
  SE_easting
  SE_northing
  SW_zone
  SW_easting
  SW_northing
  
  # define parameters
  min_easting  <- min(c(NW_easting, SW_easting))
  max_easting  <- max(c(NE_easting, SE_easting))
  min_northing <- min(c(SE_northing, SW_northing))
  max_northing <- max(c(NE_northing, NW_northing))
  # check
  min_easting 
  max_easting 
  min_northing
  max_northing
  
  # equator_crossing
  ### if-else-condition checking for equator crossing
  if((N_lon_lat < 0) == (S_lon_lat < 0)){
    equator_crossing <- 0
  } else {
    equator_crossing <- 1
  } ### end if-else-condition checking for equator crossing
  equator_crossing
  
  # write into tab_output (all NA are to be replaced)              # keep this for the order of columns
  tab_output[i,1]  <- volcano_name                                 # volcano_name
  tab_output[i,2]  <- volcano_number                               # volcano_number
  tab_output[i,3]  <- min_easting                                  # min_easting
  tab_output[i,4]  <- max_easting                                  # max_easting
  tab_output[i,5]  <- min_northing                                 # min_northing
  tab_output[i,6]  <- max_northing                                 # max_northing
  tab_output[i,7]  <- NW_zone                                      # NW_zone
  tab_output[i,8]  <- NE_zone                                      # NE_zone
  tab_output[i,9]  <- SW_zone                                      # SW_zone
  tab_output[i,10] <- SE_zone                                      # SE_zone
  tab_output[i,11] <- vent_zone                                    # vent_zone
  tab_output[i,12] <- 10000                                        # resolution
  tab_output[i,13] <- mean_elevation                               # mean_elevation
  tab_output[i,14] <- paste0(volcano_number, "_grid")              # grid_name
  tab_output[i,15] <- 1                                            # zone_crossing    # yes (1) or no (0) (due to the size of the grids as 500 km buffers around the vent, all grids are corssing zones)
  tab_output[i,16] <- equator_crossing                             # equator_crossing # yes (1) or no (0)
  
  # progress monitoring
  print(paste0("finished ", i, " out of ", nrow(tab_input), " which is ", tab_input[i,3]))
} ### end loop over all volcanoes

# check
tab_output
head(tab_output)
tail(tab_output)
# for checking of selected cases: https://www.latlong.net/lat-long-utm.html

# write out csv
write.csv(tab_output, "volc_grids.csv")

### done
