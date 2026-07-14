import "Controls" as Controls
import "Theme"
import Mixxx 1.0 as Mixxx
import QtQuick

Item {
    id: root

    property date currentTime: new Date()
    required property real splitX

    height: TouchTheme.navigationBarHeight

    Mixxx.ControlProxy {
        id: libraryViewControl

        group: "[Skin]"
        key: "show_maximized_library"
    }
    Mixxx.ControlProxy {
        id: effectsViewControl

        group: "[Skin]"
        key: "show_effectrack"
    }
    Mixxx.ControlProxy {
        id: recordingStatusControl

        group: "[Recording]"
        key: "status"
    }
    Mixxx.ControlProxy {
        id: recordingToggleControl

        group: "[Recording]"
        key: "toggle_recording"
    }
    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: root.currentTime = new Date()
    }
    Rectangle {
        anchors.fill: parent
        color: TouchTheme.navigationBackground
    }
    Row {
        anchors.fill: parent
        spacing: 2

        Controls.NavigationButton {
            active: libraryViewControl.value > 0
            height: parent.height
            iconSource: Qt.resolvedUrl("Icons/browse.svg")
            label: qsTr("Browse")
            width: 112

            onTriggered: {
                const opening = libraryViewControl.value <= 0;
                effectsViewControl.value = 0;
                libraryViewControl.value = opening ? 1 : 0;
            }
        }
        Controls.NavigationButton {
            active: effectsViewControl.value > 0
            height: parent.height
            iconSource: Qt.resolvedUrl("Icons/touch-fx.svg")
            label: qsTr("Touch FX")
            width: 126

            onTriggered: {
                const opening = effectsViewControl.value <= 0;
                libraryViewControl.value = 0;
                effectsViewControl.value = opening ? 1 : 0;
            }
        }
    }
    Row {
        anchors.fill: parent
        anchors.leftMargin: Math.max(0, root.splitX)
        layoutDirection: Qt.RightToLeft
        spacing: 4

        Item {
            height: parent.height
            width: 82

            Text {
                anchors.centerIn: parent
                color: TouchTheme.primaryText
                font.family: TouchTheme.fontFamily
                font.pixelSize: TouchTheme.navigationLabelSize
                font.weight: Font.DemiBold
                height: TouchTheme.navigationIconSize
                text: Qt.formatTime(root.currentTime, "hh:mm")
                verticalAlignment: Text.AlignVCenter
            }
        }
        Item {
            height: parent.height
            visible: Mixxx.Battery.isBatteryAvailable
            width: visible ? 88 : 0

            Row {
                anchors.centerIn: parent
                spacing: 6

                Image {
                    antialiasing: true
                    fillMode: Image.PreserveAspectFit
                    height: TouchTheme.navigationIconSize
                    mipmap: true
                    source: Mixxx.Battery.isCharging ? "Icons/battery-charging.svg" : "Icons/battery.svg"
                    sourceSize.height: TouchTheme.navigationIconSize
                    sourceSize.width: TouchTheme.navigationIconSize
                    width: TouchTheme.navigationIconSize
                }
                Text {
                    color: TouchTheme.secondaryText
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 14
                    height: TouchTheme.navigationIconSize
                    text: Math.round(Mixxx.Battery.percentage) + "%"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Controls.NavigationButton {
            active: recordingStatusControl.value > 0
            height: parent.height
            iconSource: Qt.resolvedUrl("Icons/record.svg")
            label: recordingStatusControl.value > 0 ? Mixxx.Recording.durationText : qsTr("REC")
            width: recordingStatusControl.value > 0 ? 108 : 80

            onTriggered: recordingToggleControl.trigger()
        }
    }
    Rectangle {
        id: leftAccent

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: TouchTheme.deck1Accent
        height: TouchTheme.navigationAccentHeight
        width: root.splitX
    }
    Rectangle {
        id: rightAccent

        anchors.bottom: parent.bottom
        color: TouchTheme.deck2Accent
        height: TouchTheme.navigationAccentHeight
        width: root.width - root.splitX
        x: root.splitX
    }
}
