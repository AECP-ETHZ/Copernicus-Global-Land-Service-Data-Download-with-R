############################################################################################################################
#
#COPERNICUS DATA DOWNLOAD AND READ: EXAMPLE
#
#This is an example on how to run the functions found in 'land.Copernicus Data Download.R'
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data as rasterstack in R.
#See: https://land.copernicus.eu/global/
#
#These functions rely on the data provided in the data manifest of the Copernicus service.
#These functinos allow to download the data without ordering products first,
#but you need to register at https://land.copernicus.eu/global/ and create a username and password. 
#
#Set your path, username, password, timeframe, variable, resolution and if more than 1 version exists, version number. New products are created regularly.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Author: Willemijn Vroege, ETH Zürich with support of Tim Jacobs, VITO, Copernicus Global Help Desk
#E-mail: wvroege@ethz.ch
#
#
#First version: 28.10.2019
#Last update  : 08.06.2020
#
###########################################################################################################################


## Reading Functions ####
if(require(devtools) == FALSE){install.packages("devtools", repos = "https://cloud.r-project.org"); library(devtools)} else {library(devtools)}
source_url("https://github.com/xavi-rp/Copernicus-Global-Land-Service-Data-Download-with-R/blob/master/land.Copernicus%20Data%20Download.R?raw=TRUE")


## Downloading Data ####
#SET TARGET DIRECTORY USERNAME, PASSWORD, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a variable, resolution and version). 
#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest 

PATH       <- "" #INSERT TARGET DIRECTORY, for example: D:/land.copernicus
USERNAME   <- "" #INSERT USERNAME
PASSWORD   <- "" #INSERT PASSWORD
TIMEFRAME  <- seq(as.Date("2019-06-01"), as.Date("2019-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
VARIABLE   <- "ssm" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ssm, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",... 


download.copernicus.data(path=PATH, username=USERNAME, password=PASSWORD, timeframe=TIMEFRAME, variable=VARIABLE, resolution=RESOLUTION, version=VERSION)





## Reading Data ####
#SET TARGET DIRECTORY, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a variable, resolution and version). 

PATH       <- "D:/land.copernicus" #INSERT DIRECTORY, for example: D:/land.copernicus
TIMEFRAME  <- seq(as.Date("2019-06-01"), as.Date("2019-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
VARIABLE   <- "ssm" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ss, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",... 


data <- read.copernicus.data(path=PATH,timeframe=TIMEFRAME, variable=VARIABLE, resolution=RESOLUTION, version=VERSION)

#view first layer of the data
plot(data[[1]])
