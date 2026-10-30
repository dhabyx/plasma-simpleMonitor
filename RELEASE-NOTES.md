# Simple Monitor 0.7.0

Simple Monitor now supports KDE Plasma 6 and Qt 6, with readings from KDE's
KSystemStats sensors. Plasma 5 is no longer supported.

- Reorganized Content, Appearance and Sensors preferences with a live preview.
- Optional content visibility, compact spacing, CPU columns and CPU frequency.
- Separate distribution name, version and codename, with one or multiple lines.
- Optional physical-core temperature grouping: one initial cpuinfo read,
  cached per widget instance; ongoing measurements come from KDE.
- Corrected CPU alignment, missing readings, sensor lifecycle and natural sizing.
- Optional content auto-fit, custom SVG/PNG logos and improved bundled artwork.
- Eight translation catalogs, contributor credits and uninstall documentation.

## Download and install

Download `plasma-simpleMonitor-v0.7.0.plasmoid`. It includes the widget, bundled
logos/fonts and compiled translations. Install it through Plasma's widget dialog,
or run:

```sh
kpackagetool6 -t Plasma/Applet -i plasma-simpleMonitor-v0.7.0.plasmoid
```

Use `-u` instead of `-i` to upgrade. Back up the existing widget and settings
before upgrading; see the README for backup and rollback instructions.

`SHA256SUMS` verifies the attached files. The separate translation archive is
provided for manual deployments; the `.plasmoid` already contains those files.
GitHub's source archives include the CMake installer, PO sources, tests, credits
and artwork provenance. The widget requires Plasma 6, KSystemStats and the KDE
KItemModels QML module.

## Known limitations

Desktop auto-fit uses private Plasma 6.6 APIs and was tested in an isolated grid,
not on the user's live desktop. Some strings fall back to English. Artwork
source/usage questions remain documented in `LOGO-SOURCES.md`; distribution
trademarks retain their respective owners' terms. Grouping may require manual
refresh after a sensor-service restart or CPU changes.

Thanks to the contributors credited in `AUTHORS.md`, including the Plasma 6
port and adapted community contributions.
