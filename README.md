# [**RPi-Monitor-deb**](http://rpi-experiences.blogspot.fr/)

**RPi-Monitor-deb** is the project packaging [**RPi-Monitor**](https://github.com/XavierBerger/RPi-Monitor) into a debian package. **RPi-Monitor** is a self monitoring application designed to run on [Raspberry Pi](http://www.raspberrypi.org/).

Installation, usage and customization are detailed into the official web site: [http://rpi-experiences.blogspot.fr/](http://rpi-experiences.blogspot.fr/)


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
   
## Repository

Build script also create a debian repository.

This repository can be used by adding the following lines in /etc/apt/source.list

    # RPi-Monitor official repository
    deb https://github.com XavierBerger/RPi-Monitor-deb/raw/devel/repo/

The following command will then work:

To activate https transport for apt:
    
    sudo apt-get install apt-transport-https

For installation
  
    sudo apt-get install rpimonitor

For update
  
    sudo apt-get update
    sudo apt-get upgrade

**Note**: *The package is not signed, it will be require to accept installation of 
unauthenticated package*.
    
## Authors

**Xavier Berger**

+ [http://rpi-experiences.blogspot.fr](http://rpi-experiences.blogspot.fr)
