import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    required property string group
    required property int hotcueNumber
    readonly property real markerX: trackSamplesControl.value > 0 ?
        width * positionControl.value / trackSamplesControl.value : -1
    readonly property color markerColor: colorControl.value >= 0 ?
        "#" + Math.round(colorControl.value).toString(16).padStart(6, "0").slice(-6) :
        TouchTheme.border

    visible: statusControl.value > 0 && positionControl.value >= 0 && markerX >= 0
    z: 3

    Shape {
        id: pointer

        readonly property real pointerTipX: Math.max(0, Math.min(width,
            root.markerX - x))

        antialiasing: true
        height: TouchTheme.overviewHotcuePointerHeight
        width: TouchTheme.overviewHotcuePointerWidth
        x: Math.max(0, Math.min(root.width - width,
            root.markerX - width / 2))
        y: 0

        ShapePath {
            fillColor: root.markerColor
            strokeColor: "transparent"
            startX: 0
            startY: 0

            PathLine {
                x: pointer.width
                y: 0
            }
            PathLine {
                x: pointer.pointerTipX
                y: pointer.height
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }
    Mixxx.ControlProxy {
        id: trackSamplesControl

        group: root.group
        key: "track_samples"
    }
    Mixxx.ControlProxy {
        id: statusControl

        group: root.group
        key: "hotcue_" + root.hotcueNumber + "_status"
    }
    Mixxx.ControlProxy {
        id: positionControl

        group: root.group
        key: "hotcue_" + root.hotcueNumber + "_position"
    }
    Mixxx.ControlProxy {
        id: colorControl

        group: root.group
        key: "hotcue_" + root.hotcueNumber + "_color"
    }
}
