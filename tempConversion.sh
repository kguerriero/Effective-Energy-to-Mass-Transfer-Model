#!/bin/bash

# NOTE: Assumes that you have all relevant .tiff files in the working directory


# A script that calculates the temperature based on the following parameters
# Parameters:
#     1. A name for the output file
#     2. The RASTER for the temperature 
#     3. The RASTER for the OpenTopography 10 meter DEM 
#     4. The RASTER for the NASA 1 kilometer DEM

usage() {
   echo "Usage: calcTemp -h -o output -t temp -m 10m raster -k 1km raster" >&2
   echo "         -h print usage message" >&2
   echo "         -t temperature raster" >&2
   echo "         -m 10m DEM raster" >&2
   echo "         -k 1km DEM raster" >&2
   echo "         -o output file name" >&2
}

opts() {
   while getopts ":ht:m:k:o:" opt 
   do
      case $opt in
         h)
            usage
            exit 0
            ;;
         t)
            temperatureRaster=$OPTARG
            ;;
         m)
            scaleToRaster=$OPTARG
            ;;
         k)
            needScaleRaster=$OPTARG
            ;;
         o)
            outputName=$OPTARG
            ;;
         :)
            echo "Option $OPTARG requires an argument" >&2
            exit 1
            ;;
         \?)
            echo "Invalid option -$OPTARG" >$2
            exit 1
            ;;
      esac
   done
}

temperatureRaster=""
scaleToRaster=""
needScaleRaster=""
outputName=""
opts $@

tempOutRaster="$temperatureRaster"
tempOutRaster+="_RASTER"
scaleRasterOut="$scaleToRaster"
scaleRasterOut+="_RASTER"
needScaleOut="$needScaleRaster"
needScaleOut+="_RASTER"



`r.in.gdal --overwrite -o input=$temperatureRaster output=$tempOutRaster`
`r.in.gdal --overwrite -o input=$scaleToRaster output=$scaleRasterOut`
`r.in.gdal --overwrite -o input=$needScaleRaster output=$needScaleOut`

echo""

echo "Calling r.mapcalc..."
echo "Writing to: $outputName, args: $tempOutRaster, $scaleRasterOut, $needScaleOut"

`r.mapcalc "$outputName=$tempOutRaster-0.00649*($scaleRasterOut-$needScaleOut)"`

