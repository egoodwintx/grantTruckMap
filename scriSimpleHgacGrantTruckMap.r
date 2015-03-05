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
library(ggthemes)
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
vehnum = c(70089, 70090, 70091, 70092, 70093)

## reads in vehicle data for one unit at a time
readvehdat = function(unit) {
  filestr = paste0("../../scriHgacGrantTruckMap/data/Vehicle_Position_History_Report_Unit", unit, ".csv")
  unitdat = read.csv(filestr, header=T, skip=7)
  names(unitdat) = c("Time", "Location", "Status", "Latitude", "Longitude", "Speed", "Direction")
  unitdat$UnitID = as.factor(unit)
  
  ## drop last two rows of report since these are blank
  rownum = nrow(unitdat)
  unitdat = unitdat[-c(rownum-1,rownum)]
  
  ## return unitdat
  unitdat
}

## combine all the unit data into one data frame
createvehdf = function(vec) {
  vehdat = readvehdat(vec[1])
  for(i in vec[-1]){
    vehdat = rbind(vehdat, readvehdat(i))
  }
  vehdat
}
# vehpos = read.csv("../../scriHgacGrantTruckMap/data/veh_pos.csv", header=T, skip=9)
vehpos = createvehdf(vehnum)

## create Unit plot
ppoints = c(geom_point(data=vehpos, aes(x=Longitude, y=Latitude, colour=UnitID), alpha=0.4))

p = ggplot() +
  geom_polygon(data=plotData, aes(x=long, y=lat, group=group, fill=fillval), color="black", size=0.25) +
  # take care of shape distortion
  coord_map() +
  # eliminates background, gridlines, tick lines, axis titles, legend and chart border
  theme_nothing(legend=TRUE) +
  labs(title="HGAC Grant Truck Operating Activity", fill="") +
  theme(plot.title = element_text(size = rel(2))) +
  ppoints +
  scale_fill_distiller(palette="Greens")
p

## are vehicles in county area?
# proj4string(vehpos) = proj4string(plotData)