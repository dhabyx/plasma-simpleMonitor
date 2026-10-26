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
import org.kde.ksysguard.sensors as Sensors

import "../../code/code.js" as Code

KCM.SimpleKCM {
    id: root

    property int cfg_logo
    property int cfg_bgColor
    property alias cfg_showGpuTemp: showGpuTempCheckBox.checked
    property alias cfg_showSwap: showSwapCheckBox.checked
    property alias cfg_showUptime: showUptimeCheckBox.checked
    property alias cfg_showNetwork: showNetworkCheckBox.checked
    property int cfg_netUnit
    property int cfg_tempUnit
    property int cfg_cpuTempMode
    property alias cfg_cpuHighTemp: cpuHighTempSpinBox.value
    property alias cfg_cpuCritTemp: cpuCritTempSpinBox.value

    // Defaults, required so "Restore defaults" works with the non-aliased values.
    property int cfg_logoDefault
    property int cfg_bgColorDefault
    property int cfg_tempUnitDefault
    property int cfg_cpuTempModeDefault
    property bool cfg_showGpuTempDefault
    property bool cfg_showSwapDefault
    property bool cfg_showUptimeDefault
    property bool cfg_showNetworkDefault
    property int cfg_netUnitDefault
    property int cfg_cpuHighTempDefault
    property int cfg_cpuCritTempDefault

    // Used to preview the logo of the "Default" choice.
    Sensors.Sensor { id: osNameSensor; sensorId: "os/system/name" }
    Sensors.Sensor { id: osPrettyNameSensor; sensorId: "os/system/prettyName" }
    Sensors.Sensor { id: osLogoSensor; sensorId: "os/system/logo" }
    readonly property string distroKey: Code.detectDistro([osLogoSensor.value, osNameSensor.value, osPrettyNameSensor.value])

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: logoComboBox
            Kirigami.FormData.label: i18n("Logo:")
            model: [i18n("Default"), i18n("Tux"), i18n("Slackware"), i18n("Ubuntu"), i18n("Kubuntu"),
                    i18n("OpenSUSE"), i18n("Manjaro"), i18n("Arch"), i18n("Fedora"), i18n("Debian"),
                    i18n("Linux Mint"), i18n("EndeavourOS"), i18n("Pop!_OS"), i18n("Zorin OS"), i18n("elementary OS"), i18n("NixOS"), i18n("Gentoo"), i18n("Alpine"), i18n("Void"), i18n("Rocky"), i18n("AlmaLinux"), i18n("Red Hat"), i18n("CentOS"), i18n("Kali")]
            currentIndex: root.cfg_logo
            onActivated: root.cfg_logo = currentIndex
        }

        Image {
            Kirigami.FormData.label: ""
            source: Qt.resolvedUrl("../../images/" + Code.getStandardLogo(root.cfg_logo, root.distroKey))
            sourceSize.height: 100
            fillMode: Image.PreserveAspectFit
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ButtonGroup {
            id: bgColorGroup
        }

        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("Background color:")
            QQC2.ButtonGroup.group: bgColorGroup
            text: i18n("Standard")
            checked: root.cfg_bgColor === 0
            onToggled: root.cfg_bgColor = 0
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: bgColorGroup
            text: i18n("Crystal")
            checked: root.cfg_bgColor === 1
            onToggled: root.cfg_bgColor = 1
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: bgColorGroup
            text: i18n("Translucent")
            checked: root.cfg_bgColor === 2
            onToggled: root.cfg_bgColor = 2
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showGpuTempCheckBox
            Kirigami.FormData.label: i18n("Show:")
            text: i18n("GPU Temperature")
        }
        QQC2.CheckBox {
            id: showSwapCheckBox
            text: i18n("Swap")
        }
        QQC2.CheckBox {
            id: showUptimeCheckBox
            text: i18n("Uptime")
        }
        QQC2.CheckBox {
            id: showNetworkCheckBox
            text: i18n("Network")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Network speed unit:")
            enabled: showNetworkCheckBox.checked
            model: [i18n("Bytes per second"), i18n("Bits per second")]
            currentIndex: root.cfg_netUnit
            onActivated: root.cfg_netUnit = currentIndex
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Temperature settings:")
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            text: i18n("You can use the <b>sensors</b> command to find the appropriate values for this section.")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            font.italic: true
        }

        QQC2.ButtonGroup {
            id: tempUnitGroup
        }

        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("Temperature units:")
            QQC2.ButtonGroup.group: tempUnitGroup
            text: i18n("Celsius °C")
            checked: root.cfg_tempUnit === 0
            onToggled: root.cfg_tempUnit = 0
        }
        QQC2.RadioButton {
            QQC2.ButtonGroup.group: tempUnitGroup
            text: i18n("Fahrenheit °F")
            checked: root.cfg_tempUnit === 1
            onToggled: root.cfg_tempUnit = 1
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("CPU temperature:")
            model: [i18n("Per core"), i18n("Average"), i18n("Maximum")]
            currentIndex: root.cfg_cpuTempMode
            onActivated: root.cfg_cpuTempMode = currentIndex
        }

        QQC2.SpinBox {
            id: cpuHighTempSpinBox
            Kirigami.FormData.label: i18n("CPU High Temperature:")
            from: 0
            to: 150
            editable: true
        }
        QQC2.SpinBox {
            id: cpuCritTempSpinBox
            Kirigami.FormData.label: i18n("CPU Critical Temperature:")
            from: 0
            to: 150
            editable: true
        }
    }
}
