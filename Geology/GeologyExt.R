## Title   :: File Description
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-17 19:57:30
#  DOLE    :: 2019-07-17
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(rgeos)){install.packages("rgeos");library(rgeos)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}

## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index  <- which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")

LithoLayer <- raster("./Geology/glim_wgs84.asc") # reading the raster file.
crs(LithoLayer) <- ("+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

#India <- readOGR("./CatchmentDelineation/India_SHP_plotting","All_India", verbose = FALSE)
#plot(LithoLayer);plot(India,add = TRUE);rm(India)
Classes = 16
LithoCount <- matrix(NA, nrow = length(Index), ncol = Classes)
for(cat in seq_along(Index)){
  #now extract the information in the grids
  temp <- extract(x                = LithoLayer, 
                  y                = AllShpFile[[cat]], 
                  weights          = TRUE, 
                  normalizeWeights = TRUE,
                  df               = TRUE)

  LithoExt   <- temp$glim_wgs84[!is.na(temp$glim_wgs84)]
  LithoWt    <- temp$weight[!is.na(temp$glim_wgs84)]

  for(Type in 1:Classes) {
    LithoCount[cat,Type] <- sum(LithoWt[LithoExt == Type])*100
  }
  cat(cat,"\n")
}
LithoInfo <- read.csv(file = "./Geology/LithoInfo.csv",header = TRUE)
colnames(LithoCount) <- LithoInfo$CatName
write.csv(LithoCount,file = "./Geology/Geology.csv", row.names = FALSE)
