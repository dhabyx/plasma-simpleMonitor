/** Plasma 6.6 desktop adapter; private containment API may change. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import org.kde.plasma.private.containmentlayoutmanager as CL

QtObject {
    id: root
    property var appletItem
    property real targetWidth: 0
    property real targetHeight: 0
    readonly property var container: findContainer()
    readonly property bool supported: isSupported()
    property string result: "unsupported"
    signal retryRequested()

    function findContainer() {
        // Never infer ownership from a fixed parent depth or touch neighbours.
        for (let p = appletItem ? appletItem.parent : null; p; p = p.parent) {
            if (p instanceof CL.AppletContainer && p.applet === appletItem)
                return p
        }
        return null
    }
    function isSupported() {
        const box = container
        const layout = box && box.layout
        return !!layout && typeof layout.itemIsManaged === "function" &&
            typeof layout.releaseSpace === "function" && typeof layout.isRectAvailable === "function" &&
            typeof layout.positionItem === "function" && typeof layout.save === "function" &&
            layout.itemIsManaged(box)
    }
    property Connections editConnections: Connections {
        target: root.container
        ignoreUnknownSignals: true
        function onEditModeChanged() { if (root.container && !root.container.editMode) root.retryRequested() }
        function onDragActiveChanged() { if (root.container && !root.container.dragActive) root.retryRequested() }
    }
    function apply() {
        const box = container
        const layout = box && box.layout
        if (!isSupported()) {
            result = "unsupported"; return false
        }
        if (box.editMode || box.dragActive || layout.editMode) { result = "editing"; return false }
        if (!(targetWidth > 0 && targetHeight > 0 && layout.cellWidth > 0 && layout.cellHeight > 0)) {
            result = "invalid"; return false
        }
        const w = Math.ceil((targetWidth + box.leftPadding + box.rightPadding) / layout.cellWidth) * layout.cellWidth
        const h = Math.ceil((targetHeight + box.topPadding + box.bottomPadding) / layout.cellHeight) * layout.cellHeight
        const old = {x: box.x, y: box.y, w: box.width, h: box.height}
        if (old.w === w && old.h === h) { result = "ok"; return true }
        // Never shrink below the required content or intrude into another item.
        if (old.x < 0 || old.y < 0 || old.x + w > layout.width || old.y + h > layout.height) {
            result = "no-space"; return false
        }
        let released = false
        try {
            layout.releaseSpace(box); released = true
            if (!layout.isRectAvailable(old.x, old.y, w, h)) {
                layout.positionItem(box); released = false
                result = "no-space"; return false
            }
            box.width = w; box.height = h
            layout.positionItem(box); released = false
            // positionItem can move items; fitting must never change their position.
            if (box.x !== old.x || box.y !== old.y || box.width !== w || box.height !== h) {
                layout.releaseSpace(box); released = true
                box.x = old.x; box.y = old.y; box.width = old.w; box.height = old.h
                layout.positionItem(box); released = false
                result = "no-space"; return false
            }
            layout.save()
            result = "ok"; return true
        } catch (e) {
            try {
                if (!released) layout.releaseSpace(box)
                box.x = old.x; box.y = old.y; box.width = old.w; box.height = old.h
                layout.positionItem(box)
            } catch (rollbackError) { console.warn("Desktop auto-fit rollback failed:", rollbackError) }
            result = "unsupported"; return false
        }
    }
}
