import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property color accentColor
    required property string deckGroup
    required property int unitNumber
    readonly property string unitGroup: "[EffectRack1_EffectUnit" + unitNumber + "]"

    Mixxx.ControlProxy {
        id: assignmentControl

        group: root.unitGroup
        key: "group_" + root.deckGroup + "_enable"
    }
    Mixxx.ControlProxy {
        id: unitEnabledControl

        group: root.unitGroup
        key: "enabled"
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: 3

            EffectButton {
                required property int index

                Layout.fillHeight: true
                Layout.fillWidth: true
                accentColor: root.accentColor
                assigned: assignmentControl.value > 0
                deckGroup: root.deckGroup
                effectNumber: index + 1
                quickEffect: false
                unitEnabled: unitEnabledControl.value > 0
                unitNumber: root.unitNumber
            }
        }
        EffectButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            accentColor: root.accentColor
            assigned: true
            deckGroup: root.deckGroup
            effectNumber: 1
            quickEffect: true
            unitEnabled: true
            unitNumber: root.unitNumber
        }
    }
}
