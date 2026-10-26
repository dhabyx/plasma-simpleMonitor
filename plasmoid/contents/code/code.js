/**
 * Copyright 2013-2016 Dhaby Xiloj, Konstantin Shtepa
 *
 * This file is part of plasma-simpleMonitor.
 *
 * plasma-simpleMonitor is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or any later version.
 *
 * plasma-simpleMonitor is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with plasma-simpleMonitor.  If not, see <http://www.gnu.org/licenses/>.
 **/

.pragma library

// Order matters: the logo selector in the configuration uses index + 1.
var logos = ["tux", "slackware", "ubuntu", "kubuntu", "opensuse", "manjaro", "arch", "fedora", "debian",
            "linuxmint", "endeavouros", "pop", "zorin", "elementary", "nixos", "gentoo",
            "alpine", "void", "rocky", "almalinux", "rhel", "centos", "kali"]

// Names (as found in the OS name, pretty name or LOGO icon of the system)
// mapped to the bundled logos. Derivatives without their own logo use the
// logo of the distribution they are based on.
var aliases = {
    "arch": "arch", "archlinux": "arch", "cachyos": "arch", "garuda": "arch",
    "arcolinux": "arch", "artix": "arch", "endeavouros": "endeavouros",
    "manjaro": "manjaro", "debian": "debian", "ubuntu": "ubuntu",
    "kubuntu": "kubuntu", "neon": "kubuntu", "fedora": "fedora",
    "opensuse": "opensuse", "suse": "opensuse", "sles": "opensuse",
    "slackware": "slackware", "linuxmint": "linuxmint", "mint": "linuxmint",
    "pop": "pop", "zorin": "zorin", "elementary": "elementary",
    "nixos": "nixos", "gentoo": "gentoo", "alpine": "alpine", "void": "void",
    "rocky": "rocky", "almalinux": "almalinux", "alma": "almalinux",
    "redhat": "rhel", "rhel": "rhel", "centos": "centos", "kali": "kali"
}

/**
 * Tries to find a bundled logo for the running distribution.
 * candidates: strings such as the OS name ("Ubuntu"), the pretty name or
 * the LOGO icon name from os-release ("distributor-logo-fedora").
 * Returns the logo key (e.g. "ubuntu") or "" if nothing matched.
 */
function detectDistro(candidates) {
    for (var i = 0; i < candidates.length; ++i) {
        var c = String(candidates[i] || "").toLowerCase().trim()
        if (c === "")
            continue
        // "Arch Linux", "distributor-logo-fedora", "Pop!_OS 24.04", "Red Hat Enterprise Linux"
        var tokens = c.split(/[^a-z0-9]+/)
        var compact = c.replace(/[^a-z0-9]/g, "")
        tokens.push(compact)
        for (var t = 0; t < tokens.length; ++t) {
            if (aliases.hasOwnProperty(tokens[t]))
                return aliases[tokens[t]]
        }
        for (var key in aliases) {
            if (key.length >= 5 && compact.indexOf(key) === 0)
                return aliases[key]
        }
    }
    return ""
}

/**
 * Returns the file name (inside contents/images) of the bundled logo to use,
 * or "" if none fits. logoId: 0 = automatic, n > 0 = logos[n - 1].
 */
function logoFile(logoId, distroKey) {
    if (logoId > 0 && logoId <= logos.length)
        return "distro-" + logos[logoId - 1] + ".svg"
    if (distroKey && logos.indexOf(distroKey) !== -1)
        return "distro-" + distroKey + ".svg"
    return ""
}

/** Same as logoFile() but falls back to Tux. */
function getStandardLogo(logoId, distroKey) {
    return logoFile(logoId, distroKey) || "distro-tux.svg"
}

/** Shortens "7.0.0-38-generic" to "7.0.0". */
function shortKernelVersion(version) {
    var v = String(version || "")
    var dash = v.indexOf('-')
    return dash > 0 ? v.substring(0, dash) : v
}

/** Number() that maps undefined/NaN to a fallback. */
function num(value, fallback) {
    var n = Number(value)
    return (value === undefined || value === null || isNaN(n)) ? fallback : n
}

/**
 * Shell command used to find the number of physical CPU cores (the sensors
 * only know about logical CPUs).
 */
var cpuCoresCommand = "grep -m1 'cpu cores' /proc/cpuinfo"

/**
 * Parses the "cpu cores" line of /proc/cpuinfo. Returns 0 when unknown.
 */
function parseCpuCores(text) {
    var match = /cpu cores\s*:\s*(\d+)/.exec(String(text))
    return match ? parseInt(match[1]) : 0
}

function toFahrenheit(celsius) {
    return celsius * 9 / 5 + 32
}
