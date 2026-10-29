#!/bin/sh
# Update one locale only, using the existing POT; no MO files are written here.
set -eu
cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 LOCALE (e.g. hu or pt_BR)" >&2
    exit 2
fi
case "$1" in *[!A-Za-z0-9_@-]*|'') echo "Invalid locale" >&2; exit 2;; esac
name=plasma_applet_org.kde.simpleMonitor
po="$1/LC_MESSAGES/$name.po"
mkdir -p "$1/LC_MESSAGES"
if [ -f "$po" ]; then
    msgmerge --update --backup=none "$po" "$name.pot"
else
    msginit --no-translator --locale="$1" --input="$name.pot" --output-file="$po"
fi
