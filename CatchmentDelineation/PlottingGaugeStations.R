## Title   :: Plotting the Indian catchments with gauge points colored with area
#  Author  :: Ankit Deshmukh
#  DOC     :: 26 June 2019
#  DOLE    :: 26 June 2019
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101/CatchmentDelineation")
## Load required libraries #####################################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}

## Main code ##########################################################
gaugeData <- readxl::read_excel(path = "./CatchmentDelineation.xlsx", sheet = "PourPoint950")
Index = gaugeData$IndexForDB != 0
Area  = log10(gaugeData$CatAreaCalc_Km2[Index])

#Read whole India shapefiles
India <- readOGR("./India_SHP_plotting", "All_India")

d <- data.frame(lon=gaugeData$Long[Index], lat=gaugeData$Lat[Index])
coordinates(d) <- c("lon", "lat")
d@proj4string <- CRS(India@proj4string@projargs)

#Color based on area of watershed
Col = colorRampPalette(c("deepskyblue","gold1","firebrick1"), alpha = 0.70)
Col = Col(500)[as.numeric(cut(Area,breaks = 500))]  

#pdf(file = 'Figure01_StudyArea.pdf')
png(file = 'Map_India.png', width = 3200, height = 3200, res = 600)
plot(India, border = 'gray40', lwd = .75)
points(gaugeData$Lat[Index], gaugeData$Long[Index], 
       pch = 21, cex = 0.5, col = 'gray40', bg = Col, lwd = 0.250)

#points(d@coords[,2], d@coords[,1], pch= 21,col= 'gray20',lwd = 0.1, bg=Colx,cex = 0.5)

rng <- par("usr")
# insert north arrow
if(!require(GISTools)){install.packages("GISTools");library(GISTools)}
north.arrow(xb=88,yb=35,len=0.3,lab="N",cex=0.80)
detach('package:GISTools')

if(!require(maps)){install.packages("maps");library(maps)}
map.scale(x=83, y=33, ratio=FALSE, relwidth=0.2,sfcol = "red")  
box()
dev.off()

#Plotting the histogram
AreaDB = data.frame(Area = Area) # log10 transformed
ggplot(data = AreaDB, aes(x = Area))+
  geom_histogram(bins = 30,color="white", fill="gray20")+
  scale_x_continuous(name = "log10(Area)", 
                     breaks =  seq(floor(min(AreaDB$Area)),ceiling(max(AreaDB$Area)),by=1),
                     labels = 10^(1:6))+ theme_bw()

ggsave(filename = "HistAreaComp_log.pdf",width = 4, height = 3, units = "in")

## Later use inkscape to merge figures into one.