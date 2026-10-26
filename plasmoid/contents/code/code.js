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

// Distributions without their own logo that are based on one that has it.
var logoAliases = {
    "cachyos": "arch",
    "garuda": "arch",
    "arcolinux": "arch",
    "artix": "arch",
    "neon": "kubuntu",
    "opensuse-tumbleweed": "opensuse",
    "opensuse-leap": "opensuse",
    "opensuse-slowroll": "opensuse",
    "sles": "opensuse"
}

/**
 * Returns the file name (inside contents/images) of the distribution logo.
 * logoId: 0 = detect from distroName, n > 0 = logos[n - 1].
 */
function getStandardLogo(logoId, distroName) {
    var name = (distroName || "tux").toLowerCase()
    var index

    if (!logoId || logoId < 0) {
        name = logoAliases[name] || name
        index = logos.indexOf(name)
        if (index === -1)
            index = 0
    } else {
        index = (logoId - 1 < logos.length) ? logoId - 1 : 0
    }

    return "distro-" + logos[index] + ".svg"
}

function removeQuotes(value) {
    return String(value).replace(/["']/g, '')
}

/**
 * Parses the content of /etc/os-release.
 * Returns {name, id, idLike, version}.
 */
function parseOsRelease(text) {
    var result = { name: "", id: "tux", idLike: "", version: "" }
    var lines = String(text).split('\n')

    for (var i = 0; i < lines.length; ++i) {
        var pos = lines[i].indexOf('=')
        if (pos < 0)
            continue
        var key = lines[i].substring(0, pos)
        var value = removeQuotes(lines[i].substring(pos + 1))
        switch (key) {
        case "NAME":
            result.name = value
            break
        case "ID":
            result.id = value
            break
        case "ID_LIKE":
            result.idLike = value
            break
        case "VERSION":
            result.version = value
            break
        }
    }

    return result
}

/**
 * Parses the output of `uname -sr` ("Linux 6.8.0-45-generic").
 * Returns {name, version}.
 */
function parseKernelRelease(text) {
    var parts = String(text).trim().split(' ')
    var version = parts.length > 1 ? parts[1] : ""
    var dash = version.indexOf('-')

    return {
        name: parts[0] || "",
        version: dash >= 0 ? version.substring(0, dash) : version
    }
}

/**
 * Parses the "cpu cores" line of /proc/cpuinfo. Returns 0 when unknown.
 */
function parseCpuCores(text) {
    var match = /cpu cores\s*:\s*(\d+)/.exec(String(text))
    return match ? parseInt(match[1]) : 0
}

/**
 * Shell command used to collect static system information.
 * The three outputs are separated by a line with the separator below.
 */
var systemInfoSeparator = "@@simpleMonitor@@"
var systemInfoCommand = "cat /etc/os-release; echo '" + systemInfoSeparator + "'; "
                      + "uname -sr; echo '" + systemInfoSeparator + "'; "
                      + "grep -m1 'cpu cores' /proc/cpuinfo"

function parseSystemInfo(text) {
    var sections = String(text).split(systemInfoSeparator)
    return {
        os: parseOsRelease(sections[0] || ""),
        kernel: parseKernelRelease(sections[1] || ""),
        cpuCores: parseCpuCores(sections[2] || "")
    }
}

/**
 * Picks the distribution id used to choose the logo: the os-release ID when
 * there is a logo (or alias) for it, otherwise the first matching ID_LIKE.
 */
function resolveLogoId(os) {
    var candidates = [os.id].concat(String(os.idLike).split(' '))
    for (var i = 0; i < candidates.length; ++i) {
        var id = candidates[i].toLowerCase()
        if (logos.indexOf(id) >= 0 || logoAliases[id])
            return id
    }
    return os.id
}

function toFahrenheit(celsius) {
    return celsius * 9 / 5 + 32
}
