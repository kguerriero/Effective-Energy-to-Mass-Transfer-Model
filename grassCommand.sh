#input params
#calcs tmin and tmax
#calcs Total wetness index
#generates EEMT
#$1 what year to use
#$2 what month to use
#$3 total wetness file (TWI) from OpenTopo
#$4 slope from r.sun
#$5 aspect from r.sun
#TODO pull in slope and aspect from r.sun (already generated)

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
g.proj -c proj4="+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

#r.external input="na_dem.tif" output=naDem band=1 --overwrite -o -r 


#import NASA dem
r.external input=na_dem.tif band=1 output=nasaDEM --overwrite -o -r

#import the DAYMET tmin / tmax
r.external input=tmin_$1_$2.tif output=daymetTmin --overwrite -o -r 
r.external input=tmax_$1_$2.tif output=daymetTmax --overwrite -o -r
r.external input=prcp_$1_$2.tif output=prcp --overwrite -o -r



#Import the warped geoTiff
r.external input=output.den.tif.warped band=1 output=warped --overwrite -o -r

#Setup the correct region
g.region rast=warped res=10

#run mapcalc for tmin/tmax
r.mapcalc tmin_loc=daymetTmin-0.00649*\(warped-nasaDEM\)
r.mapcalc tmax_loc=daymetTmax-0.00649*\(warped-nasaDEM\)

#6 Locally corrected temp that accounts for solar radiation
r.mapcalc zeros="if(warped>0,0,null())"
r.sun elevin=daymet aspin=zeros slopein=zeros day="1" step="0.05" dis="1" glob_rad=flat_total_sun
#TODO need to have r.sun generating flat_total_sun
r.mapcalc S_i="total_sun/flat_total_sun"
r.mapcalc tmin_topo="tmin_loc*(S_i-(1/S_i))"
r.mapcalc tmax_topo="tmin_loc*(S_i-(1/S_i))"

#7Local water balance accounting for topo water distribution
r.external input="$3" band=1 output=TWI --overwrite -o -r
r.mapcalc a_i="(TWI/((max(TWI)+min(TWI))/2))*pecp"

#sun joules
r.mapcalc total_sun_joules="total_sun/(3600*hours_sun)"

#mean air density
r.mapcalc p_a="101325*exp(-9.80665*0.289644*warped/(8.31447*288.15))/287.35*((tmax_topo+tmin_topo/2)+273.125)"

#saturated vapor pressure
r.mapcalc f_tmin_topo="0.6108*exp((12.27*tmin_topo)/(tmin_topo+273.3))"
r.mapcalc f_tmax_topo="0.6108*exp((12.27*tmax_topo)/(tmax_topo+273.3))"
r.mapcalc vp_s_topo="(f_tmax_topo+f_tmin_topo)/2"

#local area vapor pressure
r.mapcalc vp_loc="6.11*10^(7.5*tmin_topo)/(237.3+tmin_topo)"

#aerodynamic resistance
r.mapcalc ra="(4.72*(ln(2/0.00137))^2)/(1+0.536*5)"

#slope of saturated vapor pressure-temperature relationship
r.mapcalc m_vp="0.04145*exp(0.06088*(tmax_topo+tmin_topo/2))"

#psychromatic constant
r.mapcalc g_psy="0.001013*(101.3*((293-0.00649*warped)/293)^5.26)/(0.622*2.45)"

#actual evapotranspiration (AET)
r.mapcalc AET="prcp*(1+PET/prcp-(1+(PET/prcp)^2.63)^(1/2.63))"


#8.1 Traditional EEMT
r.mapcalc F="a_i*prcp"
r.mapcalc DT="((tmax_topo+tmin_topo)/2)-273.15"

r.mapcalc NPP="3000*(1+exp(1.315-0.119*(tmin_loc+tmin_loc)/2)^-1)"
r.mapcalc h_bio="22*(10^6)"
r.mapcalc E_bio="NPP*h_bio"
r.mapcalc E_ppt="F*4185.5*DT*E_bio"

#calc trad EEMT
r.mapcalc tradEEMT="E_ppt+E_bio"
r.out.gdal -c createopt="TFW=NO" input=tradEEMT output="./tradEEMT"


#EEMT topo
echo "r.mapcalc NPP_topo=0.39*warped+346*(sin(slope)*cos(aspect*0.0174532925))-187"


#r.mapcalculator amap=warped bmap=nasaDEM cmap=daymet formula="C-5.69/1000*(A-B)" outfile=mapCalcOutput --overwrite

