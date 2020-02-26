## Title   :: Porosity and permeability crop then covert to raster for extraction
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-24 19:00:07
#  DOLE    :: 2019-07-24
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}

## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index = which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")
ppShpData    <- readOGR(dsn = "./Soil/PORPER",layer="PorPerWGSTras")

Extent       <- extent(ppShpData)
rr           <- raster(Extent, res=0.01)
Porosity     <- rasterize(ppShpData, rr, field = "Porosity")
Permeability <- rasterize(ppShpData, rr, field = "Permeabili")

PorPer <- matrix(NA,nrow = length(Index), ncol = 2)
colnames(PorPer) <- c("Porosity","Permeability")

Porosity@data@names <- "rasterLayer"
Permeability@data@names <- "rasterLayer"

for(cat in seq_along(Index)){ 
  shpFile <- AllShpFile[[cat]]
  temp <- extract(x                 = Porosity, 
                  y                 = shpFile,
                  weights           = TRUE, 
                  normalizeWeights  = TRUE,
                  df                = TRUE)
  PorPer[cat,1] <- sum(temp$rasterLayer*temp$weight, na.rm = T)
  
  temp <- extract(x                 = Permeability, 
                  y                 = shpFile,
                  weights           = TRUE, 
                  normalizeWeights  = TRUE,
                  df                = TRUE)
  PorPer[cat,2] <- 10^(sum(temp$rasterLayer * temp$weight, na.rm = T)/100)
  cat(cat,'\ ')
}

write.csv(PorPer,file = "./Soil/PorPer.csv",row.names = FALSE)
