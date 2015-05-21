#!/bin/bash
# (c) 2013-2015 - Xavier Berger - http://rpi-experiences.blogspot.fr/
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
RPIMONITOR_REPO=../RPi-Monitor
DPKGSRC=dpkg-src
RPIMONITOR_SRC=source
VERSION=$(cat ../RPi-Monitor/VERSION)
REVISION=$(cat REVISION)
BRANCH=$(git branch | perl -ne '/^\* (.*)/ and print "$1"')

echo -e "\033[1mIs changelog need update for version $(cat ../RPi-Monitor/VERSION)?"
echo -ne "yes/no ["
if [[ $BRANCH == *"master"* ]]; then
  echo -ne "yes"
else
  echo -ne "no"
fi
echo -ne "]:\033[0m"
read continue

if [[ $BRANCH == *"master"* ]] || [[ $continue == *"yes"* ]]; then
  vi debian/changelog
fi

echo
echo -e "\033[1mRemoving old ${DPKGSRC} directory\033[0m"
sudo rm -fr ${DPKGSRC}

echo
echo -e "\033[1mUpdating RPi-Monitor source\033[0m"
rm -fr ${RPIMONITOR_SRC}
if [[ $BRANCH == *"master"* ]]; then
  git clone --no-hardlinks ${RPIMONITOR_REPO} ${RPIMONITOR_SRC}
  REVISION="-1"
else
  mkdir -p ${RPIMONITOR_SRC}
  cp -a ../RPi-Monitor/* ${RPIMONITOR_SRC}/
  ((REVISION++));
  echo ${REVISION} > REVISION
  REVISION="-beta-${REVISION}"
fi  
RPIMONITOR_SRC=../${RPIMONITOR_SRC}

echo
echo -e "\033[1mCreating a new ${DPKGSRC} directory\033[0m"
mkdir ${DPKGSRC}

echo
echo -e "\033[1mConstructing debian package structure\033[0m"
cd ${DPKGSRC}
cp -a ../debian DEBIAN
mv DEBIAN/apt-release.conf ../repo
sed -i "s/{DATE}/$(LANG=EN; date)/" DEBIAN/changelog
sed -i "s/{VERSION}/${VERSION}/" DEBIAN/changelog
sed -i "s/{REVISION}/${REVISION}/" DEBIAN/changelog
cp -a ${RPIMONITOR_SRC}/init etc
rm etc/apt/sources.list.d/rpimonitor.list
mkdir -p usr/bin etc/rpimonitor usr/share/rpimonitor var/lib/rpimonitor
cp ${RPIMONITOR_SRC}/rpimonitor/daemon.conf etc/rpimonitor
cp -a ${RPIMONITOR_SRC}/rpimonitor/template etc/rpimonitor/template
cp ${RPIMONITOR_SRC}/rpimonitor/rpimonitord usr/bin
cp -a ${RPIMONITOR_SRC}/rpimonitor/web/ usr/share/rpimonitor
cp -a ${RPIMONITOR_SRC}/scripts/ usr/share/rpimonitor
cp ${RPIMONITOR_SRC}/rpimonitor/updatestatus.txt var/lib/rpimonitor
pushd usr/share/rpimonitor/web
  ln -s /var/lib/rpimonitor/stat stat
popd

echo
echo -e "\033[1mPost processing\033[0m"
sed -i "s/{DEVELOPMENT}/${VERSION}${REVISION}/" DEBIAN/control
sed -i "s/{DEVELOPMENT}/${VERSION}/" usr/bin/rpimonitord
sed -i "s/{DEVELOPMENT}/${VERSION}/" usr/share/rpimonitor/web/js/rpimonitor.js
find etc/rpimonitor/ -type f | sed  's/etc/\/etc/' > DEBIAN/conffiles

mkdir -p usr/share/man/man1
../help2man.pl usr/bin/rpimonitord ${VERSION} | gzip -c > usr/share/man/man1/rpimonitord.1.gz
mkdir -p usr/share/man/man5
cat ${RPIMONITOR_SRC}/rpimonitor/daemon.conf ${RPIMONITOR_SRC}/rpimonitor/template/raspbian.conf > rpimonitord.conf
../conf2man.pl rpimonitord.conf ${VERSION} | gzip -c > usr/share/man/man5/rpimonitord.conf.5.gz
rm -f rpimonitord.conf

echo
echo -e "\033[1mBuilding package\033[0m"
find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
sudo chown -R root:root etc usr
cd ..
dpkg -b ${DPKGSRC} packages/rpimonitor_${VERSION}${REVISION}_all.deb

echo
echo -e "\033[1mUpdate repository for ${VERSION}?"
echo -ne "yes/no ["
if [[ $BRANCH == *"master"* ]]; then
  echo -ne "yes"
else
  echo -ne "no"
fi
echo -ne "]:\033[0m"
read continue

if [[ $BRANCH == *"master"* ]] || [[ $continue == *"yes"* ]]; then
  echo
  echo -e "\033[1mUpdating repository for branch \033[31m\033[1m${BRANCH}\033[0m:\033[0m"
  cd repo
  sed -i "s/{BRANCH}/${BRANCH}/" apt-release.conf
  rm *.deb Packages.gz
  ln ../packages/rpimonitor_${VERSION}${REVISION}_all.deb rpimonitor_${VERSION}${REVISION}_all.deb
  cd ..
  dpkg-scanpackages repo /dev/null XavierBerger/RPi-Monitor-deb/raw/${BRANCH}/ > repo/Packages
  gzip -k repo/Packages

  apt-ftparchive -c=repo/apt-release.conf release repo > repo/Release
  rm repo/Release.gpg
  gpg --armor --detach-sign --sign --output repo/Release.gpg repo/Release

  echo
  echo -e "\033[1mCreating package for Raspberry Pi Store\033[0m"
  cd store/rpimonitor
  rm *.deb
  ln ../../packages/rpimonitor_${VERSION}${REVISION}_all.deb rpimonitor_${VERSION}${REVISION}_all.deb
  cd ..
  zip rpimonitor_${VERSION}${REVISION}_all.zip rpimonitor/*
  cd ..
fi

echo
echo -ne "\033[1mInstall RPi-Monitor ${VERSION} now? (Ctl+C to cancel)\033[0m"
read continue
sudo dpkg -i packages/rpimonitor_${VERSION}${REVISION}_all.deb
