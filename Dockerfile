FROM ubuntu:22.04 AS base

# Create a build environment
FROM base AS tools

WORKDIR /arduino

# Install necessary build tools
RUN apt-get update

RUN set -eux; \
    apt-get install -y locales arduino

RUN locale-gen --no-purge en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install board packages
RUN arduino --pref "compiler.warning_level=default" --save-prefs
RUN arduino --install-boards "arduino:samd"
RUN arduino --pref "boardsmanager.additional.urls=https://adafruit.github.io/arduino-board-index/package_adafruit_index.json" --save-prefs
RUN arduino --install-boards "adafruit:samd"
ENV BOARD="arduino:samd:arduino_zero_edbg"
RUN arduino --board "${BOARD}" --save-prefs
RUN arduino --install-library "MIDI Library"
RUN arduino --install-library "Adafruit DotStar"
RUN arduino --install-library "Adafruit BusIO"

RUN set -eux; \
    apt-get install -y git

# Install uf2conv
RUN set -eux; \
    git clone --branch stable --sparse https://github.com/masto/uf2.git; \
    cd uf2; \
    git sparse-checkout set utils
RUN cp uf2/utils/uf2conv.py uf2/utils/uf2families.json /usr/bin/
RUN rm -rf uf2

COPY ./build.sh /usr/bin/

FROM tools AS builder

VOLUME /arduino

ENTRYPOINT ["/usr/bin/build.sh"]

# docker run -it --rm -v $(pwd):/arduino $image NABU/NABU.ino firmware/NABU.ino.trinket_m0.uf2
