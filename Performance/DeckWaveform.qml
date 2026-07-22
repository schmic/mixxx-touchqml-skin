import "../Theme"
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls
import QtQuick

Rectangle {
    id: root

    required property color accentColor
    required property string group
    readonly property string zoomGroup: Mixxx.Config.waveformZoomSynchronization ? "[Channel1]" : root.group

    clip: true
    color: TouchTheme.overviewBackground

    Mixxx.ControlProxy {
        id: zoomControl

        group: root.zoomGroup
        key: "waveform_zoom"
    }
    MixxxControls.WaveformDisplay {
        anchors.fill: parent
        backgroundColor: "transparent"
        group: root.group
        zoom: zoomControl.value

        Mixxx.WaveformRendererEndOfTrack {
            color: TouchTheme.recording
            endOfTrackWarningTime: 30
        }
        Mixxx.WaveformRendererPreroll {
            color: TouchTheme.recording
        }
        Mixxx.WaveformRendererMarkRange {
            Mixxx.WaveformMarkRange {
                color: TouchTheme.activeLoop
                disabledColor: TouchTheme.primaryText
                disabledOpacity: 0.2
                enabledControl: "loop_enabled"
                endControl: "loop_end_position"
                opacity: 0.45
                startControl: "loop_start_position"
            }
            Mixxx.WaveformMarkRange {
                color: root.accentColor
                durationTextColor: TouchTheme.primaryText
                durationTextLocation: "after"
                endControl: "intro_end_position"
                opacity: 0.35
                startControl: "intro_start_position"
                visibilityControl: "[Skin],show_intro_outro_cues"
            }
            Mixxx.WaveformMarkRange {
                color: root.accentColor
                durationTextColor: TouchTheme.primaryText
                durationTextLocation: "before"
                endControl: "outro_end_position"
                opacity: 0.35
                startControl: "outro_start_position"
                visibilityControl: "[Skin],show_intro_outro_cues"
            }
        }
        Mixxx.WaveformRendererRGB {
            axesColor: TouchTheme.border
            gainAll: 1.0
            gainHigh: 1.0
            gainLow: 1.0
            gainMid: 1.0
            highColor: TouchTheme.waveformHigh
            lowColor: TouchTheme.waveformLow
            midColor: TouchTheme.waveformMid
        }
        Mixxx.WaveformRendererBeat {
            color: TouchTheme.border
        }
        Mixxx.WaveformRendererMark {
            playMarkerBackground: "transparent"
            playMarkerColor: TouchTheme.primaryText
            playMarkerPosition: TouchTheme.mainWaveformPlayMarkerPosition
            untilMark.align: Qt.AlignBottom
            untilMark.showBeats: true
            untilMark.showTime: true
            untilMark.textSize: 11

            defaultMark: Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.border.toString()
                text: " %1 "
                textColor: TouchTheme.primaryText.toString()
            }

            Mixxx.WaveformMark {
                align: "top|right"
                color: TouchTheme.recording.toString()
                control: "cue_point"
                text: "CUE"
                textColor: TouchTheme.primaryText.toString()
            }
            Mixxx.WaveformMark {
                align: "top|right"
                color: TouchTheme.activeLoop.toString()
                control: "loop_start_position"
                text: "LOOP"
                textColor: TouchTheme.background.toString()
            }
            Mixxx.WaveformMark {
                align: "bottom|right"
                color: TouchTheme.activeLoop.toString()
                control: "loop_end_position"
                textColor: TouchTheme.background.toString()
            }
            Mixxx.WaveformMark {
                align: "top|right"
                color: root.accentColor.toString()
                control: "intro_start_position"
                text: "IN"
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: "[Skin],show_intro_outro_cues"
            }
            Mixxx.WaveformMark {
                align: "top|left"
                color: root.accentColor.toString()
                control: "intro_end_position"
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: "[Skin],show_intro_outro_cues"
            }
            Mixxx.WaveformMark {
                align: "top|right"
                color: root.accentColor.toString()
                control: "outro_start_position"
                text: "OUT"
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: "[Skin],show_intro_outro_cues"
            }
            Mixxx.WaveformMark {
                align: "top|left"
                color: root.accentColor.toString()
                control: "outro_end_position"
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: "[Skin],show_intro_outro_cues"
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        color: root.accentColor
        width: TouchTheme.mainWaveformAccentWidth
        z: 2
    }
}
