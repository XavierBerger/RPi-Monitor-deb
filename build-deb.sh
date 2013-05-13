#!/bin/bash
# (c) 2013 - Xavier Berger - http://rpi-experiences.blogspot.fr/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
DPKGSRC=dpkg-src
RPIMONITOR=../../RPi-Monitor
VERSION=$(cat ../RPi-Monitor/VERSION)

#echo -e "\033[31mWARNING: the directory $(pwd)/${DPKGSRC} will be destroyed\033[0m"
#echo -ne "\033[31mContinue yes/no [no]:\033[0m"
#read continue
#if [[ $continue != *"yes"* ]]; then
# echo -e "You must enter \033[1myes\033[0m to continue. Script aborted".
# exit
#fi

echo "Removing old ${DPKGSRC} directory"
sudo rm -fr ${DPKGSRC}

echo "Creating a new ${DPKGSRC} directory"
mkdir ${DPKGSRC}

echo "Constructing debian package structure"
cd ${DPKGSRC}
cp -a ../debian DEBIAN
mkdir -p etc/init.d etc/default
cp ${RPIMONITOR}/init/default/rpimonitor etc/default
cp ${RPIMONITOR}/init/sysv/rpimonitor etc/init.d
cp ${RPIMONITOR}/rpimonitor/rpimonitord.conf etc
mkdir -p usr/bin usr/share/rpimonitor/certs
cp ${RPIMONITOR}/rpimonitor/rpimonitord usr/bin
cp -a ${RPIMONITOR}/rpimonitor/web/ usr/share/rpimonitor

echo "Post processing"
sed -i 's/#webroot=/webroot=\/usr\/share\/rpimonitor\/web/' etc/rpimonitord.conf
sed -i 's/DAEMON=.*/DAEMON="\/usr\/bin\/rpimonitord"/' etc/init.d/rpimonitor
sed -i "s/{DEVELOPMENT}/${VERSION}-1/" DEBIAN/control
sed -i "s/{DEVELOPMENT}/$VERSION/" usr/bin/rpimonitord
sed -i "s/{DEVELOPMENT}/$VERSION/" usr/share/rpimonitor/web/js/rpimonitor.js

mkdir -p usr/share/man/man1
../help2man.pl usr/bin/rpimonitord $VERSION | gzip -c > usr/share/man/man1/rpimonitord.1.gz

echo "Building package"
find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
sudo chown -R root:root etc usr
cd ..
dpkg -b ${DPKGSRC} packages/rpimonitor_${VERSION}-1_all.deb
