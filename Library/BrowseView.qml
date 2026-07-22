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
    readonly property int durationColumnWidth: 60
    property var availableGenres: []
    readonly property int genreColumnWidth: 120
    readonly property int keyColumnWidth: 48
    readonly property int libraryViewFocus: 3
    readonly property var modelCapabilities: root.trackModel ? root.trackModel.getCapabilities() : Mixxx.LibraryTrackListModel.Capability.None
    property var openSwipeRow: null
    readonly property string previewDeckGroup: "[PreviewDeck1]"
    readonly property int ratingColumnWidth: 72
    property int selectedListIndex: -1
    property string selectedGenreFilter: ""
    property string selectedSourceLabel: qsTr("All Tracks")
    property url selectedUrl
    property int sortColumn: 2
    property int sortOrder: Qt.AscendingOrder
    property var sourceModel: null
    property var trackModel: null

    readonly property bool canLoadToDeck: root.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToDeck)
    readonly property bool canLoadToPreviewDeck: numPreviewDecksControl.value > 0 && root.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToPreviewDeck)
    readonly property bool canSort: root.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.Sorting)

    function applySearchFilter() {
        if (root.trackModel === null) {
            return;
        }
        if (root.openSwipeRow) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = "";
        root.selectedListIndex = -1;
        root.refreshAvailableGenres();
        const query = searchField.text.trim().toLocaleLowerCase();
        const genreFilter = root.selectedGenreFilter.toLocaleLowerCase();
        for (let i = filteredTrackModel.items.count - 1; i >= 0; --i) {
            const entry = filteredTrackModel.items.get(i);
            const track = entry.model.track;
            const genre = String(track?.genre || "").trim();
            const searchableText = [track?.title, track?.artist, track?.genre, track?.comment, track?.keyText].map(value => String(value || "")).join(" ").toLocaleLowerCase();
            const genreMatches = genreFilter.length === 0 || genre.toLocaleLowerCase() === genreFilter;
            entry.inSearchResults = genreMatches && (query.length === 0 || searchableText.includes(query));
        }
        trackList.positionViewAtBeginning();
        Qt.callLater(root.ensureSelection);
    }
    function hasCapabilities(capabilities) {
        return (root.modelCapabilities & capabilities) === capabilities;
    }
    function loadUrlIntoDeck(url, group, play = false) {
        if (!root.canLoadToDeck || !url || url.toString().length === 0) {
            return false;
        }
        Mixxx.PlayerManager.getPlayer(group).loadTrackFromLocationUrl(url, play);
        return true;
    }
    function loadUrlIntoNextAvailableDeck(url, play = false) {
        if (!root.canLoadToDeck || !url || url.toString().length === 0) {
            return false;
        }
        Mixxx.PlayerManager.loadLocationUrlIntoNextAvailableDeck(url, play);
        return true;
    }
    function loadUrlIntoPreviewDeck(url) {
        if (!root.canLoadToPreviewDeck || !url || url.toString().length === 0) {
            return false;
        }
        const player = Mixxx.PlayerManager.getPlayer(root.previewDeckGroup);
        if (!player) {
            return false;
        }
        player.loadTrackFromLocationUrl(url, true);
        return true;
    }
    function loadSelectedIntoDeck(group, play = false) {
        return root.loadUrlIntoDeck(root.selectedUrl, group, play);
    }
    function refreshAvailableGenres() {
        const genresByKey = {};
        for (let i = 0; i < filteredTrackModel.items.count; ++i) {
            const genre = String(filteredTrackModel.items.get(i).model.track?.genre || "").trim();
            const key = genre.toLocaleLowerCase();
            if (genre.length > 0 && !Object.prototype.hasOwnProperty.call(genresByKey, key)) {
                genresByKey[key] = genre;
            }
        }
        root.availableGenres = Object.keys(genresByKey).map(key => genresByKey[key]).sort((left, right) => left.localeCompare(right));
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
            nextIndex = Mixxx.MathUtils.positiveModulo(nextIndex + direction, count);
        }
        const entry = searchResultsGroup.get(nextIndex);
        root.selectedListIndex = nextIndex;
        root.selectedUrl = entry.model.file_url;
        trackList.currentIndex = nextIndex;
        trackList.positionViewAtIndex(nextIndex, ListView.Contain);
    }
    function ensureSelection() {
        const count = searchResultsGroup.count;
        if (count === 0) {
            root.selectedListIndex = -1;
            root.selectedUrl = "";
            trackList.currentIndex = -1;
            return;
        }
        for (let i = 0; i < count; ++i) {
            if (searchResultsGroup.get(i).model.file_url.toString() === root.selectedUrl.toString()) {
                root.selectedListIndex = i;
                trackList.currentIndex = i;
                return;
            }
        }
        const firstEntry = searchResultsGroup.get(0);
        root.selectedListIndex = 0;
        root.selectedUrl = firstEntry.model.file_url;
        trackList.currentIndex = 0;
    }
    function activateSource(modelIndex, label) {
        if (root.openSwipeRow) {
            root.openSwipeRow.closeMenu();
        }
        root.selectedUrl = "";
        root.selectedListIndex = -1;
        root.selectedGenreFilter = "";
        root.availableGenres = [];
        trackList.currentIndex = -1;
        root.sourceModel.activate(modelIndex);
        root.trackModel = root.sourceModel.tracklist;
        if (root.sortColumn >= 0) {
            root.trackModel.sort(root.sortColumn, root.sortOrder);
        }
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
        trackList.currentIndex = row.index;
        focusedWidgetControl.value = root.libraryViewFocus;
        trackList.forceActiveFocus();
    }
    function sortByColumn(column) {
        if (!root.trackModel || !root.canSort) {
            return;
        }
        if (root.sortColumn === column) {
            root.sortOrder = root.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder;
        } else {
            root.sortColumn = column;
            root.sortOrder = Qt.AscendingOrder;
        }
        root.trackModel.sort(root.sortColumn, root.sortOrder);
        Qt.callLater(root.restoreSelectedIndex);
    }
    function restoreSelectedIndex() {
        for (let i = 0; i < searchResultsGroup.count; ++i) {
            if (searchResultsGroup.get(i).model.file_url.toString() === root.selectedUrl.toString()) {
                root.selectedListIndex = i;
                trackList.currentIndex = i;
                trackList.positionViewAtIndex(i, ListView.Contain);
                return;
            }
        }
        root.selectedListIndex = -1;
        root.selectedUrl = "";
        trackList.currentIndex = -1;
    }

    color: TouchTheme.libraryBackground

    Component.onCompleted: {
        root.sourceModel = sourceTree.sidebar();
        root.activateSource(root.sourceModel.index(0, 0), qsTr("All Tracks"));
        if (libraryViewControl.value > 0) {
            focusedWidgetControl.value = root.libraryViewFocus;
        }
    }

    Mixxx.LibrarySourceTree {
        id: sourceTree

        visible: false

        // qmllint disable unresolved-type
        defaultColumns: [
            Mixxx.TrackListColumn {
                columnIdx: Mixxx.TrackListColumn.SQLColumns.Title
                label: qsTr("Title")
            },
            Mixxx.TrackListColumn {
                columnIdx: 25 // ColumnCache::COLUMN_LIBRARYTABLE_RATING
                label: qsTr("Rating")
            },
            Mixxx.TrackListColumn {
                columnIdx: 6 // ColumnCache::COLUMN_LIBRARYTABLE_GENRE
                label: qsTr("Genre")
            },
            Mixxx.TrackListColumn {
                columnIdx: 11 // ColumnCache::COLUMN_LIBRARYTABLE_COMMENT
                label: qsTr("Comment")
            },
            Mixxx.TrackListColumn {
                columnIdx: Mixxx.TrackListColumn.SQLColumns.Key
                label: qsTr("Key")
            },
            Mixxx.TrackListColumn {
                columnIdx: 12 // ColumnCache::COLUMN_LIBRARYTABLE_DURATION
                label: qsTr("Duration")
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

        onValueChanged: value => {
            if (value > 0) {
                focusedWidgetControl.value = root.libraryViewFocus;
                trackList.forceActiveFocus();
                Qt.callLater(root.ensureSelection);
            }
        }
    }
    Mixxx.ControlProxy {
        id: numPreviewDecksControl

        group: "[App]"
        key: "num_preview_decks"
    }
    Mixxx.ControlProxy {
        id: focusedWidgetControl

        group: "[Library]"
        key: "focused_widget"
    }
    Mixxx.ControlProxy {
        group: "[Library]"
        key: "GoToItem"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0 && focusedWidgetControl.value === root.libraryViewFocus) {
                root.loadUrlIntoNextAvailableDeck(root.selectedUrl);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Playlist]"
        key: "LoadSelectedIntoFirstStopped"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0 && focusedWidgetControl.value === root.libraryViewFocus) {
                root.loadUrlIntoNextAvailableDeck(root.selectedUrl);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Playlist]"
        key: "SelectTrackKnob"

        onValueChanged: value => {
            if (value !== 0 && libraryViewControl.value > 0) {
                focusedWidgetControl.value = root.libraryViewFocus;
                root.moveSelection(value);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Playlist]"
        key: "SelectPrevTrack"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0) {
                focusedWidgetControl.value = root.libraryViewFocus;
                root.moveSelection(-1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Playlist]"
        key: "SelectNextTrack"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0) {
                focusedWidgetControl.value = root.libraryViewFocus;
                root.moveSelection(1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Library]"
        key: "MoveVertical"

        onValueChanged: value => {
            if (value !== 0 && libraryViewControl.value > 0) {
                focusedWidgetControl.value = root.libraryViewFocus;
                root.moveSelection(value);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Library]"
        key: "MoveUp"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0 && focusedWidgetControl.value === root.libraryViewFocus) {
                root.moveSelection(-1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Library]"
        key: "MoveDown"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0 && focusedWidgetControl.value === root.libraryViewFocus) {
                root.moveSelection(1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Channel1]"
        key: "LoadSelectedTrack"

        onValueChanged: value => {
            if (value > 0) {
                root.loadSelectedIntoDeck("[Channel1]");
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Channel2]"
        key: "LoadSelectedTrack"

        onValueChanged: value => {
            if (value > 0) {
                root.loadSelectedIntoDeck("[Channel2]");
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Channel1]"
        key: "LoadSelectedTrackAndPlay"

        onValueChanged: value => {
            if (value > 0) {
                root.loadSelectedIntoDeck("[Channel1]", true);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Channel2]"
        key: "LoadSelectedTrackAndPlay"

        onValueChanged: value => {
            if (value > 0) {
                root.loadSelectedIntoDeck("[Channel2]", true);
            }
        }
    }
    Connections {
        function onTracklistChanged() {
            root.trackModel = root.sourceModel.tracklist;
            if (root.sortColumn >= 0) {
                root.trackModel.sort(root.sortColumn, root.sortOrder);
            }
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
    Connections {
        function onCountChanged() {
            Qt.callLater(root.ensureSelection);
        }

        target: searchResultsGroup
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
            loadEnabled: root.canLoadToDeck
            previewEnabled: root.canLoadToPreviewDeck
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
            onPreviewRequested: row => {
                root.selectTrack(file_url, row);
                root.loadUrlIntoPreviewDeck(file_url);
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

            PreviewDeck {
                Layout.preferredHeight: TouchTheme.minimumTouchSize
                Layout.preferredWidth: 320
                group: root.previewDeckGroup
                visible: numPreviewDecksControl.value > 0
            }
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
        height: TouchTheme.minimumTouchSize

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 64
            anchors.rightMargin: 16
            spacing: 12

            ColumnHeader {
                Layout.fillWidth: true
                columnIndex: 0
                label: qsTr("TRACK")
            }
            ColumnHeader {
                Layout.preferredWidth: root.ratingColumnWidth
                columnIndex: 1
                label: qsTr("RATING")
            }
            ColumnHeader {
                Layout.preferredWidth: root.genreColumnWidth
                columnIndex: 2
                highlighted: root.selectedGenreFilter.length > 0
                holdEnabled: root.trackModel !== null
                label: qsTr("GENRE")

                onHeld: {
                    root.refreshAvailableGenres();
                    genrePicker.open();
                }
            }
            ColumnHeader {
                Layout.preferredWidth: root.commentColumnWidth
                columnIndex: 3
                label: qsTr("COMMENT")
            }
            ColumnHeader {
                Layout.preferredWidth: root.keyColumnWidth
                columnIndex: 4
                label: qsTr("KEY")
            }
            ColumnHeader {
                Layout.preferredWidth: root.durationColumnWidth
                columnIndex: 5
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
        currentIndex: -1
        focus: libraryViewControl.value > 0
        model: filteredTrackModel
        reuseItems: true

        Keys.onDownPressed: event => {
            root.moveSelection(1);
            event.accepted = true;
        }
        Keys.onEnterPressed: event => {
            root.loadUrlIntoNextAvailableDeck(root.selectedUrl);
            event.accepted = true;
        }
        Keys.onReturnPressed: event => {
            root.loadUrlIntoNextAvailableDeck(root.selectedUrl);
            event.accepted = true;
        }
        Keys.onUpPressed: event => {
            root.moveSelection(-1);
            event.accepted = true;
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }
    Text {
        anchors.centerIn: trackList
        color: TouchTheme.mutedText
        font.family: TouchTheme.fontFamily
        font.pixelSize: 18
        text: root.trackModel === null ? qsTr("Loading library…") : searchField.text.length > 0 || root.selectedGenreFilter.length > 0 ? qsTr("No tracks match current filters") : qsTr("No tracks in the library")
        visible: trackList.count === 0
    }
    Popup {
        id: genrePicker

        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(400, parent.width - 32)
        height: Math.min(520, 56 + (root.availableGenres.length + 1) * TouchTheme.minimumTouchSize, parent.height - 32)
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
                id: genrePickerHeader

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                color: TouchTheme.libraryHeaderBackground
                height: 56

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: closeGenrePicker.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: TouchTheme.primaryText
                    elide: Text.ElideRight
                    font.family: TouchTheme.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    text: qsTr("Genre Filter")
                }
                Rectangle {
                    id: closeGenrePicker

                    anchors.right: parent.right
                    anchors.top: parent.top
                    color: closeGenrePickerTap.pressed ? TouchTheme.controlPressedBackground : "transparent"
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
                        id: closeGenrePickerTap

                        onTapped: genrePicker.close()
                    }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    color: TouchTheme.border
                    height: 1
                    width: parent.width
                }
            }
            ListView {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: genrePickerHeader.bottom
                clip: true
                model: [""].concat(root.availableGenres)

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    id: genreDelegate

                    required property int index
                    required property string modelData
                    readonly property bool selected: root.selectedGenreFilter === modelData

                    color: selected ? TouchTheme.libraryRowSelectedBackground : genreDelegateTap.pressed ? TouchTheme.controlPressedBackground : index % 2 === 0 ? TouchTheme.libraryRowBackground : TouchTheme.libraryRowAlternateBackground
                    height: TouchTheme.minimumTouchSize
                    width: ListView.view.width

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        color: genreDelegate.selected ? TouchTheme.deck1Accent : TouchTheme.primaryText
                        elide: Text.ElideRight
                        font.family: TouchTheme.fontFamily
                        font.pixelSize: 15
                        font.weight: genreDelegate.selected ? Font.DemiBold : Font.Normal
                        text: genreDelegate.modelData.length > 0 ? genreDelegate.modelData : qsTr("ALL GENRES")
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        color: TouchTheme.border
                        height: 1
                        width: parent.width
                    }
                    TapHandler {
                        id: genreDelegateTap

                        onTapped: {
                            root.selectedGenreFilter = genreDelegate.modelData;
                            root.applySearchFilter();
                            genrePicker.close();
                        }
                    }
                }
            }
        }
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
        required property int columnIndex
        property bool highlighted: false
        property bool holdEnabled: false
        property bool holdTriggered: false
        required property string label
        property bool sortEnabled: root.canSort

        signal held

        color: highlighted ? TouchTheme.activeLeader : TouchTheme.mutedText
        enabled: sortEnabled || holdEnabled
        elide: Text.ElideRight
        font.family: TouchTheme.fontFamily
        font.pixelSize: 11
        font.weight: Font.DemiBold
        opacity: !enabled ? 0.42 : headerTapHandler.pressed ? 0.62 : 1.0
        text: root.sortColumn === columnIndex ?
            label + (root.sortOrder === Qt.AscendingOrder ? "  ^" : "  v") : label
        verticalAlignment: Text.AlignVCenter

        TapHandler {
            id: headerTapHandler

            enabled: parent.enabled
            longPressThreshold: 0.5

            onLongPressed: {
                if (parent.holdEnabled) {
                    parent.holdTriggered = true;
                    parent.held();
                }
            }
            onPressedChanged: {
                if (pressed) {
                    parent.holdTriggered = false;
                }
            }
            onTapped: {
                if (parent.holdTriggered) {
                    parent.holdTriggered = false;
                    return;
                }
                if (parent.sortEnabled) {
                    root.sortByColumn(parent.columnIndex);
                }
            }
        }
    }
}
