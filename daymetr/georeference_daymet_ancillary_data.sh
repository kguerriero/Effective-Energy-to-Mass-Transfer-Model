#!/bin/bash

# get filename with no extension
no_extension=`basename $1 | cut -d'.' -f1`

# convert the netCDF file to an ascii file 
gdal_translate -of AAIGrid $1 original.asc

# extract the data with no header
tail -n +7 original.asc > ascii_data.asc

# paste everything together again with a correct header
echo "ncols        8011" 	>  final_ascii_data.asc
echo "nrows        8220"	>> final_ascii_data.asc
echo "xllcorner    -4659000.0" 	>> final_ascii_data.asc
echo "yllcorner    -3135000.0" 	>> final_ascii_data.asc
echo "cellsize     1000" 	>> final_ascii_data.asc
echo "NODATA_value 0"    	>> final_ascii_data.asc 

# append flipped data
tac ascii_data.asc >> final_ascii_data.asc

# translate the data into Lambert Conformal Conic GTiff
gdal_translate -of GTiff -a_srs "+proj=lcc +datum=WGS84 +lat_1=25 n +lat_2=60n +lat_0=42.5n +lon_0=100w" final_ascii_data.asc tmp.tif

# convert to latitude / longitude
gdalwarp -of GTiff -overwrite -tr 0.009 0.009 -t_srs "EPSG:4326" tmp.tif tmp_lat_lon.tif

# crop to reduce file size / only cover the DAYMET tiles
gdal_translate -a_nodata -9999 -projwin -131.487784581 52.5568285568 -51.8801911189 13.9151864748 tmp_lat_lon.tif $no_extension.tif

# clean up
rm original.asc
rm ascii_data.asc
rm final_ascii_data.asc
rm tmp.tif
rm tmp_lat_lon.tif



