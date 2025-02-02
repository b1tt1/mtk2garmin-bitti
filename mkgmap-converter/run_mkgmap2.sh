#!/bin/bash
set -euxo pipefail

# rm -rf /splitted/*
# rm -rf /output/mtkgarmin
rm -rf /output/mtkgarmin_noparcel/*
# BITTI: time java -jar -Xmx10G splitter.jar --output-dir=/splitted --max-areas=4096 --max-nodes=3200000 --resolution=14 /convertedpbf/all_osm.osm.pbf
# time java -jar splitter.jar --output-dir=/splitted --max-areas=4096 --max-nodes=3200000 --resolution=14 /convertedpbf/all_osm.osm.pbf
# (cat mkgmap_mtk2garmin.args;echo;cat /splitted/template.args) > /splitted/mkgmap_mtk2garmin.args
(cat mkgmap_mtk2garmin_noparcel.args;echo;cat /splitted/template.args) > /splitted/mkgmap_mtk2garmin_noparcel.args
# time java -jar -Xmx14G mkgmap.jar -c /splitted/mkgmap_mtk2garmin.args perus.typ
# BITTI: time java -Xmx10G -jar mkgmap.jar -c /splitted/mkgmap_mtk2garmin_noparcel.args perus.typ
time java -Xmx8G -jar mkgmap.jar -c /splitted/mkgmap_mtk2garmin_noparcel.args perus.typ
# time java -jar mkgmap.jar -c /splitted/mkgmap_mtk2garmin_noparcel.args perus.typ

# cp perus.typ /output/mtkgarmin/perus.typ
cp perus.typ /output/mtkgarmin_noparcel/perus.typ
