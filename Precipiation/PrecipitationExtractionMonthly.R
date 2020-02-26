## Title   :: Convert Daily Data to monthly data 
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-06-30 14:27:42
#  DOLE    :: 2019-06-30
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database 101/")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(readxl)){install.packages("readxl");library(readxl)}
if(!require(lubridate)){install.packages("lubridate");library(lubridate)}

## Main code ##########################################################
gaugeData <- readxl::read_excel("./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
gaugeName <- paste(gaugeData$`River Basins`,gaugeData$GaugeStations,sep = "_")
gaugeName <- gaugeName[gaugeData$IndexForDB ==1] 

Len = seq(ymd(19510101),ymd(20131231),by = "days")
precipAllShp <- matrix(NA, nrow = length(Len), ncol = (length(gaugeName)+1)) #One for Date
colnames(precipAllShp) <- c("Date",gaugeName)

for(shp in seq_along(gaugeName)){
  precipData = read.csv(paste0("./Precipiation/CatPrecipDaily/IMD_precip_daily_",gaugeName[shp],".csv"),header = TRUE)
  Index = seq(which(precipData$Date == "19510101"), which(precipData$Date == "20131231"),by = 1)
  precipAllShp[,1] <- precipData$Date[Index] 
  precipAllShp[,shp+1] <- precipData$Precipitation[Index]
  rm(precipData)
  print(shp)
}
write.csv(precipAllShp,file = "precipAllShp.csv",row.names = FALSE)

# get the monthly data based on month.
Month = month(ymd(precipAllShp[,1]))
Year  = year(ymd(precipAllShp[,1]))

precipAllShpMonth <- matrix(NA,nrow = 63*12,(length(gaugeName)+2))
colnames(precipAllShpMonth) <- c("Month","Year",gaugeName)

for(shp in seq_along(gaugeName)){
  df = data.frame(Precip = precipAllShp[,(shp+1)],
                  Month  = Month,
                  Year   = Year)
  Temp = aggregate(Precip~ Month + Year ,df,mean)
  precipAllShpMonth[,1] <- Temp$Month
  precipAllShpMonth[,2] <- Temp$Year
  precipAllShpMonth[,(shp+2)] <- Temp$Precip
  rm(df,Temp)
}

write.csv(precipAllShpMonth,file = "precipAllShpMonth.csv",row.names = FALSE)




