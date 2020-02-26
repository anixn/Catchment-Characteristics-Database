## Title   :: Precipitation data processing daily and monthly products
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-06-27 15:25:12
#  DOLE    :: 2019-06-27
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database 101")
## Load required libraries ############################################
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}
if(!require(reader)){install.packages("reader");library(reader)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(reshape2)){install.packages("reshape2");library(reshape2)}
if(!require(doParallel)){install.packages("doParallel");library(doParallel)}
## Main code ##########################################################
Extent = data.frame(Long = c(66.50, 100.00), # West to East  
                    Lat  = c(6.50, 38.50))   # South to Norths
Res       = 0.25
naVal     = -99.9
startYear = 1951
endYear   = 2013
DateName <-  paste0("R",gsub("-","",seq(as.Date("1951-01-01"), as.Date("2013-12-31"), by="days")))

kk = 1
for(Year in 1:(endYear- startYear+1)){
  startData = paste0((startYear+Year-1),"-01-01")
  endData   = paste0((startYear+Year-1),"-12-31")
  Date = gsub("-","",seq(as.Date(startData), as.Date(endData), by="days"))
  fileName = paste0("./Precipiation/IMDPrecipData/IND",(startYear+Year-1),"_rfP25.TXT")
  allLines = readLines(fileName)
  indexLine = substr(allLines[1], start = 9, stop = nchar(allLines[1])) #nchar(20190101)+1 = 9 
  
  indexRow = c()
  for(ii in seq_along(Date)){
    indexRow[ii] <- which(allLines %in% paste0(Date[ii],indexLine))
  }
  
  Rows = (indexRow[2]-indexRow[1])-1
  for(Day in seq_along(indexRow)){
    Data = read.table(fileName,header = FALSE,skip = indexRow[Day], 
                      nrows = Rows) 
    
    Data = Data[,2:dim(Data)[2]]   #remove latitude column.
    rownames(Data) <- seq(Extent$Lat[1],Extent$Lat[2], by = Res)
    colnames(Data) <- seq(Extent$Long[1],Extent$Long[2], by = Res)
    #image(as.matrix(Data))
    Data = apply(t(as.matrix(Data)),1,rev)
    #image(as.matrix(Data))
    Raster = raster(nrows = dim(Data)[1], ncols = dim(Data)[2],
                    xmn = Extent$Long[1], xmx = Extent$Long[2], 
                    ymn = Extent$Lat[1], ymx = Extent$Lat[2],
                    crs =  CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"), #proj4string(catShp)
                    vals = Data)
    
    #graphics.off();plot(indRaster);plot(catShp,add = T)
    print(paste(kk,Day))
    save(Raster,file = paste0("C:/Temp/RasterData/",DateName[kk],".RData"))
    kk = kk+1
  }
}

gaugeData <- readxl::read_excel("./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
gaugeName <- paste(gaugeData$`River Basins`,gaugeData$GaugeStations,sep = "_")
gaugeName <- gaugeName[gaugeData$IndexForDB ==1] 

# Read the shapefile
for(shp in 1:length(gaugeName)){
  a= Sys.time()
  precipDaily = data.frame(Date          = rep(NA,length(DateName)),
                           Precipitation = matrix(NA,nrow = length(DateName),ncol = 1))
  catShp <- readOGR("./CatchmentDelineation/Shapefiles 950",gaugeName[shp])
  
  #making loop parellel
  cl <- makeCluster(24)
  registerDoParallel(cl)
  precip = unlist(foreach(Day = 1:length(rasterData))%dopar%{
    if(!require(raster)){install.packages("raster");library(raster)}
    # load the image data file and extract the value
    load(paste0("C:/Temp/RasterData/",DateName[Day],".RData"))
    temp = extract(x                = Raster,
                   y                = catShp,
                   weights          = TRUE, 
                   normalizeWeights = TRUE,
                   df               = TRUE)
    rmIndex = temp$layer != naVal
    tempePrecip = sum(temp$layer[rmIndex]*temp$weight[rmIndex],na.rm = T)
  }
  )
  stopCluster(cl)
  precipDaily[,1] <- gsub("R","",DateName)
  precipDaily[,2] <-  precip;rm(precip)
  write.csv(precipDaily,file = paste0("IMD_precip_daily_",gaugeName[shp],".csv"),row.names = FALSE)
  print(shp);print(Sys.time()-a)
}
