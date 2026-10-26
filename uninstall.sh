#!/bin/sh

cd "${0%/*}"

# Remove the Simple System Monitor plasmoid.
kpackagetool6 -t Plasma/Applet -r org.kde.simpleMonitor > /dev/null

# Remove the Simple System Monitor icon.
ICON_PATH=${HOME}/.local/share/icons/hicolor/scalable/apps/
rm -f ${ICON_PATH}/simpleMonitor_icon.svg
