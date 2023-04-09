#!/bin/sh

set -e

ino=$1
out=$2

arduino --pref build.path=/tmp --verify --board adafruit:samd:adafruit_trinket_m0 "${ino}"
uf2conv.py -o "${out}" -c "/tmp/$(basename "${ino}").bin"
