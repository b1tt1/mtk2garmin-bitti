# FROM teemupel/mtk2garmin-ubuntugis-base
FROM localhost:5000/mtk2garmin-ubuntugis-base

WORKDIR /opt/mtk2garmin

ADD . .

RUN mvn clean package install
