## Title   :: Temperature data processing daily and monthly products
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-06-27 15:25:12
#  DOLE    :: 2019-06-27
#  Remarks :: Min and Max

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database 101")
## Load required libraries ############################################
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}
if(!require(reader)){install.packages("reader");library(reader)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(stringr)){install.packages("stringr");library(stringr)}
if(!require(reshape2)){install.packages("reshape2");library(reshape2)}
if(!require(doParallel)){install.packages("doParallel");library(doParallel)}
## Main code ##########################################################
Extent = data.frame(Long = c(67.50, 97.50), # West to East  
                    Lat  = c(7.50, 37.50))   # South to Norths
Res       = 1.0
naVal     = 99.90
startYear = 1951
endYear   = 2013

temp = seq(dmy("01-01-1951"),dmy("31-12-2013"),by = "days")
DateName <-  paste0("R",str_pad(day(temp),2,pad="0"),str_pad(month(temp),2,pad = "0"),year(temp)); rm(temp)

# Choose min, mean or max data procession
flag = c("MaxT","MeanT","MinT")[as.numeric(readline(prompt="Enter 1:Max | 2:Mean | 3:Min : "))]

kk = 1
for(Year in 1:(endYear- startYear+1)){
  startData = paste0((startYear+Year-1),"-01-01")
  endData   = paste0((startYear+Year-1),"-12-31")
  Date      = seq(ymd(startData), ymd(endData), by="days")
  Date      = paste0(str_pad(day(Date),2,pad="0"),str_pad(month(Date),2,pad = "0"),year(Date))
  fileName  = paste0("./Temperature/",flag,"/",flag,"_",(startYear+Year-1),".TXT")
  allLines  = readLines(fileName)
  allLines  = allLines[-1]
  indexRow <- (which(allLines %in% allLines[1])) + 1 # one line removed form title 

  Rows = (indexRow[2]-indexRow[1]) # -1 removed when used n.readline: "99.9-10.54"
  for(Day in seq_along(indexRow)){
    #Data = read.table(fileName,header = FALSE,skip = indexRow[Day], 
    #                 nrows = Rows) #
    #Data = Data[,3:dim(Data)[2]]   #remove latitude column.
    #total row is  32.
    dtLines = n.readLines(fileName , n = Rows, skip = indexRow[Day]-1) 
    listChar = regmatches(dtLines,gregexpr("\\-*\\d+\\.*\\d*",dtLines))
    Data = matrix(NA,nrow=length(dtLines),ncol = 31)
    for(ii in seq_along(listChar)){
      Data[ii,] = as.numeric(unlist(listChar[ii]))[3:33]
    }

    rownames(Data) <- seq(Extent$Lat[1],Extent$Lat[2], by = Res)
    colnames(Data) <- seq(Extent$Long[1],Extent$Long[2], by = Res)
    #image(as.matrix(Data))
    Data = apply(t(as.matrix(Data)),1,rev)
    #image(as.matrix(Data))
    Raster = raster(nrows = dim(Data)[1], ncols = dim(Data)[2],
                    xmn = Extent$Long[1], xmx = Extent$Long[2], 
                    ymn = Extent$Lat[1], ymx = Extent$Lat[2],
                    crs = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"), #proj4string(catShp)
                    vals = Data)
    
    #graphics.off();plot(Raster);plot(catShp,add = T)
    print(paste(kk,Day))
    save(Raster,file = paste0("C:/Temp/RasterData",flag,"/",DateName[kk],".RData"))
    kk = kk+1
  }
}

gaugeData <- readxl::read_excel("./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
gaugeName <- paste(gaugeData$`River Basins`,gaugeData$GaugeStations,sep = "_")
gaugeName <- gaugeName[gaugeData$IndexForDB ==1] 

# Read the shapefile
for(shp in 1:length(gaugeName)){ #473
  a= Sys.time()
  temperDaily = data.frame(Date          = rep(NA,length(DateName)),
                           Temperature = matrix(NA,nrow = length(DateName),ncol = 1))
  catShp <- readOGR("./CatchmentDelineation/Shapefiles 950",gaugeName[shp])
  
  #making loop parellel
  cl <- makeCluster(24)
  registerDoParallel(cl)
  temper = unlist(foreach(Day = 1:length(DateName))%dopar%{
    if(!require(raster)){install.packages("raster");library(raster)}
    # load the image data file and extract the value
    load(paste0("C:/Temp/RasterData",flag,"/",DateName[Day],".RData"))
    temp = extract(x                = Raster,
                   y                = catShp,
                   weights          = TRUE, 
                   normalizeWeights = TRUE,
                   df               = TRUE)
    rmIndex = temp$layer != naVal
    tempTemp = sum(temp$layer[rmIndex]*temp$weight[rmIndex],na.rm = T)
  }
  )
  stopCluster(cl)
  temperDaily[,1] <- gsub("R","",DateName)
  temperDaily[,2] <-  temper;rm(temper)
  write.csv(temperDaily,file = paste0("./Temperature/",flag,"/IMD_Temper_",flag,"_daily_",gaugeName[shp],".csv"),row.names = FALSE)
  print(shp);print(Sys.time()-a)
}
