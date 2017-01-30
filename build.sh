#!/bin/bash
plasmapkg2 -r simpleMonitor
rm -rf ~/.local/share/plasma/plasmoids/simpleMonitor
plasmapkg2 -t plasmoid -i ./plasmoid
kbuildsycoca5 --noincremental
# plasmawindowed simpleMonitor
plasmoidviewer -a simpleMonitor
