## Title   :: Plotting the Indian catchments with gauge points colored with area
#  Author  :: Ankit Deshmukh
#  DOC     :: 26 June 2019
#  DOLE    :: 26 June 2019
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101/")
## Load required libraries #####################################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}
if(!require(raster)){install.packages("raster");library(raster)}

## Main code ##########################################################
gaugeData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx", sheet = "PourPoint950")
Index = which(gaugeData$IndexForDB != 0)
Cats  = length(Index)

Area  = log10(gaugeData$CatAreaCalc_Km2[Index])
Order = order(Area,decreasing = TRUE)

#Read whole India shapefiles
India <- readOGR("./CatchmentDelineation/India_SHP_plotting", "All_India",verbose = FALSE)

#Read all the shapefiles
load("./CatchmentDelineation/AllShpFile567.RData")

#Transform coordinates into spatial point for plotting
d <- data.frame(lon=gaugeData$Long[Index], lat=gaugeData$Lat[Index])
coordinates(d) <- c("lon", "lat")
d@proj4string <- CRS(India@proj4string@projargs) 

#Color based on area of watershed
colorRampAlpha <- function(..., n, alpha) {
  colors <- colorRampPalette(...)(n)
  paste(colors, sprintf("%x", ceiling(255*alpha)), sep="")
}
colVec <- c("deepskyblue","gold1","firebrick1")
Col <- colorRampAlpha(colVec, n=Cats, alpha=0.75)
Col = Col[as.numeric(cut(Area,breaks = Cats))]  

#pdf(file = 'Figure01_StudyArea.pdf')
png(file = 'CatPourPlot.png', width = 3600, height = 3600, res = 600)
plot(India, border = 'gray40', lwd = 0.75)

# plotting order, such that biggest catchment poltted first. 
for(cat in seq_along(Index)){#
  printIndex = Order[cat]
  plot(AllShpFile[[printIndex]],
       border =Col[printIndex],lwd = 0.5, add = T)
  
  points(gaugeData$Long[Index[printIndex]],
         gaugeData$Lat[Index[printIndex]], 
         pch = 21, cex = 0.5, col = 'gray40', 
         bg = Col[printIndex], lwd = 0.5)
  
  cat(cat,"\ ")
}

rng <- par("usr")
# insert north arrow
if(!require(GISTools)){install.packages("GISTools");library(GISTools)}
north.arrow(xb=88,yb=35.5,len=0.3,lab="N",cex=0.80)
detach('package:GISTools')

# insert scale
if(!require(maps)){install.packages("maps");library(maps)}
map.scale(x=83, y=33.5, ratio=FALSE, relwidth=0.2,sfcol = "red") 
detach('package:maps')
dev.off()

#Plotting the histogram
AreaDB = data.frame(Area = Area) # log10 transformed
nbins  = 30 # did some interation; but can be automated
Col    = colorRampPalette(colVec, alpha = 0.75)

ggplot(data = AreaDB, aes(x = Area))+
  geom_histogram(bins = nbins,color="white", fill= Col(nbins))+
  scale_x_continuous(name = "Area [scale::log10]", 
                     breaks = seq(floor(min(AreaDB$Area)),ceiling(max(AreaDB$Area)),by=1),
                     labels = 10^(1:6))+ylab('Catchment count[-]') +theme_bw()
ggsave(filename = "HistAreaComp_log.pdf",width = 4, height = 3.5, units = "in")

## Later use inkscape to merge figures into one.
