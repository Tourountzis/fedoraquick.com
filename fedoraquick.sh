#!/bin/bash
#
# FedoraQuick 24.0
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

FQVERSION="24.0"
FQSUPPORTEDOS="24"
FQRPMKEYID="5250AEF3"
FQRPMKEYFP="36EB EB08 D346 B0A8 5B58  E140 EE78 8F49 5250 AEF3"
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
echo "${FB}*${FN} UnitedRPMs integration."
echo "${FB}*${FN} Audio/video format support."
echo "${FB}*${FN} Better font smoothing."
echo "${FB}*${FN} ExFAT filesystem support."

confirm && exit

echo ""
echo "${FB}UnitedRPMs integration${FN}"
echo -n "Starting in 3 seconds... "
sleep 3
echo ""

echo -n "Verifying signing keys... "
gpg --keyserver pgp.mit.edu --recv-keys $FQRPMKEYID &> /dev/null
if [[ $(
	gpg --fingerprint $FQRPMKEYID | grep -oh "$FQRPMKEYFP"
) != $FQRPMKEYFP ]]; then
	echo "failed. Exiting."
	exit
fi
echo "OK!"

echo -n "Installing UnitedRPMs repository... "
dnf -y config-manager \
--add-repo=https://raw.githubusercontent.com/UnitedRPMs/unitedrpms.github.io/master/unitedrpms.repo \
&> /dev/null
if [[ ! -e /etc/yum.repos.d/unitedrpms.repo ]]; then
	echo "failed. Exiting."
	exit
fi
echo "OK!"

echo -n "Updating system (may take a while)... "
dnf -y update &> /dev/null
echo "OK!"

echo ""
echo "${FB}Audio/video format support${FN}"
echo -n "Starting in 3 seconds... "
sleep 3
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
echo -n "Starting in 3 seconds... "
sleep 3
echo ""

echo -n "Installing freetype... "
FONTCONFIG="PD94bWwgdmVyc2lvbj0nMS4wJz8+CjwhRE9DVFlQRSBmb250Y29uZmlnIFNZU1RFTSAnZm9udHMuZHRkJz4KPGZvbnRjb25maWc+CiAgICA8bWF0Y2ggdGFyZ2V0PSJmb250Ij4KICAgICAgICA8ZWRpdCBuYW1lPSJhbnRpYWxpYXMiIG1vZGU9ImFzc2lnbiI+CiAgICAgICAgICAgIDxib29sPnRydWU8L2Jvb2w+CiAgICAgICAgPC9lZGl0PgogICAgICAgIDxlZGl0IG5hbWU9ImF1dG9oaW50IiBtb2RlPSJhc3NpZ24iPgogICAgICAgICAgICA8Ym9vbD5mYWxzZTwvYm9vbD4KICAgICAgICA8L2VkaXQ+CiAgICAgICAgPGVkaXQgbmFtZT0iZW1iZWRkZWRiaXRtYXAiIG1vZGU9ImFzc2lnbiI+CiAgICAgICAgICAgIDxib29sPmZhbHNlPC9ib29sPgogICAgICAgIDwvZWRpdD4KICAgICAgICA8ZWRpdCBuYW1lPSJoaW50aW5nIiBtb2RlPSJhc3NpZ24iPgogICAgICAgICAgICA8Ym9vbD50cnVlPC9ib29sPgogICAgICAgIDwvZWRpdD4KICAgICAgICA8ZWRpdCBuYW1lPSJoaW50c3R5bGUiIG1vZGU9ImFzc2lnbiI+CiAgICAgICAgICAgIDxjb25zdD5oaW50c2xpZ2h0PC9jb25zdD4KICAgICAgICA8L2VkaXQ+CiAgICAgICAgPGVkaXQgbmFtZT0ibGNkZmlsdGVyIiBtb2RlPSJhc3NpZ24iPgogICAgICAgICAgICA8Y29uc3Q+bGNkbGlnaHQ8L2NvbnN0PgogICAgICAgIDwvZWRpdD4KICAgICAgICA8ZWRpdCBuYW1lPSJyZ2JhIiBtb2RlPSJhc3NpZ24iPgogICAgICAgICAgICA8Y29uc3Q+cmdiPC9jb25zdD4KICAgICAgICA8L2VkaXQ+CiAgICA8L21hdGNoPgo8L2ZvbnRjb25maWc+Cg=="
dnf -y install freetype-freeworld &> /dev/null
echo "Xft.lcdfilter: lcddefault" >> /etc/X11/Xresources
echo $FONTCONFIG | base64 --decode > /etc/fonts/local.conf
echo "OK!"

echo ""
echo "${FB}ExFAT filesystem support${FN}"
echo -n "Starting in 3 seconds... "
sleep 3
echo ""

echo -n "Installing ExFAT utilities... "
dnf -y install exfat-utils fuse-exfat &> /dev/null
echo "OK!"

echo ""
echo "--"
echo ""
echo "All done. Thank you for using FedoraQuick."
echo ""
