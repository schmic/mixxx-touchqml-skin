import "Deck" as Deck
import "Effects" as Effects
import "Library" as Library
import "Performance" as Performance
import "Samples" as Samples
import "Theme"
import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property ApplicationWindow applicationWindow
    readonly property real deckSplitX: width / 2
    property bool windowSizeRestored: false

    Component.onCompleted: {
        applicationWindow.width = Math.max(applicationWindow.minimumWidth,
                                           windowWidthControl.value);
        applicationWindow.height = Math.max(applicationWindow.minimumHeight,
                                            windowHeightControl.value);
        root.windowSizeRestored = true;
    }
    onHeightChanged: {
        if (windowSizeRestored && applicationWindow.visibility === Window.Windowed) {
            windowHeightControl.value = applicationWindow.height;
        }
    }
    onWidthChanged: {
        if (windowSizeRestored && applicationWindow.visibility === Window.Windowed) {
            windowWidthControl.value = applicationWindow.width;
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
        id: samplesViewControl

        group: "[Skin]"
        key: "show_samplers"
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

            StackLayout {
                anchors.fill: parent
                currentIndex: libraryViewControl.value > 0 ? 1 :
                    effectsViewControl.value > 0 ? 2 :
                    samplesViewControl.value > 0 ? 3 : 0

                Performance.PerformanceView {
                    splitX: root.deckSplitX
                }

                Library.BrowseView {}

                Effects.EffectRackView {}

                Samples.SampleRackView {}
            }
        }
    }
}
