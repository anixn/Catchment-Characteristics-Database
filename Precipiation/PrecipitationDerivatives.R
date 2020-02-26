## Title   :: Precipitation derivatives
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-02 12:25:37
#  DOLE    :: 2019-07-02
#  Remarks :: 
## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(lubridate)){install.packages("lubridate");library(lubridate)}

## Main code ##########################################################
#load the precipitation dataset
precipDaily   <- read.csv("./Precipiation/precipAllShp.csv",header = T)
gaugeCount    <- dim(precipDaily)[2]-1

Month = month(ymd(precipDaily[,1]))
Year  = year(ymd(precipDaily[,1]))

## 1. Mean annual precip (mm) for the watershed.
# computing mean of 63 year of daily precipitation data for all 567 catchments
PPTAVG_BASIN = colMeans(precipDaily[,2:dim(precipDaily)[2]]) # Col:1 == Date coloumn. 

## 2. Watershed average of maximum monthly precipitation (mm).
## 3. Watershed average of minimum monthly precipitation (mm).
# idenfity maximum values of each month and average it 

PPTMAX_BASIN <- PPTMIN_BASIN <- rep(NA,gaugeCount)
for (cat in 1:gaugeCount) {
  df = data.frame(Precip = precipDaily[,cat+1],
                  Month  = Month,
                  Year   = Year)
  PPTMAX_BASIN[cat] = mean(aggregate(Precip ~ Month+Year,df,max)$Precip)
  PPTMIN_BASIN[cat] = mean(aggregate(Precip ~ Month+Year,df,min)$Precip)
  print(cat)
}
#plot(1:length(maxMonthlyPrecip),maxMonthlyPrecip,"l",lwd = 1,col = "red")
#lines(1:length(minMonthlyPrecip),minMonthlyPrecip,"l",lwd = 1,col = "#33eeff66")

## 4. Watershed average of annual number of days (days) of measurable precipitation.
WD_BASIN <- rep(NA,gaugeCount)
for(cat in 1:gaugeCount){
  precipDayIndex <- precipDaily[,cat+1] > 0
  mesurePrecip   <- precipDaily[,cat+1][precipDayIndex]
  mesureYear     <- Year[precipDayIndex]
  df <- data.frame(Precip = mesurePrecip,
                   Year   = mesureYear)
  WD_BASIN[cat] <- mean(aggregate(Precip ~ Year,df,function(x){length(x)})$Precip)
}

# 5. Watershed average of monthly maximum number of days (days) of measurable precipitation.
# 6. Watershed average of monthly minimum number of days (days) of measurable precipitation.
WDMAX_BASIN <- WDMIN_BASIN <- rep(NA,gaugeCount)
for(cat in 1:gaugeCount){
  precipDayIndex <- precipDaily[,cat+1] > 0
  mesurePrecip   <- precipDaily[,cat+1][precipDayIndex]
  mesureMonth    <- Month[precipDayIndex]
  mesureYear     <- Year[precipDayIndex]
  df <- data.frame(Precip = mesurePrecip,
                   Month  = mesureMonth,
                   Year   = mesureYear)
  df <- aggregate(Precip ~ Year+Month,df,function(x){length(x)})
  
  WDMAX_BASIN[cat] <- mean(aggregate(Precip ~ Month,df,max)$Precip)
  WDMIN_BASIN[cat] <- mean(aggregate(Precip ~ Month,df,min)$Precip)
}
# 7. Precipitation seasonality index (Walsh and Lawler (1981)). Index of how much annual precipitation falls seasonally (high values) or spread out over the year (low values).  Based on monthly precip values from 30 year (1971-2000) PRISM.  Range is 0 (precip spread out exactly evenly in each month) to 1 (all precip falls in a single month).
PRECIP_SEAS_IND <- PRECIP_SEAS_IND_CLS <- rep(NA,gaugeCount)
for(cat in 1:gaugeCount){
  df <- data.frame(Precip = precipDaily[,cat+1],
                   Month  = Month,
                   Year   = Year)
  catPrecipMonthly <- aggregate(Precip ~ Month+Year,df,sum)
  
  yrLn <- length(unique(catPrecipMonthly$Year))
  SI <- rep(NA,yrLn)
  k = 0
  for(ii in 1:yrLn){
    monthPrecipSI <- catPrecipMonthly$Precip[(k+1):(k+12)]
    SI[ii] <- sum(abs((monthPrecipSI-mean(monthPrecipSI,na.rm = TRUE))/(mean(monthPrecipSI,na.rm = TRUE)*12)),na.rm = TRUE)
    k= k+12
  }
  PRECIP_SEAS_IND[cat] <- mean(SI)
  print(cat)
}
# ----------------------------------------------------------------|
# Seasonality Index classes (when using mean monthly data)        |
# ----------------------------------------------------------------|
# Class | Class definition                          | Ranges      |
# ----------------------------------------------------------------|
#     1 | Very equable                              | <= 0.19     |
#     2 | Equable but with a definite wetter season | 0.20 - 0.39 |
#     3 | Rather seasonal with a short drier season | 0.40 - 0.59 |
#     4 | Seasonal                                  | 0.60 - 0.79 |
#     5 | Markedly seasonal with a long drier season| 0.80 - 0.99 |
#     6 | Most rain in 3 months or less             | 1.00 - 1.19 |
#     7 | Extreme, almost all rain in 1 - 2 months  | >= 1.20     |
# ----------------------------------------------------------------|

PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND <= 0.19] <- 1
PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND > 0.19 & PRECIP_SEAS_IND <= 0.39] <- 2
PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND > 0.39 & PRECIP_SEAS_IND <= 0.59] <- 3
PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND > 0.59 & PRECIP_SEAS_IND <= 0.79] <- 4
PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND > 0.79 & PRECIP_SEAS_IND <= 0.99] <- 5
PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND > 0.99 & PRECIP_SEAS_IND <= 1.19] <- 6
PRECIP_SEAS_IND_CLS[PRECIP_SEAS_IND > 1.19] <- 7

# 8. Mean January precip (mm) for the watershed.
# 9. Mean February precip (mm) for the watershed.
# 10. Mean March precip (mm) for the watershed.
# 11. Mean April precip (mm) for the watershed.
# 12. Mean May precip (mm) for the watershed.
# 13. Mean June precip (mm) for the watershed.
# 14. Mean July precip (mm) for the watershed.
# 16. Mean August precip (mm) for the watershed.
# 17. Mean September precip (mm) for the watershed.
# 18. Mean October precip (mm) for the watershed.
# 19. Mean November precip (mm) for the watershed.
# 20. Mean December precip (mm) for the watershed.
## 4. Watershed average of annual number of days (days) of measurable precipitation.
meanMonthlyPrecip <- matrix(NA, nrow =  gaugeCount, ncol = length(month.name))
colnames(meanMonthlyPrecip) <- month.name
for(cat in 1:gaugeCount){
  df <- data.frame(Precip = precipDaily[,cat+1],
                   Month   = Month)
  meanMonthlyPrecip[cat,] <- aggregate(Precip ~ Month,df,mean)$Precip
}

## Exporting to csv
PrecipExp <- data.frame(PPTAVG_BASIN        = PPTAVG_BASIN,
                        PPTMAX_BASIN        = PPTMAX_BASIN,
                        PPTMIN_BASIN        = PPTMIN_BASIN,
                        WD_BASIN            = WD_BASIN,
                        WDMAX_BASIN         = WDMAX_BASIN,
                        WDMIN_BASIN         = WDMIN_BASIN,
                        PRECIP_SEAS_IND     = PRECIP_SEAS_IND,
                        PRECIP_SEAS_IND_CLS = PRECIP_SEAS_IND_CLS,
                        JAN_PPT7100_CM      = meanMonthlyPrecip[,1],
                        FEB_PPT7100_CM      = meanMonthlyPrecip[,2],
                        MAR_PPT7100_CM      = meanMonthlyPrecip[,3],
                        APR_PPT7100_CM      = meanMonthlyPrecip[,4],
                        MAY_PPT7100_CM      = meanMonthlyPrecip[,5],
                        JUN_PPT7100_CM      = meanMonthlyPrecip[,6],
                        JUL_PPT7100_CM      = meanMonthlyPrecip[,7],
                        AUG_PPT7100_CM      = meanMonthlyPrecip[,8],
                        SEP_PPT7100_CM      = meanMonthlyPrecip[,9],
                        OCT_PPT7100_CM      = meanMonthlyPrecip[,10],
                        NOV_PPT7100_CM      = meanMonthlyPrecip[,11],
                        DEC_PPT7100_CM      = meanMonthlyPrecip[,12])

write.csv(PrecipExp,file = "./Precipiation/Climate.csv",row.names = FALSE)




