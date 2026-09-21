import Mixxx 1.0 as Mixxx
import QtQuick
import "Theme"

Rectangle {
    id: root

    readonly property color backgroundColor: TouchTheme.background
    readonly property int progressBarWidth: 224

    required property int progress

    color: backgroundColor

    Accessible.name: Mixxx.Core.initializationService

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            color: TouchTheme.primaryText
            font.family: TouchTheme.fontFamily
            font.pixelSize: 24
            font.weight: Font.DemiBold
            text: qsTr("Touch QML")
        }

        Rectangle {
            color: TouchTheme.controlBackground
            height: 4
            width: root.progressBarWidth

            Rectangle {
                color: TouchTheme.deck1Accent
                height: parent.height
                width: parent.width * Math.min(100, Math.max(0, root.progress)) / 100
            }
        }
    }
}
