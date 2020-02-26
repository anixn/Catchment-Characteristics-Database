## Title   :: Land use classification 
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
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(viridis)){install.packages("viridis");library(viridis)}

## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index  <- which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")

LandUse <- raster("./Landuse/Anthropogenic World Biome/2000/anthro2_a2000.tif")
LandUse@data@names <- "RasterLayer"

if(!require(foreign)){install.packages("foreign");library(foreign)}
AttTbl = read.dbf("./Landuse/Anthropogenic World Biome/2000/anthro2_a2000.tif.vat.dbf")
detach("package:foreign", unload=TRUE)

AttTbl$LABEL <-  gsub(" ","_", trimws(gsub('[[:punct:]]+|[[:digit:]]+'," ",toupper(AttTbl$LABEL))))

Classes = unique(AttTbl$VALUE)
LU_Count <- matrix(NA, nrow = length(Index), ncol = length(Classes))
colnames(LU_Count) <- AttTbl$LABEL

India    <- readOGR(dsn = "./CatchmentDelineation/India_SHP_plotting", layer = "All_India", verbose = FALSE)

pdf("./Landuse/LU.pdf", width = 16, height = 8)
plot(LandUse,col = viridis(10), axes=FALSE, box=FALSE)
plot(India, add = T, border  = "orange", lwd = 1)
dev.off()

for(cat in seq_along(Index)){
  #now extract the information in the grids
  temp <- extract(x                = LandUse,
                  y                = AllShpFile[[cat]],
                  weights          = TRUE,
                  normalizeWeights = TRUE,
                  df               = TRUE)
  
  LU_Ext   <- temp$RasterLayer[!is.na(temp$RasterLayer)]
  LU_Wt    <- temp$weight[!is.na(temp$RasterLayer)]
  
  for(Type in 1:length(Classes)) {
    LU_Count[cat,Type] <- sum(LU_Wt[LU_Ext == Classes[Type]])*100
  }
  cat(cat,"\ ")
}

write.csv(LU_Count,file = "./Landuse/LandUse.csv", row.names = FALSE)

