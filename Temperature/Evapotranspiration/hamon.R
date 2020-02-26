## Title   :: Hamon fuction to compute ET
#  Author  :: Ankit Deshmukh
#  DOC     :: 2019-07-08 17:44:43
#  DOLE    :: 2019-07-08
#  Remarks :: 
#hamon_new: function to calculate the Potential evapotranspiration using the Hamon equation
#latitude: numeric with latitute data
#date: a structure array with fields: Year, Month, Day ranging from the beginning date all the way to the end dates for the analysis

## ClearUp and dir ####################################################
## Load required libraries ############################################
if(!require(tidyverse)){install.packages("tidyverse");library(tidyverse)}
source("./Temperature/Evapotranspiration/solar_rad.R")
source("./Temperature/Evapotranspiration/is.leapyear.R")
## Main code ##########################################################
hamon <- function(tav,latitude,Date){
  numdays = length(tav)
  PET <- rep(0,numdays)
  for(day in 1: numdays){
   J = Date$JDay[day]
   e_a = 0.611*exp(17.3*tav[day]/(tav[day]+237.3))
   
   if(is.leapyear(Date$Year[day])){
     Gamma = 2*pi*(J-1)/366
   }else{
     Gamma = 2*pi*(J-1)/365
   }
   
   delta = (0.006918-0.399912*cos(Gamma)+0.070257*sin(Gamma)-0.006758*cos(2*Gamma)+0.000907*sin(2*Gamma)-0.002697*cos(3*Gamma)+0.00148*sin(3*Gamma));
   #delta should be in radians so no multiplication with 180/pi
   #from Page 602 in Dingman: Physical Hydrology
   omega      =   2*pi/24; #angluar velocity of Earth's rotation
   
   #from Page 603 in Dingman: Physical Hydrology
   Dy         =   2*acos(-tan(delta)*tan(latitude*pi/180))/omega;
   
   #from Page 310 in Dingman: Physical Hydrology
   if(tav[day] == -9999){
     PET[day] = -9999
   }else{
       if(tav[day] > 0){
         PET[day] = 29.8*Dy*(e_a/(tav[day]+237.2))
       }else{
         PET[day] = 0
       }
     } 
    rm(J,e_a,Gamma,delta,omega,Dy)
  }
  return(PET)
}