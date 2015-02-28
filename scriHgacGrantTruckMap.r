##----------------------------------------------------------------
## Title: scriHgacGrantTruckMap.r
## Author: Ed Goodwin
## Date: 02.13.2015
## Description: 
##  plot grant trucks in r
##----------------------------------------------------------------

# scriHgacGrantTruckMap.r BEGIN CODE
library(ggplot2)
library(gpclib)
library(gdata)
library(maptools)
library(plyr)
library(rgdal)
library(foreign)

setwd("/Users/egoodwin/Documents/active/code/R/scriHgacGrantTruckMap/")

## read in vehicle position data
# vehpos = read.csv("data/veh_pos.csv", header=T, skip=9)
# NAMEs(vehpos) = c("Time", "Location", "Ignition.Status", "Latitude", "Longitude", "Speed", "Direction", "Trip.Status", "Odometer")

# read DBF file
txdbf.df = read.dbf("../shapefiles/county/tl_2009_48_county.dbf")

# read in county ids and NAMEs, set fill to 0
county.df = data.frame(CNTYIDFP=txdbf.df$CNTYIDFP, NAME=txdbf.df$NAME, FILL=0) 

# what counties do we want to color?
# grantcounties = c("Brazoria", "Chambers", "Fort Bend", "Galveston", "Harris", "Liberty", "Montgomery", "Waller")
county.df[county.df$NAME == "Brazoria",]$FILL = 1
county.df[county.df$NAME == "Chambers",]$FILL = 1
county.df[county.df$NAME == "Fort Bend",]$FILL = 1
county.df[county.df$NAME == "Galveston",]$FILL = 1
county.df[county.df$NAME == "Harris",]$FILL = 1
county.df[county.df$NAME == "Liberty",]$FILL = 1
county.df[county.df$NAME == "Montgomery",]$FILL = 1
county.df[county.df$NAME == "Waller",]$FILL = 1

## read in Texas base plot shapefile
texaspoly = readShapePoly("../shapefiles/county/tl_2009_48_county")
texaspoly@data$id = rownames(texaspoly@data)
texasmap.points = fortify(texaspoly, region="CNTYIDFP")
texasmap.df = join(texasmap.points, texaspoly@data, by="CNTYIDFP")
#texasmap = join(texasmap.df, county.df, by="CNTYIDFP")
pcounty = c(geom_polygon(data=texasmap, aes(x=long, y=lat, group=group, fill="white"), colour= "#4B4B4B",lwd=0.2))


## remove axes from plot
xquiet = scale_x_continuous("", breaks=NULL)
yquiet = scale_y_continuous("", breaks=NULL)
quiet = list(xquiet, yquiet)

## add layers
pplot = ggplot() + pcounty + quiet + ggtitle("HGAC Grant Operating Counties")
pplot


# if(require(maps)) {
#   tx = map_data("county", "texas")
#   qplot(long, lat, data=tx, geom="polygon", group=group, colour=I("black"), fill=I("white")) + quiet
# }