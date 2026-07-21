import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick

Rectangle {
    id: root

    readonly property var cueData: {
        const revision = labelRevision;
        const model = currentTrack?.hotcuesModel;
        if (!model) {
            return null;
        }
        for (let i = 0; i < model.rowCount(); ++i) {
            const cue = model.get(i);
            if (cue.hotcueNumber === hotcueNumber - 1) {
                return cue;
            }
        }
        return null;
    }
    required property var currentTrack
    required property bool deckLoaded
    required property string group
    required property int hotcueNumber
    readonly property color hotcueColor: colorControl.value >= 0 ?
        "#" + Math.round(colorControl.value).toString(16).padStart(6, "0").slice(-6) :
        TouchTheme.border
    readonly property bool isSet: statusControl.value > 0
    property int labelRevision: 0

    color: hotcueTapHandler.pressed ? TouchTheme.controlPressedBackground : TouchTheme.controlBackground
    enabled: deckLoaded
    opacity: enabled ? 1.0 : 0.45

    Component.onDestruction: {
        if (activateControl.initialized) {
            activateControl.value = 0;
        }
    }
    onEnabledChanged: {
        if (!enabled && activateControl.initialized) {
            activateControl.value = 0;
        }
    }

    Mixxx.ControlProxy {
        id: activateControl

        group: root.group
        key: "hotcue_" + root.hotcueNumber + "_activate"
    }
    Mixxx.ControlProxy {
        id: colorControl

        group: root.group
        key: "hotcue_" + root.hotcueNumber + "_color"
    }
    Mixxx.ControlProxy {
        id: statusControl

        group: root.group
        key: "hotcue_" + root.hotcueNumber + "_status"
    }
    Connections {
        function onModelReset() {
            root.labelRevision++;
        }

        target: root.currentTrack?.hotcuesModel ?? null
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: root.isSet ? root.hotcueColor : TouchTheme.border
        height: TouchTheme.hotcueColorStripeHeight
        z: 2
    }
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: TouchTheme.hotcueColorStripeHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: root.isSet ? TouchTheme.primaryText : TouchTheme.secondaryText
        elide: Text.ElideRight
        font.family: TouchTheme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        text: root.cueData?.isLoop ? qsTr("LOOP %1").arg(root.hotcueNumber) : qsTr("CUE %1").arg(root.hotcueNumber)
        verticalAlignment: Text.AlignVCenter
    }
    TapHandler {
        id: hotcueTapHandler

        enabled: root.enabled

        onPressedChanged: {
            activateControl.value = pressed ? 1 : 0;
        }
    }
}
