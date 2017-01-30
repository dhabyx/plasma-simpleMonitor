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

Item {
    id: datePicker
    FontLoader{
        id: michroma
        source: "../fonts/Michroma/Michroma.ttf"
    }
    FontLoader {
        id: playBold
        source: "../fonts/Play/Play-Bold.ttf"
    }
    FontLoader {
        id: playRegular
        source: "../fonts/Play/Play-Regular.ttf"
    }
    
    Text {
        id: dayName
        text: "mie"
        font.pointSize: 14
        y:5
        x:5
        color: "white"
        font.capitalization: Font.AllLowercase
    }
    Text {
        id: dayNumber
        text: "25"
        font {
            family: michroma.name
            pointSize: 40
        }
        x: 0
        y: 5
        anchors.leftMargin: 0
        color: "#999"
    }
    Text {
        id: monthName
        text: "dic"
        anchors.left: dayNumber.right
        y:45
        font {
            family: playBold.name
            capitalization: Font.AllUppercase
            pointSize: 16
        }
        color: "white"
    }
    Text {
        id: hour
        text: "00:"
        anchors.left: dayNumber.right
        y:60
        font {
            family: playRegular.name
            pointSize: 30
        }
        color: "white"
    }
    Text {
        id: mins
        text: "00"
        anchors.left: hour.right
        y: 72
        font {
            family: playRegular.name
            pointSize: 20
        }
        color: "#cdde87"
    }
    Text {
        id: secs
        text: "00"
        anchors.left: mins.right
        y: 78
        font {
            family: playRegular.name
            pointSize: 15
        }
        color: "#ebff9d"
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            var dateTime = new Date()
            dayName.text = Qt.formatDateTime(dateTime,'ddd')
            dayNumber.text = Qt.formatDateTime(dateTime,'dd')
            monthName.text = Qt.formatDateTime(dateTime,'MMM')
            hour.text = Qt.formatDateTime(dateTime,'hh')+':'
            mins.text = Qt.formatDateTime(dateTime,'mm')+':'
            secs.text = Qt.formatDateTime(dateTime,'ss')
        }
    }


}
