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
import org.kde.kirigami as Kirigami

Item {
    id: root

    property real fillScale: 1.0
    // Name of a theme icon shown instead of the image (when not empty).
    property string iconName: ""
    property bool editMode: false
    property alias image: image

    onFillScaleChanged: {
        if (fillScale && fillScale <= 1.0)
            d.scale = fillScale
        else
            console.log("Error in LogoImage: fillScale set to " + fillScale)
    }

    QtObject {
        id: d
        property real scale: 1.0
    }

    implicitWidth: iconName !== "" ? 128 : image.implicitWidth
    implicitHeight: iconName !== "" ? 128 : image.implicitHeight

    Image {
        id: image
        visible: root.iconName === ""
        anchors.centerIn: parent
        width: parent.width * d.scale
        height: parent.height * d.scale
        fillMode: Image.PreserveAspectFit
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * d.scale
        height: width
        visible: root.iconName !== ""
        source: root.iconName
    }

    // Frame and handle shown while the scale of the logo can be changed.
    Rectangle {
        anchors.fill: image
        visible: root.editMode
        color: "transparent"
        border { width: 1; color: "black" }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            border { width: 1; color: "white" }
        }

        Image {
            anchors { right: parent.right; top: parent.top }
            source: "../../images/resize.svg"
            sourceSize: Qt.size(10, 10)

            MouseArea {
                id: resizeArea
                anchors.fill: parent
                cursorShape: pressed ? Qt.SizeBDiagCursor : Qt.ArrowCursor

                onPositionChanged: mouse => {
                    if (pressed) {
                        var p = mapToItem(root, mouse.x, mouse.y)
                        root.fillScale = Math.min(Math.max(0.3, Math.max(2 * p.x / root.width - 1.0,
                                                                         1.0 - 2 * p.y / root.height)), 1.0)
                    }
                }
            }
        }
    }
}
