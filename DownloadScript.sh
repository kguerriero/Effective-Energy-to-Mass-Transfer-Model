#!/bin/bash
#This script takes in 9 arguments
#It converts the coordinates from OpenTopo into the format used by daymet
#Downloads the data from daymet
#Warps OpenTopo Geotiff
#Converts .nc files from DAYMET to .tif
#1. xmin
#2. ymin
#3. xmax
#4. ymax
#5. EPSG
#6. year
#7. month or if using daymentR use endYear
#8. what category to download from daymet (eg. ALL, tmin ... etc)
#9. geoTiff from OpenTopography
       
wget -w 2 -O coordinates.txt "http://opentopo.sdsc.edu/LidarPortlet/jsp/projection.jsp?minx=$1&miny=$2&maxx=$3&maxy=$4&inEpsg=$5&outEpsg=4326"

#file downloaded is in "long lat long lat" format
#get first coordinate
first=$(cat coordinates.txt | sed "s/|/   /g" | egrep -o "^?-[0-9]*\.[0-9][0-9][0-9]")
echo $first

#get second coordinate
second=$(cat coordinates.txt | egrep -o "[|][0-9][0-9]\.[0-9][0-9][0-9]|" | tr "\n" " "| egrep -o "^[|][0-9]*[.][0-9]+" | sed "s/|//g" | sed "s/[[:space:]]//g")
echo $second

#get third coordinate
third=$(cat coordinates.txt | egrep -o "?-[0-9]*\.[0-9][0-9][0-9]" | tr "\n" " " | egrep -o "?-[0-9]*\.[0-9]+.$")
echo $third

#get final coordinate
fourth=$(cat coordinates.txt | egrep -o "[|][0-9][0-9]\.[0-9][0-9][0-9]|" | tr "\n" " " | egrep -o "[0-9]*[.][0-9]+.$")

echo $fourth

#get the dayment data
#uncomment this if getting data from daymet (not Tyson's irods)
#Rscript ./daymetr/daymet_tile.R $second $first $fourth $third $6 $7 "$8" ./output/

#OR use tysons irods data. Just uncomment this code and comment out the above Rscript code
#comment this code out if using Tyson's irods account
export PATH=$PATH:~/icommands/
iget -f /iplant/home/tyson_swetnam/DAYMET/$8_allyrs/$8_$6_$7.tif

#warp open topo file
bash WarpTool.sh $5 $9

#convert all .nc files from daymet to GeoTiff
#uncomment this if getting data from daymet (not Tyson's irods)
#bash nc_to_tiff.sh

#clean up
#uncomment this if getting data from daymet (not Tyson's irods)
#rm *.nc

#begin executing grass commands
#params are 1 what to calc (tmin, tmax etc)
#2 year 
#3 month
#bash grassCommand.sh $8 $6 $7 
