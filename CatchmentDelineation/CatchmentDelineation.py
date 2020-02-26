# -*- coding: utf-8 -*- ###############################################
"""
Created  Thu Jun 30 17:37:50 2016
Last edited Fri Sep 16 15:01:38 2016
@author: Ankit Deshmukh
"""
## Spatial analysis with DEM ########################################## 

import arcpy
arcpy.env.workspace = r"C:\TempWork"
arcpy.env.overwriteOutput = True

# input dem:
originalDEM = "IndiaDEM.tif"
arcpy.AddMessage("Elevation File: " + originalDEM+ "\n")

outFill = arcpy.sa.Fill(originalDEM)
outFill.save(r"D:\AnkitWork\20160603_rasterProc\DEM\shp\arcpyFiles\fill.tif")
arcpy.AddMessage("Fill DEM complete.\n")

#run flow direction tool and save raster
outFlowD = arcpy.sa.FlowDirection(outFill)
outFlowD.save('DEM_FlowD')
arcpy.AddMessage("Flow direction raster saved.\n")
outFlowD = r"D:\AnkitWork\20160603_rasterProc\DEM\shp\arcpyFiles\dem_flowd"

#run flow accumulation tool and save raster
outFlowA = arcpy.sa.FlowAccumulation(outFlowD)
outFlowA.save('DEM_FlowA')
arcpy.AddMessage("Flow accumulation raster saved.\n")

outFlowD = r"C:\TempWork\dem_flowd"
outFlowA = r"C:\TempWork\dem_flowa"

#Build a stream network and save raster
threshold = "2000" #(defalt = 2000)
arcpy.AddMessage("Stream network threshold:" + threshold+ "\n")
streamNetwork = arcpy.sa.Con(outFlowA,1,"","Value > "+threshold,)
streamNetwork.save("streamNetwork")

#use stream link tool and save raster
streamLink = arcpy.sa.StreamLink(streamNetwork,outFlowD)
streamLink.save("streamLink")

#use stream order tool and save raster
orderMethod = "STRAHLER" # specify the method ("SHREVE")
streamOrder = arcpy.sa.StreamOrder(streamNetwork,outFlowD,orderMethod)
streamOrder.save("streamOrder")

#Convert Stream to Feature
simplify = "SIMPLIFY"  # option 2 : simplify = "NO_SIMPLIFY"
arcpy.sa.StreamToFeature(streamNetwork,outFlowD,"streams.shp")

#Run Snap Pour Point tooland save raster
arcpy.AddMessage("Running Snap Pour Point tool\n")

## read CSV file for input coords.
import csv
ptFile = open(r"C:\TempWork\PointData.csv")
ptReader = csv.reader(ptFile)
ptData = list(ptReader) # reading all data in once
shapeArea = []

for row in ptData:
    ptList = [float(row[3]), float(row[4])] # pour point one at a time
    wsName = row[1]+"_"+row[2]+ ".shp"
    wsNameNil = row[1]+"_"+row[2]

# Creating a point shape file;
    pt = arcpy.Point()
    ptGeoms = []
    pt.Y = ptList[0]
    pt.X = ptList[1]
    ptGeoms.append(arcpy.PointGeometry(pt))

#Writing pourpoint shapefile
    pourPoints = arcpy.CopyFeatures_management(ptGeoms, arcpy.env.workspace+ "\point.shp")
    tolerance = 0.01
    arcpy.AddMessage("Tolerance is fixed at %r\n" %tolerance)

#set env settings so union of inputs are used
    arcpy.env.extent = "MAXOF"
    snapPts = arcpy.sa.SnapPourPoint(pourPoints,outFlowA,tolerance)
    snapPts.save("SnapPourPts")

#run watershed tool and save raster
    arcpy.AddMessage("Running Watershed tool...\n")
    watershed = arcpy.sa.Watershed(outFlowD,snapPts)
    watershed.save("Watershed")

# converting raster to polygon shapefile:
    arcpy.AddMessage("Converting raster to shapefile...\n")
    arcpy.RasterToPolygon_conversion("Watershed", "temp.shp") # wsName

# dessloving shpapefiles for only single polygon
    fc = "temp.shp" # Temporary shapefiles
    fc_dis= arcpy.Dissolve_management(fc, wsName)

# Calulating area of each shapefile and saving into a csv.
    arcpy.AddField_management(fc_dis,"area","Double")
    expression1 = "{0}".format("!SHAPE.area@SQUAREKILOMETERS!") #SQL expression!.
    arcpy.CalculateField_management(fc_dis, "area", expression1, "PYTHON")

# reading area from shapefiles and
    featureClass = wsName
    searchCol = ["area"]
    with arcpy.da.SearchCursor(featureClass,searchCol) as sc:
        for row in sc:
            k = float(row[0])
            print k
            shapeArea.append((wsNameNil,k))

# saving area with shapefile name
with open("Shapefile_area.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerows(shapeArea)
