import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    readonly property real actionWidth: TouchTheme.deckStatusActionMinimumWidth +
        (TouchTheme.deckStatusActionWidth - TouchTheme.deckStatusActionMinimumWidth) * root.layoutProgress
    readonly property var currentTrack: player?.currentTrack
    readonly property string displayArtist: root.loaded ?
        root.currentTrack?.artist || qsTr("Unknown artist") : ""
    readonly property string displayKey: root.loaded ? Mixxx.KeyUtils.keyToString(keyControl.value, keyNotationControl.value) : "--"
    readonly property string displayTitle: {
        if (!root.loaded) {
            return qsTr("No track loaded");
        }
        return root.currentTrack?.title || qsTr("Unknown title");
    }
    required property string group
    readonly property real layoutProgress: Math.max(0, Math.min(1, (width - 512) / 448))
    readonly property bool loaded: player?.isLoaded ?? false
    readonly property var player: Mixxx.PlayerManager.getPlayer(root.group)
    readonly property real statusRightMargin: TouchTheme.deckStatusRightMargin * root.layoutProgress
    readonly property int syncModeExplicitLeader: 3
    required property string syncPartnerGroup

    function beatSizeText(value) {
        if (!root.loaded || value <= 0) {
            return "--";
        }
        if (value < 1) {
            return "1/" + Math.round(1 / value);
        }
        return Math.abs(value - Math.round(value)) < 0.001 ? Math.round(value).toString() : value.toFixed(1);
    }
    function remainingTimeText() {
        if (!root.loaded || durationControl.value <= 0) {
            return "--:--.-";
        }
        const remaining = Math.max(0, durationControl.value * (1 - playPositionControl.value));
        const minutes = Math.floor(remaining / 60);
        const seconds = Math.floor(remaining % 60);
        return "-" + minutes + ":" + seconds.toString().padStart(2, "0");
    }

    color: TouchTheme.deckStatusBackground
    height: TouchTheme.deckStatusHeight

    Mixxx.ControlProxy {
        id: bpmControl

        group: root.group
        key: "bpm"
    }
    Mixxx.ControlProxy {
        id: rateRatioControl

        group: root.group
        key: "rate_ratio"
    }
    Mixxx.ControlProxy {
        id: rateRangeControl

        group: root.group
        key: "rateRange"
    }
    Mixxx.ControlProxy {
        id: keyControl

        group: root.group
        key: "key"
    }
    Mixxx.ControlProxy {
        id: keyNotationControl

        group: "[Library]"
        key: "key_notation"
    }
    Mixxx.ControlProxy {
        id: durationControl

        group: root.group
        key: "duration"
    }
    Mixxx.ControlProxy {
        id: playPositionControl

        group: root.group
        key: "playposition"
    }
    Mixxx.ControlProxy {
        id: loopEnabledControl

        group: root.group
        key: "loop_enabled"
    }
    Mixxx.ControlProxy {
        id: reloopControl

        group: root.group
        key: "reloop_toggle"
    }
    Mixxx.ControlProxy {
        id: beatloopSizeControl

        group: root.group
        key: "beatloop_size"
    }
    Mixxx.ControlProxy {
        id: beatjumpSizeControl

        group: root.group
        key: "beatjump_size"
    }
    Mixxx.ControlProxy {
        id: beatjumpForwardControl

        group: root.group
        key: "beatjump_forward"
    }
    Mixxx.ControlProxy {
        id: syncEnabledControl

        group: root.group
        key: "sync_enabled"
    }
    Mixxx.ControlProxy {
        id: beatSyncControl

        group: root.group
        key: "beatsync"
    }
    Mixxx.ControlProxy {
        id: syncLeaderControl

        group: root.group
        key: "sync_leader"
    }
    Mixxx.ControlProxy {
        id: syncModeControl

        group: root.group
        key: "sync_mode"
    }
    Mixxx.ControlProxy {
        id: partnerSyncLeaderControl

        group: root.syncPartnerGroup
        key: "sync_leader"
    }
    Item {
        id: coverArtSlot

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        width: TouchTheme.deckStatusHeight

        Rectangle {
            id: coverArtPlaceholder

            anchors.centerIn: parent
            color: TouchTheme.controlBackground
            height: TouchTheme.deckStatusArtworkSize
            width: TouchTheme.deckStatusArtworkSize

            Rectangle {
                anchors.centerIn: parent
                border.color: TouchTheme.mutedText
                border.width: 2
                color: "transparent"
                height: 36
                radius: 18
                width: 36

                Rectangle {
                    anchors.centerIn: parent
                    color: TouchTheme.mutedText
                    height: 6
                    radius: 3
                    width: 6
                }
            }
            Image {
                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                source: root.loaded ? root.currentTrack?.coverArtUrl : ""
                sourceSize.height: TouchTheme.deckStatusArtworkSize
                sourceSize.width: TouchTheme.deckStatusArtworkSize
                visible: status === Image.Ready
            }
        }
    }
    Item {
        id: upperRow

        anchors.left: coverArtSlot.right
        anchors.right: parent.right
        anchors.top: parent.top
        height: TouchTheme.deckStatusRowHeight

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: root.statusRightMargin
            spacing: 0

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: TouchTheme.deckStatusRowHeight
                Layout.rightMargin: 8
                color: root.loaded ? TouchTheme.primaryText : TouchTheme.mutedText
                elide: Text.ElideRight
                font.family: TouchTheme.fontFamily
                font.pixelSize: 20
                font.weight: Font.DemiBold
                bottomPadding: 1
                text: root.displayTitle
                verticalAlignment: Text.AlignBottom
            }
            MetaValue {
                Layout.preferredWidth: 80 + 32 * root.layoutProgress
                fontPixelSize: 20
                text: root.remainingTimeText()
            }
            MetaValue {
                Layout.preferredWidth: 48 + 32 * root.layoutProgress
                accent: true
                fontPixelSize: 20
                text: root.displayKey.length > 0 ? root.displayKey : "--"
            }
            MetaValue {
                Layout.preferredWidth: 80 + 60 * root.layoutProgress
                fontPixelSize: 20
                text: root.loaded && bpmControl.value > 0 ? bpmControl.value.toFixed(1) : "--.-"
            }
        }
    }
    Item {
        id: lowerRow

        anchors.bottom: parent.bottom
        anchors.left: coverArtSlot.right
        anchors.right: parent.right
        height: TouchTheme.deckStatusRowHeight

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: root.statusRightMargin
            spacing: 8

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: TouchTheme.deckStatusRowHeight
                color: TouchTheme.mutedText
                elide: Text.ElideRight
                font.family: TouchTheme.fontFamily
                font.pixelSize: 16
                text: root.displayArtist
                topPadding: TouchTheme.deckStatusLowerContentTopMargin
                verticalAlignment: Text.AlignTop
            }
            PitchRangeCell {
                available: root.loaded
                pitchText: root.loaded ? ((rateRatioControl.value - 1) * 100).toFixed(1) : "--"
                rangeText: root.loaded ? (rateRangeControl.value * 100).toFixed(0) : "--"
            }
            IconValueCell {
                available: root.loaded
                iconSource: loopEnabledControl.value > 0 ? Qt.resolvedUrl("../Icons/loop-active.svg") : Qt.resolvedUrl("../Icons/loop.svg")
                interactive: true
                text: root.beatSizeText(beatloopSizeControl.value)
                textColor: loopEnabledControl.value > 0 ? TouchTheme.activeLoop : TouchTheme.mutedText

                onTriggered: reloopControl.trigger()
            }
            IconValueCell {
                available: root.loaded
                iconSource: Qt.resolvedUrl("../Icons/beatjump.svg")
                interactive: true
                text: root.beatSizeText(beatjumpSizeControl.value)

                onTriggered: beatjumpForwardControl.trigger()
            }
            Item {
                id: syncAction

                property bool holdActionTriggered: false

                Layout.preferredHeight: TouchTheme.deckStatusRowHeight
                Layout.preferredWidth: root.actionWidth
                opacity: !root.loaded ? 0.45 : syncTapHandler.pressed ? 0.62 : 1.0

                Timer {
                    id: syncHoldTimer

                    interval: 2000
                    repeat: false

                    onTriggered: {
                        syncAction.holdActionTriggered = true;
                        if (partnerSyncLeaderControl.value > 0) {
                            syncEnabledControl.value = 1;
                        } else {
                            syncModeControl.value = root.syncModeExplicitLeader;
                        }
                    }
                }
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: TouchTheme.deckStatusLowerContentTopMargin
                    spacing: 0

                    Text {
                        color: syncEnabledControl.value > 0 ? TouchTheme.activeSync : TouchTheme.mutedText
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("SYNC")
                        width: syncAction.width
                    }
                    Text {
                        color: syncLeaderControl.value > 0 ? TouchTheme.activeLeader : TouchTheme.mutedText
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("LEAD")
                        width: syncAction.width
                    }
                }
                TapHandler {
                    id: syncTapHandler

                    enabled: root.loaded

                    onPressedChanged: {
                        if (pressed) {
                            syncAction.holdActionTriggered = false;
                            syncHoldTimer.restart();
                        } else {
                            syncHoldTimer.stop();
                        }
                    }
                    onTapped: {
                        syncHoldTimer.stop();
                        if (syncAction.holdActionTriggered) {
                            syncAction.holdActionTriggered = false;
                            return;
                        }
                        beatSyncControl.trigger();
                    }
                }
            }
        }
    }

    component IconValueCell: Item {
        id: iconValueCell

        required property bool available
        required property url iconSource
        property bool interactive: false
        required property string text
        property color textColor: TouchTheme.mutedText

        signal triggered

        Layout.preferredHeight: TouchTheme.deckStatusRowHeight
        Layout.preferredWidth: root.actionWidth
        opacity: !available ? 0.45 : iconValueTapHandler.pressed ? 0.62 : 1.0

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: TouchTheme.deckStatusLowerContentTopMargin
            spacing: 4

            Image {
                antialiasing: true
                fillMode: Image.PreserveAspectFit
                height: TouchTheme.deckStatusIconSize
                mipmap: true
                source: iconValueCell.iconSource
                sourceSize.height: TouchTheme.deckStatusIconSize
                sourceSize.width: TouchTheme.deckStatusIconSize
                width: TouchTheme.deckStatusIconSize
            }
            Text {
                color: iconValueCell.textColor
                font.family: TouchTheme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                height: TouchTheme.deckStatusIconSize
                text: iconValueCell.text
                verticalAlignment: Text.AlignVCenter
            }
        }
        TapHandler {
            id: iconValueTapHandler

            enabled: iconValueCell.available && iconValueCell.interactive

            onTapped: iconValueCell.triggered()
        }
    }
    component PitchRangeCell: Item {
        id: pitchRangeCell

        required property bool available
        required property string pitchText
        required property string rangeText

        Layout.preferredHeight: TouchTheme.deckStatusRowHeight
        Layout.preferredWidth: root.actionWidth + 32
        opacity: available ? 1.0 : 0.45

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: TouchTheme.deckStatusLowerContentTopMargin
            spacing: 4

            Image {
                antialiasing: true
                fillMode: Image.PreserveAspectFit
                height: TouchTheme.deckStatusIconSize
                mipmap: true
                source: Qt.resolvedUrl("../Icons/pitch.svg")
                sourceSize.height: TouchTheme.deckStatusIconSize
                sourceSize.width: TouchTheme.deckStatusIconSize
                width: TouchTheme.deckStatusIconSize
            }
            Text {
                color: TouchTheme.mutedText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                height: TouchTheme.deckStatusIconSize
                text: pitchRangeCell.pitchText
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                color: TouchTheme.mutedText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                height: TouchTheme.deckStatusIconSize
                text: "/"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                color: TouchTheme.mutedText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                height: TouchTheme.deckStatusIconSize
                text: "±"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                color: TouchTheme.mutedText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                height: TouchTheme.deckStatusIconSize
                text: pitchRangeCell.rangeText
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    component MetaValue: Item {
        id: metaValue

        property bool accent: false
        property int fontPixelSize: 18
        required property string text

        Layout.preferredHeight: TouchTheme.deckStatusRowHeight

        Text {
            anchors.fill: parent
            bottomPadding: 1
            color: metaValue.accent ? TouchTheme.keyText : TouchTheme.primaryText
            elide: Text.ElideRight
            font.family: TouchTheme.fontFamily
            font.pixelSize: metaValue.fontPixelSize
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            text: metaValue.text
            verticalAlignment: Text.AlignBottom
        }
    }
}
