import "../Theme"
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls
import QtQuick

Rectangle {
    id: root

    required property string group
    readonly property var player: Mixxx.PlayerManager.getPlayer(root.group)

    clip: true
    color: TouchTheme.overviewBackground
    height: TouchTheme.deckOverviewHeight

    MixxxControls.WaveformOverview {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.margins: 2
        channels: Mixxx.WaveformOverview.Channels.LeftChannel
        colorHigh: TouchTheme.waveformHigh
        colorLow: TouchTheme.waveformLow
        colorMid: TouchTheme.waveformMid
        group: root.group
        opacity: root.player?.isLoaded ? 1.0 : 0.25
        renderer: Mixxx.WaveformOverview.Renderer.RGB

        Repeater {
            model: 8

            OverviewHotcuePointer {
                required property int index

                anchors.fill: parent
                group: root.group
                hotcueNumber: index + 1
            }
        }
    }
}
