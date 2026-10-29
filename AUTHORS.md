# Authors

- Dhaby Xiloj (DhabyX) and Konstantin Shtepa: original Plasma 5 widget (2013-2017).
- Contributors to the Plasma 5 version, see the git history.
- Plasma 6 port: Saulo Campos.
- Hungarian translation and blackPanther OS logo: Charles K Barcza / Barcza Károly (PR #16).
- PO-to-MO build workflow proposal: Dhaby Xiloj (PR #17).
- KDE neon logo proposal and updated Kubuntu artwork: YamiYukiSenpai (PR #40).
  The bundled neon SVG is now sourced from KDE; see `LOGO-SOURCES.md`.

Several ideas of the Plasma 6 port were taken from the independent port
https://github.com/krumbinet/plasma-simplemonitor6 (GPL-3.0-or-later,
© 2026 krumbinet): reading the distribution and kernel from the
`os/system/*` and `os/kernel/*` sensors, using the distribution's own logo
icon when there is no bundled logo, the average/maximum CPU temperature mode,
GPU detection that tolerates gaps in the GPU indices, and the context menu
action to unlock the logo scaling. The code in this repository is a separate
implementation.
