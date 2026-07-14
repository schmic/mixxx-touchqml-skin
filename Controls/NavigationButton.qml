import "../Theme"
import QtQuick

Rectangle {
    id: root

    property bool active: false
    property url iconSource
    required property string label

    signal triggered

    color: tapHandler.pressed || root.active ? TouchTheme.controlPressedBackground : "transparent"
    implicitHeight: TouchTheme.minimumTouchSize
    implicitWidth: 112
    opacity: root.enabled ? 1.0 : 0.45

    Row {
        anchors.centerIn: parent
        spacing: 8

        Image {
            antialiasing: true
            fillMode: Image.PreserveAspectFit
            height: TouchTheme.navigationIconSize
            mipmap: true
            opacity: root.active ? 1.0 : 0.82
            source: root.iconSource
            sourceSize.height: TouchTheme.navigationIconSize
            sourceSize.width: TouchTheme.navigationIconSize
            visible: root.iconSource.toString().length > 0
            width: TouchTheme.navigationIconSize
        }
        Text {
            color: root.active ? TouchTheme.primaryText : TouchTheme.secondaryText
            font.family: TouchTheme.fontFamily
            font.pixelSize: TouchTheme.navigationLabelSize
            font.weight: Font.DemiBold
            height: TouchTheme.navigationIconSize
            text: root.label
            verticalAlignment: Text.AlignVCenter
        }
    }
    TapHandler {
        id: tapHandler

        enabled: root.enabled

        onTapped: root.triggered()
    }
}
