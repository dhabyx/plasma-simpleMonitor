#!/bin/sh

# Reinstalls the plasmoid in the user directory and opens it in a window.
cd "${0%/*}"
kpackagetool6 -t Plasma/Applet -u ./plasmoid || kpackagetool6 -t Plasma/Applet -i ./plasmoid
plasmawindowed org.kde.simpleMonitor
