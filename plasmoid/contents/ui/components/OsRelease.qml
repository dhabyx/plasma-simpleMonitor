/** SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import "../../code/code.js" as Code

// A fixed, read-only command. Its output is parsed as data, not executed.
QtObject {
    id: root
    property var info: ({name: "", version: "", codename: ""})
    readonly property string command: "if [ -r /etc/os-release ]; then cat /etc/os-release; elif [ -r /usr/lib/os-release ]; then cat /usr/lib/os-release; fi"
    Component.onCompleted: source.connectSource(command)
    property Plasma5Support.DataSource source: Plasma5Support.DataSource {
        engine: "executable"
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            root.info = Code.parseOsRelease(data["stdout"] || "")
        }
    }
}
