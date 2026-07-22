import "../Theme"
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls
import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root

    required property string group

    clip: true
    color: TouchTheme.controlBackground
    implicitHeight: TouchTheme.minimumTouchSize
    implicitWidth: 320

    Mixxx.ControlProxy {
        id: playControl

        group: root.group
        key: "play"
    }
    Mixxx.ControlProxy {
        id: playIndicatorControl

        group: root.group
        key: "play_indicator"
    }
    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"
    }
    Rectangle {
        id: playButton

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        color: !enabled ? TouchTheme.controlBackground : playTapHandler.pressed ? TouchTheme.controlPressedBackground : playIndicatorControl.value > 0 ? TouchTheme.libraryRowSelectedBackground : TouchTheme.controlBackground
        enabled: trackLoadedControl.value > 0
        width: TouchTheme.minimumTouchSize

        Shape {
            anchors.centerIn: parent
            height: 20
            visible: playIndicatorControl.value <= 0
            width: 18

            ShapePath {
                fillColor: playButton.enabled ? TouchTheme.primaryText : TouchTheme.mutedText
                startX: 2
                startY: 0
                strokeColor: "transparent"

                PathLine {
                    x: 18
                    y: 10
                }
                PathLine {
                    x: 2
                    y: 20
                }
                PathLine {
                    x: 2
                    y: 0
                }
            }
        }
        Row {
            anchors.centerIn: parent
            spacing: 5
            visible: playIndicatorControl.value > 0

            Repeater {
                model: 2

                Rectangle {
                    color: TouchTheme.primaryText
                    height: 20
                    width: 5
                }
            }
        }
        TapHandler {
            id: playTapHandler

            enabled: playButton.enabled
            onTapped: playControl.value = playControl.value > 0 ? 0 : 1
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: playButton.right
        anchors.right: parent.right
        anchors.top: parent.top
        color: TouchTheme.overviewBackground

        MixxxControls.WaveformOverview {
            anchors.fill: parent
            anchors.margins: 2
            channels: Mixxx.WaveformOverview.Channels.LeftChannel
            colorHigh: TouchTheme.waveformHigh
            colorLow: TouchTheme.waveformLow
            colorMid: TouchTheme.waveformMid
            enabled: trackLoadedControl.value > 0
            group: root.group
            opacity: enabled ? 1.0 : 0.25
            renderer: Mixxx.WaveformOverview.Renderer.RGB
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: playButton.right
        anchors.top: parent.top
        color: TouchTheme.border
        width: 1
    }
    Rectangle {
        anchors.fill: parent
        border.color: TouchTheme.border
        border.width: 1
        color: "transparent"
    }
}
