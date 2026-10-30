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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2


Item {
    id: root
    property bool compactLayout: false
    property string autoFitIssue: ""
    property string cpuGroupingIssue: ""
    property string distroName: ""
    property string distroVersion: ""
    property string distroCodename: ""
    property bool showDistroName: true
    property bool showDistroVersion: true
    property bool showDistroCodename: true
    property int distroLayout: 0

    readonly property string distroText: {
        const fields = []
        if (showDistroName && distroName.trim()) fields.push(distroName.trim())
        if (showDistroVersion && distroVersion.trim()) fields.push(distroVersion.trim())
        if (showDistroCodename && distroCodename.trim()) fields.push(distroCodename.trim())
        return fields.join(distroLayout === 1 ? "\n" : " ")
    }

    property string kernelName: ""
    property string kernelVersion: ""

    // Keep long distribution names from widening the entire skin.
    implicitWidth: 180
    implicitHeight: infoColumn.implicitHeight + (compactLayout ? 8 : 16)

    FontLoader {
        id: mondaRegular
        source: "../../fonts/Monda/Monda-Regular.ttf"
    }

    ColumnLayout {
        id: infoColumn

        spacing: root.compactLayout ? 2 : 4
        anchors.fill: parent
        anchors.leftMargin: root.compactLayout ? 8 : 12
        anchors.rightMargin: root.compactLayout ? 8 : 12
        anchors.topMargin: root.compactLayout ? 4 : 8
        anchors.bottomMargin: root.compactLayout ? 4 : 8

        Text {
            id: distroInfo
            text: root.distroText
            visible: text.length > 0
            color: "white"

            lineHeight: 1.1
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 2
        Text {
            id: kernelInfo
            text: kernelName + " " + kernelVersion
            Layout.fillWidth: true
            elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit
            minimumPointSize: 8
            color: "white"
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
        }
        Text {
            visible: root.cpuGroupingIssue !== ""
            text: "⚠"
            color: "#ffc766"
            font.pixelSize: 14
            QQC2.ToolTip.visible: cpuGroupHover.hovered
            QQC2.ToolTip.text: !visible ? "" : root.cpuGroupingIssue === "stale"
                ? i18n("CPU list changed. Using logical CPUs; use Refresh CPU grouping in the widget menu.")
                : root.cpuGroupingIssue === "incomplete"
                    ? i18n("CPU topology is incomplete. Unknown CPUs remain separate.")
                    : i18n("CPU grouping is unavailable. Using logical CPUs; retry from the widget menu.")
            HoverHandler { id: cpuGroupHover }
        }
        Text {
            visible: root.autoFitIssue !== ""
            text: "⚠"
            color: "#ffc766"
            font.pixelSize: 14
            QQC2.ToolTip.visible: warningHover.hovered
            QQC2.ToolTip.text: !visible ? "" : root.autoFitIssue === "no-space"
                ? i18n("Not enough space to fit. Free space or disable automatic fitting.")
                : i18n("Automatic fitting is unavailable in this host; you can resize manually.")
            HoverHandler { id: warningHover }
        }
        }
    }
}
