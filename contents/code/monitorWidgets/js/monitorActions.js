/**
 * Copyright 2013-2014 Dhaby Xiloj
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

function modelAddData(model,index,value) {
    if (model.count <= index) {
        model.append(value)
    }
    else {
        model.set(index,value)
    }
}

function removeQuotes(value) {
    return String(value).replace(/["']/g,'')
}

function parseOsRelease(text){
    var arrayResult = []
    var textLineSplit =text.split('\n')
    for (i in textLineSplit)
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

    for (i in arrayResult)
        console.log(arrayResult[i])
    return arrayResult
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

function formatNumberLength(num, length) {
    var r = "" + num;
    while (r.length < length) {
        r = "0" + r;
    }
    return r;
}

function getLogoInfo() {
    var distrosLogoNames = ["logoTux", "logoTuz",
                            "logoSlackware", "logoUbuntu",
                            "logoKubuntu"]
    for (i in distrosLogoNames) {
        if (plasmoid.readConfig(distrosLogoNames[i]) == true) {
            return distrosLogoNames[i].replace("logo","").toLowerCase()
        }
    }
}

function configListener() {
    if (plasmoid.readConfig("standard") == true)
        plasmoid.setBackgroundHints(StandardBackground)
    else if (plasmoid.readConfig("crystal") == true)
        plasmoid.setBackgroundHints(NoBackground)
    else if (plasmoid.readConfig("translucent") == true)
        plasmoid.setBackgroundHints(TranslucentBackground)
    distroLogo.source = "monitorWidgets/images/distro-"+getLogoInfo()+".png"
    swapArea.visible=plasmoid.readConfig("showSwap")
    uptimePicker.visible=plasmoid.readConfig("showUptime")
    coreTempList.highTemp =plasmoid.readConfig("cpuHighTemp")
    coreTempList.criticalTemp =plasmoid.readConfig("cpuCritTemp")
    coreTempList.tempUnit = plasmoid.readConfig("fahrenheit")
}
