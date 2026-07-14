pragma ComponentBehavior: Bound

import "../Theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property real actionWidth: 192
    required property int commentColumnWidth
    required property url cover_art
    property real dragStartX: 0
    required property int durationColumnWidth
    required property url file_url
    required property int genreColumnWidth
    required property int index
    required property int keyColumnWidth
    property bool menuOpen: false
    required property int ratingColumnWidth
    property bool selected: false
    required property var track

    signal loadNextRequested
    signal loadRequested(string group)
    signal menuClosed(var row)
    signal menuOpenRequested(var row)
    signal selectRequested(var row)

    function closeMenu() {
        root.menuOpen = false;
        rowContent.x = 0;
        root.menuClosed(root);
    }
    function durationText(seconds) {
        if (!Number.isFinite(seconds) || seconds <= 0) {
            return "--:--";
        }
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = Math.floor(seconds % 60);
        return minutes + ":" + remainingSeconds.toString().padStart(2, "0");
    }
    function openMenu() {
        root.menuOpenRequested(root);
        root.menuOpen = true;
        rowContent.x = -root.actionWidth;
    }

    clip: true
    height: 56

    ListView.onPooled: root.closeMenu()
    ListView.onReused: root.closeMenu()

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.actionWidth

        SwipeLoadButton {
            accentColor: TouchTheme.deck1Accent
            height: parent.height
            label: qsTr("LOAD 1")
            width: root.actionWidth / 2

            onTriggered: {
                root.loadRequested("[Channel1]");
                root.closeMenu();
            }
        }
        SwipeLoadButton {
            accentColor: TouchTheme.deck2Accent
            height: parent.height
            label: qsTr("LOAD 2")
            width: root.actionWidth / 2

            onTriggered: {
                root.loadRequested("[Channel2]");
                root.closeMenu();
            }
        }
    }
    Rectangle {
        id: rowContent

        color: root.selected ? TouchTheme.libraryRowSelectedBackground : root.index % 2 === 0 ? TouchTheme.libraryRowBackground : TouchTheme.libraryRowAlternateBackground
        height: parent.height
        width: parent.width
        x: 0

        Behavior on x {
            enabled: !swipeDragHandler.active

            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: TouchTheme.border
            height: 1
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            color: root.selected ? TouchTheme.deck1Accent : "transparent"
            width: 3
        }
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color: TouchTheme.controlBackground
            height: 44
            width: 44

            Image {
                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                source: root.cover_art
                visible: status === Image.Ready
            }
        }
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Column {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    color: TouchTheme.primaryText
                    elide: Text.ElideRight
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    text: root.track?.title || qsTr("Untitled track")
                    width: parent.width
                }
                Text {
                    color: TouchTheme.secondaryText
                    elide: Text.ElideRight
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 13
                    text: root.track?.artist || qsTr("Unknown artist")
                    width: parent.width
                }
            }
            MetadataValue {
                Layout.preferredWidth: root.ratingColumnWidth
                text: root.track && root.track.stars > 0 ? root.track.stars + "/5" : "--"
            }
            MetadataValue {
                Layout.preferredWidth: root.genreColumnWidth
                text: root.track?.genre || "--"
            }
            MetadataValue {
                Layout.preferredWidth: root.commentColumnWidth
                text: root.track?.comment || "--"
            }
            MetadataValue {
                Layout.preferredWidth: root.keyColumnWidth
                color: TouchTheme.keyText
                text: root.track?.keyText || "--"
            }
            MetadataValue {
                Layout.preferredWidth: root.durationColumnWidth
                color: TouchTheme.secondaryText
                horizontalAlignment: Text.AlignRight
                text: root.durationText(root.track?.duration || 0)
            }
        }
        TapHandler {
            acceptedButtons: Qt.LeftButton

            onDoubleTapped: {
                if (root.menuOpen) {
                    root.closeMenu();
                    return;
                }
                root.selectRequested(root);
                root.loadNextRequested();
            }
            onTapped: {
                if (root.menuOpen) {
                    root.closeMenu();
                    return;
                }
                root.selectRequested(root);
            }
        }
        DragHandler {
            id: swipeDragHandler

            acceptedButtons: Qt.LeftButton
            target: null
            xAxis.enabled: true
            yAxis.enabled: false

            onActiveChanged: {
                if (active) {
                    root.dragStartX = rowContent.x;
                    root.selectRequested(root);
                } else if (rowContent.x <= -root.actionWidth * 0.35) {
                    root.openMenu();
                } else {
                    root.closeMenu();
                }
            }
            onTranslationChanged: {
                if (!active) {
                    return;
                }
                rowContent.x = Math.max(-root.actionWidth, Math.min(0, root.dragStartX + translation.x));
            }
        }
    }

    component MetadataValue: Text {
        color: TouchTheme.secondaryText
        elide: Text.ElideRight
        font.family: TouchTheme.fontFamily
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
    }
    component SwipeLoadButton: Rectangle {
        id: swipeLoadButton

        required property color accentColor
        required property string label

        signal triggered

        color: swipeLoadTapHandler.pressed ? TouchTheme.controlPressedBackground : TouchTheme.libraryHeaderBackground

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            color: swipeLoadButton.accentColor
            width: 2
        }
        Text {
            anchors.centerIn: parent
            color: swipeLoadButton.accentColor
            font.family: TouchTheme.fontFamily
            font.pixelSize: 14
            font.weight: Font.Bold
            text: swipeLoadButton.label
        }
        TapHandler {
            id: swipeLoadTapHandler

            onTapped: swipeLoadButton.triggered()
        }
    }
}
