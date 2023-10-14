#!/bin/sh

# Go to script dir
cd "$(dirname $0)"
DIR=$(pwd)
LANGDIR="$1"
NAME="plasma_applet_"$(grep "X-KDE-PluginInfo-Name" ../plasmoid/metadata.desktop | sed 's/.*=//')

set -e

if [ -n "$LANGDIR" ]; then
    if [ ! -d "$LANGDIR" ]; then
        mkdir -p "${LANGDIR}/LC_MESSAGES"
    fi
else
  echo "Missing LANG parameter
usage: $0 LANG

 example:
 $0 es"
  exit
fi


if [ -d "$LANGDIR" ]; then
    if [ -f "${LANGDIR}/LC_MESSAGES/$NAME.po" ]; then
        echo "Merging $NAME.pot -> ${LANGDIR}/LC_MESSAGES/$NAME.po ..."
        msgmerge -U --backup=none "${LANGDIR}/LC_MESSAGES/$NAME.po" "$NAME.pot"
    else
        echo "Copying $NAME.pot -> ${LANGDIR}/LC_MESSAGES/$NAME.po ..."
        cp "$NAME.pot" "${LANGDIR}/LC_MESSAGES/$NAME.po"
    fi
fi
