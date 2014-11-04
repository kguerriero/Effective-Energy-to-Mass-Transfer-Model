export GISBASE="/usr/lib/grass64"  
export GRASS_VERSION="6.4.3"
export PATH="$PATH:$GISBASE/bin:$GISBASE/scripts"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GISBASE/lib"
export PYTHONPATH="$GISBASE/etc/python"
export SHELL=/bin/bash

#generate GISRCRC, !!!!you need change them to the correct ones!!!!!!
MYGISDBASE=$HOME/grassLocation
MYLOC=location
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
g.proj -c proj4="+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

r.external input="na_dem.tif" output=naDem band=1 --overwrite -o -r 
r.external input="./output.den.tif.warped" output=warped --overwrite -o -r
r.external input="./tmin_1980_11208.nc.tif" output=tmin --overwrite -o -r 


