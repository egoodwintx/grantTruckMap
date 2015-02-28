##----------------------------------------------------------------
## Title: scriHgacGrantTruckMap.r
## Author: Ed Goodwin
## Date: 02.13.2015
## Description:
##  plot grant trucks in r
##----------------------------------------------------------------


## Note: ggplot2's fortify() function requires gpclibPermit() set to TRUE
## since gpclib is no longer maintained you need to install package rgeos
## prior to installing ggplot2 and rgdal.
## If that is not the case, install rgeos and reinstall ggplot2 and rgdal

# scriHgacGrantTruckMap.r BEGIN CODE
library(ggplot2)
library(ggmap)
library(rgdal)
library(maptools)
library(dplyr)
library(foreign)

setwd("/Users/egoodwin/Documents/active/code/R/shapefiles/county/")
# grant counties

## read in the shapefile...use names(texas) to get a list of available regions to read in
## you can also use str(texas@data)
texas = readOGR(dsn=".", layer="tl_2009_48_county")
texas = fortify(texas, region="NAME")

## get all county names
counties = unique(texas$id)
grantcounties = c("Brazoria", "Chambers", "Fort Bend", "Galveston", "Harris", "Liberty", "Montgomery", "Waller")

fillcounties = data.frame(id=counties,
                          fillval=0)

## set fillval to 1 to indicate counties we want to color
fillcounties[fillcounties$id %in% grantcounties, ]$fillval = 1

plotData = left_join(texas, fillcounties)

## read in vehicle position data
vehpos = read.csv("../../scriHgacGrantTruckMap/data/veh_pos.csv", header=T, skip=9)
names(vehpos) = c("Time", "Location", "Ignition.Status", "Latitude", "Longitude", "Speed", "Direction", "Trip.Status", "Odometer")

## create Unit plot
ppoints = c(geom_point(data=vehpos, aes(x=Longitude, y=Latitude), colour="red", size=2, alpha=0.2))


p = ggplot() +
  geom_polygon(data=plotData, aes(x=long, y=lat, group=group, fill=fillval), color="black", size=0.25) +
  ppoints + quiet() +
  ggtitle("HGAC Grant Operating Area")
p

#
# # print out Texas counties
# if(require(maps)) {
#   tx = map_data("county", "texas")
#   qplot(long, lat, data=tx, geom="polygon", group=group, colour=I("black"), fill=I("white"))
# }