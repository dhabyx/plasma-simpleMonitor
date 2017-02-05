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
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import "../../code/code.js" as Code

Item {
    id: root

    Layout.fillHeight: true
    Layout.fillWidth: true

    implicitHeight: settingsLayout.implicitHeight
    implicitWidth: settingsLayout.implicitWidth

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    property alias cfg_skin: skinComboBox.currentIndex

    ColumnLayout {
        id: settingsLayout

        spacing: 2

        Row {
            spacing: 3

            Label {
                text: i18n("Skin:")
                anchors.verticalCenter: skinComboBox.verticalCenter
            }

            ComboBox {
                id: skinComboBox
                model: ["Default", "Column"]

                onCurrentIndexChanged: {
                    switch (currentIndex)  {
                    default:
                        print("unknown skinComboBox.currentIndex")
                        // fall through
                    case 0:
                        skinImage.source = "../../images/defaultSkin-preview.png"
                        break
                    case 1:
                        skinImage.source = "../../images/columnSkin-preview.png"
                        break
                    }
                }
            }
        }

        Label {
            text: i18n("preview:")
        }

        Image {
            id: skinImage
        }
    }
}
