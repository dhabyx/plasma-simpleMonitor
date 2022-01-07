#!/bin/sh

cd "${0%/*}"

# Remove the Simple System Monitor plasmoid.
plasmapkg2 -r ./plasmoid > /dev/null

# Install the Simple System Monitor plasmoid.
plasmapkg2 -t plasmoid -i ./plasmoid

# Install the Simple System Monitor icon.
ICON_PATH=${HOME}/.local/share/icons/hicolor/scalable/apps/
mkdir -p ${ICON_PATH}
cp plasmoid/contents/images/simpleMonitor_icon.svg ${ICON_PATH}
