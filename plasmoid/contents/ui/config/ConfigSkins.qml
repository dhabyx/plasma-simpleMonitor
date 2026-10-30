/** Appearance settings. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.ksysguard.sensors as Sensors
import "../../code/code.js" as Code

KCM.SimpleKCM {
    id: root
    property int cfg_skin
    property int cfg_bgColor
    property int cfg_logo
    property string cfg_customLogo
    property bool cfg_compactLayout
    property bool cfg_autoFitContent
    property int cfg_cpuColumns
    property alias cfg_coloredCpuLoad: coloredCheck.checked
    property alias cfg_flatCpuLoad: flatCheck.checked
    property alias cfg_indicatorHeight: indicatorHeight.value
    // Content values are read only here to reflect the applied configuration in
    // the synthetic preview and to enable dependent controls.
    property bool cfg_showLogo
    property bool cfg_showCpuFrequency
    property bool cfg_showDistroName
    property bool cfg_showDistroVersion
    property bool cfg_showDistroCodename
    property int cfg_distroLayout
    property bool cfg_showGpuTemp
    property bool cfg_showSwap
    property bool cfg_showUptime
    property bool cfg_showNetwork
    property int cfg_dateVisibility
    property int cfg_timeVisibility
    property int cfg_skinDefault
    property int cfg_bgColorDefault
    property int cfg_logoDefault
    property string cfg_customLogoDefault
    property bool cfg_compactLayoutDefault
    property bool cfg_autoFitContentDefault
    property int cfg_cpuColumnsDefault
    property bool cfg_coloredCpuLoadDefault
    property bool cfg_flatCpuLoadDefault
    property int cfg_indicatorHeightDefault
    property bool cfg_showLogoDefault
    property bool cfg_showCpuFrequencyDefault
    property bool cfg_showDistroNameDefault
    property bool cfg_showDistroVersionDefault
    property bool cfg_showDistroCodenameDefault
    property int cfg_distroLayoutDefault
    property bool cfg_showGpuTempDefault
    property bool cfg_showSwapDefault
    property bool cfg_showUptimeDefault
    property bool cfg_showNetworkDefault
    property int cfg_dateVisibilityDefault
    property int cfg_timeVisibilityDefault

    Sensors.Sensor { id: osName; sensorId: "os/system/name" }
    Sensors.Sensor { id: osPretty; sensorId: "os/system/prettyName" }
    Sensors.Sensor { id: osLogo; sensorId: "os/system/logo" }
    readonly property string distroKey: Code.detectDistro([osLogo.value, osName.value, osPretty.value])

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Presentation:")
            model: [i18n("Default"), i18n("Column"), i18n("Minimalistic")]
            currentIndex: root.cfg_skin
            onActivated: root.cfg_skin = currentIndex
        }
        Preview {
            Kirigami.FormData.label: i18n("Preview:")
            skin: root.cfg_skin
            bgColor: root.cfg_bgColor
            logo: root.cfg_logo
            customLogo: root.cfg_customLogo
            distroKey: root.distroKey
            osLogoIcon: String(osLogo.value || "")
            compact: root.cfg_compactLayout
            columns: root.cfg_cpuColumns
            showLogo: root.cfg_showLogo
            showFrequency: root.cfg_showCpuFrequency
            showDistroName: root.cfg_showDistroName
            showDistroVersion: root.cfg_showDistroVersion
            showDistroCodename: root.cfg_showDistroCodename
            distroLayout: root.cfg_distroLayout
            showGpu: root.cfg_showGpuTemp
            showSwap: root.cfg_showSwap
            showUptime: root.cfg_showUptime
            showNetwork: root.cfg_showNetwork
            dateVisibility: root.cfg_dateVisibility
            timeVisibility: root.cfg_timeVisibility
            colored: root.cfg_coloredCpuLoad
        }
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Layout:")
            text: i18n("Compact")
            checked: root.cfg_compactLayout
            onClicked: root.cfg_compactLayout = checked
        }
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Size:")
            objectName: "autoFitContentCheck"
            text: i18n("Fit size to content")
            checked: root.cfg_autoFitContent
            onClicked: root.cfg_autoFitContent = checked
        }
        QQC2.Label {
            text: i18n("Disable this to resize manually. Available only in supported Plasma environments.")
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("CPU columns:")
            enabled: root.cfg_skin !== 2
            model: [i18n("Automatic"), "1", "2", "3", "4", "5", "6", "7", "8"]
            currentIndex: root.cfg_cpuColumns
            onActivated: root.cfg_cpuColumns = currentIndex
        }
        QQC2.Label {
            visible: root.cfg_skin === 2
            text: i18n("Minimalistic shows a CPU summary instead of per-core columns.")
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Background color:")
            model: [i18n("Standard"), i18n("Crystal"), i18n("Translucent")]
            currentIndex: root.cfg_bgColor
            onActivated: root.cfg_bgColor = currentIndex
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Logo:")
            enabled: root.cfg_showLogo
            model: [i18n("Default"), i18n("Tux"), i18n("Slackware"), i18n("Ubuntu"), i18n("Kubuntu"),
                    i18n("OpenSUSE"), i18n("Manjaro"), i18n("Arch"), i18n("Fedora"), i18n("Debian"),
                    i18n("Linux Mint"), i18n("EndeavourOS"), i18n("Pop!_OS"), i18n("Zorin OS"), i18n("elementary OS"), i18n("NixOS"), i18n("Gentoo"), i18n("Alpine"), i18n("Void"), i18n("Rocky"), i18n("AlmaLinux"), i18n("Red Hat"), i18n("CentOS"), i18n("Kali"), i18n("blackPanther OS"), i18n("KDE neon"), i18n("Custom")]
            currentIndex: root.cfg_logo
            onActivated: root.cfg_logo = currentIndex
        }
        FileDialog {
            id: logoDialog
            title: i18n("Choose a custom logo")
            nameFilters: [i18n("Images (*.svg *.png)")]
            onAccepted: {
                const url = selectedFile.toString()
                if (url.indexOf("file://") === 0) root.cfg_customLogo = url
            }
        }
        QQC2.Button {
            Kirigami.FormData.label: i18n("Custom logo:")
            visible: root.cfg_logo === Code.logos.length + 1
            enabled: root.cfg_showLogo
            text: i18n("Choose image…")
            onClicked: logoDialog.open()
        }
        LogoImage {
            Kirigami.FormData.label: ""
            enabled: root.cfg_showLogo
            implicitWidth: 100; implicitHeight: 100
            Rectangle { anchors.fill: parent; z: -1; color: "#30343a"; radius: 4 }
            readonly property bool custom: root.cfg_logo === Code.logos.length + 1
            readonly property string file: Code.logoFile(custom ? 0 : root.cfg_logo, root.distroKey)
            iconName: root.cfg_logo === 0 ? String(osLogo.value || "") : ""
            image.source: custom ? (root.cfg_customLogo.indexOf("file://") === 0 ? root.cfg_customLogo : "") : Qt.resolvedUrl("../../images/" + (file || "distro-tux.svg"))
            fallbackSource: Qt.resolvedUrl("../../images/" + (file || "distro-tux.svg"))
        }
        QQC2.CheckBox { id: coloredCheck; Kirigami.FormData.label: i18n("CPU load indicator style:"); text: i18n("Colored") }
        QQC2.CheckBox { id: flatCheck; text: i18n("Flat") }
        QQC2.SpinBox { id: indicatorHeight; Kirigami.FormData.label: i18n("CPU load indicator height:"); from: 1; to: 99; editable: true }
        QQC2.Button {
            Kirigami.FormData.label: ""
            text: i18n("Restore page defaults")
            onClicked: {
                root.cfg_skin = root.cfg_skinDefault
                root.cfg_bgColor = root.cfg_bgColorDefault
                root.cfg_logo = root.cfg_logoDefault
                root.cfg_customLogo = root.cfg_customLogoDefault
                root.cfg_compactLayout = root.cfg_compactLayoutDefault
                root.cfg_autoFitContent = root.cfg_autoFitContentDefault
                root.cfg_cpuColumns = root.cfg_cpuColumnsDefault
                root.cfg_coloredCpuLoad = root.cfg_coloredCpuLoadDefault
                root.cfg_flatCpuLoad = root.cfg_flatCpuLoadDefault
                root.cfg_indicatorHeight = root.cfg_indicatorHeightDefault
            }
        }
    }
}
