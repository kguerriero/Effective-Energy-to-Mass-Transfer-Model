#!/bin/bash
#This file warps an OpenTopo GTiff to the correct format that works with DAYMET
#The parameters are 1. EPSG 2. Input Gtiff file (from OpenTopo)

gdalwarp -s_srs EPSG:$1 -t_srs "+proj=lcc +lat_1=25 +lat_2=60 + lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs" -r bilinear -of GTiff ./$2 ./$(echo $2).warped 

if [ $? -eq 0 ]; then
echo "output file called " $(echo $2).warped generated
else
echo "an error occured, file was not generated. "
fi
