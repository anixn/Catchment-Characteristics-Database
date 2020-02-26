## Title   :: Topologic characteristic extraction
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-23 12:47:43
#  DOLE    :: 2019-07-23
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(viridis)){install.packages("viridis");library(viridis)}

## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index  <- which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")

fName <- paste0("./Hyderology/DEM_Derivatives/",xlData$RiverBasins,"_",xlData$GaugeStations)[Index]

Topography <- matrix(NA,nrow = length(Index), ncol = 14)
colnames(Topography) <- c("ELEV_MEAN_M_BASIN","ELEV_MEDIAN_M_BASIN","ELEV_MAX_M_BASIN","ELEV_MIN_M_BASIN",
                          "ELEV_STD_M_BASIN","RRMEAM","RRMEDIAN","ASPECT_DEGREES","ASPECT_NORTHNESS",
                          "ASPECT_EASTNESS","NS_SLOPE","EW_SLOPE","SLOPE_PCT","TAN_CURVE")

## Function files
rm.na.ras <- function(filename,ext){
  temp <- as.vector(raster(paste0(filename,ext)))
  temp <- temp[!is.na(temp)]
  return(temp)
}

aspectCompFun <- function(angle){
  if(angle == 0){
    compAsp = 0
  }else if(angle <= 90){
    compAsp = (90 - angle)
  }else(compAsp =  (360 + 90 - angle))
  return(compAsp)
}

## Iteration for catchments
for(cat in seq_along(Index)){
  demVect <- rm.na.ras(fName[cat],'.tif')
  
  Topography[cat,1] <- mean(demVect)
  Topography[cat,2] <- median(demVect)
  Topography[cat,3] <- max(demVect)
  Topography[cat,4] <- min(demVect)
  Topography[cat,5] <- sd(demVect)
  Topography[cat,6] <- (mean(demVect)-min(demVect))/(max(demVect)-min(demVect))
  Topography[cat,7] <- (median(demVect)-min(demVect))/(max(demVect)-min(demVect))
  
  ## Aspect products
  meanAspect <- mean(rm.na.ras(fName[cat],"_Aspect.tif"))
  Topography[cat,8]  <- meanAspect
  Topography[cat,9]  <- cos(aspectCompFun(meanAspect))
  Topography[cat,10] <- sin(aspectCompFun(meanAspect))
  Topography[cat,11] <- mean(rm.na.ras(fName[cat],"_NS_slope.tif"))
  Topography[cat,12] <- mean(rm.na.ras(fName[cat],"_EW_slope.tif"))
  Topography[cat,13] <- mean(rm.na.ras(fName[cat],"_Slope.tif"))
  Topography[cat,14] <- mean(rm.na.ras(fName[cat],"_tCurv.tif"))
  cat(cat,"\n")
}

write.csv(Topography,file = "./Topography/Topography.csv",row.names = FALSE)

