#! /usr/bin/env bash
#XGETTEXT="xgettext --from-code=UTF-8 --language=JavaScript --keyword=i18n --keyword=i18n:1,2 --add-comments=TRANSLATORS"
$XGETTEXT `find . -name \*.qml` -o $podir/plasma_applet_simple.pot
#$XGETTEXT `find . -name \*.qml`
