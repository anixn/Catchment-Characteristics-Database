<!-- An overview of file for the dataset -->
# Catchment-Characteristics-Database
## Catchment Characteristics Database development and publication

### Outline of the database building
* Various categories for data.
* Climate data is from IMD Pune
* Temperature data is from IMD Pune
* Most dataset is from freely available for academic use
* Dataset has averaged values for a catchment 
* Delineated our own catchments
* The dataset consists 567 catchments and more than 160 characteristics.
* India wide dataset is useful for the comparative hydrology in reginal studies

### Introduction 
A catchment is a basic hydrological unit for anyone who works with naturally flowing water. Each catchment is unique and has specific characteristics. We found there is no such dataset available by which we can characterize the catchment completely. For the United States, a catchment dataset Falcone [Falcone, 2011] provides in-depth knowledge of more than 6000 United States catchments. Falcone data used in numerous studies and proven to be very useful. We are unable to find such a database for India, will use in future research which required rich physio-climatic characteristics for India catchments. We try to keep dataset processing and collection steps as transparent as possible. Methods and algorithms are used to develop this dataset, are carefully presented in this document.

The dataset is called Physio-climatic characteristics for India. We present the dataset into the following sub-categories,(1) Climate, (2) Geology, (3) Hydrologic, (4) Land cover, (5) Land use, (6) Socioeconomic, and (7) Topographic. Each sub-category has several characteristics and the summary of each characteristic is shown in the Index sheet of the dataset. Index sheet has fields like Name, description, method of data preparation, data units, data source citation. We want to add as many characteristics we are able to find in the Falcone dataset. Our basic approach to get the data is to crop a raster with shape file and then take a weighted mean of the characteristics.
