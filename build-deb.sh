#!/bin/bash
# (c) 2013-2017 - Xavier Berger - http://rpi-experiences.blogspot.fr/
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
DPKGSRC=$(pwd)/dpkg-src/
RPIMONITOR_SRC=source
VERSION=$(cat ../RPi-Monitor/VERSION)
REVISION=$(cat REVISION)
BRANCH=$(git branch | perl -ne '/^\* (.*)/ and print "$1"')

# Shall we update changelog
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

# Remove old package directory
sudo rm -fr ${DPKGSRC}
mkdir ${DPKGSRC}

function updateRevision(){
  echo
  if [[ $BRANCH == *"master"* ]]; then
    PREFIX=r
  else
    PREFIX=beta
  fi
  echo -e "\033[1mUpdate revision (REVISION=${PREFIX}${REVISION})?"
  echo -ne "yes/no [no]:\033[0m"
  read continue
  if [[ $continue == *"yes"* ]]; then
    ((REVISION++))
    echo -n "Set revicion number [${REVISION}]: "
    read choice
    if [[ "x${choice}" != "x" ]]; then
      REVISION=${choice}
    fi
    echo ${REVISION} > REVISION
  fi
}

# Update RPi-Monitor source in ${RPIMONITOR_SRC}
echo
echo -e "\033[1mUpdating RPi-Monitor source\033[0m"
rm -fr ${RPIMONITOR_SRC}
if [[ $BRANCH == *"master"* ]]; then
  git clone --no-hardlinks ${RPIMONITOR_REPO} ${RPIMONITOR_SRC}
  updateRevision
  REVISION="r${REVISION}"
else
  mkdir -p ${RPIMONITOR_SRC}
  cp -a ${RPIMONITOR_REPO}/* ${RPIMONITOR_SRC}/
  updateRevision
  REVISION="beta${REVISION}"
fi  

echo
echo -e "\033[1mConstructing debian package structure\033[0m"
pushd ${DPKGSRC} > /dev/null
  cp -a ../debian DEBIAN
  mv DEBIAN/apt-release.conf ../repo
  sed -i "s/{DATE}/$(LANG=EN; date)/" DEBIAN/changelog
  sed -i "s/{VERSION}/${VERSION}/"    DEBIAN/changelog
  sed -i "s/{REVISION}/${REVISION}/"  DEBIAN/changelog
popd > /dev/null

# Copy from sources
echo
echo -e "\033[1mGetting RPi-Monitor from sources\033[0m"
pushd ${RPIMONITOR_SRC} > /dev/null
  export TARGETDIR=${DPKGSRC}
  make install
popd > /dev/null

echo
echo -e "\033[1mSetting version to ${VERSION}-${REVISION}\033[0m"

# Defining version
pushd ${DPKGSRC} > /dev/null
  sed -i "s/{DEVELOPMENT}/${VERSION}-${REVISION}/" DEBIAN/control
  sed -i "s/{DEVELOPMENT}/${VERSION}-${REVISION}/" usr/bin/rpimonitord
  sed -i "s/{DEVELOPMENT}/${VERSION}-${REVISION}/" usr/share/rpimonitor/web/js/rpimonitor.js
  find etc/rpimonitor/ -type f | sed  's/etc/\/etc/' > DEBIAN/conffiles
popd > /dev/null

# Creating man files
mkdir -p ${DPKGSRC}/usr/share/man/man1
${RPIMONITOR_SRC}/tools/help2man.pl ${DPKGSRC}/usr/bin/rpimonitord ${VERSION} | gzip -c > ${DPKGSRC}/usr/share/man/man1/rpimonitord.1.gz
mkdir -p ${DPKGSRC}/usr/share/man/man5
cat ${DPKGSRC}/etc/rpimonitor/daemon.conf ${DPKGSRC}/etc/rpimonitor/template/raspbian.conf > rpimonitord.conf
${RPIMONITOR_SRC}/tools/conf2man.pl rpimonitord.conf ${VERSION} | gzip -c > ${DPKGSRC}/usr/share/man/man5/rpimonitord.conf.5.gz
rm -f rpimonitord.conf

# Building deb package
echo
echo -e "\033[1mBuilding package\033[0m"
pushd ${DPKGSRC} > /dev/null
  find . -type f ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
  sudo chown -R root:root etc usr
popd > /dev/null
dpkg -b ${DPKGSRC} packages/rpimonitor_${VERSION}-${REVISION}_all.deb > /dev/null
rm packages/rpimonitor_latest.deb
ln -sr packages/rpimonitor_${VERSION}-${REVISION}_all.deb packages/rpimonitor_latest.deb

echo
echo -e "\033[1mUpdate repository for ${VERSION}?"
echo -ne "yes/no [yes]:\033[0m"
read continue

if [[ $BRANCH == *"master"* ]] || [[ $continue != *"no"* ]]; then
  echo
  echo -e "\033[1mUpdating repository for branch \033[31m\033[1m${BRANCH}\033[0m:\033[0m"
  cd repo
  rm *.deb Packages.gz
  ln ../packages/rpimonitor_${VERSION}-${REVISION}_all.deb rpimonitor_${VERSION}-${REVISION}_all.deb
  dpkg-scanpackages -h sha256 . /dev/null rpimonitor/ > Packages
  gzip -k Packages

  apt-ftparchive -c=apt-release.conf release . > Release
  rm Release.gpg
  gpg --armor --detach-sign --sign --output Release.gpg Release
  cd ..
fi

echo
echo -ne "\033[1mInstall RPi-Monitor ${VERSION} now? (Ctl+C to cancel)\033[0m"
read continue
sudo dpkg -i packages/rpimonitor_${VERSION}-${REVISION}_all.deb
