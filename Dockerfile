# syntax=docker/dockerfile:1
FROM debian:stable-slim
MAINTAINER WEEE Open
RUN apt-get update \
    && apt-get -y install live-build \
    && apt-get clean
WORKDIR /miso
COPY miso_maker.sh .
ENTRYPOINT ["/miso/miso_maker.sh"]
