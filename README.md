Simple Monitor for Plasma
=========================

A simple monitor for plasma, completely written in QML and Javascript. 

Packaging
=========

Simple way for make plasmoid package:

````Shell
$ git clone https://github.com/dhabyx/plasma-simpleMonitor.git plasma-simpleMonitor
$ cd plasma-simpleMonitor/plasmoid
$ zip -r plasma-simpleMonitor.plasmoid contents metadata.desktop
````

Installation
============

In KDE you can use asistant for installation.

In a terminal you can use plasmapkg command:
````Shell
$ plasmapkg2 -i plasma-simpleMonitor.plasmoid
````

If you want update:
````Shell
$ plasmapkg2 -u plasma-simpleMonitor.plasmoid
````

Development
===========

Use launch.sh script to launch and debug plasma-simpleMonitor plasmoid without install it.

License
=======
Simple Monitor for Plasma is licensed under the GNU General Public License Version 3 or later.

You can modify or/and distribute it under the conditions of this license.
