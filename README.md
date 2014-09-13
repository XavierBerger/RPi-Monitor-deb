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

Build script also create a debian repository. To use this repository follow the instruction bellow:

Activate https transport for apt:
    
    sudo apt-get install apt-transport-https ca-certificates

Execute the following command to add rpimonitor into your list of repository:

    sudo wget https://raw.githubusercontent.com/XavierBerger/RPi-Monitor/master/init/apt/sources.list.d/rpimonitor.list -O /etc/apt/sources.list.d/rpimonitor.list

This will add the file `/etc/apt/source.list.d/rpimonitor.list` containing:

    # RPi-Monitor official repository
    deb https://github.com XavierBerger/RPi-Monitor-deb/raw/master/repo/

**Note**: To test unstable version, replace *master* by *devel* into the upper line.

Install **RPi-Monitor**

    sudo apt-get update
    sudo apt-get install rpimonitor

For update (when a new release of RPi-Monitor is available)
  
    sudo apt-get update
    sudo apt-get upgrade

**Note**: *The package is not signed, it will be require to accept installation of 
unauthenticated package*.

    
## Authors

**Xavier Berger**

+ [http://rpi-experiences.blogspot.fr](http://rpi-experiences.blogspot.fr)
