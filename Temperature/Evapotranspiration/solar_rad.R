## Title   :: Solar radiation computation with latitude and Jday
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-08 16:42:32
#  DOLE    :: 2019-07-08
#  Remarks :: 

## ClearUp and dir ####################################################
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
source("./Temperature/Evapotranspiration/is.leapyear.R")
## Main code ##########################################################
solar_rad <- function(latitude,Date){
  numdays <-  length(Date$JDay)
  J      <- rep(0,numdays)
  delta  <- rep(0,numdays)
  dr     <- rep(0,numdays)
  omegas <- rep(0,numdays)
  So     <- rep(0,numdays)
  
  for (day in 1:numdays){
    J[day]      = Date$JDay[day];
    lat         = latitude*pi/180;
    
    if(is.leapyear(Date$Year[day])){
      delta[day] = 0.4093 * sin((2*pi*J[day]/366) - 1.405)
      dr[day]    = 1+0.0333 * cos(2*pi*J[day]/366)
    }else{
      delta[day] = 0.4093 * sin((2*pi*J[day]/365) - 1.405)
      dr[day]    = 1+0.0333  *cos(2*pi*J[day]/365) 
    }
    omegas[day] = acos(-tan(lat)* tan(delta[day]))
    So[day]     = 15.392*dr[day]*((omegas[day]*sin(lat)*sin(delta[day]))+(cos(lat)*cos(delta[day])*sin(omegas[day])))
  }
  return(So)
}
