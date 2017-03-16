#!/bin/sh

# Go to script dir

cd "${0%/*}"
DIR=$(pwd)

NAME="plasma_applet_"$(grep "X-KDE-PluginInfo-Name" ../plasmoid/metadata.desktop | sed 's/.*=//')
VERSION=$(grep "X-KDE-PluginInfo-Version" ../plasmoid/metadata.desktop | sed 's/.*=//')

XGETTEXT="xgettext --from-code=UTF-8 -kde -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 \
          -ki18ncp:1c,2,3 -ktr2i18n:1 -kI18N_NOOP:1 -kI18N_NOOP2:1c,2 -kaliasLocale \
          -kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3xgettext -ki18n -ki18nc
          -ki18ncp -ki18np"

if [ "x$1" != "x" ]; then
    if [ ! -d "$1" ]; then
        mkdir -p "$1/LC_MESSAGES"
    fi
fi

$XGETTEXT `find ../plasmoid -name \*.qml -o -name \*.js` -L JavaScript -o "$NAME.pot" 
sed -e 's/charset=CHARSET/charset=UTF-8/g' -i "$NAME.pot"
sed -e 's/SOME DESCRIPTIVE TITLE./plasma-simpleMonitor language translation file./g' -i "$NAME.pot"
sed -e "s/Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER/Copyright (C) 2013-2016 Dhaby Xiloj, Konstantin Shtepa/g" -i "$NAME.pot"
sed -e 's/This file is distributed under the same license as the PACKAGE package./This file is distributed under the same license as the plasma-simpleMonitor package./g' -i "$NAME.pot"
sed -e 's/FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.//g' -i "$NAME.pot"
sed -e "s/Project-Id-Version: PACKAGE VERSION/Project-Id-Version: $VERSION/g" -i "$NAME.pot"

for d in *; do
    if [ -d "$d" ]; then
        if [ -f "$d/LC_MESSAGES/$NAME.po" ]; then
            echo "Merging $NAME.pot -> $d/LC_MESSAGES/$NAME.po ..."
            msgmerge -U --backup=none "$d/LC_MESSAGES/$NAME.po" "$NAME.pot"
        else
            echo "Copying $NAME.pot -> $d/LC_MESSAGES/$NAME.po ..."
            cp "$NAME.pot" "$d/LC_MESSAGES/$NAME.po"
        fi
    fi
done

for d in *; do
    if [ -d "$d" ]; then
        echo "Making $d/LC_MESSAGES/$NAME.mo ..."
        msgfmt "$d/LC_MESSAGES/$NAME.po" -o "$d/LC_MESSAGES/$NAME.mo"
    fi
done

# rm -f $NAME.pot
