import "../Deck" as Deck
import "../Theme"
import QtQuick

Rectangle {
    id: root

    readonly property real fixedControlsHeight: TouchTheme.deckOverviewHeight +
        TouchTheme.hotcueRowHeight * 2 +
        TouchTheme.hotcueWaveformSpacing * 2 +
        TouchTheme.effectRowTopSpacing + TouchTheme.effectRowHeight
    readonly property real deckWaveformHeight: Math.max(0,
        (height - fixedControlsHeight) / 2)
    required property real splitX

    color: TouchTheme.background

    Deck.DeckOverviewRow {
        id: overviewRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        splitX: root.splitX
    }
    MainWaveformRow {
        id: mainWaveforms

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: overviewRow.bottom
        deckWaveformHeight: root.deckWaveformHeight
        height: root.deckWaveformHeight * 2 + TouchTheme.hotcueRowHeight * 2 +
            TouchTheme.hotcueWaveformSpacing * 2
    }
    EffectRow {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: mainWaveforms.bottom
        anchors.topMargin: TouchTheme.effectRowTopSpacing
        height: TouchTheme.effectRowHeight
        splitX: root.splitX
    }
}
