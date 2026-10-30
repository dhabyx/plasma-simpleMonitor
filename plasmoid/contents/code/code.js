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
            "alpine", "void", "rocky", "almalinux", "rhel", "centos", "kali", "blackpanther", "neon"]

// Names (as found in the OS name, pretty name or LOGO icon of the system)
// mapped to the bundled logos. Derivatives without their own logo use the
// logo of the distribution they are based on.
var aliases = {
    "arch": "arch", "archlinux": "arch", "cachyos": "arch", "garuda": "arch",
    "arcolinux": "arch", "artix": "arch", "endeavouros": "endeavouros",
    "manjaro": "manjaro", "debian": "debian", "ubuntu": "ubuntu",
    "kubuntu": "kubuntu", "neon": "neon", "blackpanther": "blackpanther", "fedora": "fedora",
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

// Route lookup for a public address: gives the interface and the local IP of
// the connection in use, without sending any packet.
var netRouteCommand = "ip -o route get 1.1.1.1"

/**
 * Parses the output of netRouteCommand. Returns {iface, ip}, both empty when
 * there is no route.
 */
function parseNetRoute(text) {
    var dev = /\bdev\s+(\S+)/.exec(String(text))
    var src = /\bsrc\s+(\S+)/.exec(String(text))
    return { iface: dev ? dev[1] : "", ip: src ? src[1] : "" }
}

/**
 * Command that pings host once. Returns "" when host is not a plain host
 * name or address, because the command goes through a shell.
 */
function pingCommand(host) {
    host = String(host).trim()
    if (!/^[A-Za-z0-9][A-Za-z0-9.:-]*$/.test(host))
        return ""
    return "LC_ALL=C ping -n -c 1 -W 2 " + host
}

/**
 * Round-trip time in milliseconds from the output of ping, or -1 when there
 * was no reply.
 */
function parsePing(text) {
    var match = /[=<]\s*([\d.]+)\s*ms/.exec(String(text))
    return match ? parseFloat(match[1]) : -1
}

function toFahrenheit(celsius) {
    return celsius * 9 / 5 + 32
}

/** Convert a finite positive frequency from the sensor's declared unit to Hz.
 * unitValues are KSysGuard's Hz, kHz, MHz, GHz, THz and PHz enums in order.
 * Return null for unavailable data or an unknown unit.
 */
function frequencyHz(value, unit, unitValues) {
    if (typeof value !== "number" || !isFinite(value) || value <= 0)
        return null
    var index = unitValues.indexOf(unit)
    if (index < 0 || index >= 6)
        return null
    var hz = value * Math.pow(1000, index)
    return isFinite(hz) ? hz : null
}

// Parse os-release as data, never as shell code. Only the quoting and escapes
// defined for os-release are interpreted; substitutions remain literal.
function parseOsRelease(text) {
    var values = {};
    String(text || "").split(/\r?\n/).forEach(function(line) {
        var match = line.match(/^\s*([A-Z][A-Z0-9_]*)=(.*)\s*$/);
        if (!match) return;
        var value = match[2].trim();
        if (value.charAt(0) === '"') {
            if (value.length < 2 || value.charAt(value.length - 1) !== '"') return;
            value = value.slice(1, -1).replace(/\\([\\"$`])/g, '$1');
        } else if (value.charAt(0) === "'") {
            if (value.length < 2 || value.charAt(value.length - 1) !== "'") return;
            value = value.slice(1, -1);
        } else if (/\s/.test(value)) {
            return;
        }
        values[match[1]] = value;
    });
    var versionLabel = values.VERSION || "";
    var parentheses = versionLabel.match(/\(([^()]*)\)\s*$/);
    var officialCodename = values.UBUNTU_CODENAME || values.VERSION_CODENAME || "";
    var label = parentheses ? parentheses[1].trim() : "";
    var firstWord = label.split(/\s+/)[0];
    var codename = officialCodename;
    if (officialCodename && label &&
        (label.toLowerCase() === officialCodename.toLowerCase() ||
         firstWord.toLowerCase() === officialCodename.toLowerCase()))
        codename = label;
    return {
        name: values.NAME || "",
        version: values.VERSION_ID || "",
        codename: codename
    };
}

function cpuSensorIds(paths, kind) {
    if (kind !== "usage" && kind !== "temperature" && kind !== "frequency") return [];
    var pattern = new RegExp("^cpu/cpu([0-9]+)/" + kind + "$");
    var seen = {}, result = [];
    for (var i = 0; i < paths.length; ++i) {
        var m = pattern.exec(String(paths[i]));
        if (!m) continue;
        var id = Number(m[1]);
        if (!seen[id]) { seen[id] = true; result.push(id); }
    }
    return result.sort(function(a,b) { return a-b; });
}
