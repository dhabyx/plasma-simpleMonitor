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

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    LogoImage {
        id: distroLogo

        Layout.minimumWidth: (implicitWidth < implicitHeight) ? 100 * implicitWidth / implicitHeight : 100
        Layout.minimumHeight: (implicitHeight < implicitWidth) ? 100 * implicitHeight / implicitWidth : 100
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.alignment: Qt.AlignCenter

        image.source: Qt.resolvedUrl("../../images/" + Code.getStandardLogo(root.engine.logo, root.engine.distroId))

        fillScale: root.engine.logoScale
        onFillScaleChanged: if (fillScale !== root.engine.logoScale) root.engine.logoScale = fillScale
    }

    OsInfoItem {
        distroName: root.engine.distroName
        distroId: root.engine.distroId
        distroVersion: root.engine.distroVersion
        kernelName: root.engine.kernelName
        kernelVersion: root.engine.kernelVersion

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.topMargin: 2
        Layout.minimumHeight: implicitHeight
        Layout.maximumHeight: implicitHeight
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
    }
}
