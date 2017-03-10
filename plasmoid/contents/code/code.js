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

var logos = ["tux", "slackware", "ubuntu", "kubuntu", "opensuse", "manjaro", "arch", "fedora"]

function getStandardLogo(logoId, distroName) {
    if (typeof distroName === 'undefined')
        distroName = "tux"
    // logoId = 0 - default logo
    // distroId - id of default distr logo
    distroName = distroName.toLowerCase()
    if (logoId < 0)
        logoId = 0

    if (logoId === 0) {
        logoId = logos.indexOf(distroName);
        if (logoId === -1)
            logoId = 0
    } else {
        if (logos.length > logoId - 1)
            logoId -= 1
        else
            logoId = 0
    }

    return "../images/distro-" + logos[logoId] + ".svg"
}

function removeQuotes(value) {
    return String(value).replace(/["']/g,'');
}

function parseOsRelease(text){
    var arrayResult = []
    var textLineSplit = text.split('\n')
    for (var i in textLineSplit)
    {
        switch (textLineSplit[i].split('=')[0]) {
        case "NAME" :
            arrayResult["name"]=removeQuotes(textLineSplit[i].split('=')[1])
            break
        case "ID" :
            arrayResult["id"]=removeQuotes(textLineSplit[i].split('=')[1])
            break
        case "VERSION" :
            arrayResult["version"]=removeQuotes(textLineSplit[i].split('=')[1])
            break
        }
    }

    return arrayResult
}

function getDistroInfo(callback, thisArg) {
    var T
    if (this === null)
          throw new TypeError(' this is null or not defined');
    if (typeof callback !== 'function')
            throw new TypeError(callback + ' is not a function');
    if (arguments.length > 1)
          T = thisArg;

    var xhr = new XMLHttpRequest;
    xhr.open("GET", "/etc/os-release");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var arrayResult = parseOsRelease(xhr.responseText)
            callback.call(T, arrayResult)
        }
    }
    xhr.send();
}

function parseKernelRelease(text){
    var arrayResult = []
    var textLineSplit =text.split(' ')
    arrayResult["name"]=textLineSplit[0]
    if (textLineSplit[2].indexOf('-')>=0)
        textLineSplit[2]=textLineSplit[2].split('-')[0]
    arrayResult["version"]=textLineSplit[2]

    return arrayResult
}

function getKernelInfo(callback, thisArg) {
    var T
    if (this === null)
          throw new TypeError(' this is null or not defined');
    if (typeof callback !== 'function')
            throw new TypeError(callback + ' is not a function');
    if (arguments.length > 1)
          T = thisArg;

    var xhr = new XMLHttpRequest;
    xhr.open("GET", "/proc/version");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var arrayResult = parseKernelRelease(xhr.responseText)
            callback.call(T, arrayResult)
        }
    }
    xhr.send();
}
