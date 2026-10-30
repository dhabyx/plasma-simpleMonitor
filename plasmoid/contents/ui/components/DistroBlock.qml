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

import "../monitorWidgets"
import "../../code/code.js" as Code

// Distribution logo plus distribution and kernel information.
// Items declared inside are placed below the information.
ColumnLayout {
    id: root

    // The SystemData object.
    property QtObject engine
    property int blockSpacing: engine.compactLayout === true ? 2 : 4
    spacing: blockSpacing

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    LogoImage {
        id: distroLogo
        visible: root.engine.showLogo !== false

        // Fit landscape logos into a 160x100 area without enlarging the skin.
        // Square logos remain 100x100; preserve aspect ratio for all shapes.
        readonly property real aspect: implicitHeight > 0 ? implicitWidth / implicitHeight : 1
        Layout.minimumWidth: Math.min(160, 100 * aspect)
        Layout.minimumHeight: Math.min(100, 160 / aspect)
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.alignment: Qt.AlignCenter

        // An explicit choice wins; automatic prefers an installed theme icon.
        readonly property bool custom: root.engine.logo === Code.logos.length + 1
        readonly property string file: Code.logoFile(custom ? 0 : root.engine.logo, root.engine.distroKey)
        iconName: root.engine.logo === 0 ? root.engine.osLogoIcon : ""
        image.source: custom ? (root.engine.customLogo.indexOf("file://") === 0 ? root.engine.customLogo : "") : Qt.resolvedUrl("../../images/" + (file || "distro-tux.svg"))
        fallbackSource: Qt.resolvedUrl("../../images/" + (file || "distro-tux.svg"))
        editMode: root.engine.logoEditMode

        fillScale: root.engine.logoScale
        onFillScaleChanged: if (fillScale !== root.engine.logoScale) root.engine.logoScale = fillScale
    }

    OsInfoItem {
        compactLayout: root.engine.compactLayout === true
        autoFitIssue: root.engine.autoFitIssue || ""
        cpuGroupingIssue: root.engine.cpuGroupingIssue || ""
        distroName: root.engine.distroName
        distroVersion: root.engine.distroVersion
        distroCodename: root.engine.distroCodename || ""
        showDistroName: root.engine.showDistroName !== false
        showDistroVersion: root.engine.showDistroVersion !== false
        showDistroCodename: root.engine.showDistroCodename !== false
        distroLayout: root.engine.distroLayout || 0
        kernelName: root.engine.kernelName
        kernelVersion: root.engine.kernelVersion

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.topMargin: 2
        Layout.fillWidth: true
        Layout.minimumHeight: implicitHeight
        Layout.maximumHeight: implicitHeight
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
    }
}
