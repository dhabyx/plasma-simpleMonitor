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
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property int cfg_skin
    property int cfg_skinDefault

    readonly property var previews: [
        "../../images/defaultSkin-preview.png",
        "../../images/columnSkin-preview.png",
        "../../images/minimalisticSkin-preview.png"
    ]

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: skinComboBox
            Kirigami.FormData.label: i18n("Skin:")
            model: [i18n("Default"), i18n("Column"), i18n("Minimalistic")]
            currentIndex: root.cfg_skin
            onActivated: root.cfg_skin = currentIndex
        }

        Image {
            Kirigami.FormData.label: i18n("Preview:")
            source: root.previews[root.cfg_skin] || root.previews[0]
            fillMode: Image.PreserveAspectFit
        }
    }
}
