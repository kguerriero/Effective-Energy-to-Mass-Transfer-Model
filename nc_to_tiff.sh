

#!/bin/bash
#This file loops through all .nc files in directory and coverts them to geoTiff

#echo converting from netCDF to GeoTiff
#echo Please enter the name of the file that you want to convert [.nc]
#read filename
for filename in $(ls *.nc); do

fn=NETCDF:\"$filename\":lat
outinfor=gdalinfo_lat_$filename.txt
gdalinfo $fn > $outinfor

Uleft1=$(grep "Upper Left" $outinfor | egrep -o [0-9]+.[0-9]*, | sed "s/,//g")
Uleft2=$(grep "Upper Left" $outinfor | egrep -o ?-[0-9]+.[0-9]+)
Lright1=$(grep "Lower Right" $outinfor | egrep -o [0-9]+.[0-9]*, | sed "s/,//g")
Lright2=$(grep "Lower Right" $outinfor | egrep -o ?-[0-9]+.[0-9]+)

pre= echo $filename  | sed "s/[0-9]*//g" | sed "s/_*//g" | sed "s/.nc//g"

fioutput=$filename\.tif
fiinput=NETCDF:\"$filename\":$pre
gdal_translate -of GTiff -a_ullr $Uleft1 $Uleft2 $Lright1 $Lright2 -a_srs "+proj=lcc +datum=    WGS84 +lat_1=25 n +lat_2=60n +lat_0=42.5n +lon_0=100w" $fiinput $fioutput
done
