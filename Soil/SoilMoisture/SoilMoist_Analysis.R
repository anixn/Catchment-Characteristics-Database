## Title   :: Precipitation and soil moisture data analysis
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-08-17 11:33:58
#  DOLE    :: 2019-08-17
#  Remarks :: 

## ClearUp and dir #############################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101/")
## Load required libraries #####################################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(reshape2)){install.packages("reshape2");library(reshape2)}

## Main code ###################################################################
prcipDaily <- read.csv(file = "./Precipiation/precipAllShp.csv")
soilMoistDaily <- read.csv(file = "./Soil/SoilMoisture/SoilMoisture.csv")
plot(prcipDaily[1:365,3]),soilMoistDaily[1:365,2])

n = 100
TSData <- data.frame(precip = scale(prcipDaily[1:365,n+1]),
                     soilMoist = scale(soilMoistDaily[1:365,n]))
TSData <- melt(TSData)

TSData$variable<-  as.factor(TSData$variable)

TSData$X <- rep(1:365,2)

ggplot(data = TSData, aes(x =X, y = value, colour = variable)) + geom_line(size = 1) +theme_bw()
