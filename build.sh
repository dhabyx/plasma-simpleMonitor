#!/bin/bash

cd "${0%/*}"
plasmapkg2 -r org.kde.simpleMonitor
# rm -rf ~/.local/share/plasma/plasmoids/org.kde.simpleMonitor
plasmapkg2 -t plasmoid -i ./plasmoid
kbuildsycoca5 --noincremental
# plasmawindowed org.kde.simpleMonitor
plasmoidviewer -a org.kde.simpleMonitor
