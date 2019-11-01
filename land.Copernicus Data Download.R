############################################################################################################################
#
#COPERNICUS DATA DOWNLOAD AND READ
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data as rasterstack in R.
#See: https://land.copernicus.eu/global/
#
#These functions rely on the data provided in the data manifest of the Copernicus service.
#These functinos allow to download the data without ordering products first,
#but you need to register at https://land.copernicus.eu/global/ and create a username and password. 
#
#Set your path, username, password, timeframe, variable, resoltion and if more than 1 version exists, version number. New products are created regularly.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Auteur: Willemijn Vroege, ETH Zürich with support of Tim Jacobs, VITO, Copernicus Global Help Desk.
#E-mail: wvroege@ethz.ch
#
#
#First version: 28.10.2019
#Last update  : 01.11.2019
#
###########################################################################################################################

#install.packages("RCurl")
#install.packages("ncdf4")
#install.packages("raster")

library(RCurl)
library(ncdf4)
library(raster)
rm(list=ls())

#SET TARGET DIRECTORY USERNAME, PASSWORD, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a variable, resolution and version). 
#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest 

PATH       <- "D:/land.copernicus" #INSERT TARGET DIRECTORY, for example: D:/land.copernicus
USERNAME   <- "willemijnvroege" #INSERT USERNAME
PASSWORD   <- "SatImagesCop" #INSERT PASSWORD
TIMEFRAME  <- seq(as.Date("2019-06-01"), as.Date("2019-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
VARIABLE   <- "ssm" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ssm, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",... 


download.copernicus.data <- function(path, username, password, timeframe, variable, resolution, version){
  
  collection <- paste(variable, version, resolution, sep="_")
  
  product.link<- paste0("@land.copernicus.vgt.vito.be/manifest/", collection, "/manifest_cgls_", collection, "_latest.txt" )

  url <- paste0("https://", paste(username, password, sep=":"), product.link)
  if (length(url)==0) {print("This product is not available or the product name is misspecified")}

  file.url <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE, crlf = TRUE)
  file.url <- unlist(strsplit(file.url, "\n"))
  file.url <- paste0("https://", paste(username, password, sep=":"), "@", sub(".*//", "",file.url))

  setwd(path)
  dir.create(collection)
  setwd(paste(path, collection, sep="/"))
  
  for (i in 1:length(timeframe)){
    temp <- grep(gsub("-", "", timeframe[[i]]),file.url, fixed=T, value=T) #select a file for each day
    if (length(temp) > 0 ){ #if there is data for this day
      if (i>1){Sys.sleep(3)}
      download.file(temp, paste(collection, sub(".*/", "", temp), sep="_"), mode = 'wb')   #download function
      print(paste0(collection, "_", sub(".*/", "", temp), " is saved in ", getwd()))
    }
  }
}  

download.copernicus.data(path=PATH, username=USERNAME, password=PASSWORD, timeframe=TIMEFRAME, variable=VARIABLE, resolution=RESOLUTION, version=VERSION)


####Open the downloaded data in R### 
#SELECT THE DATA YOU WANT TO OPEN (data has to be downloaded first)

PATH       <- "D:/land.copernicus" #INSERT DIRECTORY, for example: D:/land.copernicus
TIMEFRAME  <- seq(as.Date("2019-06-01"), as.Date("2019-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
VARIABLE   <- "ssm" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ss, swi, lst, ...
RESOLUTION <- "1km" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",... 


read.copernicus.data <- function(path, timeframe, variable, resolution, version){
  collection <- paste(variable, version, resolution, sep="_")
  setwd(PATH)
  all.filenames.product  <- list.files(pattern=(collection), recursive = T)
  datepattern   <- gsub("-", "", timeframe)
  datepattern.in.timeframe <- names(unlist(sapply(datepattern, grep, all.filenames.product)))
  filenames.in.timeframe <- paste(PATH, all.filenames.product[unlist(sapply(datepattern, grep, all.filenames.product))], sep="/")
  data <- stack(filenames.in.timeframe)  
}

data <- read.copernicus.data(path=PATH,timeframe=TIMEFRAME, variable=VARIABLE, resolution=RESOLUTION, version=VERSION)

#view first layer of the data
plot(data[[1]])
