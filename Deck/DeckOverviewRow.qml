import "../Theme"
import QtQuick

Item {
    id: root

    required property real splitX

    height: TouchTheme.deckOverviewHeight

    DeckOverview {
        group: "[Channel1]"
        height: parent.height
        width: root.splitX
        x: 0
    }
    DeckOverview {
        group: "[Channel2]"
        height: parent.height
        width: root.width - root.splitX
        x: root.splitX
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        color: TouchTheme.centerDivider
        width: TouchTheme.centerDividerWidth
        x: root.splitX - width / 2
        z: 2
    }
}
