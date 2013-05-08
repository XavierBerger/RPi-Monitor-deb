# RPi-Monitor-deb

**Author**: Xavier Berger

**Blog**: [RPi-Experience](http://rpi-experiences.blogspot.fr/)

## About

**RPi-Monitor-deb** is the project packaging **RPi-Monitor** into a debian package.
**RPi-Monitor** is a self monitoring application designed to run on [Raspberry Pi](http://raspberrypi.org).
Fr detail aboud **RPi-Monitor**, refer to <https://github.com/XavierBerger/RPi-Monitor>

## Prerequisite

Before using **RPi-Monitor-deb** it is required to install the dependencies. To do so, execute the following command:

    sudo apt-get install dpkg-dev 

## Package creation

Clone RPi-Monitor and RPi-Minitor-dev:

    git clone https://github.com/XavierBerger/RPi-Monitor.git
    git clone https://github.com/XavierBerger/RPi-Monitor-deb.git

Build package:

    cd RPi-Monitor-deb
    ./build-deb.sh
