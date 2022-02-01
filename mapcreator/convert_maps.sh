#!/bin/bash
set -e
#echo "Installing packages"
#add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
#apt-get update
#apt-get -y upgrade
#apt-get -y install default-jre git python unzip default-jdk maven python3 libgdal-java nsis


time_stamp=$(date +%Y-%m-%d)


echo "Make /opt/mtk2garmin_build"
mkdir -p /opt/mtk2garmin_build
cd /opt/mtk2garmin_build
mkdir -p "/opt/mtk2garmin_build/output/${time_stamp}"
mkdir -p "/var/www/jekku/public_html/kartat/${time_stamp}"

rm -rf /opt/mtk2garmin_build/mtk2garmin

git clone --depth=1 -b master --single-branch https://github.com/pailakka/mtk2garmin.git

cd mtk2garmin
mkdir suomi
mkdir inputdata
./get_additional_data.sh

ln -s /home/teemu/mtk/tuotteet/maastotietokanta/kaikki/etrs89/gml inputdata/mtk
ln -s /home/teemu/mtk/tuotteet/kiinteistorekisterikartta/avoin/karttalehdittain/tm35fin/shp inputdata/krk

mvn install
java -jar -Xmx5G target/mtk2garmin-0.0.1-SNAPSHOT.jar mtk2garmin.conf 
wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert
wget -O - http://m.m.i24.cc/osmfilter.c |cc -x c - -O3 -o osmfilter

chmod +x osmconvert
chmod +x osmfilter

python3 merge_suomi.py

parallel --eta --progress -a merge_all1.sh
parallel --eta --progress -a merge_all2.sh
parallel --eta --progress -a merge_all3.sh
parallel --eta --progress -a merge_all4.sh

./process_osm.sh

cd mapsforge_peruskartta
python3 tidy_tag_mapping.py
cd ..

mkdir osmosis
cd osmosis
curl --fail -O https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz -Oosmosis-latest.tgz
tar -xvzf osmosis-latest.tgz
cd ../
mkdir plugins
cd plugins
curl --fail -O "http://central.maven.org/maven2/org/mapsforge/mapsforge-map-writer/0.10.0/mapsforge-map-writer-0.10.0-jar-with-dependencies.jar"
cd ../

mkdir mkgmap
cd mkgmap
wget -Omkgmap-latest.tar.gz http://www.mkgmap.org.uk/download/mkgmap-latest.tar.gz
tar --extract --verbose --gzip --strip-components=1 --file=mkgmap-latest.tar.gz

wget -Osplitter-latest.tar.gz http://www.mkgmap.org.uk/download/splitter-latest.tar.gz
tar --extract --verbose --gzip --strip-components=1 --file=splitter-latest.tar.gz
cd ..

mkdir splitted

echo "Splitting file..."
java -jar -Xmx10G mkgmap/splitter.jar --output-dir=splitted --max-areas=1024 --max-nodes=600000 all_osm.osm.pbf
echo "Splitting done"
(cat mkgmap_mtk2garmin.args;echo;cat splitted/template.args) > splitted/mkgmap_mtk2garmin.args
(cat mkgmap_mtk2garmin_noparcel.args;echo;cat splitted/template.args) > splitted/mkgmap_mtk2garmin_noparcel.args
echo "Compiling typ"
java -cp "mkgmap/mkgmap.jar:lib/*jar" uk.me.parabola.mkgmap.main.TypCompiler peruskartta_garmin.txt perus.typ
echo "Compiling typ done"

echo "Compiling garmin img parcels"
java -jar -Xmx10G mkgmap/mkgmap.jar -c splitted/mkgmap_mtk2garmin.args perus.typ

echo "Compiling garmin img noparcels"
java -jar -Xmx10G mkgmap/mkgmap.jar -c splitted/mkgmap_mtk2garmin_noparcel.args perus.typ

mv mtkgarmin/gmapsupp.img "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi.img"
mv mtkgarmin_noparcel/gmapsupp.img "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi_eikr.img"

echo "Running osmosis writer!"
./mapsforge_convert.sh

echo "Copying Mapsforge files"
mv all.map "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi.map"

echo "Creating windows installer parcel"
cp perus.typ mtkgarmin/perus.typ
cd mtkgarmin
makensis osmmap.nsi
echo "copying installer files"
mv "MTKSuomi.exe" "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi.exe"
cd ..

echo "Creating windows installer noparcel"
cp perus.typ mtkgarmin_noparcel/perus.typ
cd mtkgarmin_noparcel
makensis osmmap.nsi
echo "copying installer files"
mv "MTKSuomi.exe" "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi_eikr.exe"
cd ..


echo "converting osx files"
./convert_osx_map.sh
echo "copying osx files"
mv "mtk_suomi_osx.zip" "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi_osx.zip"
mv "mtk_suomi_noparcel_osx.zip" "/opt/mtk2garmin_build/output/${time_stamp}/mtk_suomi_eikr_osx.zip"

cd mapsforge_peruskartta
7za a peruskartta.zip Peruskartta.xml mml
7za a tiekartta.zip Tiekartta.xml mml
curl -O http://kartat.hylly.org/peruskartta_v3.zip -Operuskartta_v3.zip
mv "peruskartta.zip" "/opt/mtk2garmin_build/output/${time_stamp}/peruskartta.zip"
mv "tiekartta.zip" "/opt/mtk2garmin_build/output/${time_stamp}/tiekartta.zip"
mv "peruskartta_v3.zip" "/opt/mtk2garmin_build/output/${time_stamp}/peruskartta_v3.zip"

echo "Done!"
