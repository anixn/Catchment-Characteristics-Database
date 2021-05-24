## Title   :: Shiny server for geospatial visulization and processing 
#  Author  :: Ankit Deshmukh
#  DOC     :: 2020-04-24 09:43:35
#  DOLE    :: 2020-04-24
#  Remarks :: 
## ClearUp and dir ####################################################
#setwd("~/Catchment-Characteristics-Database/Visulization/Database-Visulization")
## Load required libraries ############################################
if(!require(shiny)){install.packages("shiny");library(shiny)}
if(!require(viridis)){install.packages("viridis");library(viridis)}
if(!require(raster)){install.packages("raster");library(raster)}
if(!require(GISTools)){install.packages("GISTools");library(GISTools)}

## Main code: Define server logic required to draw a plots #####################
shinyServer(function(input,output) {
  load("AppData.RData")
  inShp1 <- reactive(India)
  inShp2 <- reactive(shpFileBind)
  
  val2Col<- function(x,n,alpha){
    colVec <- plasma(n, alpha = alpha)
    Cut <- as.numeric(cut(x,n))
    return(colVec[Cut])
  }
  
  output$Myplot <- renderPlot({
    par(mar=rep(0,4))
    plot(inShp1(),col = "white", border = "gray30", lwd = 1);
    box(col = "#404040",lwd = 2);
    indData <- which(colnames(Data) == input$char);
    plot(inShp2(), 
         col = val2Col(as.matrix(Data[,indData]),10,1)[Index], 
         border = "gray90", lwd = 0.8, add = T)
    rng <- par("usr");
    mtext("")
    north.arrow(xb=rng[1]+27.1,yb=rng[3]+29.2,len=0.5,lab="North",cex=1.2,tcol = 'gray60')
  }, height = 600, width =600)
  
  output$selected_var <- renderText({ 
    IndexData$Description[which(IndexData$VariableName == input$char)]
  })
  
})
