import "../Theme"
import QtQuick

Item {
    id: root

    required property real deckWaveformHeight

    DeckHotcueGrid {
        id: deck1Hotcues

        anchors.top: parent.top
        group: "[Channel1]"
        height: TouchTheme.hotcueRowHeight
        width: root.width
    }
    DeckWaveform {
        id: deck1Waveform

        anchors.top: deck1Hotcues.bottom
        anchors.topMargin: TouchTheme.hotcueWaveformSpacing
        accentColor: TouchTheme.deck1Accent
        group: "[Channel1]"
        height: root.deckWaveformHeight
        width: root.width
    }
    DeckWaveform {
        id: deck2Waveform

        anchors.top: deck1Waveform.bottom
        accentColor: TouchTheme.deck2Accent
        group: "[Channel2]"
        height: root.deckWaveformHeight
        width: root.width
    }
    DeckHotcueGrid {
        anchors.top: deck2Waveform.bottom
        anchors.topMargin: TouchTheme.hotcueWaveformSpacing
        group: "[Channel2]"
        height: TouchTheme.hotcueRowHeight
        width: root.width
    }
}
