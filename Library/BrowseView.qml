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
    property int selectedListIndex: -1
    property string selectedSourceLabel: qsTr("All Tracks")
    property url selectedUrl
    property var sourceModel: null
    property var trackModel: null

    function applySearchFilter() {
        if (root.trackModel === null) {
            return;
        }
        if (root.openSwipeRow) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = "";
        root.selectedListIndex = -1;
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
            return false;
        }
        Mixxx.PlayerManager.getPlayer(group).loadTrackFromLocationUrl(url, false);
        return true;
    }
    function loadUrlIntoNextAvailableDeck(url) {
        if (!url || url.toString().length === 0) {
            return;
        }
        Mixxx.PlayerManager.loadLocationUrlIntoNextAvailableDeck(url, false);
    }
    function loadSelectedIntoDeck(group) {
        return root.loadUrlIntoDeck(root.selectedUrl, group);
    }
    function moveSelection(direction) {
        const count = searchResultsGroup.count;
        if (count === 0) {
            return;
        }
        let nextIndex = root.selectedListIndex;
        if (nextIndex < 0) {
            nextIndex = direction > 0 ? 0 : count - 1;
        } else {
            nextIndex = Math.max(0, Math.min(count - 1, nextIndex + direction));
        }
        const entry = searchResultsGroup.get(nextIndex);
        root.selectedListIndex = nextIndex;
        root.selectedUrl = entry.model.file_url;
        trackList.positionViewAtIndex(nextIndex, ListView.Contain);
    }
    function activateSource(modelIndex, label) {
        if (root.openSwipeRow) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = "";
        root.selectedListIndex = -1;
        root.sourceModel.activate(modelIndex);
        root.trackModel = root.sourceModel.tracklist;
        root.selectedSourceLabel = label;
        searchFilterTimer.restart();
        trackList.positionViewAtBeginning();
    }
    function selectTrack(url, row) {
        if (root.openSwipeRow && root.openSwipeRow !== row) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = url;
        root.selectedListIndex = row.index;
    }

    color: TouchTheme.libraryBackground

    Component.onCompleted: {
        root.sourceModel = sourceTree.sidebar();
        root.activateSource(root.sourceModel.index(0, 0), qsTr("All Tracks"));
    }

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

        Mixxx.LibraryAllTrackSource {
            columns: sourceTree.defaultColumns
            label: qsTr("All Tracks")
        }
    }
    Mixxx.ControlProxy {
        id: libraryViewControl

        group: "[Skin]"
        key: "show_maximized_library"
    }
    Mixxx.ControlProxy {
        group: "[Library]"
        key: "SelectPrevTrack"

        onValueChanged: value => {
            if (value > 0) {
                root.moveSelection(-1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Library]"
        key: "SelectNextTrack"

        onValueChanged: value => {
            if (value > 0) {
                root.moveSelection(1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Channel1]"
        key: "LoadSelectedTrack"

        onValueChanged: value => {
            if (value > 0 && root.loadSelectedIntoDeck("[Channel1]")) {
                libraryViewControl.value = 0;
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Channel2]"
        key: "LoadSelectedTrack"

        onValueChanged: value => {
            if (value > 0 && root.loadSelectedIntoDeck("[Channel2]")) {
                libraryViewControl.value = 0;
            }
        }
    }
    Connections {
        function onTracklistChanged() {
            root.trackModel = root.sourceModel.tracklist;
            searchFilterTimer.restart();
        }

        target: root.sourceModel
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
            id: searchResultsGroup

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
            Rectangle {
                Layout.preferredHeight: TouchTheme.minimumTouchSize
                Layout.preferredWidth: 156
                border.color: sourcePicker.visible ? TouchTheme.deck1Accent : TouchTheme.border
                border.width: 1
                color: sourceButtonTap.pressed ? TouchTheme.controlPressedBackground : TouchTheme.controlBackground

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        height: 20
                        source: Qt.resolvedUrl("../Icons/browse.svg")
                        sourceSize.height: 20
                        sourceSize.width: 20
                        width: 20
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: TouchTheme.primaryText
                        elide: Text.ElideRight
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: root.selectedSourceLabel.toLocaleUpperCase()
                        width: 104
                    }
                }
                TapHandler {
                    id: sourceButtonTap

                    onTapped: sourcePicker.open()
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
    Popup {
        id: sourcePicker

        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(440, parent.width - 32)
        height: Math.min(520, parent.height - 32)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        focus: true
        modal: true
        padding: 0

        background: Rectangle {
            border.color: TouchTheme.deck1Accent
            border.width: 1
            color: TouchTheme.libraryBackground
        }
        contentItem: Item {
            Rectangle {
                id: sourcePickerHeader

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                color: TouchTheme.libraryHeaderBackground
                height: 56

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: closeSourcePicker.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: TouchTheme.primaryText
                    elide: Text.ElideRight
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    text: qsTr("Library Source")
                }
                Rectangle {
                    id: closeSourcePicker

                    anchors.right: parent.right
                    anchors.top: parent.top
                    color: closeSourcePickerTap.pressed ? TouchTheme.controlPressedBackground : "transparent"
                    height: parent.height
                    width: 56

                    Text {
                        anchors.centerIn: parent
                        color: TouchTheme.secondaryText
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 22
                        text: "x"
                    }
                    TapHandler {
                        id: closeSourcePickerTap

                        onTapped: sourcePicker.close()
                    }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    color: TouchTheme.border
                    height: 1
                    width: parent.width
                }
            }
            TreeView {
                id: sourceTreeView

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: sourcePickerHeader.bottom
                clip: true
                model: root.sourceModel

                delegate: Rectangle {
                    id: sourceDelegate

                    required property int column
                    required property int depth
                    required property bool expanded
                    required property int hasChildren
                    required property bool isTreeNode
                    required property string label
                    required property int row
                    required property TreeView treeView
                    readonly property var modelIndex: treeView.modelIndex(column, row)

                    color: root.selectedSourceLabel === label ? TouchTheme.libraryRowSelectedBackground : sourceDelegateTap.pressed ? TouchTheme.controlPressedBackground : depth === 0 ? TouchTheme.controlBackground : TouchTheme.libraryRowBackground
                    implicitHeight: 52
                    implicitWidth: treeView.width

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16 + sourceDelegate.depth * 24
                        anchors.verticalCenter: parent.verticalCenter
                        color: TouchTheme.secondaryText
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 18
                        rotation: sourceDelegate.expanded ? 90 : 0
                        text: ">"
                        visible: sourceDelegate.isTreeNode && sourceDelegate.hasChildren > 0
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 44 + sourceDelegate.depth * 24
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.selectedSourceLabel === sourceDelegate.label ? TouchTheme.deck1Accent : TouchTheme.primaryText
                        elide: Text.ElideRight
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 15
                        font.weight: sourceDelegate.depth === 0 ? Font.DemiBold : Font.Normal
                        text: sourceDelegate.label
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        color: TouchTheme.border
                        height: 1
                        width: parent.width
                    }
                    TapHandler {
                        id: sourceDelegateTap

                        onTapped: {
                            root.activateSource(sourceDelegate.modelIndex, sourceDelegate.label);
                            if (sourceDelegate.isTreeNode && sourceDelegate.hasChildren > 0) {
                                sourceDelegate.treeView.toggleExpanded(sourceDelegate.row);
                            } else {
                                sourcePicker.close();
                            }
                        }
                    }
                }
            }
        }
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
