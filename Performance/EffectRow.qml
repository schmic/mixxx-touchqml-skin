import "../Theme"
import QtQuick

Item {
    id: root

    required property real splitX

    DeckEffectRow {
        accentColor: TouchTheme.deck1Accent
        deckGroup: "[Channel1]"
        height: parent.height
        unitNumber: 1
        width: root.splitX
    }
    DeckEffectRow {
        accentColor: TouchTheme.deck2Accent
        deckGroup: "[Channel2]"
        height: parent.height
        unitNumber: 2
        width: root.width - root.splitX
        x: root.splitX
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        color: TouchTheme.border
        width: TouchTheme.centerDividerWidth
        x: root.splitX - width / 2
        z: 2
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.top: parent.top
        color: TouchTheme.border
        width: 1
        z: 2
    }
}
