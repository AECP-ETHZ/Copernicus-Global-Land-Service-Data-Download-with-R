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
#Set your path, username, password, timeframe, variable, resolution and if more than 1 version exists, version number. New products are created regularly.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Author: Willemijn Vroege, ETH Zürich with support of Tim Jacobs, VITO, Copernicus Global Help Desk.
#E-mail: wvroege@ethz.ch
#
#
#First version: 28.10.2019
#Last update  : 08.06.2020
#
###########################################################################################################################


if(require(RCurl) == FALSE){install.packages("RCurl", repos = "https://cloud.r-project.org"); library(RCurl)} else {library(RCurl)}
if(require(ncdf4) == FALSE){install.packages("ncdf4", repos = "https://cloud.r-project.org"); library(ncdf4)} else {library(ncdf4)}
if(require(raster) == FALSE){install.packages("raster", repos = "https://cloud.r-project.org"); library(raster)} else {library(raster)}
#rm(list=ls())

#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest 

#PATH       : TARGET DIRECTORY, for example: D:/land.copernicus
#USERNAME   : USERNAME
#PASSWORD   : PASSWORD
#TIMEFRAME  : TIMEFRAME OF INTEREST, for example June 2019
#VARIABLE   : PRODUCT VARIABLE; CHOSE FROM fapar, fcover, lai, ndvi, ssm, swi, lst...
#RESOLUTION : RESOLTION; CHOSE FROM  1km, 300m or 100m
#VERSION    : VERSION; CHOSE FROM "v1", "v2", "v3"... 


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






read.copernicus.data <- function(path, timeframe, variable, resolution, version){
  collection <- paste(variable, version, resolution, sep="_")
  setwd(PATH)
  all.filenames.product  <- list.files(pattern=(collection), recursive = T)
  datepattern   <- gsub("-", "", timeframe)
  datepattern.in.timeframe <- names(unlist(sapply(datepattern, grep, all.filenames.product)))
  filenames.in.timeframe <- paste(PATH, all.filenames.product[unlist(sapply(datepattern, grep, all.filenames.product))], sep="/")
  data <- stack(filenames.in.timeframe)  
}
