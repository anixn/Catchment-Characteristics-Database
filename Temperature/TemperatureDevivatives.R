## Title   :: Temperature Derivatives 
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-05 13:22:41
#  DOLE    :: 2019-07-05
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(lubridate)){install.packages("lubridate");library(lubridate)}

## Main code ##########################################################
tempDailyMax <- read.csv("./Temperature/tempAllShp_MaxT.csv",header = TRUE)
tempDailyMean <- read.csv("./Temperature/tempAllShp_MeanT.csv",header = TRUE)
tempDailyMin <- read.csv("./Temperature/tempAllShp_MinT.csv",header = TRUE)

Month      <- month(ymd(tempDailyMean[,1]))
Year       <- year(ymd(tempDailyMean[,1]))
JDay       <- yday(ymd(tempDailyMean[,1]))

gaugeCount <- dim(tempDailyMean)[2]-1

# 1.Average annual air temperature for the watershed, degrees C.
T_AVG_BASIN <- colMeans(tempDailyMean[,2:dim(tempDailyMean)[2]])

# 2.Watershed average of maximum monthly air temperature (degrees C).
# 2.Standard deviation of maximum monthly air temperature (degrees C).
T_MAX_BASIN <- T_MAXSTD_BASIN <- rep(NA,gaugeCount)
for(cat in 1:gaugeCount){
  df <- data.frame(Temp  = tempDailyMean[,(cat+1)],
                   Month = Month,
                   Year  = Year)
  TempMon <- aggregate(Temp~Month+Year,df,max)$Temp
  
  T_MAX_BASIN[cat] <- mean(TempMon)
  T_MAXSTD_BASIN[cat] <- sd(TempMon)
  print(cat)
  rm(df)
}

# 3.Watershed average of minimum monthly air temperature (degrees C.
# 4.Standard deviation of minimum monthly air temperature (degrees C).
T_MIN_BASIN <- T_MINSTD_BASIN <- rep(NA,gaugeCount)
for(cat in 1:gaugeCount){
  df <- data.frame(Temp  = tempDailyMean[,(cat+1)],
                   Month = Month,
                   Year  = Year)
  TempMon <- aggregate(Temp~Month+Year,df,min)$Temp
  
  T_MIN_BASIN[cat] <- mean(TempMon)
  T_MINSTD_BASIN[cat] <- sd(TempMon)
  print(cat)
  rm(df)
}

# 5.Average January air temperature for the watershed, degrees C.
# 6.Average February air temperature for the watershed, degrees C.
# 7.Average March air temperature for the watershed, degrees C
# 8.Average April air temperature for the watershed, degrees C.
# 9.Average May air temperature for the watershed, degrees C.
# 10.Average June air temperature for the watershed, degrees C.
# 11.Average July air temperature for the watershed, degrees C.
# 12.Average August air temperature for the watershed, degrees C.
# 13.Average September air temperature for the watershed, degrees C.
# 14.Average October air temperature for the watershed, degrees C.
# 15.Average November air temperature for the watershed, degrees C.
# 16.Average December air temperature for the watershed, degrees C.
meanMonthlyTemp <- matrix(NA, nrow =  gaugeCount, ncol = length(month.name))
colnames(meanMonthlyTemp) <- month.name
for(cat in 1:gaugeCount){
  df <- data.frame(Temp = tempDailyMean[,cat+1],
                   Month   = Month)
  meanMonthlyTemp[cat,] <- aggregate(Temp ~ Month,df,mean)$Temp
}

# # Visulize the monthly temperature
# for(ii in 1:gaugeCount){
#   plot(meanMonthlyTemp[ii,],
#        type = "b",col= rgb(runif(ii),runif(ii),runif(ii)), 
#        lwd = 3,pch = 16,cex = 2)
#   Sys.sleep(0.5)
# }

# 17.Mean-annual potential evapotranspiration (PET), estimated using the Hamon (1961) equation. 
# 18.Mean-annual potential evapotranspiration (PET), estimated using the Hargreves (xxx) equation. 
gaugeData <- readxl::read_excel("./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Latitude  <- gaugeData$Lat[gaugeData$IndexForDB ==1]

source("./Temperature/Evapotranspiration/hargreaves.R")
source("./Temperature/Evapotranspiration/hamon.R")

DateStr<- data.frame(Year = Year,
                     Month = Month,
                     JDay = JDay)

PET_HAMON <- PET_HARTG <- rep(NA,gaugeCount)

for(cat in 1:length(Latitude)){
  PET_HAMON[cat] = mean(hamon(tempDailyMean[,(cat+1)],
            Latitude[cat],
            DateStr))
  
  PET_HARTG[cat] = mean(hargreaves(tempDailyMean[,(cat+1)],
             tempDailyMax[,(cat+1)],
             tempDailyMin[,(cat+1)],
             Latitude[cat],
             DateStr))
  print(cat)
}

TempExp <- data.frame(T_AVG_BASIN = T_AVG_BASIN,
                      T_MAX_BASIN = T_MAX_BASIN,
                      T_MAXSTD_BASIN = T_MAXSTD_BASIN,
                      T_MIN_BASIN = T_MIN_BASIN,
                      T_MINSTD_BASIN = T_MINSTD_BASIN,
                      JAN_TMP7100_DEGC = meanMonthlyTemp[,1],
                      FEB_TMP7100_DEGC = meanMonthlyTemp[,2],
                      MAR_TMP7100_DEGC = meanMonthlyTemp[,3],
                      APR_TMP7100_DEGC = meanMonthlyTemp[,4],
                      MAY_TMP7100_DEGC = meanMonthlyTemp[,5],
                      JUN_TMP7100_DEGC = meanMonthlyTemp[,6],
                      JUL_TMP7100_DEGC = meanMonthlyTemp[,7],
                      AUG_TMP7100_DEGC = meanMonthlyTemp[,8],
                      SEP_TMP7100_DEGC = meanMonthlyTemp[,9],
                      OCT_TMP7100_DEGC = meanMonthlyTemp[,10],
                      NOV_TMP7100_DEGC = meanMonthlyTemp[,11],
                      DEC_TMP7100_DEGC = meanMonthlyTemp[,12],
                      PET_HAMON = PET_HAMON,
                      PET_HARTG = PET_HARTG)

write.csv(TempExp, file = "./Temperature/Temperature.csv", row.names = FALSE)
