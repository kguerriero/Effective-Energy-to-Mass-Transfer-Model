#input params
#$1 what to calculate (tmin, tmax etc)
#$2 what year to use
#$3 what month to use
export GISBASE="/usr/lib/grass64"  
export GRASS_VERSION="6.4.3"
export PATH="$PATH:$GISBASE/bin:$GISBASE/scripts"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GISBASE/lib"
export PYTHONPATH="$GISBASE/etc/python"
export SHELL=/bin/bash

#generate GISRCRC, !!!!you need change them to the correct ones!!!!!!
MYGISDBASE=$HOME/grassLocation
MYLOC=grassLocation1
MYMAPSET=PERMANENT

# Set the global grassrc file to individual file name
MYGISRC="$HOME/.grassrc.$GRASS_VERSION"

export GISRC=$MYGISRC

echo "GISDBASE: $MYGISDBASE" > "$MYGISRC"
echo "LOCATION_NAME: $MYLOC" >> "$MYGISRC"
echo "MAPSET: $MYMAPSET" >> "$MYGISRC"
echo "DIGITIZER: none" >> "$MYGISRC"
echo "GRASS_GUI: text" >> "$MYGISRC"

#here we run grass commands
#g.proj -c proj4="+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

#r.external input="na_dem.tif" output=naDem band=1 --overwrite -o -r 


#import NASA dem
r.external input="na_dem.tif" band=1 output=nasaDEM --overwrite -o -r

#import the DAYMET tif
r.external input=$1_$2_$3.tif output=daymet --overwrite -o -r 

#Import the warped geoTiff
r.external input="./output.den.tif.warped" band=1 output=warped --overwrite -o -r

#Setup the correct region
g.region rast=warped res=10

#run mapcalc
r.mapcalculator amap=warped bmap=nasaDEM cmap=daymet formula="C-5.69/1000*(A-B)" outfile=mapCalcOutput --overwrite

r.out.gdal -c createopt="TFW=NO,COMRESS=LZW" input=mapCalcOutput output="./mapCalcOutput.tif"


