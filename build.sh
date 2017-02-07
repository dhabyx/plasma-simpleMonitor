#!/bin/bash
plasmapkg2 -r org.kde.simpleMonitor
rm -rf ~/.local/share/plasma/plasmoids/org.kde.simpleMonitor
plasmapkg2 -t plasmoid -i ./plasmoid
kbuildsycoca5 --noincremental
# plasmawindowed simpleMonitor
plasmoidviewer -a org.kde.simpleMonitor
