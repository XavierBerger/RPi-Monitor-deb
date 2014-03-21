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

#echo "Is changelog up to date for version $(cat ../RPi-Monitor/VERSION)?"
echo -e "\033[31m\033[1mWARNING\033[0m: the directory $(pwd)/${DPKGSRC} will be destroyed"
echo -ne "Continue yes/no [no]:"
read continue
if [[ $continue != *"yes"* ]]; then
 echo -e "You must enter \033[1myes\033[0m to continue. Script aborted".
 exit 1
fi

vi debian/changelog

echo "Removing old ${DPKGSRC} directory"
sudo rm -fr ${DPKGSRC}

echo "Creating a new ${DPKGSRC} directory"
mkdir ${DPKGSRC}

echo "Constructing debian package structure"
cd ${DPKGSRC}
cp -a ../debian DEBIAN
sed -i "s/{DATE}/$(LANG=EN; date)/" DEBIAN/changelog
cp -a ${RPIMONITOR}/init etc
mkdir -p usr/bin usr/share/rpimonitor/scripts etc/rpimonitord.conf.d
cp ${RPIMONITOR}/rpimonitor/rpimonitord.conf etc
cp ${RPIMONITOR}/rpimonitor/default.conf etc/rpimonitord.conf.d
cp ${RPIMONITOR}/rpimonitor/rpimonitord usr/bin
cp -a ${RPIMONITOR}/rpimonitor/web/ usr/share/rpimonitor
cp ${RPIMONITOR}/rpimonitor/updatestatus.txt usr/share/rpimonitor
rm usr/share/rpimonitor/web/stat/*

echo "Post processing"
sed -i "s/{DEVELOPMENT}/${VERSION}-1/" DEBIAN/control
sed -i "s/{DEVELOPMENT}/$VERSION/" usr/bin/rpimonitord
sed -i "s/{DEVELOPMENT}/$VERSION/" usr/share/rpimonitor/web/js/rpimonitor.js

mkdir -p usr/share/man/man1
../help2man.pl usr/bin/rpimonitord $VERSION | gzip -c > usr/share/man/man1/rpimonitord.1.gz
mkdir -p usr/share/man/man5 
cat ${RPIMONITOR}/rpimonitor/rpimonitord.conf ${RPIMONITOR}/rpimonitor/default.conf > rpimonitord.conf
../conf2man.pl rpimonitord.conf $VERSION | gzip -c > usr/share/man/man5/rpimonitord.conf.5.gz
rm -f rpimonitord.conf

echo "Building package"
find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
sudo chown -R root:root etc usr
cd ..
dpkg -b ${DPKGSRC} packages/rpimonitor_${VERSION}-1_all.deb

echo "Creating package for Raspbetty Store"
cd store/rpimonitor
ln ../../packages/rpimonitor_${VERSION}-1_all.deb rpimonitor_${VERSION}-1_all.deb
cd ..
zip rpimonitor_${VERSION}-1_all.zip rpimonitor/*
