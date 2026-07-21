import "Deck" as Deck
import "Library" as Library
import "Performance" as Performance
import "Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    readonly property real deckSplitX: width / 2
    property bool windowSizeRestored: false

    function browseOrLoad(group) {
        if (libraryViewControl.value <= 0) {
            effectsViewControl.value = 0;
            libraryViewControl.value = 1;
            return;
        }
        if (pageLoader.item?.loadSelectedIntoDeck(group)) {
            libraryViewControl.value = 0;
        }
    }

    color: TouchTheme.background
    minimumHeight: 600
    minimumWidth: 1024
    title: qsTr("Touch QML")
    visible: false

    Component.onCompleted: {
        width = Math.max(minimumWidth, windowWidthControl.value);
        height = Math.max(minimumHeight, windowHeightControl.value);
        windowSizeRestored = true;
        visible = true;
    }
    onHeightChanged: {
        if (windowSizeRestored && visibility === Window.Windowed) {
            windowHeightControl.value = height;
        }
    }
    onWidthChanged: {
        if (windowSizeRestored && visibility === Window.Windowed) {
            windowWidthControl.value = width;
        }
    }

    Shortcut {
        context: Qt.ApplicationShortcut
        sequence: "Ctrl+P"

        onActivated: Mixxx.PreferencesDialog.show()
    }
    Shortcut {
        context: Qt.ApplicationShortcut
        sequence: "Ctrl+Q"

        onActivated: Qt.quit()
    }
    Mixxx.SkinControlCreator {
        buttonMode: Mixxx.SkinControlCreator.Toggle
        defaultValue: 1
        group: "[Skin]"
        key: "show_intro_outro_cues"
        persist: true
    }
    Mixxx.SkinControlCreator {
        defaultValue: 2
        group: "[Skin]"
        key: "touchqml_controller_api_version"
    }
    Mixxx.SkinControlCreator {
        buttonMode: Mixxx.SkinControlCreator.Trigger
        group: "[Skin]"
        key: "touchqml_browse_or_load_deck1"
    }
    Mixxx.SkinControlCreator {
        buttonMode: Mixxx.SkinControlCreator.Trigger
        group: "[Skin]"
        key: "touchqml_browse_or_load_deck2"
    }
    Mixxx.SkinControlCreator {
        buttonMode: Mixxx.SkinControlCreator.Trigger
        group: "[Skin]"
        key: "touchqml_library_move_up"
    }
    Mixxx.SkinControlCreator {
        buttonMode: Mixxx.SkinControlCreator.Trigger
        group: "[Skin]"
        key: "touchqml_library_move_down"
    }
    Mixxx.SkinControlCreator {
        defaultValue: 1024
        group: "[Skin]"
        key: "touchqml_window_width"
        persist: true
    }
    Mixxx.SkinControlCreator {
        defaultValue: 600
        group: "[Skin]"
        key: "touchqml_window_height"
        persist: true
    }
    Mixxx.ControlProxy {
        id: windowWidthControl

        group: "[Skin]"
        key: "touchqml_window_width"
    }
    Mixxx.ControlProxy {
        id: windowHeightControl

        group: "[Skin]"
        key: "touchqml_window_height"
    }
    Mixxx.ControlProxy {
        id: libraryViewControl

        group: "[Skin]"
        key: "show_maximized_library"
    }
    Mixxx.ControlProxy {
        id: effectsViewControl

        group: "[Skin]"
        key: "show_effectrack"
    }
    Mixxx.ControlProxy {
        group: "[Skin]"
        key: "touchqml_browse_or_load_deck1"

        onValueChanged: value => {
            if (value > 0) {
                root.browseOrLoad("[Channel1]");
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Skin]"
        key: "touchqml_browse_or_load_deck2"

        onValueChanged: value => {
            if (value > 0) {
                root.browseOrLoad("[Channel2]");
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Skin]"
        key: "touchqml_library_move_up"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0) {
                pageLoader.item?.moveSelection(-1);
            }
        }
    }
    Mixxx.ControlProxy {
        group: "[Skin]"
        key: "touchqml_library_move_down"

        onValueChanged: value => {
            if (value > 0 && libraryViewControl.value > 0) {
                pageLoader.item?.moveSelection(1);
            }
        }
    }
    Column {
        anchors.fill: parent
        spacing: 0

        NavigationBar {
            splitX: root.deckSplitX
            width: parent.width
        }
        Deck.DeckStatusRow {
            splitX: root.deckSplitX
            width: parent.width
        }
        Item {
            height: Math.max(0, root.height - TouchTheme.persistentHeaderHeight)
            width: parent.width

            Loader {
                id: pageLoader

                anchors.fill: parent
                sourceComponent: libraryViewControl.value > 0 ? browsePage : performancePage
            }
        }
    }
    Component {
        id: performancePage

        Performance.PerformanceView {
            splitX: root.deckSplitX
        }
    }
    Component {
        id: browsePage

        Library.BrowseView {}
    }
}
