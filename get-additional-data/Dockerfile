# FROM teemupel/mtk2garmin-ubuntugis-base as loader
FROM nas.local:5500/mtk2garmin-ubuntugis-base as loader

WORKDIR /opt/get_additional_data
ADD get_additional_data.sh get_additional_data.sh
ADD grid.zip /additional-data/grid.zip
RUN chmod +x /opt/get_additional_data/get_additional_data.sh && /opt/get_additional_data/get_additional_data.sh


FROM alpine:latest as serve
WORKDIR /additional-data
COPY --from=loader /additional-data ./
