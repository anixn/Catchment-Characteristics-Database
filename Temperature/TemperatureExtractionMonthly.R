## Title   :: Convert Daily Data to monthly data for Temperature  
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-01 16:38:25
#  DOLE    :: 2019-07-01
#  Remarks :: Combine daily precipitation to one file and convert into monthly data.
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

# use flag to process Max and Min data in a single code. Mean will be avg of max and Min.
flag = c("MaxT","MeanT","MinT")[as.numeric(readline(prompt="Enter 1:Max | 2:Mean | 3:Min : "))]

Len = as.numeric(gsub("-","",seq(ymd(19510101),ymd(20131231),by = "days")))
tempAllShp <- matrix(NA, nrow = length(Len), ncol = (length(gaugeName)+1)) #One for Date
colnames(tempAllShp) <- c("Date",gaugeName)

for(shp in seq_along(gaugeName)){  
  tempData <- read.csv(paste0("./Temperature/",flag,"/IMD_Temper_",flag,"_daily_",gaugeName[shp],".csv"),header = TRUE)
  tempAllShp[,1] <- Len
  tempAllShp[,shp+1] <- tempData$Temperature
  rm(tempData)
  print(shp)
}

write.csv(tempAllShp,file = paste0("tempAllShp_",flag,".csv"),row.names = FALSE)

# get the monthly data based on month.
Month = month(ymd(tempAllShp[,1]))
Year  = year(ymd(tempAllShp[,1]))

tempAllShpMonth <- matrix(NA,nrow = (length(unique(Month)) *length(unique(Year))),(length(gaugeName)+2))# 2 extra for MM +YYYY
colnames(tempAllShpMonth) <- c("Month","Year",gaugeName)

for(shp in seq_along(gaugeName)){
  df = data.frame(Temper = tempAllShp[,(shp+1)],
                  Month  = Month,
                  Year   = Year)
  Temp = aggregate(Temper ~ Month + Year ,df,mean)
  tempAllShpMonth[,1] <- Temp$Month
  tempAllShpMonth[,2] <- Temp$Year
  tempAllShpMonth[,(shp+2)] <- Temp$Temper
  rm(df,Temp)
}

write.csv(tempAllShpMonth,file = paste0("tempAllShpMonth_",flag,".csv"),row.names = FALSE)
