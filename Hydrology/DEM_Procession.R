## Title   :: Raster procession in R using GRASS GIS-7.6 with opneSTARS and rgrass7
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-11 11:34:02
#  DOLE    :: 2019-07-11
#  Remarks ::   
## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
setwd("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101")
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
if(!require(openSTARS)){install.packages("openSTARS");library(openSTARS)}
if(!require(rgdal)){install.packages("rgdal");library(rgdal)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(readxl)){install.packages("readxl");library(readxl)}
## Main code ##########################################################
xlData <- readxl::read_excel(path = "./CatchmentDelineation/CatchmentDelineation.xlsx",sheet = "PourPoint950")
Index = which(xlData$IndexForDB == 1)

# Load files Raster and Vector files ##################################
demFileName  <- c("D:/AnkitDeshmukh/GoogleDrive/Database01/Database101/CatchmentDelineation/IndiaDEM.tif")
indDEM <- raster(demFileName)
for(cat in Index){
  shpFile  <- readOGR(paste0(getwd(), "/CatchmentDelineation/Shapefiles950"),
                      paste0(xlData$`River Basins`[cat],"_",xlData$GaugeStations[cat]))
  
  temp = mask(crop(indDEM, shpFile),shpFile)
  if(temp@extent@xmin >= 66 & temp@extent@xmax < 72){CRS = "+init=epsg:32642"}
  if(temp@extent@xmin >= 72 & temp@extent@xmax < 78){CRS = "+init=epsg:32643"}
  if(temp@extent@xmin >= 78 & temp@extent@xmax < 84){CRS = "+init=epsg:32644"}
  if(temp@extent@xmin >= 84 & temp@extent@xmax < 90){CRS = "+init=epsg:32645"}
  if(temp@extent@xmin >= 90 & temp@extent@xmax < 96){CRS = "+init=epsg:32646"}
  if(temp@extent@xmin >= 96 & temp@extent@xmax < 102){CRS = "+init=epsg:32647"}
  
  temp = projectRaster(temp, crs = CRS)
  
  # writing the raster
  writeRaster(temp,
              paste0("./Hyderology/CropTiffData/",xlData$`River Basins`[cat],"_",xlData$GaugeStations[cat]),
              format = "GTiff",
              overwrite = TRUE)
  rm(temp)
  print(cat)
}

## Initiate GRASS session #############################################
if(.Platform$OS.type == "windows"){gisbase = "C:/Program Files/GRASS GIS 7.6"}
initGRASS(gisBase  = gisbase,
          home     = tempfile(), 
          override = TRUE)

##Grass-R functions ###################################################
r.list <- function(){
  print(execGRASS("g.list",
                  parameters = list(type = "rast"),
                  intern     = TRUE))
}
v.list <- function(){
  print(execGRASS("g.list",
                  parameters = list(type = "vect"),
                  intern     = TRUE))
}

rm_grass <- function(Name,R = "r"){
  Type = ifelse(R == "r","raster","vector")
  execGRASS("g.remove",flags = "f",
            parameters = list(name = Name,type = Type),intern = TRUE)
}
#######################################################################
tifName <- paste0(xlData$RiverBasins[Index],"_",xlData$GaugeStations[Index])
tifFile <- paste0(getwd(),"/Hyderology/DEM_Derivatives/",tifName,".tif")
shpFile <- paste0(getwd(),"/CatchmentDelineation/Shapefiles950/",tifName,".shp")

for(cat in 1:length(Index)){
  ## Setting up grass GIS envionment for mapset etc
  setup_grass_environment(dem = tifFile[cat])
  gmeta()
  
  ## load the raster layers
  execGRASS("r.in.gdal", 
            flags = c("overwrite", "quiet"),
            parameters = list(input = tifFile[cat],band = 1,output = tifName[cat]), 
            ignore.stderr = T)
  
  proj_dem <- execGRASS("g.proj", flags = c("j", "f"), parameters = list(georef = tifFile[cat]), 
                        intern = TRUE, ignore.stderr = TRUE)
  
  # ## load the vector layers
  # execGRASS("v.import",flags =c("overwrite"), input = shpFile[cat],
  #           output = tifName[cat], intern = TRUE)
  
  # execGRASS("r.mask", flags = c("overwrite"),
  #           parameters = list(vector = tifName[cat]),
  #           intern = TRUE)
  # 
  # execGRASS("g.region", flags = c("overwrite","p","d"),
  #           parameters = list(raster =  "MASK"),
  #           intern = TRUE)
  # 
  # execGRASS("r.clip",flags = c("overwrite"),
  #           parameters = list(input = tifName[cat],
  #                             output = paste0(tifName[cat],"_Crop")))
  
  execGRASS("r.hydrodem",
            flags = c("overwrite"), 
            parameters = list(input = tifName[cat],output = paste0(tifName[cat],"_Cond"))
  )
  
  execGRASS("r.watershed", 
            flags = c("overwrite", "quiet"),
            parameters = list(elevation = paste0(tifName[cat],"_Cond"),
                              accumulation = paste0(tifName[cat],"_Accum"))
  )
  
  # MiKatt: Solution: set d8cut to total number of cells in g.region.
  ncell <- execGRASS("g.region",flags="p",intern=T)
  ncell <- as.numeric(unlist(strsplit(ncell[grep("cells",ncell)],split=":"))[2])
  execGRASS("r.stream.extract",
            flags =  c("overwrite", "quiet"),
            parameters = list(elevation = paste0(tifName[cat],"_Cond"),
                              accumulation = paste0(tifName[cat],"_Accum"),
                              threshold = 700, # use ATRIC to get this value?
                              d8cut = ncell,
                              stream_length = 0,
                              stream_raster = paste0(tifName[cat],"_streams_r"),
                              direction = paste0(tifName[cat],"_dirs"))
  )
  
  execGRASS("r.stream.order",
            flags = c("overwrite", "quiet","z","m"),
            parameters = list(stream_rast = paste0(tifName[cat],"_streams_r"),  # input
                              direction = paste0(tifName[cat],"_dirs"),         # input
                              elevation = paste0(tifName[cat],"_Cond"),         # input
                              accumulation = paste0(tifName[cat],"_Accum"),     # input
                              stream_vect = paste0(tifName[cat],"_stream_v")),  # output
            ignore.stderr=T)
  
  # MiKatt: ESRI shape files must not have column names with more than 10 characters
  execGRASS("v.db.renamecolumn", flags = "quiet",
            parameters = list(map = paste0(tifName[cat],"_stream_v"),
                              column = "next_stream,next_str")
  )
  # to keep column "next_str" next to prev_str
  execGRASS("v.db.renamecolumn", flags = "quiet",
            parameters = list(map = paste0(tifName[cat],"_stream_v"),
                              column = "flow_accum, flow_accu")
  )
  
  # delete unused columns
  execGRASS("v.db.dropcolumn", flags = c("quiet"),
            parameters = list(
              map = paste0(tifName[cat],"_stream_v"),
              columns = c("hack","topo_dim","scheidegger","drwal_old","stright",
                          "sinosoid","source_elev","outlet_elev","elev_drop","out_drop","gradient"))
  )
  temp = readVECT(paste0(tifName[cat],"_stream_v"))
  writeOGR(temp,".",paste0("./Hyderology/StreamOrder/",tifName[cat],"_stream_v"),
           driver = "ESRI Shapefile", overwrite_layer = TRUE);rm(temp)
  
  # Slope, Aspect, slope-NE, slope-SE
  execGRASS("r.slope.aspect", flags = c("overwrite"),
            parameters = list(elevation = tifName[cat],
                              slope = paste0(tifName[cat],"_Slope"),
                              aspect = paste0(tifName[cat],"_Aspect"),
                              dx = paste0(tifName[cat],"_EW_slope"),
                              dy = paste0(tifName[cat],"_NS_slope"),
                              tcurvature = paste0(tifName[cat],"_tCurv"))
            
  )
  
  writeRaster(raster(readRAST(paste0(tifName[cat],"_Slope"))),
              filename = paste0("./Hyderology/DEM_Derivatives/",tifName[cat],"_Slope"),
              format = "GTiff", overwrite = TRUE)
  
  writeRaster(raster(readRAST(paste0(tifName[cat],"_Aspect"))),
              filename = paste0("./Hyderology/DEM_Derivatives/",tifName[cat],"_Aspect"),
              format = "GTiff", overwrite = TRUE)
  
  writeRaster(raster(readRAST(paste0(tifName[cat],"_EW_slope"))),
              filename = paste0("./Hyderology/DEM_Derivatives/",tifName[cat],"_EW_slope"),
              format = "GTiff", overwrite = TRUE)
  
  writeRaster(raster(readRAST(paste0(tifName[cat],"_NS_slope"))),
              filename = paste0("./Hyderology/DEM_Derivatives/",tifName[cat],"_NS_slope"),
              format = "GTiff", overwrite = TRUE)
  
  writeRaster(raster(readRAST(paste0(tifName[cat],"_tCurv"))),
              filename = paste0("./Hyderology/DEM_Derivatives/",tifName[cat],"_tCurv"),
              format = "GTiff", overwrite = TRUE)
  
  #Topographic wetness index computation
  execGRASS("g.region", flags = c("overwrite","p","d"),
            parameters = list(raster = tifName[cat]),
            intern = TRUE)
  
  execGRASS("r.topidx", flags = c("overwrite"),
            parameters = list(input = tifName[cat],
                              output = paste0(tifName[cat],"_TWI"))
  )
  
  writeRaster(raster(readRAST(paste0(tifName[cat],"_TWI"))),
              filename = paste0("./Hyderology/DEM_Derivatives/",tifName[cat],"_TWI"),
              format = "GTiff", overwrite = TRUE)
  
  rm_grass(r.list())
  rm_grass(v.list(),"v")
  cat("\014")
  print(paste0("Catchments completed: ",cat))
}


