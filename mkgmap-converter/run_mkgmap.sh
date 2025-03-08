#!/bin/bash
set -euxo pipefail

rm -rf /splitted/*
rm -rf /output/mtkgarmin
rm -rf /output/mtkgarmin_noparcel
rm -rf /output/mtkgarmin_mh
# BITTI time java -jar -Xmx30G splitter.jar --output-dir=/splitted --max-areas=4096 --max-nodes=3200000 --resolution=14 /convertedpbf/all_osm.osm.pbf
time java -jar splitter.jar --output-dir=/splitted --max-areas=4096 --max-nodes=3200000 --resolution=14 /convertedpbf/all_osm.osm.pbf
# (cat mkgmap_mtk2garmin.args;echo;cat /splitted/template.args) > /splitted/mkgmap_mtk2garmin.args
(cat mkgmap_mtk2garmin_noparcel.args;echo;cat /splitted/template.args) > /splitted/mkgmap_mtk2garmin_noparcel.args
# BITTI time java -jar -Xmx30G mkgmap.jar -c /splitted/mkgmap_mtk2garmin.args perus.typ
# BITTI time java -jar -Xmx30G mkgmap.jar -c /splitted/mkgmap_mtk2garmin_noparcel.args perus.typ
# BITTI
time java -jar -Xmx8G mkgmap.jar -c /splitted/mkgmap_mtk2garmin_noparcel.args perus.typ

# cp perus.typ /output/mtkgarmin/perus.typ
cp perus.typ /output/mtkgarmin_noparcel/perus.typ
