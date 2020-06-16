############################################################################################################################
#
#COPERNICUS GLOBAL LAND SERVICE (CGLS) DATA DOWNLOAD AND READ
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data in R.
#See: https://land.copernicus.eu/global/
#
#These functions rely on the data provided in the data manifest of the Copernicus service.
#These functinos allow to download the data without ordering products first,
#but you need to register at https://land.copernicus.eu/global/ and create a username and password.
#
#Set your path, username, password, timeframe, product, resolution and if more than 1 version exists, version number. New products are created regularly.
#For the most recent product availabilities at the Copernicus data manifest check: https://land.copernicus.vgt.vito.be/manifest/
#
#Be aware that Copernicus nc files have lat/long belonging to the centre of the pixel, and R uses upper/left corner:  nc_open.CGLS.data opens the orginal data without adjusting
#coordinates, while ncvar_get_CGSL.data and stack.CGLS.data open the data and adjust the coordinates.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Author: Willemijn Vroege, ETH Zurich.
#E-mail: wvroege@ethz.ch
#Acknowlegdments: Many thanks to Tim Jacobs, VITO, Copernicus Global Help Desk and Xavier Rotllan Puig, Aster Projects for constructive feedback.
#
#
#First version: 28.10.2019
#Last update  : 12.06.2020
#
###########################################################################################################################

if(require(RCurl) == FALSE){install.packages("RCurl", repos = "https://cloud.r-project.org"); library(RCurl)} else {library(RCurl)}
if(require(ncdf4) == FALSE){install.packages("ncdf4", repos = "https://cloud.r-project.org"); library(ncdf4)} else {library(ncdf4)}
if(require(raster) == FALSE){install.packages("raster", repos = "https://cloud.r-project.org"); library(raster)} else {library(raster)}

#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest

#PATH       : TARGET DIRECTORY, for example: D:/land.copernicus
#USERNAME   : USERNAME
#PASSWORD   : PASSWORD
#TIMEFRAME  : TIMEFRAME OF INTEREST, for example June 2019
#PRODUCT    : PRODUCT VARIABLE; CHOSE FROM fapar, fcover, lai, ndvi, ssm, swi, lst...
#RESOLUTION : RESOLTION; CHOSE FROM  1km, 300m or 100m
#VERSION    : VERSION; CHOSE FROM "v1", "v2", "v3"...


download.CGLS.data <- function(path, username, password, timeframe, product, resolution, version){

  if(resolution == "300m"){
    resolution1 <- "333m"
    product <- paste0(product, "300")
  }else if(resolution == "1km"){
    resolution1 <- resolution
  }

  collection <- paste(product, version, resolution1, sep="_")

  product.link<- paste0("@land.copernicus.vgt.vito.be/manifest/", collection, "/manifest_cgls_", collection, "_latest.txt" )

  url <- paste0("https://", paste(username, password, sep=":"), product.link)

  file.url <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE, crlf = TRUE)
  file.url <- unlist(strsplit(file.url, "\n"))
  file.url <- paste0("https://", paste(username, password, sep=":"), "@", sub(".*//", "",file.url))
  if(grepl("does not exist", file.url[10])) stop("This product is not available or the product name is misspecified")

  setwd(path)
  if(!dir.exists(collection)) dir.create(collection)
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

nc_open.CGLS.data <- function(path, date, product, resolution, version){
  if(resolution == "300m"){
    resolution1 <- "333m"
    product <- paste0(product, "300")
  }else if(resolution == "1km"){
    resolution1 <- resolution
  }
  collection <- paste(product, version, resolution1, sep="_")
  setwd(path)
  all.filenames.product  <- list.files(pattern=(collection), recursive = TRUE)
  specific.filename<-grep(gsub("-","",date), all.filenames.product, value = T)
  nc  <- nc_open(specific.filename)
}

ncvar_get_CGSL.data <- function(path, date, product, resolution, version, variable){
  if(resolution == "300m"){
    resolution1 <- "333m"
    product <- paste0(product, "300")
  }else if(resolution == "1km"){
    resolution1 <- resolution
  }
  collection <- paste(product, version, resolution1, sep="_")
  setwd(path)
  all.filenames.product  <- list.files(pattern=(collection), recursive = TRUE)
  specific.filename<-grep(gsub("-","",date), all.filenames.product, value = T)
  nc  <- nc_open(specific.filename)
  lon <- ncvar_get(nc, "lon")
  lat <- ncvar_get(nc, "lat")
  time <- ncvar_get(nc, "time")

  #Copernicus nc files have lat/long belonging to the centre of the pixel, and R uses upper/left corner --> adjust coordinates!
  if(resolution == "300m"){
    lon <- lon - (1/336)/2
    lat <- lat + (1/336)/2
  }
  if(resolution == "1km"){
    lon <- lon - (1/112)/2
    lat <- lat + (1/112)/2
  }
  nc_data <- ncvar_get(nc, variable)
}

stack.CGLS.data <- function(path, timeframe, product, resolution, version, variable){
  if(resolution == "300m"){
    resolution1 <- "333m"
    product <- paste0(product, "300")
  }else if(resolution == "1km"){
    resolution1 <- resolution
  }
  collection <- paste(product, version, resolution1, sep="_")
  setwd(path)
  all.filenames.product  <- list.files(pattern=(collection), recursive = TRUE)
  datepattern   <- gsub("-", "", timeframe)
  datepattern.in.timeframe <- names(unlist(sapply(datepattern, grep, all.filenames.product)))
  filenames.in.timeframe <- paste(path, all.filenames.product[unlist(sapply(datepattern, grep, all.filenames.product))], sep="/")
  options(warn=-1)
  data <- stack(filenames.in.timeframe, varname=variable, quick=T) #this produces a warning because the projection gets off as R reads the coordinates as left upper corner. This is corrected below.
  options(warn=0)
  extent(data) <- extent(c(-180, 180, -60, 80))
  proj4string(data) <- CRS("+init=epsg:4326")
  data<-data
}
