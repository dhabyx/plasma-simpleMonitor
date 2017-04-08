#!/bin/sh

# Go to script dir
cd "$(dirname $0)"
DIR=$(pwd)

BUGLNK='https://github.com/dhabyx/plasma-simpleMonitor/issues'
AUTHORS="Dhaby Xiloj, Konstantin Shtepa"

NAME="plasma_applet_"$(grep "X-KDE-PluginInfo-Name" ../plasmoid/metadata.desktop | sed 's/.*=//')
VERSION=$(grep "X-KDE-PluginInfo-Version" ../plasmoid/metadata.desktop | sed 's/.*=//')

XGETTEXT="xgettext --from-code=UTF-8 -kde -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 \
          -ki18ncp:1c,2,3 -ktr2i18n:1 -kI18N_NOOP:1 -kI18N_NOOP2:1c,2 -kaliasLocale \
          -kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3xgettext -ki18n -ki18nc
          -ki18ncp -ki18np --package-version=${VERSION} --package-name=${NAME}\
          --msgid-bugs-address=${BUGLNK}"

$XGETTEXT --copyright-holder="${AUTHORS}" `find ../plasmoid -name \*.qml -o -name \*.js` -L JavaScript -o "$NAME.pot"

sed -e 's/SOME DESCRIPTIVE TITLE./plasma-simpleMonitor language translation file./g' -i "$NAME.pot"
sed -e "s/YEAR/2013-2017/g" -i "$NAME.pot"
sed -e '/FIRST AUTHOR <EMAIL@ADDRESS>.*/d' -i "$NAME.pot"

if [ "$1" == "--update-all" ]; then
    echo "Upgrading all translations."
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
fi
