Simple Monitor for Plasma
=========================

A simple monitor for plasma, completely written in QML and Javascript. 

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

Development
===========

Use build.sh script to launch and debug plasma-simpleMonitor plasmoid.

License
=======
Simple Monitor for Plasma is licensed under the GNU General Public License Version 3 or later.

You can modify or/and distribute it under the conditions of this license.
