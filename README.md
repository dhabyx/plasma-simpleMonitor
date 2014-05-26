Simple Monitor for Plasma
=========================

A simple monitor for plasma, completely written in QML amd Javascript. 

Packaging
=========

Simple way for make plasmoid package:

````Shell
$ git clone https://github.com/dhabyx/plasma-simpleMonitor.git plasma-simpleMonitor
$ cd plasma-simpleMonitor
$ zip -r plasma-simpleMonitor.plasmoid contents icon.svg metadata.desktop
````

Installation
============

In KDE you can use asistant for installation.

In a terminal you can use plasmapkg command:
````Shell
$ plasmapkg -i plasma-simpleMonitor.plasmoid
````

If you want update:
````Shell
$ plasmapkg -u plasma-simpleMonitor.plasmoid
````
