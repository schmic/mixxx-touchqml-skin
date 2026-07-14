pragma Singleton

import QtQuick

QtObject {
    readonly property color activeLeader: "#6aa7ff"
    readonly property color activeLoop: "#77e84d"
    readonly property color activeSync: "#85d7ff"
    readonly property color background: "#080b0c"
    readonly property color border: "#3b4243"
    readonly property color centerDivider: "#090b0c"
    readonly property int centerDividerWidth: 1
    readonly property color controlBackground: "#171b1c"
    readonly property color controlPressedBackground: "#353c3d"
    readonly property color deck1Accent: "#4b8dff"
    readonly property color deck2Accent: "#7fe34a"
    readonly property int deckOverviewHeight: 88
    readonly property int deckStatusActionMinimumWidth: 56
    readonly property int deckStatusActionWidth: 64
    readonly property color deckStatusAlternateBackground: "#1d2223"
    readonly property int deckStatusArtworkSize: 64
    readonly property color deckStatusBackground: "#24292a"
    readonly property int deckStatusHeight: 72
    readonly property int deckStatusIconSize: 18
    readonly property int deckStatusLowerContentTopMargin: 6
    readonly property int deckStatusRightMargin: 40
    readonly property int deckStatusRowHeight: 36
    readonly property int effectRowHeight: 48
    readonly property int effectRowTopSpacing: 8
    readonly property string fontFamily: "Ubuntu"
    readonly property int hotcueButtonSpacing: 2
    readonly property int hotcueColorStripeHeight: 2
    readonly property int hotcueRowHeight: 32
    readonly property var hotcueSlotColors: [
        "#f8d200",
        "#f8a030",
        "#af00cc",
        "#c50a08",
        "#008800",
        "#32be44",
        "#42d4f4",
        "#0044ff"
    ]
    readonly property int hotcueWaveformSpacing: 2
    readonly property color keyText: "#ffd19a"
    readonly property color libraryBackground: "#0c1011"
    readonly property color libraryHeaderBackground: "#171c1d"
    readonly property color libraryRowAlternateBackground: "#111617"
    readonly property color libraryRowBackground: "#0d1213"
    readonly property color libraryRowSelectedBackground: "#30393a"
    readonly property int mainWaveformAccentWidth: 3
    readonly property real mainWaveformPlayMarkerPosition: 1 / 3
    readonly property int minimumTouchSize: 48
    readonly property color mutedText: "#707879"
    readonly property int navigationAccentHeight: 2
    readonly property color navigationBackground: "#202526"
    readonly property int navigationBarHeight: 48
    readonly property int navigationIconSize: 24
    readonly property int navigationLabelSize: 16
    readonly property color overviewBackground: "#050809"
    readonly property int overviewHotcuePointerHeight: 6
    readonly property int overviewHotcuePointerWidth: 9
    readonly property int persistentHeaderHeight: navigationBarHeight + deckStatusHeight
    readonly property color primaryText: "#f2f4f4"
    readonly property color recording: "#ff5656"
    readonly property color secondaryText: "#aeb7b8"
    readonly property int topStackHeight: navigationBarHeight + deckStatusHeight + deckOverviewHeight
    readonly property color waveformHigh: "#f4f5eb"
    readonly property color waveformLow: "#347dff"
    readonly property color waveformMid: "#66df55"
}
