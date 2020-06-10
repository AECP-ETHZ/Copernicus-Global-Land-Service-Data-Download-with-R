# Copernicus-Global-Land-Service-Data-Download-with-R

##########################################################################################
#
#COPERNICUS DATA DOWNLOAD AND READ
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data in R.
#Additionally, there is an example (land.Copernicus Data Download_exampele.R) on how to run the functions found in 'land.Copernicus Data Download.R'
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
#Author: Willemijn Vroege, ETH Zurich
#E-mail: wvroege@ethz.ch
#Acknowlegdments: Many thanks to Tim Jacobs, VITO, Copernicus Global Help Desk and Xavier Rotllan Puig, Aster Projects for constructive feedback.
#
#
#First version: 28.10.2019
#Last update  : 10.08.2020
#
##########################################################################################


###This is the first time I am publishing on Github, I am happy about feedback.
