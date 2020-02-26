## Title   :: Socio-economic properties extraction
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-22 22:12:34
#  DOLE    :: 2019-07-22
#  Remarks :: 

## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(viridis)){install.packages("viridis");library(viridis)}
if(!require(ncdf4)){install.packages("ncdf4");library(ncdf4)}

## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index  <- which(xlData$IndexForDB == 1)
load("./CatchmentDelineation/AllShpFile567.RData")

pop  <- raster("./SocioEconomic/WorldPopulation/Population-density-2000.tif")
hfi  <- raster("./SocioEconomic/HumanFootprintIndex/The-Human-Footprint-Index.tif")
agri <- raster("./SocioEconomic/AgricultureSuitability/AgricultureSuitability.tif")
nCon <- raster("./SocioEconomic/FertilizerConsumption/Nitrogen_Consumption.tif")
pCon <- raster("./SocioEconomic/FertilizerConsumption/Phosphorus_Consumption.tif")
kCon <- raster("./SocioEconomic/FertilizerConsumption/Potassium_Consumption.tif")
gdp  <- "./SocioEconomic/GPP/GDP_PCPTA_PPP_1990_2015.nc" 
hdi  <- "./SocioEconomic/GPP/HDI_1990_2015.nc"

## Reading the NC file to get band information
NC <- nc_open(gdp); 
print(NC)
Years <- ncvar_get(NC,"time")
missing_value <- -9
nc_close(NC);rm(NC)

## Save multiband raster in the memory
gdp <- stack(gdp)
hdi <- stack(hdi)

## Get column name R:576 | C:(6+2*26)
cols <- c("POP","HFI","AGRI","NITRO","PHOSF","POTAS",paste0("GDP_",Years),paste0("HDI_",Years))
SocioEco_save <- matrix(NA, nrow = length(Index),ncol = length(cols))
colnames(SocioEco_save) <- cols

## Loop through all the catchments
for(cat in 1:length(Index)){ # [1:141] | [142:284] | [285:423] | [424:567]
  ## 1. Gridded population extraction
  pop@data@names <- "RasterLayer"
  temp <- raster::extract(x                = pop,
                          y                = AllShpFile[[cat]],
                          weights          = TRUE,
                          normalizeWeights = TRUE,
                          df               = TRUE)
  
  keepIndex <- !is.na(temp$RasterLayer)
  SocioEco_save[cat,1] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
  
  ## 2. Human Footprint Index extraction
  hfi@data@names <- "RasterLayer"
  temp <- raster::extract(x                = hfi,
                          y                = AllShpFile[[cat]],
                          weights          = TRUE,
                          normalizeWeights = TRUE,
                          df               = TRUE)
  
  keepIndex <- !is.na(temp$RasterLayer)
  SocioEco_save[cat,2] <- sum((temp$RasterLayer*temp$weight)[keepIndex])

  ## 3. Agriculture Suitability gridded data extraction
  agri@data@names <- "RasterLayer"
  temp <- raster::extract(x                = agri,
                          y                = AllShpFile[[cat]],
                          weights          = TRUE,
                          normalizeWeights = TRUE,
                          df               = TRUE)
  keepIndex <- !is.na(temp$RasterLayer)
  SocioEco_save[cat,3] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
  
  ## 4. Nitrogen Consumption gridded data extraction
  nCon@data@names <- "RasterLayer"
  temp <- raster::extract(x                = nCon,
                          y                = AllShpFile[[cat]],
                          weights          = TRUE,
                          normalizeWeights = TRUE,
                          df               = TRUE)
  keepIndex <- !is.na(temp$RasterLayer)
  SocioEco_save[cat,4] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
  
  ## 5. Phosphorus consumption gridded data extraction
  pCon@data@names <- "RasterLayer"
  temp <- raster::extract(x                = pCon,
                          y                = AllShpFile[[cat]],
                          weights          = TRUE,
                          normalizeWeights = TRUE,
                          df               = TRUE)
  keepIndex <- !is.na(temp$RasterLayer)
  SocioEco_save[cat,5] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
  
  ## 6. Potassium Consumption gridded data extraction
  kCon@data@names <- "RasterLayer"
  temp <- raster::extract(x                = kCon,
                          y                = AllShpFile[[cat]],
                          weights          = TRUE,
                          normalizeWeights = TRUE,
                          df               = TRUE)
  keepIndex <- !is.na(temp$RasterLayer)
  SocioEco_save[cat,6] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
  
  ## 7. Gridded gross domestic product extraction
  for(Band in seq_along(Years)){
    gdp_slice <- gdp[[Band]]
    gdp_slice@data@names <- "RasterLayer"
    temp <- raster::extract(x                = gdp_slice,
                            y                = AllShpFile[[cat]],
                            weights          = TRUE,
                            normalizeWeights = TRUE,
                            df               = TRUE)
    
    keepIndex <- temp$RasterLayer != missing_value
    SocioEco_save[cat,(6+Band)] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
  }

  ## 8. Human developement index extraction
  for(Band in seq_along(Years)){
    hdi_slice <- hdi[[Band]]
    hdi_slice@data@names <- "RasterLayer"
    temp <- raster::extract(x                = hdi_slice,
                            y                = AllShpFile[[cat]],
                            weights          = TRUE,
                            normalizeWeights = TRUE,
                            df               = TRUE)
    
    keepIndex <- temp$RasterLayer != missing_value
    SocioEco_save[cat,(6+length(Years)+Band)] <- sum((temp$RasterLayer*temp$weight)[keepIndex])
    cat(Band,"\ ")
  }
  cat("\n",cat,"\n")
}

write.csv(SocioEco_save,file = "./SocioEconomic/SocioEconomic.csv", row.names = FALSE)
