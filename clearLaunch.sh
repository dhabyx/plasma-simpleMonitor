#!/bin/sh

find . \( -name *.qmlc -o -name *.jsc \) -exec rm -f "{}" \;
