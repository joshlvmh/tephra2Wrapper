### project: Probabilistic ash fall hazard assessment to coral reefs in the Coral Triangle
### Jan-Christopher Fischer (jc.fischer@bristol.ac.uk)
### select volcanoes to be included
### add coordinates for wind data download
### 08.09.2021, modified 29.11.2021 (reduction of volcanoes due to lack in eruption probability data)

# check and clean memory
ls()
rm(list=ls(all.names=T))
gc()
ls()

# load libraries
library(raster)
library(rgeos)
library(rgdal)

setwd("~")
AOI <- shapefile("AOI.shp")
AOI
AOI_buff_500_km <- shapefile("AOI_buff_500_km.shp")
AOI_buff_500_km
extent(AOI_buff_500_km)
# xmin: 87.52166 
# xmax: 178.1652 
# ymin: -20.64415 
# ymax: 28.40833 

# load land data
setwd("~")
land <- shapefile("ne_10m_land.shp")
land
land_crop <- crop(land, extent(AOI_buff_500_km))
land_crop
#plot(land_crop)

### load volcano data
setwd("~")
#volc_holo <- read.csv("GVP_Volcano_List_Holocene_2020.csv", sep=";")
volc_holo <- read.csv("GVP_Volcano_List_Holocene.csv", sep=",")
# this file was downloaded here https://volcano.si.edu/list_volcano_holocene.cfm on 03.09.2021
volc_holo
head(volc_holo)
nrow(volc_holo) # 1356 volcanoes included
names(volc_holo)

# exclude volcanoes by location (extent of AOI)
volc_holo <- volc_holo[volc_holo$Latitude  > -20.64415,]
volc_holo <- volc_holo[volc_holo$Latitude  < 28.40833 ,]
volc_holo <- volc_holo[volc_holo$Longitude > 87.52166 ,]
volc_holo <- volc_holo[volc_holo$Longitude < 178.1652 ,]
head(volc_holo)
nrow(volc_holo)

# exclude volcanoes by location (AOI)
# convert to SpatialPointsDataFrame
xy <- volc_holo[,c(10,9)]
xy
volc_holo_spat <- SpatialPointsDataFrame(coords=xy, data=volc_holo, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
volc_holo_spat
plot(volc_holo_spat)
volc_holo_spat_crop <- crop(volc_holo_spat, AOI_buff_500_km)
volc_holo_spat_crop
plot(volc_holo_spat_crop, col="red", add=T)
# convert back to data frame
volc_holo <- as.data.frame(volc_holo_spat_crop)
volc_holo
head(volc_holo)
nrow(volc_holo) # 271 volcanoes included

### percentage of Holocene volcanoes located in the Coral Triangle: ~20%
# p = W/G
round((271 / 1356) * 100)

# exclude submarine volcanoes by type
volc_holo <- volc_holo[volc_holo$Primary.Volcano.Type != "Submarine",]
head(volc_holo)
nrow(volc_holo)

# exclude submarine volcanoes by elevation
volc_holo <- volc_holo[volc_holo$Elevation..m. > 0,]
head(volc_holo)
nrow(volc_holo)

# exclude volcanoes with uncertain evidence
volc_holo <- volc_holo[volc_holo$Activity.Evidence != "Evidence Uncertain",]
head(volc_holo)
nrow(volc_holo)

# list countries of retained volcanoes
sort(unique(volc_holo$Country))
### search at https://volcano.si.edu/search_eruption.cfm for eruptions from all those countries
# "Burma (Myanmar)"  "China"            "Fiji"             "India"            "Indonesia"        "Japan"           
# "Papua New Guinea" "Philippines"      "Solomon Islands"  "Taiwan"           "United States"    "Vanuatu"         
# "Vietnam"
# resultant file "GVP_Eruption_Results" was converted to csv

### load eruption data
setwd("C:/Users/zs20225/OneDrive - University of Bristol/Documents/4D-REEF PhD Uni Bristol/Research/02_Ash_fall_modelling/Data/Original data/GVP")
eruptions <- read.csv("GVP_Eruption_Results.csv", sep=",")
eruptions
head(eruptions)
nrow(eruptions)
names(eruptions)
class(eruptions)

# only retain confirmed eruptions
unique(eruptions$Eruption.Category)
eruptions <- eruptions[eruptions$Eruption.Category == "Confirmed Eruption",]
head(eruptions)
nrow(eruptions)

# retain only eruption records of pre-selected volcanoes
eruptions_mody <- eruptions[eruptions$Volcano.Name %in% volc_holo$Volcano.Name,]
eruptions_mody
head(eruptions_mody)
nrow(eruptions_mody)

# check numbers of volcanoes
length(sort(unique(volc_holo$Volcano.Name)))
length(sort(unique(eruptions_mody$Volcano.Name)))

# retain only volcanoes with documented eruptions
volc_holo_mody <- volc_holo[volc_holo$Volcano.Name %in% eruptions_mody$Volcano.Name,]
volc_holo_mody
head(volc_holo_mody)
nrow(volc_holo_mody)

length(sort(unique(volc_holo_mody$Volcano.Name)))
sort(unique(volc_holo_mody$Volcano.Name))

# exclude volcanoes by name (exclude volcanoes with lacking data on eruption probabilities provided by Jenkins et al. in Loughlin et al. 2015 calculated by Susanna)
# Ambang, Dawson Strait Group, Isarog, Kadovar, Kueishantao, Mariveles, Muria, Traitor's Head
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Ambang", ]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Dawson Strait Group",]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Isarog",]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Kadovar",]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Kueishantao",]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Mariveles",]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Muria",]
volc_holo_mody <- volc_holo_mody[volc_holo_mody$Volcano.Name != "Traitor's Head",]

# check
head(volc_holo_mody)
nrow(volc_holo_mody)
length(sort(unique(volc_holo_mody$Volcano.Name)))
sort(unique(volc_holo_mody$Volcano.Name))

#############
###### other option: only keep volcanoes with VEI>=2
###unique(eruptions_mody$VEI)
###eruptions_VEI <- eruptions_mody[eruptions_mody$VEI >= 2,]
###eruptions_VEI <- eruptions_VEI[!is.na(eruptions_VEI$VEI),]
###head(eruptions_VEI)
###nrow(eruptions_VEI)
###unique(eruptions_VEI$VEI)
###
#### retain only volcanoes with documented eruptions of VEI>=2
###volc_holo_VEI <- volc_holo_mody[volc_holo_mody$Volcano.Name %in% eruptions_VEI$Volcano.Name,]
###volc_holo_VEI
###head(volc_holo_VEI)
###nrow(volc_holo_VEI)
###
###length(sort(unique(volc_holo_VEI$Volcano.Name)))
###sort(unique(volc_holo_VEI$Volcano.Name))

##########
### exclude all columns but number, name, coordinates and elevation
volc_holo_mody <- volc_holo_mody[,c(1, 2, 10, 9, 11)]
head(volc_holo_mody)
###volc_holo_VEI <- volc_holo_VEI[,c(1, 2, 10, 9, 11)]
###head(volc_holo_VEI)

# sort alphabetically
volc_holo_mody <- volc_holo_mody[order(volc_holo_mody$Volcano.Name),]
head(volc_holo_mody)
###volc_holo_VEI <- volc_holo_VEI[order(volc_holo_VEI$Volcano.Name),]
###head(volc_holo_VEI)

### check tables
# volcanoes with documented eruptions
volc_holo_mody
head(volc_holo_mody)
nrow(volc_holo_mody)
length(sort(unique(volc_holo_mody$Volcano.Name)))
sort(unique(volc_holo_mody$Volcano.Name))

#### volcanoes with documented eruptions of VEI>=2
###volc_holo_VEI
###head(volc_holo_VEI)
###nrow(volc_holo_VEI)
###length(sort(unique(volc_holo_VEI$Volcano.Name)))
###sort(unique(volc_holo_VEI$Volcano.Name))

### add coordinates for wind data download
# add empty columns to be filled in loop
volc_holo_mody["wind_north"] <- NA
volc_holo_mody["wind_south"] <- NA
volc_holo_mody["wind_east" ] <- NA
volc_holo_mody["wind_west" ] <- NA
head(volc_holo_mody)

###volc_holo_VEI["wind_north"] <- NA
###volc_holo_VEI["wind_south"] <- NA
###volc_holo_VEI["wind_east" ] <- NA
###volc_holo_VEI["wind_west" ] <- NA
###head(volc_holo_VEI)

# rename tables
tab <- volc_holo_mody
###tab <- volc_holo_VEI
head(tab)

### loop over all volcanoes to add coordinates for wind data download
#i=1
for(i in 1:nrow(tab)){
  ### extract individual volcano coordinates
  lon <- tab[i,3]
  lon
  lat <- tab[i,4]
  lat
  
  ### identify north, south, east and west coordinates for wind points
  # North
  tab[i,6] <- round((lat + 0.01), 2)
  # South
  tab[i,7] <- round((lat - 0.01), 2)
  # East
  tab[i,8] <- round((lon + 0.01), 2)
  # West
  tab[i,9] <- round((lon - 0.01), 2)
  
  # check
  #head(tab)
  
  # print for progress monitoring
  print(paste0("finished ", i, " out of ", nrow(tab), " which is ", tab[i,1]))
}

# check
head(tab)

# write out csv
setwd("~")
write.csv(tab, "volcano_set_wind.csv")
###write.csv(tab, "volc_holo_VEI.csv")

### done
