#!/bin/bash
set -euxo pipefail

printf -v date '%(%Y%m%d)T' -1

docker-compose down -v

docker pull quay.io/azavea/openjdk-gdal:3.1-jdk11-slim
docker build --tag "localhost:5000/mtk2garmin-ubuntugis-base" -f ./ubuntugis-base/Dockerfile ./ubuntugis-base
# docker push teemupel/mtk2garmin-ubuntugis-base
docker push localhost:5000/mtk2garmin-ubuntugis-base

echo "******1*****"

docker-compose build --parallel
docker-compose push

echo "******2*****"

if docker build --tag "localhost:5000/mtk2garmin-additional-data:$date" -f ../get-additional-data/Dockerfile --no-cache ../get-additional-data; then
  echo "Succesfully loaded additional data"
  docker tag "localhost:5000/mtk2garmin-additional-data:$date" localhost:5000/mtk2garmin-additional-data:latest
  docker push localhost:5000/mtk2garmin-additional-data:latest
fi

docker-compose pull

echo "******3*****"

time docker-compose run mml-client /go/src/app/mml-muutostietopalvelu-client load -p maastotietokanta -t kaikki -f application/gml+xml -d /mtkdata
echo "******4*****"

time docker-compose run mml-client /go/src/app/mml-muutostietopalvelu-client load -p kiinteistorekisterikartta -t karttalehdittain -f application/x-shapefile -d /krkdata

echo "******5*****"


docker-compose up --no-start additional-data
echo "******6*****"

docker-compose up --no-start mapstyles
echo "******7*****"


time docker-compose run mtk2garmin-converter java -jar /opt/mtk2garmin/target/mtk2garmin-0.0.2.jar /opt/mtk2garmin/mtk2garmin.conf
echo "******8*****"

time docker-compose run merger ./merge_files.sh

echo "******9*****"

time docker-compose run mkgmap ./run_mkgmap.sh

echo "******10*****"

# time docker-compose run mapsforge /app/bin/osmosis \
#            --rbf file=/convertedpbf/all_osm.osm.pbf workers=2 \
#            --mapfile-writer file=/output/mtk_all.map bbox=59.4507573,19.0714057,70.1120744,31.6133108 \
#            simplification-max-zoom=12 simplification-factor=16 threads=4 \
#            zoom-interval-conf=5,4,7,8,8,11,12,12,13,14,14,21 \
#            label-position=true polylabel=true \
#            tag-conf-file=/mapstyles/mapsforge_peruskartta/mml_tag-mapping_tidy.xml type=hd comment="(c) NLS, Metsahallitus, Liikennevirasto, OpenStreetMap contributors 2019"


echo "******11*****"

# time docker-compose run osxconverter

echo "******12*****"

# time docker-compose run nsis /output/mtkgarmin/osmmap.nsi
echo "******13*****"

# time docker-compose run nsis /output/mtkgarmin_noparcel/osmmap.nsi
echo "******14*****"


# time docker-compose run site
docker-compose down -v
