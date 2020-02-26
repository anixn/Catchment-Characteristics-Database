## Title   :: Hydrologic characteristics extraction
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-23 23:18:46
#  DOLE    :: 2019-07-23
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(foreign)){install.packages("foreign");library(foreign)} # to read .dbf files

## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index  <- which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")
fName <- paste0("./Hyderology/StreamOrder/",xlData$RiverBasins,"_",xlData$GaugeStations,"_stream_v.dbf")[Index]

Hydrology <- matrix(NA,nrow = length(Index), ncol = 9) 
colnames(Hydrology) <- c("TOPWET","STREAMS_KM_SQ_KM","STRAHLER_MAX","PCT_1ST_ORDER",
                         "PCT_2ND_ORDER","PCT_3RD_ORDER","PCT_4TH_ORDER",
                         "PCT_5TH_ORDER","PCT_6TH_ORDER_OR_MORE")

## Function files
rm.na.ras <- function(filename,ext){
  temp <- as.vector(raster(paste0(filename,ext)))
  temp <- temp[!is.na(temp)]
  return(temp)
}

for(cat in 1:length(Index)){
  twiFname <- paste0("./Hyderology/DEM_Derivatives/",xlData$RiverBasins[Index[cat]],
                     "_",xlData$GaugeStations[Index[cat]])
  Hydrology[cat,1] <- mean(rm.na.ras(twiFname,"_TWI.tif"))

  #1. Stream density, km of streams per watershed sq km.
  Area             <- AllShpFile[[1]]$area
  shpDbf           <- read.dbf(fName[cat])
  Hydrology[cat,2] <- sum(shpDbf$length)/Area/1000
  Hydrology[cat,3] <- max(shpDbf$strahler)
  
  for(Order in 1:6){ # above 6th order are merged. 
    if(Order <=5){
      Hydrology[cat,3+Order] <- sum(shpDbf$length[shpDbf$strahler %in% Order])/sum(shpDbf$length)
    }else{
      Hydrology[cat,3+Order] <-  sum(shpDbf$length[shpDbf$strahler %in% c(6:max(shpDbf$strahler))])/sum(shpDbf$length)
    }
  }
  cat(cat,"\ ")
}
write.csv(Hydrology,file = "./Hyderology/Hydrology.csv",row.names = FALSE)
