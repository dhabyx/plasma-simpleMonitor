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

    property alias cfg_coloredCpuLoad: coloredCpuLoadCheckBox.checked
    property alias cfg_flatCpuLoad: flatCpuLoadCheckBox.checked
    property alias cfg_indicatorHeight: indicatorHeightSpinBox.value
    property double cfg_updateInterval

    property bool cfg_coloredCpuLoadDefault
    property bool cfg_flatCpuLoadDefault
    property int cfg_indicatorHeightDefault
    property double cfg_updateIntervalDefault

    Kirigami.FormLayout {
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Style settings:")
        }

        QQC2.CheckBox {
            id: coloredCpuLoadCheckBox
            Kirigami.FormData.label: i18n("CPU load indicator style:")
            text: i18n("Colored")
        }
        QQC2.CheckBox {
            id: flatCpuLoadCheckBox
            text: i18n("Flat")
        }

        QQC2.SpinBox {
            id: indicatorHeightSpinBox
            Kirigami.FormData.label: i18n("CPU load indicator height:")
            from: 1
            to: 99
            editable: true
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Performance settings:")
        }

        // The interval is stored in seconds; the spin box works in tenths of a second.
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: i18n("Update interval:")
            from: 1
            to: 100
            stepSize: 1
            editable: true
            value: Math.round(root.cfg_updateInterval * 10)
            onValueModified: root.cfg_updateInterval = value / 10

            textFromValue: (value, locale) => Number(value / 10).toLocaleString(locale, 'f', 1)
                                              + i18nc("Abbreviation for seconds", "s")
            valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text.replace(/[^\d.,]/g, "")) * 10)
        }
    }
}
