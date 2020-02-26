## Title   :: Land cover classification 
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-17 19:57:30
#  DOLE    :: 2019-07-17
#  Remarks :: 

## ClearUp and dir ####################################################
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(rgeos)){install.packages("rgeos");library(rgeos)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}
if(!require(viridis)){install.packages("viridis");library(viridis)}
## Main code ##########################################################

xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index  <- which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")
LandCover <- raster("./Landcover/SouthAsia_Grid_v4_LC/south_asia_v4")
LandCover@data@names <- "RasterLayer"
Table <- as.data.frame(LandCover@data@attributes)
Table$CLASS_NAMES <-  gsub(" ","_", trimws(gsub('[[:punct:] ]+'," ",toupper(Table$CLASS_NAMES))))

Classes = unique(Table$ID)
LC_Count <- matrix(NA, nrow = length(Index), ncol = length(Classes))
colnames(LC_Count) <- Table$CLASS_NAMES

## Add Crop percentage 2005
India    <- readOGR(dsn = "./CatchmentDelineation/India_SHP_plotting", layer = "All_India")
CropLand <- raster("./Landcover/World cropland/CropLand.tif")
CropLand <- crop(x = CropLand, y = India@bbox )
CropLand@data@names <- "RasterLayer"


pdf("./Landcover/LC.pdf", width = 10, height = 16)
plot(CropLand,col = viridis(10), axes=FALSE, box=FALSE)
plot(India, add = T, border  = "orange", lwd = 1)
dev.off()

LC_Count <- cbind(LC_Count,rep(NA,length(Index)))
colnames(LC_Count) <- c(colnames(LC_Count)[1:length(Classes)],"CROP_LAND")

for(cat in seq_along(Index)){
  #now extract the information in the grids
  temp <- extract(x                = LandCover,
                  y                = AllShpFile[[cat]],
                  weights          = TRUE,
                  normalizeWeights = TRUE,
                  df               = TRUE)

  LC_Ext   <- temp$RasterLayer[!is.na(temp$RasterLayer)]
  LC_Wt    <- temp$weight[!is.na(temp$RasterLayer)]

  for(Type in 1:length(Classes)) {
    LC_Count[cat,Type] <- sum(LC_Wt[LC_Ext == Classes[Type]])*100
  }
  rm(temp,LC_Ext,LC_Wt)
  
  temp <- extract(x                = CropLand, 
                  y                = AllShpFile[[cat]], 
                  weights          = TRUE, 
                  normalizeWeights = TRUE,
                  df               = TRUE)
  
  LC_Count[cat,(length(Classes)+1)] <- sum(temp$RasterLayer[!is.na(temp$RasterLayer)]*temp$weight[!is.na(temp$RasterLayer)])
  rm(temp)
  cat(cat,"\ ")
}

write.csv(LC_Count,file = "./Landcover/LandCover.csv", row.names = FALSE)

