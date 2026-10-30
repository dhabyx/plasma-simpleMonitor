/** Content settings. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    property alias cfg_showLogo: logoCheck.checked
    property alias cfg_showDistroName: distroNameCheck.checked
    property alias cfg_showDistroVersion: distroVersionCheck.checked
    property alias cfg_showDistroCodename: distroCodenameCheck.checked
    property int cfg_distroLayout
    property alias cfg_showGpuTemp: gpuCheck.checked
    property alias cfg_showSwap: swapCheck.checked
    property alias cfg_showUptime: uptimeCheck.checked
    property alias cfg_showNetwork: networkCheck.checked
    property alias cfg_showCpuFrequency: frequencyCheck.checked
    property int cfg_dateVisibility
    property int cfg_timeVisibility
    property bool cfg_showLogoDefault
    property bool cfg_showDistroNameDefault
    property bool cfg_showDistroVersionDefault
    property bool cfg_showDistroCodenameDefault
    property int cfg_distroLayoutDefault
    property bool cfg_showGpuTempDefault
    property bool cfg_showSwapDefault
    property bool cfg_showUptimeDefault
    property bool cfg_showNetworkDefault
    property bool cfg_showCpuFrequencyDefault
    property int cfg_dateVisibilityDefault
    property int cfg_timeVisibilityDefault

    Kirigami.FormLayout {
        QQC2.CheckBox { id: logoCheck; Kirigami.FormData.label: i18n("Show:"); text: i18n("Distribution logo") }
        QQC2.CheckBox { id: distroNameCheck; Kirigami.FormData.label: i18n("Distribution information:"); text: i18n("Name") }
        QQC2.CheckBox { id: distroVersionCheck; text: i18n("Version") }
        QQC2.CheckBox { id: distroCodenameCheck; text: i18n("Codename") }
        QQC2.ComboBox {
            objectName: "distroLayoutSelector"
            Kirigami.FormData.label: i18n("Distribution layout:")
            enabled: (Number(root.cfg_showDistroName) + Number(root.cfg_showDistroVersion) + Number(root.cfg_showDistroCodename)) >= 2
            model: [i18n("One line"), i18n("One item per line")]
            currentIndex: root.cfg_distroLayout
            onActivated: root.cfg_distroLayout = currentIndex
        }
        QQC2.CheckBox { id: gpuCheck; text: i18n("GPU temperature") }
        QQC2.CheckBox { id: swapCheck; text: i18n("Swap") }
        QQC2.CheckBox { id: uptimeCheck; text: i18n("Uptime") }
        QQC2.CheckBox { id: networkCheck; text: i18n("Network") }
        QQC2.CheckBox { id: frequencyCheck; text: i18n("CPU frequency") }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Date:")
            model: [i18n("According to presentation"), i18n("Show"), i18n("Hide")]
            currentIndex: root.cfg_dateVisibility
            onActivated: root.cfg_dateVisibility = currentIndex
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Time:")
            model: [i18n("According to presentation"), i18n("Show"), i18n("Hide")]
            currentIndex: root.cfg_timeVisibility
            onActivated: root.cfg_timeVisibility = currentIndex
        }
        QQC2.Button {
            Kirigami.FormData.label: ""
            text: i18n("Restore page defaults")
            onClicked: {
                root.cfg_showLogo = root.cfg_showLogoDefault
                root.cfg_showDistroName = root.cfg_showDistroNameDefault
                root.cfg_showDistroVersion = root.cfg_showDistroVersionDefault
                root.cfg_showDistroCodename = root.cfg_showDistroCodenameDefault
                root.cfg_distroLayout = root.cfg_distroLayoutDefault
                root.cfg_showGpuTemp = root.cfg_showGpuTempDefault
                root.cfg_showSwap = root.cfg_showSwapDefault
                root.cfg_showUptime = root.cfg_showUptimeDefault
                root.cfg_showNetwork = root.cfg_showNetworkDefault
                root.cfg_showCpuFrequency = root.cfg_showCpuFrequencyDefault
                root.cfg_dateVisibility = root.cfg_dateVisibilityDefault
                root.cfg_timeVisibility = root.cfg_timeVisibilityDefault
            }
        }
    }
}
