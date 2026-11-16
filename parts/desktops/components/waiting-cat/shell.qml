import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    // Only create the window on the output named in $CAT_GIF_OVERLAY_OUTPUT
    model: Quickshell.screens.filter(s => s.name === Quickshell.env("CAT_GIF_OVERLAY_OUTPUT"))

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        readonly property int size:   parseInt(Quickshell.env("CAT_GIF_OVERLAY_SIZE")   || "64")
        readonly property int bottom: parseInt(Quickshell.env("CAT_GIF_OVERLAY_BOTTOM") || "18")
        readonly property int right:  parseInt(Quickshell.env("CAT_GIF_OVERLAY_RIGHT")  || "8")

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "gif-overlay"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors { bottom: true; right: true }
        margins { bottom: win.bottom; right: win.right }
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: size
        implicitHeight: size
        color: "transparent"
        mask: Region {}

        AnimatedImage {
            anchors.fill: parent
            source: "file://" + Quickshell.env("CAT_GIF_OVERLAY_SOURCE")
            fillMode: Image.PreserveAspectFit
            playing: win.visible
        }
    }
}
