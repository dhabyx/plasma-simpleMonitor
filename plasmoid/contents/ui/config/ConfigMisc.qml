/** Sensor settings. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    property int cfg_tempUnit
    property int cfg_cpuTempMode
    property alias cfg_groupCpuTemperatures: groupingCheck.checked
    property alias cfg_cpuHighTemp: highTemp.value
    property alias cfg_cpuCritTemp: criticalTemp.value
    property double cfg_updateInterval
    property int cfg_netUnit
    property alias cfg_showPing: pingCheck.checked
    property alias cfg_pingHost: pingHost.text
    // Read-only in this page: used for dependencies, not a duplicate control.
    property bool cfg_showNetwork
    property int cfg_tempUnitDefault
    property int cfg_cpuTempModeDefault
    property bool cfg_groupCpuTemperaturesDefault
    property int cfg_cpuHighTempDefault
    property int cfg_cpuCritTempDefault
    property double cfg_updateIntervalDefault
    property int cfg_netUnitDefault
    property bool cfg_showPingDefault
    property string cfg_pingHostDefault
    property bool cfg_showNetworkDefault

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Temperature units:")
            model: [i18n("Celsius °C"), i18n("Fahrenheit °F")]
            currentIndex: root.cfg_tempUnit
            onActivated: root.cfg_tempUnit = currentIndex
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("CPU temperature:")
            model: [i18n("Per logical CPU"), i18n("Average"), i18n("Maximum")]
            currentIndex: root.cfg_cpuTempMode
            onActivated: root.cfg_cpuTempMode = currentIndex
        }
        QQC2.CheckBox {
            id: groupingCheck
            objectName: "groupCpuTemperaturesCheck"
            Kirigami.FormData.label: i18n("CPU grouping:")
            text: i18n("Group logical CPUs by physical core")
            enabled: root.cfg_cpuTempMode === 0
        }
        QQC2.Label {
            text: i18n("When CPUs change, use Refresh CPU grouping from the widget menu. Topology is read once.")
            visible: groupingCheck.checked
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }
        QQC2.Label {
            text: i18n("Some logical CPUs may share a temperature sensor.")
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }
        QQC2.SpinBox { id: highTemp; Kirigami.FormData.label: i18n("CPU High Temperature:"); from: 0; to: 150; editable: true }
        QQC2.SpinBox { id: criticalTemp; Kirigami.FormData.label: i18n("CPU Critical Temperature:"); from: 0; to: 150; editable: true }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Update interval:")
            from: 1; to: 100; stepSize: 1; editable: true
            value: Math.round(root.cfg_updateInterval * 10)
            onValueModified: root.cfg_updateInterval = value / 10
            textFromValue: (value, locale) => Number(value / 10).toLocaleString(locale, 'f', 1) + i18nc("Abbreviation for seconds", "s")
            valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text.replace(/[^\d.,]/g, "")) * 10)
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Network speed unit:")
            enabled: root.cfg_showNetwork
            model: [i18n("Bytes per second"), i18n("Bits per second")]
            currentIndex: root.cfg_netUnit
            onActivated: root.cfg_netUnit = currentIndex
        }
        QQC2.CheckBox { id: pingCheck; enabled: root.cfg_showNetwork; Kirigami.FormData.label: i18n("Network:"); text: i18n("Ping") }
        QQC2.TextField { id: pingHost; enabled: root.cfg_showNetwork && pingCheck.checked; Kirigami.FormData.label: i18n("Host to ping:"); placeholderText: "1.1.1.1" }
        QQC2.Button {
            Kirigami.FormData.label: ""
            text: i18n("Restore page defaults")
            onClicked: {
                root.cfg_tempUnit = root.cfg_tempUnitDefault
                root.cfg_cpuTempMode = root.cfg_cpuTempModeDefault
                root.cfg_groupCpuTemperatures = root.cfg_groupCpuTemperaturesDefault
                root.cfg_cpuHighTemp = root.cfg_cpuHighTempDefault
                root.cfg_cpuCritTemp = root.cfg_cpuCritTempDefault
                root.cfg_updateInterval = root.cfg_updateIntervalDefault
                root.cfg_netUnit = root.cfg_netUnitDefault
                root.cfg_showPing = root.cfg_showPingDefault
                root.cfg_pingHost = root.cfg_pingHostDefault
            }
        }
    }
}
