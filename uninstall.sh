#!/bin/sh

cd "${0%/*}"

# Remove the Simple System Monitor plasmoid.
plasmapkg2 -r ./plasmoid > /dev/null

# Remove the Simple System Monitor icon.
ICON_PATH=${HOME}/.local/share/icons/hicolor/scalable/apps/
rm -f ${ICON_PATH}/simpleMonitor_icon.svg
