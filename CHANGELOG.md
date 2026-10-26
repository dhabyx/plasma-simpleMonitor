# plasma-simpleMonitor Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).

## [0.7.0] - Unreleased
    ### Changed
    - Ported to Plasma 6 / Qt 6 (PlasmoidItem, metadata.json, kpackagetool6).
    - System data now comes from KSysGuard sensors (org.kde.ksysguard.sensors).
    - Distribution and kernel are read from the os/* sensors; only the number of physical CPU cores still needs a shell call, and only in per-core temperature mode.
    - Configuration pages rewritten with Kirigami and Qt Quick Controls 2.
    - Memory "Used/Free" now follows the KSysGuard definition (free = available).
    - Translations moved to <lang>/LC_MESSAGES and regenerated.

    ### Performance
    - Averages are updated incrementally; free memory is derived instead of polled; static totals stop polling; date refreshes every 30 s; CPU load gradient no longer uses rotated items.

    ### Added
    - CPU temperature mode: per core, average or maximum.
    - The logo icon of the distribution is used when there is no bundled logo.
    - Credits file (AUTHORS.md).
    - Minimalistic skin selectable in configuration.
    - Debian logo selectable in configuration; ID_LIKE based logo detection.
    - Logos (Simple Icons) for Linux Mint, EndeavourOS, Pop!_OS, Zorin OS, elementary OS, NixOS, Gentoo, Alpine, Void, Rocky, AlmaLinux, Red Hat, CentOS and Kali.
    - Brazilian Portuguese translation.
    - Network download/upload monitor (network/all sensors), with bytes or bits units, in every skin.

    ### Fixed
    - GPUs whose sensor indices have gaps (e.g. only gpu1) are handled; the label is "GPU:" when there is only one.
    - Broken merges in skins and code.js.
    - Critical temperature binding and temperature colour order.

    ### Removed
    - Plasma 5 support, metadata.desktop, qmake project file.
    - ATI/AMD/NVIDIA command line GPU probes (GPU temperature uses the gpu/* sensors).

## [Unreleased] - 2017-xx-xx
    ### Added
    - Turkish translation.

## [Unreleased] - 2017-xx-xx
    ### Added
    - Chinese(simplified) translation.
    - Polish translation.

    ### Fixed
    - Plasmoid logo path in .desktop file.

## [0.6] - 2017-03-19
    ### Added
    - Translation support.
    - ru translation.
    - SVG logo scaling.
    - Base support for RightToLeft view.
    - Logos for Fedora, Manjaro and Arch.
    - CMake support.
    - CMake installation instructions in README.
    - Script to cleanup after launch.sh.
    - CHANGELOG.

    ### Changed
    - SVG logos replaced PNG logos.

    ### Fixed
    - Plasmoid name and version in .desktop file.
    - Items positions.

    ## Removed
    - Tuz logo.

## [0.6-rc1] - 2017-02-07
    ### Added
    - Plasma 5 support.
    - Instructions for installation in README.
    - GPL LICENCE.
    - Skin support.
    - Column skin.
    - OpenSUSE logo.
    - Launch script to test plasmoids without install.

    ### Changed
    - Migrated from KDE4 to KF5.
    - Structure of project.
    - Migrated in development from .qmlproject to .pro file.
    - Config now base on .qml files.
    - QML now depend on quick 2.
    - Predefined CPU temperatures.

    ### Fixed
    - Additional plasmoid don't work with database.

    ## Removed
    - Plasma(KDE4) support.

## [0.5] - 2014-05-26
    ### Added
    - Fahrenheit support.
    - Visual improvements.
    - Plasma style support.

    ### Changed
    - LoadBar completed.

## [0.4] - 2013-12-28
    ### Fixed
    - Elements alignments.
    - Bad uptime.

## [0.3] - 2013-12-28
    ### Added
    - Background settings.
    - Logos for Kubuntu, Ubuntu and tuz.
    ### Changed
    - Detection of distro name.

    ### Fixed
    - Fonts.

## [0.2] - 2013-12-27
    ### Added
    - AMD K7 support for lmsensors.
    - Temperature settings.
    - README.

## [0.1] - 2013-12-27
    - Initial Commit.
