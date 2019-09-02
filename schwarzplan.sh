#!/usr/bin/env bash

# exit shell if something fails
set -o errexit

# make sure Inkscape is installed
if [ ! -x "$(command -v inkscape)" ]; then
     echo ""
     echo "\033[0;31m[Error with Exception]\033[0m"
     echo "Make sure Inkscape is installed"
     echo ""
     exit
fi

echo "\033[0;34m+++ creating map.yaml +++\033[0m"
cat << EOF > ./map.yaml
ServiceURL: http://printmaps-osm.de:8282/api/beta2/maps/
Fileformat: svg
Scale: $3
PrintWidth: 1920
PrintHeight: 1080
Latitude: $1
Longitude: $2
Style: schwarzplan+
Projection: 3857
HideLayers: admin-low-zoom,admin-mid-zoom,admin-high-zoom,admin-text,protected-areas,protected-areas-text
UserObjects:
UserFiles:
EOF

echo "\033[0;34m+++ creating map +++\033[0m"
./printmaps create

echo "\033[0;34m+++ ordering map +++\033[0m"
./printmaps order

echo "\033[0;34m+++ waiting 20s for order to process +++\033[0m"
sleep 20s

echo "\033[0;34m+++ downloading map +++\033[0m"
./printmaps download

echo "\033[0;34m+++ unzipping file +++\033[0m"
unzip printmaps.zip

echo "\033[0;34m+++ renaming file and deleting map files +++\033[0m"
rm map.id
rm map.yaml
rm printmaps.zip
mv printmaps.svg $4.svg

echo "\033[0;34m+++ replacing colors +++\033[0m"
# make background black
sed -i -e 's/rgb(100%,100%,100%)/#000000/g' ./$4.svg
# make waterways violet
sed -i -e 's/rgb(73.333333%,81.176471%,81.176471%)/#8814CC/g' ./$4.svg
# make buildings gray
sed -i -e 's/rgb(0%,0%,0%)/#666666/g' ./$4.svg
# make transport ways black or violet
sed -i -e 's/rgb(60%,60%,60%)/#000000/g' ./$4.svg
# sed -i -e 's/rgb(60%,60%,60%)/#8814CC/g' ./$4.svg

echo "\033[0;34m+++ exporting to png +++\033[0m"
inkscape $4.svg --export-png=$4.png --export-area-page --export-width=1920 --export-height=1080

echo "\033[0;34m+++ converting to jpg +++\033[0m"
convert $4.png $4.jpg

echo "\033[0;34m+++ all good! +++\033[0m"
