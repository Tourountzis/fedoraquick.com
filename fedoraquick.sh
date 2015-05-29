#!/bin/bash
#
# FedoraQuick 22.0
# Nadim Kobeissi
# GPLv3
#
# Disclaimer: FedoraQuick is not associated with
# or endorsed by the Fedora Project, Red Hat or any
# related organization. It is entirely a third party
# community effort.
#
# FedoraQuick comes with absolutely no warranty.
# Use FedoraQuick at your own risk.

FQVERSION="22.0"
FQSUPPORTEDOS="22"
FQRPMFKEYID="A6708DA3"
FQRPMFKEYFP="BAD2 40A4 79FF 87E7 791E  105F 27D7 7A09 A670 8DA3"
FB=$(tput bold)
FN=$(tput sgr0)

confirm() {
	read -r -p "${1:-Would you like to continue? [y/N]} " r
	case $r in [yY][eE][sS]|[yY]) 
	false;; *)
	true;; esac
}

echo "FedoraQuick $FQVERSION"
echo ""
sleep 1

if [[ $(whoami) != "root" ]]; then
	echo "Sorry, but you must run FedoraQuick as root."
	echo "Doing this will allow FedoraQuick administrator"
	echo "access over your computer. If you do not trust"
	echo "FedoraQuick, you probably should not do this."
	exit
fi

if [[ $(rpm -E %fedora) != $FQSUPPORTEDOS ]]; then
	echo "Sorry, but this version of FedoraQuick"
	echo "is only compatible with Fedora $FQSUPPORTEDOS."
	exit
fi

echo "Welcome! This version of FedoraQuick is ${FB}compatible${FN}"
echo "with your system! We can now proceed."
echo "${FB}An active Internet connection will be required.${FN}"
echo ""
echo "We will be enabling:"
echo "${FB}*${FN} RPMFusion integration."
echo "${FB}*${FN} Audio/video format support."
echo "${FB}*${FN} Better font smoothing."

confirm && exit

echo ""
echo "${FB}RPMFusion integration${FN}"
echo -n "Starting in 5 seconds..."
sleep 5
echo ""

echo -n "Verifying signing keys... "
gpg --keyserver pgp.mit.edu --recv-keys $FQRPMFKEYID &> /dev/null
if [[ $(
	gpg --fingerprint $FQRPMFKEYID | grep -oh "$FQRPMFKEYFP"
) != $FQRPMFKEYFP ]]; then
	echo "failed. Exiting."
	exit
fi
echo "OK!"

echo -n "Installing RPMFusion repository... "
dnf -y install \
http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-\
$(rpm -E %fedora).noarch.rpm &> /dev/null
if [[ ! -e /etc/yum.repos.d/rpmfusion-free.repo ]]; then
	echo "failed. Exiting."
	exit
fi
echo "OK!"

echo -n "Updating system (may take a while)... "
dnf -y update &> /dev/null
echo "OK!"

echo ""
echo "${FB}Audio/video format support${FN}"
echo -n "Starting in 5 seconds..."
sleep 5
echo ""

echo -n "Installing codecs... "
dnf -y install gstreamer{1,}-plugins-{base,good,ugly} \
gstreamer-plugins-bad gstreamer-plugins-bad-free \
gstreamer1-libav gstreamer-ffmpeg faad2 libdca &> /dev/null
if [[ $(rpm -qa | grep -c ^gstreamer) -lt 12 ]]; then
	echo "failed. Exiting."
	exit
fi
echo "OK!"

echo ""
echo "${FB}Better font smoothing${FN}"
echo -n "Starting in 5 seconds..."
sleep 5
echo ""

echo -n "Installing freetype... "
dnf -y install freetype-freeworld &> /dev/null
echo "OK!"

echo ""
echo "--"
echo ""
echo "All done. Thank you for using FedoraQuick."
echo ""