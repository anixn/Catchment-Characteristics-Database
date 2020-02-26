## Title   :: Process soil mousture data
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-08-13 16:57:12
#  DOLE    :: 2019-08-13
#  Remarks :: 

## ClearUp and dir #############################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries #####################################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(viridis)){install.packages("viridis");library(viridis)}
if(!require(ncdf4)){install.packages("ncdf4");library(ncdf4)}
if(!require(doParallel)){install.packages("doParallel");library(doParallel)}
## Main code ###################################################################
#1. Find if any nc4 files are missing.
DateName  <- paste0(gsub("-","",seq(as.Date("1951-01-01"), as.Date("2014-12-30"), by="days")))
ncName    <- dir(path = "D:/SoilMoistureDataDaily", pattern = ".nc4"); (ncName[1])
ncAllName <- paste0("GLDAS_CLSM025_D.A",DateName,".020.nc4.SUB.nc4")
misData   <- DateName[!(ncAllName %in% ncName)]

#2. Read one nc4 file to know basic and band informations.
ncDir    <- "D:/SoilMoistureDataDaily/"
fileName <- paste0(ncDir,"GLDAS_CLSM025_D.A",DateName[1],".020.nc4.SUB.nc4")
NC       <- nc_open(fileName); 
print(NC)
Years    <- ncvar_get(NC,"time")
missing_value <- -9999
nc_close(NC);rm(NC)

#SoilMoist_RZ_tavg[lon,lat,time]
gaugeData <- readxl::read_excel("./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
gaugeName <- paste(gaugeData$RiverBasins,gaugeData$GaugeStations,sep = "_")
gaugeName <- gaugeName[gaugeData$IndexForDB ==1] 


# load all shapefile
load("./CatchmentDelineation/AllShpFile567.RData")
soilMoistDaily <- matrix(data = NA, nrow =  length(DateName),ncol = length(AllShpFile))
colnames(soilMoistDaily) <- gaugeName
for(shp in 1:length(gaugeName)){
  a = Sys.time()
  catShp <- AllShpFile[[shp]]
  #making loop parellel
  cl <- makeCluster(28)
  registerDoParallel(cl)
  
  temp = unlist(foreach(Day = 1:length(DateName))%dopar%{  #
    library(raster)
    fileName = paste0(ncDir,"GLDAS_CLSM025_D.A",DateName[Day],".020.nc4.SUB.nc4")
    soilMoist <- raster::stack(fileName,varname='SoilMoist_RZ_tavg')
    temp = extract(x                = soilMoist,
                   y                = catShp,
                   weights          = TRUE, 
                   normalizeWeights = TRUE,
                   df               = TRUE)
    keepIndex = temp$Root.Zone.Soil.moisture != missing_value
    tempePrecip = sum(temp$Root.Zone.Soil.moisture[keepIndex]*temp$weight[keepIndex],na.rm = T)
  })
  soilMoistDaily[,shp] <- temp
  stopCluster(cl)
  cat("Cat:",shp,"| Time difference:",Sys.time() - a,"min","\ ")
}
write.csv(soilMoistDaily,"./Soil/SoilMoisture/SoilMoisture.csv",row.names = FALSE)

k = 1
for(ii in 1: 63){
  plot(soilMoistDaily[k:(k+365),120],type = "l", col = rgb(runif(1),runif(1),runif(1)))
  k = k+365
  Sys.sleep(1)
}
