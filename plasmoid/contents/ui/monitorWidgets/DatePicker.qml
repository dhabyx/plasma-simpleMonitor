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

import QtQuick 2.0
import QtQuick.Layouts 1.1

ColumnLayout {
    id: datePicker

    spacing: 0

    FontLoader{
        id: michroma
        source: "../../fonts/Michroma/Michroma.ttf"
    }
    FontLoader {
        id: playBold
        source: "../../fonts/Play/Play-Bold.ttf"
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
        }
    }
    
    Text {
        id: dayName
        text: i18n("mie")
        font.pointSize: 14
        color: "white"
        font.capitalization: Font.AllLowercase
        Layout.bottomMargin: -20
    }

    Row {
        id: rowMounth

        Text {
            id: dayNumber
//            height: 65
            text: "25"
            font {
                family: michroma.name
                pointSize: 40
            }
            color: "#999"
        }
        Text {
            id: monthName
            anchors.bottom: parent.bottom
            text: i18n("dic")
            font {
                family: playBold.name
                capitalization: Font.AllUppercase
                pointSize: 16
            }
            color: "white"
        }
    }
}
