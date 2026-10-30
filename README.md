Simple Monitor for Plasma
=========================

A simple monitor for plasma, completely written in QML and Javascript.

Development preview (`develop`)
-------------------------------

This branch contains the locally reviewed Plasma 6 development preview. It is
not a tagged stable release. `master` remains the separate release baseline.
The preview includes optional content, compact layouts, CPU columns and
frequency, configurable distribution fields, custom logos, and opt-in sizing.
Community credits are recorded in [AUTHORS.md](AUTHORS.md); artwork provenance
and outstanding source/usage questions are recorded in [LOGO-SOURCES.md](LOGO-SOURCES.md).

The desktop auto-fit adapter uses private Plasma 6.6 interfaces. It was tested
with real containers in an isolated grid; acceptance in a user's actual
plasmashell desktop remains pending. Windowed sizing was tested separately.
Missing translations may fall back to English.

Dependencies
============

- Plasma 6 (Plasma Shell) and Qt 6.
- `kstatsviewer` / KSysGuard sensors (`ksystemstats`, shipped with Plasma).
- KDE KItemModels QML module for discovering the available sensor IDs.

Plasma 5 is no longer supported by this branch.

### Extra Dependencies For CMake ###

Only needed if you use `cmake` to install this widget.

- CMake >= 3.16
- Extra CMake Modules (`extra-cmake-modules`)
- Plasma Framework Development Package (`libplasma` headers/cmake files)
- GNU gettext (`msgfmt`) to compile translations

Installation
============

### CMake ###

If you need localisation (i18n/l10n) support, please use `cmake` to install this widget to your system-wide directory. You also would need root permission.

````Shell
git clone --branch develop https://github.com/dhabyx/plasma-simpleMonitor.git plasma-simpleMonitor
cd plasma-simpleMonitor
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
````

CMake generates translations from PO files in the build directory. See
[translations/README.md](translations/README.md) to update a language.

### kpackagetool6 ###

This way may be more convenient, but localisation support is not possible. This widget will be installed into your home directory.

````Shell
git clone --branch develop https://github.com/dhabyx/plasma-simpleMonitor.git plasma-simpleMonitor
cd plasma-simpleMonitor
./install.sh        # or: kpackagetool6 -t Plasma/Applet -i ./plasmoid
````

For upgrade, run `kpackagetool6 -t Plasma/Applet -u ./plasmoid` instead.

Configuration and removal
=========================

Open the widget's configuration to choose content, appearance and sensors.
Existing settings retain their previous defaults: CPU frequency and compact
layout start disabled, the logo remains visible, date/time follow the selected
skin, and CPU bars use one column. Auto columns use the screen size; a tall
CPU list scrolls inside its own area. Frequency requires KSysGuard sensors and
is shown only when enabled. Unsupported or missing readings appear as a dash.
The appearance preview uses example values, not live readings.

“Fit size to content” is optional and off by default. When enabled it adjusts
supported PlasmaWindowed windows and Plasma 6.6 desktop widgets after content
changes; disable it to resize manually. A small width tolerance avoids jitter
from changing sensor values. Desktop fitting uses a private Plasma containment
API that can change between releases. If the host is unsupported or there is
no room in the desktop grid, the widget shows a warning next to the kernel;
hover it for the reason and use “Retry fitting size to content” from the
widget's context menu after freeing space. Other hosts retain their own sizing
behaviour. Fitting never changes another widget's position or size.

Distribution name, version and codename can be shown independently on one
line or on separate lines; the kernel stays visible. The short name uses the
KSystemStats operating-system name, falling back to NAME in /etc/os-release.
VERSION_ID supplies the version; UBUNTU_CODENAME or VERSION_CODENAME supplies
the codename. The final parenthesized text in VERSION is used as a more readable
name only when its first word or whole text matches that codename, ignoring
case. Missing fields are omitted. /etc/os-release is read once, falling back to
/usr/lib/os-release if unavailable; its contents are parsed as data without
evaluating shell expressions.

Per-logical-CPU temperatures use the processors and sensors reported by
KSystemStats. A processor can appear without an available temperature reading;
missing readings appear as a dash. Some logical CPUs may share a temperature
sensor, so separate rows do not necessarily represent independent physical
cores. Average and maximum modes use KSystemStats' aggregate sensors.
Optional physical-core grouping is disabled by default and applies only to the
per-logical-CPU temperature mode. When enabled, the widget reads local CPU
topology once and groups reported logical CPUs by sibling relationship; if
CPU topology changes, use “Refresh CPU grouping” in the widget context menu.
Grouping does not create independent temperature readings where hardware or
KSystemStats provides a shared sensor.

Before replacing or removing a user-installed widget, save its package and
configuration. For example, choose a backup directory and copy the installed
`~/.local/share/plasma/plasmoids/org.kde.simpleMonitor` directory and the
relevant Plasma configuration file, normally
`~/.config/plasma-org.kde.plasma.desktop-appletsrc` (or
`~/.config/plasmawindowedrc` for a windowed test). Preserve those files outside
the package directory. Closing or removing the widget can change its stored
configuration; restore a backup only when appropriate for the Plasma session.

For a user package installed with kpackagetool, remove it with
`kpackagetool6 -t Plasma/Applet -r org.kde.simpleMonitor`. To restore the
package, install the saved package directory with `kpackagetool6 -t
Plasma/Applet -i /path/to/saved/org.kde.simpleMonitor`. This does not uninstall
a separately installed CMake copy.

CMake installations use the `CMAKE_INSTALL_PREFIX` selected at configuration;
inspect `build/install_manifest.txt` to identify their exact files. Retain the
build directory and back up any pre-existing files before installing. To undo a
CMake installation, review the manifest and remove or restore only the files
that this installation added or replaced under that prefix; use the system
package manager instead if those files belong to a distribution package. A
user-level kpackage and a CMake installation can coexist, so check the active
package path after removal rather than assuming one command removes both.

Packaging
=========

Simple way for make plasmoid package:

````Shell
cd plasma-simpleMonitor/plasmoid
zip -r plasma-simpleMonitor.plasmoid contents metadata.json
````

Distribution logos
==================

Automatic mode prefers the distribution icon installed in the current icon
theme, then a bundled logo, then Tux. Explicit choices keep their saved indices.
Choose Custom in the widget settings and select a local SVG or PNG; if the file
is missing or cannot be loaded, the matching bundled logo or Tux is shown. The
file remains in its original location, so keep it there. SVGs are rendered at
higher resolution for a sharp preview and widget; wide logos can use up to
160 × 100 pixels while preserving their proportions. No network download
is performed. Source and trademark information for bundled artwork is recorded
in [LOGO-SOURCES.md](LOGO-SOURCES.md).

Development
===========

Use launch.sh script (`plasmawindowed ./plasmoid`) to launch and debug plasma-simpleMonitor plasmoid without install it.
Use clearLaunch.sh script to clean sources from files generated by launch.sh.

If you love QtCreator IDE visit the [wiki](https://github.com/dhabyx/plasma-simpleMonitor/wiki) for more details.

License
=======
Simple Monitor for Plasma is licensed under the GNU General Public License Version 3 or later.

You can modify or/and distribute it under the conditions of this license.

Development checks
==================

Tests live in `tests/`. JavaScript tests run with Node.js; Python Qt tests
require PyQt6 with Qt Quick, Qt SVG and Qt Test. Native runtime tests additionally
require `xvfb-run`, `dbus-run-session`, `plasmawindowed` and installed Plasma QML
modules. They use temporary packages, configuration directories and private
session buses. A sandbox must permit creating a private D-Bus socket.

For example:

```sh
node tests/test_os_release.js
python3 tests/test_cpu_temperature_settings.py
python3 tests/test_settings_schema.py
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software python3 tests/test_natural_geometry.py
python3 tests/test_window_autofit_runtime.py
python3 tests/test_desktop_autofit_runtime.py
```

Native tests assert their completion markers before the deliberately timed-out
preview exits; a timeout alone is not evidence of a passing test. Synthetic CPU
models exercise up to 128 threads, rather than claiming physical hardware
coverage for each topology.
