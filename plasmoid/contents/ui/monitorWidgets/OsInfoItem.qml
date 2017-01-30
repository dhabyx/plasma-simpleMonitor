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

import QtQuick 1.1
import "js/monitorActions.js" as MonitorActions

Item {
    property string distroName : "tux"
    FontLoader {
        id: mondaRegular
        source: "../fonts/Monda/Monda-Regular.ttf"
    }

    Column {
        spacing: 1
        anchors.fill: parent
        Text {
            id: distroInfo
            text: "Distro "
            color: "white"
            width: parent.width
            lineHeight: 0.6
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
            Component.onCompleted: {
                var xhr = new XMLHttpRequest;
                xhr.open("GET", "/etc/os-release");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == XMLHttpRequest.DONE) {
                        var osInfo = MonitorActions.parseOsRelease(xhr.responseText)
                        if (osInfo.version.indexOf(',')>=0) {
                            var distroStr=osInfo.name+" "
                            distroStr +=osInfo.version.substring(0,osInfo.version.indexOf(','))+'\n'
                            distroStr +=osInfo.version.substring(
                                        osInfo.version.indexOf(',')+2,
                                        osInfo.version.length)
                            text = distroStr
                        } else
                            text = osInfo.name+" "+osInfo.version
                        distroName = osInfo.name
                    }
                }
                xhr.send();
            }
        }
        
        Text {
            id: kernelInfo
            text:"Kernel"
            color: "white"
            width: parent.width
            lineHeight: 0.6
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
            Component.onCompleted: {
                var xhr = new XMLHttpRequest;
                xhr.open("GET", "/proc/version");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == XMLHttpRequest.DONE) {
                        var kernelInfoArray = MonitorActions.parseKernelRelease(xhr.responseText)
                        text = kernelInfoArray.name+" "+kernelInfoArray.version
                    }
                }
                xhr.send();
            }
        }
    }
}
