pragma ComponentBehavior: Bound

import "../Theme"
import Mixxx 1.0 as Mixxx
import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    readonly property int commentColumnWidth: 190
    readonly property int durationColumnWidth: 52
    readonly property int genreColumnWidth: 120
    readonly property int keyColumnWidth: 42
    property var openSwipeRow: null
    readonly property int ratingColumnWidth: 72
    property url selectedUrl
    property var trackModel: null

    function applySearchFilter() {
        if (root.trackModel === null) {
            return;
        }
        if (root.openSwipeRow) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = "";
        const query = searchField.text.trim().toLocaleLowerCase();
        for (let i = filteredTrackModel.items.count - 1; i >= 0; --i) {
            const entry = filteredTrackModel.items.get(i);
            const track = entry.model.track;
            const searchableText = [track?.title, track?.artist, track?.genre, track?.comment, track?.keyText].map(value => String(value || "")).join(" ").toLocaleLowerCase();
            entry.inSearchResults = query.length === 0 || searchableText.includes(query);
        }
        trackList.positionViewAtBeginning();
    }
    function loadUrlIntoDeck(url, group) {
        if (!url || url.toString().length === 0) {
            return;
        }
        Mixxx.PlayerManager.getPlayer(group).loadTrackFromLocationUrl(url, false);
    }
    function loadUrlIntoNextAvailableDeck(url) {
        if (!url || url.toString().length === 0) {
            return;
        }
        Mixxx.PlayerManager.loadLocationUrlIntoNextAvailableDeck(url, false);
    }
    function selectTrack(url, row) {
        if (root.openSwipeRow && root.openSwipeRow !== row) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = url;
    }

    color: TouchTheme.libraryBackground

    Component.onCompleted: root.trackModel = sourceTree.allTracks()

    Mixxx.LibrarySourceTree {
        id: sourceTree

        visible: false

        // qmllint disable unresolved-type
        defaultColumns: [
            Mixxx.TrackListColumn {
                columnIdx: Mixxx.TrackListColumn.SQLColumns.Title
                label: qsTr("Title")
            }
        ]
        // qmllint enable unresolved-type
    }
    Timer {
        id: searchFilterTimer

        interval: 120

        onTriggered: root.applySearchFilter()
    }
    Connections {
        function onCountChanged() {
            searchFilterTimer.restart();
        }

        target: filteredTrackModel.items
    }
    DelegateModel {
        id: filteredTrackModel

        filterOnGroup: "searchResults"
        model: root.trackModel

        delegate: TrackRow {
            id: visualTrackRow

            commentColumnWidth: root.commentColumnWidth
            durationColumnWidth: root.durationColumnWidth
            genreColumnWidth: root.genreColumnWidth
            keyColumnWidth: root.keyColumnWidth
            ratingColumnWidth: root.ratingColumnWidth
            selected: root.selectedUrl.toString() === file_url.toString()
            width: trackList.width

            onLoadNextRequested: root.loadUrlIntoNextAvailableDeck(file_url)
            onLoadRequested: group => {
                root.selectTrack(file_url, visualTrackRow);
                root.loadUrlIntoDeck(file_url, group);
            }
            onMenuClosed: row => {
                if (root.openSwipeRow === row) {
                    root.openSwipeRow = null;
                }
            }
            onMenuOpenRequested: row => {
                if (root.openSwipeRow && root.openSwipeRow !== row) {
                    root.openSwipeRow.closeMenu();
                }
                root.openSwipeRow = row;
            }
            onSelectRequested: row => root.selectTrack(file_url, row)
        }
        groups: DelegateModelGroup {
            includeByDefault: true
            name: "searchResults"
        }
    }
    Rectangle {
        id: searchBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: TouchTheme.libraryHeaderBackground
        height: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            TextField {
                id: searchField

                Layout.fillWidth: true
                Layout.preferredHeight: TouchTheme.minimumTouchSize
                color: TouchTheme.primaryText
                font.family: TouchTheme.fontFamily
                font.pixelSize: 16
                leftPadding: 44
                placeholderText: qsTr("Search title, artist, genre, comment, or key")
                placeholderTextColor: TouchTheme.mutedText
                selectByMouse: true
                selectionColor: TouchTheme.deck1Accent

                background: Rectangle {
                    border.color: searchField.activeFocus ? TouchTheme.deck1Accent : TouchTheme.border
                    border.width: 1
                    color: TouchTheme.controlBackground

                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        height: TouchTheme.navigationIconSize
                        source: Qt.resolvedUrl("../Icons/search.svg")
                        sourceSize.height: TouchTheme.navigationIconSize
                        sourceSize.width: TouchTheme.navigationIconSize
                        width: TouchTheme.navigationIconSize
                    }
                }

                onTextChanged: searchFilterTimer.restart()
            }
            Rectangle {
                Layout.preferredHeight: TouchTheme.minimumTouchSize
                Layout.preferredWidth: visible ? 80 : 0
                border.color: TouchTheme.border
                border.width: 1
                color: clearTapHandler.pressed ? TouchTheme.controlPressedBackground : TouchTheme.controlBackground
                visible: searchField.text.length > 0

                Text {
                    anchors.centerIn: parent
                    color: TouchTheme.secondaryText
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    text: qsTr("CLEAR")
                }
                TapHandler {
                    id: clearTapHandler

                    onTapped: searchField.clear()
                }
            }
        }
    }
    Rectangle {
        id: columnHeader

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: searchBar.bottom
        color: TouchTheme.deckStatusAlternateBackground
        height: 30

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 64
            anchors.rightMargin: 16
            spacing: 12

            ColumnHeader {
                Layout.fillWidth: true
                label: qsTr("TRACK")
            }
            ColumnHeader {
                Layout.preferredWidth: root.ratingColumnWidth
                label: qsTr("RATING")
            }
            ColumnHeader {
                Layout.preferredWidth: root.genreColumnWidth
                label: qsTr("GENRE")
            }
            ColumnHeader {
                Layout.preferredWidth: root.commentColumnWidth
                label: qsTr("COMMENT")
            }
            ColumnHeader {
                Layout.preferredWidth: root.keyColumnWidth
                label: qsTr("KEY")
            }
            ColumnHeader {
                Layout.preferredWidth: root.durationColumnWidth
                horizontalAlignment: Text.AlignRight
                label: qsTr("TIME")
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: TouchTheme.border
            height: 1
        }
    }
    ListView {
        id: trackList

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: columnHeader.bottom
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: filteredTrackModel
        reuseItems: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }
    Text {
        anchors.centerIn: trackList
        color: TouchTheme.mutedText
        font.family: TouchTheme.fontFamily
        font.pixelSize: 18
        text: root.trackModel === null ? qsTr("Loading library…") : searchField.text.length > 0 ? qsTr("No matching tracks") : qsTr("No tracks in the library")
        visible: trackList.count === 0
    }

    component ColumnHeader: Text {
        required property string label

        color: TouchTheme.mutedText
        elide: Text.ElideRight
        font.family: TouchTheme.fontFamily
        font.pixelSize: 10
        font.weight: Font.DemiBold
        text: label
        verticalAlignment: Text.AlignVCenter
    }
}
