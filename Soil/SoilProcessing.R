## Title   :: Soil data processing value extraction and projection
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-11 11:34:02
#  DOLE    :: 2019-07-11
#  Remarks ::   
## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(readxl)){install.packages("readxl");library(readxl)}
if(!require(doParallel)){install.packages("doParallel");library(doParallel)}
## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index = which(xlData$IndexForDB == 1)

# AllShpFile <- list()
# for(cat in seq_along(Index)){
#   AllShpFile[cat]  <- readOGR(paste0(getwd(), "/CatchmentDelineation/Shapefiles950"),
#                       paste0(xlData$RiverBasins[Index[cat]],"_",xlData$GaugeStations[Index[cat]]),verbose = FALSE)
#   print(cat)
# }
# save(AllShpFile,file = "AllShpFile567.R")

load("./CatchmentDelineation/AllShpFile567.RData")

dirName <- c("BLD","CLYPPT","CRFVOL","ORCDRC","SLTPPT","SNDPPT")
mnLayer <- c("D2.5cm","D10cm","D22.5cm","D45cm","D80cm","D150cm")
tileNums <- c(350,386,387,421,422,423,424,458,459)

SoilData <- matrix(NA,nrow = length(Index),ncol = length(dirName)*length(mnLayer))

colName <- c()
for(ii in 1: length(dirName)){colName <- append(colName, paste0(dirName[ii],"_",mnLayer))}
colnames(SoilData) <- colName; rm(colName)

kk = 1
for(Dir in seq_along(dirName)){
  for(Layers in seq_along(mnLayer)){
    a = Sys.time() # Time computation 
    RasterLayer <- list()
    for(Tile in tileNums){
      RasterLayer  <- append(RasterLayer,
                             list(raster(paste0("./Soil/",dirName[Dir],
                                                "/",dirName[Dir],
                                                "_sd",Layers,"_M_1km_T",Tile,".tif"))))
    }
    # merging soil tiles for whole India Dir: Dx and Layer Lx
    mergeRaster <- do.call(merge, RasterLayer);rm(RasterLayer)
    Vals <- rep(NA,length(Index))
    for(cat in seq_along(Index)){ 
      shpFile  <- AllShpFile[[cat]]
      temp <- extract(x                 = mergeRaster, 
                      y                 = shpFile,
                      weights           = TRUE, 
                      normalizeWeights  = TRUE,
                      df                = TRUE)
      Vals[cat] <- sum(temp$layer*temp$weight, na.rm = TRUE)
      rm(shpFile,temp)
      cat(cat,'\n')
    }
    SoilData[,kk] <- Vals
    kk <- kk +1
    print(Sys.time()-a)
  }
}

write.csv(SoilData,file = "./Soil/Soil.csv",row.names = FALSE)
