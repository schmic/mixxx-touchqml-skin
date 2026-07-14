import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    required property color accentColor
    required property bool assigned
    required property string deckGroup
    required property int effectNumber
    required property bool quickEffect
    required property int unitNumber
    required property bool unitEnabled
    readonly property string buttonLabel: quickEffect ? qsTr("QUICK FX") : qsTr("FX%1").arg(effectNumber)
    readonly property string controlGroup: quickEffect ?
        "[QuickEffectRack1_" + deckGroup + "]" : effectSlot.group
    readonly property bool routeReady: quickEffect || (assigned && unitEnabled)
    readonly property var selectionModel: quickEffect ?
        Mixxx.EffectsManager.quickChainPresetModel :
        Mixxx.EffectsManager.visibleEffectsModel
    property Mixxx.EffectSlotProxy effectSlot: Mixxx.EffectsManager.getEffectSlot(
        unitNumber, effectNumber)
    property bool holdTriggered: false
    property int modelRevision: 0
    readonly property int selectionIndex: {
        const revision = modelRevision;
        if (quickEffect) {
            return Math.round(presetControl.value);
        }
        const count = selectionModel.rowCount();
        for (let i = 0; i < count; ++i) {
            if (selectionModel.get(i).effectId === effectSlot.effectId) {
                return i;
            }
        }
        return -1;
    }
    readonly property string effectName: {
        const revision = modelRevision;
        if (!routeReady) {
            return assigned ? qsTr("Unit Off") : qsTr("Unrouted");
        }
        if (selectionIndex >= 0 && selectionIndex < selectionModel.rowCount()) {
            return selectionModel.get(selectionIndex).display;
        }
        if (!quickEffect && effectSlot.effectId.length > 0) {
            return effectSlot.effectId;
        }
        return qsTr("No Effect");
    }
    readonly property bool active: enabledControl.value > 0

    function chooseEffect(index) {
        if (root.quickEffect) {
            presetControl.value = index;
        } else {
            root.effectSlot.effectId = root.selectionModel.get(index).effectId;
        }
        selector.close();
    }

    color: active ? Qt.darker(accentColor, effectTapHandler.pressed ? 1.8 : 2.5) : effectTapHandler.pressed ? TouchTheme.controlPressedBackground : TouchTheme.controlBackground
    enabled: enabledControl.initialized && routeReady
    opacity: enabled ? 1.0 : 0.45

    Mixxx.ControlProxy {
        id: enabledControl

        group: root.controlGroup
        key: "enabled"
    }
    Mixxx.ControlProxy {
        id: presetControl

        group: root.quickEffect ? root.controlGroup : "[QuickEffectRack1_" + root.deckGroup + "]"
        key: "loaded_chain_preset"
    }
    Connections {
        function onModelReset() {
            root.modelRevision++;
        }

        target: root.selectionModel
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: root.active ? root.accentColor : TouchTheme.border
        height: 1
        z: 2
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: root.active ? root.accentColor : TouchTheme.border
        height: 1
        z: 2
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        color: TouchTheme.border
        width: 1
        z: 2
    }
    Column {
        anchors.centerIn: parent
        spacing: 0
        width: parent.width - 12

        Text {
            color: root.active ? root.accentColor : TouchTheme.secondaryText
            elide: Text.ElideRight
            font.family: TouchTheme.fontFamily
            font.pixelSize: 9
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            text: root.buttonLabel
            width: parent.width
        }
        Text {
            color: root.routeReady ? TouchTheme.primaryText : TouchTheme.mutedText
            elide: Text.ElideRight
            font.family: TouchTheme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            text: root.effectName
            width: parent.width
        }
    }
    TapHandler {
        id: effectTapHandler

        enabled: root.enabled
        longPressThreshold: 0.25

        onLongPressed: {
            root.holdTriggered = true;
            selector.open();
        }
        onPressedChanged: {
            if (pressed) {
                root.holdTriggered = false;
            }
        }
        onTapped: {
            if (!root.holdTriggered) {
                enabledControl.value = enabledControl.value > 0 ? 0 : 1;
            }
            root.holdTriggered = false;
        }
    }
    Popup {
        id: selector

        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(420, parent.width - 32)
        height: Math.min(456, parent.height - 32)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        focus: true
        modal: true
        padding: 0

        background: Rectangle {
            border.color: root.accentColor
            border.width: 1
            color: TouchTheme.libraryBackground
        }
        contentItem: ListView {
            id: effectList

            clip: true
            model: root.selectionModel

            delegate: Rectangle {
                id: effectDelegate

                required property string display
                required property int index

                color: root.selectionIndex === index ? TouchTheme.controlPressedBackground : effectDelegateTap.pressed ? TouchTheme.controlPressedBackground : TouchTheme.controlBackground
                height: TouchTheme.minimumTouchSize
                width: effectList.width

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    color: root.selectionIndex === effectDelegate.index ? root.accentColor : TouchTheme.primaryText
                    elide: Text.ElideRight
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 15
                    font.weight: root.selectionIndex === effectDelegate.index ? Font.Bold : Font.Normal
                    text: effectDelegate.display
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    color: TouchTheme.border
                    height: 1
                    width: parent.width
                }
                TapHandler {
                    id: effectDelegateTap

                    onTapped: root.chooseEffect(effectDelegate.index)
                }
            }
        }
    }
}
