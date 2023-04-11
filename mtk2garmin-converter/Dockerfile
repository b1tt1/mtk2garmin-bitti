# FROM teemupel/mtk2garmin-ubuntugis-base
FROM nas.local:5500/mtk2garmin-ubuntugis-base

WORKDIR /opt/mtk2garmin

ADD . .

RUN mvn clean package install
