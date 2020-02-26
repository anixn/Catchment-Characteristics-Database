## Title   :: Hargreaves and Samini PET equation 1985 formulation
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-08 18:25:29
#  DOLE    :: 2019-07-08
#  Remarks :: 

## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
source("./Temperature/Evapotranspiration/solar_rad.R")
## Main code ##########################################################
hargreaves <- function(Tav,Tmax,Tmin,latitude,daterun){
  # Estimating the solar radiation
  So       = solar_rad(latitude,daterun)
  num_runs = length(Tmax)
  PET      = rep(0,num_runs)
  
  # Based on Hargreeaves and Samani 1985
  for(timestep in 1:num_runs){
    if(Tav[timestep] == -9999 | Tmax[timestep] == -9999 | Tmin[timestep] ==  -9999){
      PET[timestep] = -9999
    } else{
      if((Tmax[timestep] - Tmin[timestep]) >=0 & Tmax[timestep] >= 0){
        PET[timestep]= 0.0023*So[timestep] * (Tmax[timestep]-Tmin[timestep])^0.5 * (Tav[timestep]+17.8)
      }else{
        PET[timestep] = 0
      }
    }
  }
  return(PET)
}