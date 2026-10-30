#!/bin/sh
# Extract QML/JavaScript messages into the POT; does not update translations.
set -eu
cd "$(dirname "$0")"
name=plasma_applet_org.kde.simpleMonitor
find ../plasmoid -type f \( -name '*.qml' -o -name '*.js' \) -print | LC_ALL=C sort > "${TMPDIR:-/tmp}/simplemonitor-xgettext-$$"
trap 'rm -f "${TMPDIR:-/tmp}/simplemonitor-xgettext-$$"' EXIT HUP INT TERM
xgettext --from-code=UTF-8 --language=JavaScript --files-from="${TMPDIR:-/tmp}/simplemonitor-xgettext-$$" \
    --keyword=i18n:1 --keyword=i18nc:1c,2 --keyword=i18np:1,2 --keyword=i18ncp:1c,2,3 \
    --package-name=plasma-simpleMonitor --output="$name.pot"
sed -i 's/charset=CHARSET/charset=UTF-8/' "$name.pot"
