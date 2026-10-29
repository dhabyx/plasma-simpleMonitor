# Contributing translations

The source catalogs are `LOCALE/LC_MESSAGES/plasma_applet_org.kde.simpleMonitor.po`.
Install GNU gettext for `xgettext`, `msgmerge`, `msginit`, and `msgfmt`.

1. Run `./translations/Messages.sh` from the repository root to extract the
   current QML and JavaScript strings into the POT. It does not alter any PO.
2. Run `./translations/translation.sh hu` (replace `hu` with your locale) to
   create or update only that locale's PO from the POT. Review fuzzy entries.
3. Edit the PO and validate it with `msgfmt --check -o /dev/null PATH_TO_PO`.
4. Build with CMake (`cmake -S . -B build && cmake --build build`). CMake
   compiles every PO into the build directory; installation places the MO files
   under the appropriate `share/locale/LOCALE/LC_MESSAGES` directory. Source
   catalogs are never modified by the build. Do not commit generated MO files.

Existing translations can be incomplete, especially for features introduced
since Plasma 6; untranslated messages fall back to English. The metadata names
and descriptions are in `plasmoid/metadata.json` and are translated separately.
