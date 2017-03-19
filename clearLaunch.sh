#!/bin/sh

cd "${0%/*}"
find plasmoid/ \( -name *.qmlc -o -name *.jsc \) -exec rm -f "{}" \;
