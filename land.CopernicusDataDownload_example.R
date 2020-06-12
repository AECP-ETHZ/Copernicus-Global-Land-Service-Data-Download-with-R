############################################################################################################################
#
#COPERNICUS GLOBAL LAND SERVICE (CGLS) DATA DOWNLOAD AND READ: EXAMPLE
#
#This is an example on how to run the functions found in 'land.Copernicus Data Download.R'
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data in R.
#See: https://land.copernicus.eu/global/
#
#These functions rely on the data provided in the data manifest of the Copernicus service.
#These functinos allow to download the data without ordering products first,
#but you need to register at https://land.copernicus.eu/global/ and create a username and password.
#
#Set your path, username, password, timeframe, product, resolution and if more than 1 version exists, version number. New products are created regularly.
#
#Be aware that Copernicus nc files have lat/long belonging to the centre of the pixel, and R uses upper/left corner:  nc_open.CGLS.data opens the orginal data without adjusting 
#coordinates, while ncvar_get_CGSL.data and stack.CGLS.data open the data and adjust the coordinates.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Author: Willemijn Vroege, ETH Zurich
#E-mail: wvroege@ethz.ch
#Acknowlegdments: Many thanks to Tim Jacobs, VITO, Copernicus Global Help Desk and Xavier Rotllan Puig, Aster Projects for constructive feedback.
#
#
#First version: 28.10.2019
#Last update  : 12.06.2020
#
###########################################################################################################################


## Reading Functions ####
if(require(devtools) == FALSE){install.packages("devtools", repos = "https://cloud.r-project.org"); library(devtools)} else {library(devtools)}
source_url("https://github.com/xavi-rp/Copernicus-Global-Land-Service-Data-Download-with-R/blob/master/land.Copernicus%20Data%20Download.R?raw=TRUE")


## Downloading Data ####
#SET TARGET DIRECTORY USERNAME, PASSWORD, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a product, resolution and version).
#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest

PATH       <- "" #INSERT TARGET DIRECTORY, for example: D:/land.copernicus
USERNAME   <- "" #INSERT USERNAME
PASSWORD   <- "" #INSERT PASSWORD
TIMEFRAME  <- seq(as.Date("2019-06-01"), as.Date("2019-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
PRODUCT    <- "fapar" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ssm, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",...

download.CGLS.data(path=PATH, username=USERNAME, password=PASSWORD, timeframe=TIMEFRAME, product=PRODUCT, resolution=RESOLUTION, version=VERSION)


## Reading Single netCDF File #### 
#This function is to open and explore a nc file. Be aware that Copernicus nc files have lat/long belonging to the centre of the pixel, 
#and R uses upper/left corner --> therefore adjust coordinates with ncvar_get_CGSL.data before using the netCDF file further!
#SET TARGET DIRECTORY, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a product, resolution and version).

PATH       <- "D:/land.copernicus" #INSERT DIRECTORY, for example: D:/land.copernicus
DATE       <- "2019-06-13" #INSERT DATE OF INTEREST, for example June 13 2019
PRODUCT    <- "fapar" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ss, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",...
VARIABLE   <- "FAPAR" #INSERT VARIABLE NAME, for example: FAPAR, FAPAR_ERR, FAPAR_QFLAG, LMK, NMOD, ssm, ssm_noise, ... . -->Go to the product site e.g. https://land.copernicus.eu/global/products/ssm) and check for available variable names under the tap 'techinal'

#just explore
nc      <- nc_open.CGLS.data   (path=PATH,date=DATE, product=PRODUCT, resolution=RESOLUTION, version=VERSION)

#get data of a specific variable (with adjusted coordinates)
nc_data <- ncvar_get_CGSL.data (path=PATH,date=DATE, product=PRODUCT, resolution=RESOLUTION, version=VERSION, variable=VARIABLE)


## Reading all Files within a Timeframe as Raster Stack####
#SET TARGET DIRECTORY, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a product, resolution and version).

PATH       <- "D:/land.copernicus" #INSERT DIRECTORY, for example: D:/land.copernicus
TIMEFRAME  <- seq(as.Date("2019-06-01"), as.Date("2019-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
PRODUCT    <- "fapar" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ss, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",...
VARIABLE   <- "FAPAR" #INSERT VARIABLE NAME, for example: FAPAR, FAPAR_ERR, FAPAR_QFLAG, LMK, NMOD, ssm, ssm_noise, ... . -->Go to the product site e.g. https://land.copernicus.eu/global/products/ssm) and check for available variable names under the tap 'techinal'

data   <- stack.CGLS.data(path=PATH,timeframe=TIMEFRAME, product=PRODUCT, resolution=RESOLUTION, version=VERSION, variable=VARIABLE)

