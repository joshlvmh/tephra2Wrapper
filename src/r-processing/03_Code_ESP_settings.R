### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
### Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
### create table with eruption source parameter settings for tephra modelling
### 10.09.2021 modified 26.10.2021, 05.10.2021

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(rgdal)

# set working directory
setwd("$REPO_HOME/inputs/")

### ESP settings as outlined in appendix doc
# write data into vectors
VEI	             <-c(2,
                     3,
                     4,
                     5,
                     6,
                     7)
Min_plume_height <-c(1000,
                     3000,
                     14000,
                     23000,
                     30000,
                     37000)
Max_plume_height <-c(5000,
                     15000,
                     22000,
                     31000,
                     41000,
                     45000)
Min_mass         <-c(4.5 * 10^8 ,
                     8.9 * 10^8 ,
                     4.0 * 10^10,
                     9.2 * 10^11,
                     1.0 * 10^13,
                     1.2 * 10^14)
Max_mass         <-c(1.8 * 10^9 ,
                     5.7 * 10^10,
                     6.5 * 10^11,
                     1.5 * 10^13,
                     4.7 * 10^14,
                     1.9 * 10^15)
### volumes are not needed as model input
###Min_volume       <-c(0.00018	,
###                     0.000356,
###                     0.016	  ,
###                     0.368	  ,
###                     4	      ,
###                     48      )
###Max_volume       <-c(0.00072,
###                     0.0228 ,
###                     0.26	 ,
###                     6			 ,
###                     188		 ,
###                     760		 )
Min_duration     <-c(1 ,
                     1 ,
                     1 ,
                     6 ,
                     12,
                     12)
Max_duration     <-c(6 ,
                     12,
                     12,
                     12,
                     24,
                     24)
Min_grain_size   <-c(7,
                     7,
                     7,
                     7,
                     7,
                     7)
Mean_grain_size  <-c(-0.74,
                     -0.74,
                     0.9	,
                     0.9	,
                     1.35	,
                     1.35	)
Max_grain_size   <-c(-6,
                     -6,
                     -6,
                     -6,
                     -6,
                     -6)
sd_grain_size    <-c(2.4,
                     2.4,
                     1	,
                     1	,
                     1.2,
                     1.2)
Diff_coeff       <-c(4900,
                     4900,
                     8000,
                     8000,
                     8000,
                     8000)
FTT              <-c(5000,
                     5000,
                     9700,
                     9700,
                     9700,
                     9700)
# check vectors
VEI             
Min_plume_height
Max_plume_height
Min_mass        
Max_mass        
#Min_volume      
#Max_volume      
Min_duration    
Max_duration    
Min_grain_size  
Mean_grain_size 
Max_grain_size  
sd_grain_size   
Diff_coeff      
FTT             

# check individually
Max_mass[2]

# read csv with all selected volcanoes
tab_input <- read.csv("volc_holo_mody.csv")
tab_input
head(tab_input)
class(tab_input)

### construct empty matrix for ESP per volcano
tab_output <- matrix(NA, nrow=nrow(tab_input), ncol=58)
colnames(tab_output) <- c("run_name",
                          "out_name",
                          "grid_pth",
                          "wind_pth",
                          "volcano_name",
                          "vent_easting",
                          "vent_northing",
                          "vent_zone",
                          "vent_ht",
                          "min_ht",
                          "max_ht",
                          "min_mass",
                          "max_mass",
                          "min_dur",
                          "max_dur",
                          "constrain",
                          "nb_wind",
                          "wind_start",
                          "wind_per_day",
                          "seasonality",
                          "wind_start_rainy",
                          "wind_start_dry",
                          "constrain_eruption_date",
                          "eruption_date",
                          "constrain_wind_dir",
                          "min_wind_dir",
                          "max_wind_dir",
                          "trop_height",
                          "max_phi",
                          "min_phi",
                          "min_med_phi",
                          "max_med_phi",
                          "min_std_phi",
                          "max_std_phi",
                          "min_agg",
                          "max_agg",
                          "max_diam",
                          "long_lasting",
                          "ht_sample",
                          "mass_sample",
                          "nb_runs",
                          "write_conf",
                          "write_gs",
                          "write_fig_sep",
                          "write_fig_all",
                          "write_log_sep",
                          "write_log_all",
                          "par",
                          "par_cpu",
                          "eddy_const",
                          "diff_coeff",
                          "ft_thresh",
                          "lithic_dens",
                          "pumice_dens",
                          "col_step",
                          "part_step",
                          "alpha",
                          "beta")
head(tab_output)
class(tab_output)
ncol(tab_output)
nrow(tab_output)

### loop over all VEIs
#v=1
#for(v in v:v){
for(v in 1:length(VEI)){
  # set VEI-specific parameters
  this_VEI              <- VEI[v]
  this_Min_plume_height <- Min_plume_height[v]
  this_Max_plume_height <- Max_plume_height[v]
  #this_Min_mass         <- as.numeric(format(Min_mass[v], scientific=F))
  this_Min_mass         <- Min_mass[v]
  this_Max_mass         <- Max_mass[v]
  #this_Min_volume       <- Min_volume[v]
  #this_Max_volume       <- Max_volume[v]
  this_Min_duration     <- Min_duration[v]
  this_Max_duration     <- Max_duration[v]
  this_Min_grain_size   <- Min_grain_size[v]
  this_Mean_grain_size  <- Mean_grain_size[v]
  this_Max_grain_size   <- Max_grain_size[v]
  this_sd_grain_size    <- sd_grain_size[v]
  this_Diff_coeff       <- Diff_coeff[v]
  this_FTT              <- FTT[v]
  
  # check
  this_VEI             
  this_Min_plume_height
  this_Max_plume_height
  this_Min_mass        
  this_Max_mass        
  #this_Min_volume      
  #this_Max_volume      
  this_Min_duration    
  this_Max_duration    
  this_Min_grain_size  
  this_Mean_grain_size 
  this_Max_grain_size  
  this_sd_grain_size   
  this_Diff_coeff      
  this_FTT             
  
  
  ### loop over all rows/volcanoes
  #i=1
  for(i in 1:nrow(tab_input)){
    record <- tab_input[i,]
    record
    
    volcano <- tab_input[i,2]
    volcano
    volcano <- gsub("([^A-Za-z0-9])+", "", x=volcano)
    volcano
    
    lon <- tab_input[i,4]
    lon
    UTM_zone <- floor((lon + 180) / 6) + 1 # from here: https://stackoverflow.com/questions/9186496/determining-utm-zone-to-convert-from-longitude-latitude
    UTM_zone
    # for visual check of UTM zones: https://de.wikipedia.org/wiki/UTM-Koordinatensystem#/media/Datei:Utm-zones.jpg
    
    # convert to SpatialPointsDataFrame
    xy <- record[,c(4,5)]
    xy
    record_spat <- SpatialPointsDataFrame(coords=xy, data=record, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
    record_spat
    class(record_spat)
    # reproject to UTM
    ### if-else-condition for southern hemisphere
    if(tab_input[i,5]<0){
      UTM_point <- spTransform(record_spat, CRS(paste0("+proj=utm +zone=", UTM_zone, " +south ellps=WGS84")))
    } else {
      UTM_point <- spTransform(record_spat, CRS(paste0("+proj=utm +zone=", UTM_zone, " ellps=WGS84")))
    } ### end if-else-condition for southern hemisphere
    UTM_point
    class(UTM_point)
    coordinates(UTM_point)
    # extract easting and northing
    easting <- coordinates(UTM_point)[1]
    easting
    northing <- coordinates(UTM_point)[2]
    northing
    
    # change UTM zone for table
    ### if-else-condition for southern hemisphere
    if(tab_input[i,5]<0){
      UTM_zone <- UTM_zone * -1
    } else {
      UTM_zone <- UTM_zone
    } ### end if-else-condition for southern hemisphere
    UTM_zone
    
    # define vent height
    vent_ht <- tab_input$Elevation..m.[i]
    
    ### if-else-condition accounting for special case of vent elevation being added to VEI 2 plume height 
    if(this_VEI==2){
      this_Min_plume_height_individual <- this_Min_plume_height + vent_ht
      this_Max_plume_height_individual <- this_Max_plume_height + vent_ht
    } else {
      this_Min_plume_height_individual <- this_Min_plume_height
      this_Max_plume_height_individual <- this_Max_plume_height
    }### end if-else-condition accounting for special case of vent elevation being added to VEI 2 plume height
    
    # write into tab_output (all NA are to be replaced)         # keep this for the order of columns
    tab_output[i,1]  <- paste0(volcano, "VEI", this_VEI)        # tab_output$run_name                
    tab_output[i,2]  <- paste0(volcano, "VEI", this_VEI, "OUT") # tab_output$out_name                
    tab_output[i,3]  <- NA                                      # tab_output$grid_pth                
    tab_output[i,4]  <- NA                                      # tab_output$wind_pth                
    tab_output[i,5]  <- tab_input$Volcano.Name[i]               # tab_output$volcano_name            
    tab_output[i,6]  <- easting                                 # tab_output$vent_easting            
    tab_output[i,7]  <- northing                                # tab_output$vent_northing           
    tab_output[i,8]  <- UTM_zone                                # tab_output$vent_zone               
    tab_output[i,9]  <- vent_ht                                 # tab_output$vent_ht                 
    tab_output[i,10] <- this_Min_plume_height_individual        # tab_output$min_ht                  
    tab_output[i,11] <- this_Max_plume_height_individual        # tab_output$max_ht                  
    tab_output[i,12] <- this_Min_mass                           # tab_output$min_mass                
    tab_output[i,13] <- this_Max_mass                           # tab_output$max_mass                
    tab_output[i,14] <- this_Min_duration                       # tab_output$min_dur                 
    tab_output[i,15] <- this_Max_duration                       # tab_output$max_dur                 
    tab_output[i,16] <- 1                                       # tab_output$constrain               
    tab_output[i,17] <- NA                                      # tab_output$nb_wind                 
    tab_output[i,18] <- NA                                      # tab_output$wind_start              
    tab_output[i,19] <- 4                                       # tab_output$wind_per_day            
    tab_output[i,20] <- 0                                       # tab_output$seasonality             
    tab_output[i,21] <- 0                                       # tab_output$wind_start_rainy        
    tab_output[i,22] <- 0                                       # tab_output$wind_start_dry          
    tab_output[i,23] <- 0                                       # tab_output$constrain_eruption_date 
    tab_output[i,24] <- 0                                       # tab_output$eruption_date           
    tab_output[i,25] <- 0                                       # tab_output$constrain_wind_dir      
    tab_output[i,26] <- 0                                       # tab_output$min_wind_dir            
    tab_output[i,27] <- 0                                       # tab_output$max_wind_dir            
    tab_output[i,28] <- 17000                                   # tab_output$trop_height             
    tab_output[i,29] <- this_Max_grain_size                     # tab_output$max_phi                 
    tab_output[i,30] <- this_Min_grain_size                     # tab_output$min_phi                 
    tab_output[i,31] <- this_Mean_grain_size                    # tab_output$min_med_phi             
    tab_output[i,32] <- this_Mean_grain_size                    # tab_output$max_med_phi             
    tab_output[i,33] <- this_sd_grain_size                      # tab_output$min_std_phi             
    tab_output[i,34] <- this_sd_grain_size                      # tab_output$max_std_phi             
    tab_output[i,35] <- 0                                       # tab_output$min_agg                 
    tab_output[i,36] <- 0                                       # tab_output$max_agg                 
    tab_output[i,37] <- 0                                       # tab_output$max_diam                
    tab_output[i,38] <- 0                                       # tab_output$long_lasting            
    tab_output[i,39] <- 1                                       # tab_output$ht_sample               
    tab_output[i,40] <- NA                                      # tab_output$mass_sample             
    tab_output[i,41] <- 10000                                   # tab_output$nb_runs                 
    tab_output[i,42] <- 1                                       # tab_output$write_conf              
    tab_output[i,43] <- 0                                       # tab_output$write_gs                
    tab_output[i,44] <- 0                                       # tab_output$write_fig_sep           
    tab_output[i,45] <- 0                                       # tab_output$write_fig_all           
    tab_output[i,46] <- 0                                       # tab_output$write_log_sep           
    tab_output[i,47] <- 0                                       # tab_output$write_log_all           
    tab_output[i,48] <- NA                                      # tab_output$par                     
    tab_output[i,49] <- NA                                      # tab_output$par_cpu                 
    tab_output[i,50] <- 0.04                                    # tab_output$eddy_const              
    tab_output[i,51] <- this_Diff_coeff                         # tab_output$diff_coeff              
    tab_output[i,52] <- this_FTT                                # tab_output$ft_thresh               
    tab_output[i,53] <- 2900                                    # tab_output$lithic_dens             
    tab_output[i,54] <- 1000                                    # tab_output$pumice_dens             
    tab_output[i,55] <- 50                                      # tab_output$col_step                
    tab_output[i,56] <- 50                                      # tab_output$part_step               
    tab_output[i,57] <- 3                                       # tab_output$alpha                   
    tab_output[i,58] <- 1.5                                     # tab_output$beta                    
    
    # progress monitoring
    print(paste0("finished VEI ", this_VEI, " volcano ", i, " out of ", nrow(tab_input), " which is ", tab_input[i,2]))
    
  } ### loop over all rows/volcanoes
  
  # check
  tab_output
  head(tab_output)
  tail(tab_output)
  # for checking coordinate conversion of selected cases: https://www.latlong.net/lat-long-utm.html
  
  # write out csv
  write.csv(tab_output, paste0("VEI", this_VEI, "_Tephra_ESP_settings.csv"))
  
} ### end loop over all VEIs

### done
