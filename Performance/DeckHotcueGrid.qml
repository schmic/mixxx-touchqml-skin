import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string group
    readonly property var player: Mixxx.PlayerManager.getPlayer(root.group)

    GridLayout {
        anchors.fill: parent
        columnSpacing: TouchTheme.hotcueButtonSpacing
        columns: 8
        rowSpacing: 0
        rows: 1

        Repeater {
            model: 8

            HotcueButton {
                required property int index

                Layout.column: index
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.row: 0
                currentTrack: root.player?.currentTrack
                deckLoaded: root.player?.isLoaded ?? false
                group: root.group
                hotcueNumber: index + 1
            }
        }
    }
}
