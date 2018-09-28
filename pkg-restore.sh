#!/bin/bash
##
# The purpose of this script is to restore deb packages
# that were removed (in my case by accident using autoremove :/)
# based on the output from /var/log/apt/history.log when running the
# remove command. The script will organize the output, download all
# listed packages. The end result is a tarball that can be transferred
# to the affected host for re-install.
## - acamara/datamonk

BASE_PATH="~/tmp"
RAW_PKG_FILE="$BASE_PATH/pkg_raw.tmp"
GROOMED_PKG_FILE="$BASE_PATH/pkg_groomed.tmp"

mkdir -p ${BASE_PATH}/extra-pkgs
touch $GROOMED_PKG_FILE

# Parse out the deb package names by \n so we can iterate
# over them later.
for i in `seq 1 446`; do
  pkg=$( cat $RAW_PKG_FILE | cut -d',' -f$i | cut -d' ' -f2 )
  echo $pkg >> $GROOMED_PKG_FILE
done

# Using APT, iterate though the groomed list and ONLY download
# the packages (and there deps) to a defined directory.
IFS=$'\n'
for j in $( cat $GROOMED_PKG_FILE ); do
  # ROOT access required for below.
  sudo apt-get -d -o=dir::cache=$BASE_PATH/extra-pkgs install $j -y
done

# Create a tarball of all downloaded packages.
tar -czvf $BASE_PATH/pkgs_$(date +%Y%m%d).tar.gz $BASE_PATH/extra-pkgs/ 

# For completness, run the below commond on the intended
# remote host to install each package after manual extraction.
#
## $ sudo dpkg -i ~/tmp/*.deb && sudo apt-get install -f

unset IFS
exit 0
