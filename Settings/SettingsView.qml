import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: TouchTheme.background

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        VinylDeckSettings {
            Layout.fillHeight: true
            Layout.fillWidth: true
            accent: TouchTheme.deck1Accent
            deckName: qsTr("Deck 1")
            group: "[Channel1]"
        }
        VinylDeckSettings {
            Layout.fillHeight: true
            Layout.fillWidth: true
            accent: TouchTheme.deck2Accent
            deckName: qsTr("Deck 2")
            group: "[Channel2]"
        }
    }

    component VinylDeckSettings: Rectangle {
        id: deckSettings

        required property color accent
        required property string deckName
        required property string group

        color: TouchTheme.libraryHeaderBackground
        border.color: deckSettings.accent
        border.width: 1

        Mixxx.ControlProxy {
            id: vinylEnabledControl

            group: deckSettings.group
            key: "vinylcontrol_enabled"
        }
        Mixxx.ControlProxy {
            id: vinylModeControl

            group: deckSettings.group
            key: "vinylcontrol_mode"
        }
        Mixxx.ControlProxy {
            id: vinylCueingControl

            group: deckSettings.group
            key: "vinylcontrol_cueing"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                Layout.fillWidth: true
                color: TouchTheme.primaryText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 22
                font.weight: Font.DemiBold
                text: deckSettings.deckName
            }
            Text {
                Layout.fillWidth: true
                color: TouchTheme.secondaryText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 16
                text: qsTr("Vinyl Control")
            }
            SettingButton {
                Layout.fillWidth: true
                active: vinylEnabledControl.value > 0
                label: qsTr("Vinyl Control")

                onTriggered: vinylEnabledControl.parameter = vinylEnabledControl.value > 0 ? 0 : 1
            }
            Text {
                Layout.fillWidth: true
                color: TouchTheme.secondaryText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 16
                text: qsTr("Tracking Mode")
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                SettingButton {
                    Layout.fillWidth: true
                    active: vinylModeControl.value === 0
                    label: qsTr("ABS")

                    onTriggered: vinylModeControl.parameter = 0
                }
                SettingButton {
                    Layout.fillWidth: true
                    active: vinylModeControl.value === 1
                    label: qsTr("REL")

                    onTriggered: vinylModeControl.parameter = 1
                }
                SettingButton {
                    Layout.fillWidth: true
                    active: vinylModeControl.value === 2
                    label: qsTr("CONST")

                    onTriggered: vinylModeControl.parameter = 2
                }
            }
            Text {
                Layout.fillWidth: true
                color: TouchTheme.secondaryText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 16
                text: qsTr("Relative Cueing")
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                SettingButton {
                    Layout.fillWidth: true
                    active: vinylCueingControl.value === 0
                    label: qsTr("OFF")

                    onTriggered: vinylCueingControl.parameter = 0
                }
                SettingButton {
                    Layout.fillWidth: true
                    active: vinylCueingControl.value === 1
                    label: qsTr("ONE")

                    onTriggered: vinylCueingControl.parameter = 1
                }
                SettingButton {
                    Layout.fillWidth: true
                    active: vinylCueingControl.value === 2
                    label: qsTr("HOT")

                    onTriggered: vinylCueingControl.parameter = 2
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }

    component SettingButton: Rectangle {
        id: button

        property bool active: false
        required property string label

        signal triggered

        color: tapHandler.pressed || button.active ? TouchTheme.controlPressedBackground : TouchTheme.controlBackground
        implicitHeight: TouchTheme.minimumTouchSize

        Text {
            anchors.centerIn: parent
            color: button.active ? TouchTheme.primaryText : TouchTheme.secondaryText
            font.family: TouchTheme.fontFamily
            font.pixelSize: 16
            font.weight: Font.DemiBold
            text: button.label
        }
        TapHandler {
            id: tapHandler

            onTapped: button.triggered()
        }
    }
}
