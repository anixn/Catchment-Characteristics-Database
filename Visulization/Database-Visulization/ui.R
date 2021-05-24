## Title   :: Shiny app for data visulization
#  Author  :: Ankit Deshmukh
#  DOC     :: 2020-04-20 17:18:08
#  DOLE    :: 2020-04-20
#  Remarks :: 
## ClearUp and dir ####################################################
graphics.off(); rm(list = ls()); cat("\014")
## Load required libraries ############################################
if(!require(shiny)){install.packages("shiny");library(shiny)}

## Main code ##########################################################

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    includeCSS("./www/style.css"),
    
    # to add  horizonalt ruler
    tags$head(tags$style(HTML("hr {border-top: 1.5px solid #303030;}"))), 
    
    titlePanel(h1("Visualization of geospatial dataset")),
    
    p("The dataset is called Physio-Climatic Characteristics Dataset for India. We present the dataset into the following sub-categories,(1) Climate, (2) Geology, (3) Hydrologic, (4) Land cover, (5) Land use, (6) Socioeconomic, and (7) Topographic. Each sub-category has several characteristics and the summary of each characteristic is shown in the Index sheet of the dataset. Index sheet has fields like Name, description, method of data preparation, data units, data source citation. We want to add as many characteristics we are able to find in the Falcone dataset. Our basic approach to get the data is to crop a raster with shape file and then take a weighted mean of the characteristics."),
    hr(),
    sidebarLayout(
      sidebarPanel(h4("Select characteristics"),
                   selectInput("char",
                               label = "Characteristic",
                               choices = c("POP" ,"PPTMIN_BASIN", "TOPWET"),
                               selected = "TOPWET"),
                   textOutput("selected_var")),
      
      mainPanel(h4("Map represents the characteristics"),
                plotOutput("Myplot"))
    )
  )
)
