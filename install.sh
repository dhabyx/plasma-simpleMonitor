#!/bin/sh

cd "${0%/*}"

# Install (or upgrade) the Simple System Monitor plasmoid.
kpackagetool6 -t Plasma/Applet -u ./plasmoid 2> /dev/null || kpackagetool6 -t Plasma/Applet -i ./plasmoid

# Install the Simple System Monitor icon.
ICON_PATH=${HOME}/.local/share/icons/hicolor/scalable/apps/
mkdir -p ${ICON_PATH}
cp plasmoid/contents/images/simpleMonitor_icon.svg ${ICON_PATH}
