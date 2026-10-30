/** Opt-in windowed preview sizing. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import "autofit-policy.js" as Policy

QtObject {
    id: root
    property bool enabled: false
    property string applicationName: ""
    property var targetWindow: null
    property var ownerWindow: null
    property real contentWidth: 0
    property real contentHeight: 0
    readonly property bool supported: targetWindow && Policy.isWindowed(applicationName, String(targetWindow), targetWindow === ownerWindow)

    function requestFit() {
        if (enabled && supported) { if (!widthSettle.running) widthSettle.start(); if (!heightSettle.running) heightSettle.start() }
        else { widthSettle.stop(); heightSettle.stop() }
    }
    onEnabledChanged: requestFit()
    onSupportedChanged: requestFit()
    onContentWidthChanged: if (enabled && supported && !widthSettle.running) widthSettle.start()
    onContentHeightChanged: if (enabled && supported && !heightSettle.running) heightSettle.start()

    // Separate timers prevent frequently changing sensor labels from blocking
    // a stable change in the other dimension. A small width tolerance avoids
    // jitter when live numeric values change their number of digits.
    property Timer widthSettle: Timer {
        interval: 750
        onTriggered: {
            if (!root.enabled || !root.supported || !isFinite(root.contentWidth) || root.contentWidth <= 0) return
            const width = Math.ceil(root.contentWidth)
            if (Policy.shouldAdjustWidth(root.targetWindow.width, width)) root.targetWindow.width = width
        }
    }
    property Timer heightSettle: Timer {
        interval: 750
        onTriggered: {
            if (!root.enabled || !root.supported || !isFinite(root.contentHeight) || root.contentHeight <= 0) return
            const height = Math.ceil(root.contentHeight)
            if (height !== root.targetWindow.height) root.targetWindow.height = height
        }
    }
}
