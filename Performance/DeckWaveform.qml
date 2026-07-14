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
                color: TouchTheme.deck1Accent
                durationTextColor: TouchTheme.primaryText
                durationTextLocation: "after"
                endControl: "intro_end_position"
                opacity: 0.35
                startControl: "intro_start_position"
            }
            Mixxx.WaveformMarkRange {
                color: TouchTheme.deck1Accent
                durationTextColor: TouchTheme.primaryText
                durationTextLocation: "before"
                endControl: "outro_end_position"
                opacity: 0.35
                startControl: "outro_start_position"
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
            color: TouchTheme.mutedText
        }
        Mixxx.WaveformRendererMark {
            playMarkerBackground: "transparent"
            playMarkerColor: TouchTheme.primaryText
            playMarkerPosition: TouchTheme.mainWaveformPlayMarkerPosition
            untilMark.align: Qt.AlignBottom
            untilMark.showBeats: true
            untilMark.showTime: true
            untilMark.textSize: 11

            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[0].toString()
                control: "hotcue_1_position"
                text: " 1 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_1_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[1].toString()
                control: "hotcue_2_position"
                text: " 2 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_2_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[2].toString()
                control: "hotcue_3_position"
                text: " 3 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_3_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[3].toString()
                control: "hotcue_4_position"
                text: " 4 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_4_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[4].toString()
                control: "hotcue_5_position"
                text: " 5 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_5_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[5].toString()
                control: "hotcue_6_position"
                text: " 6 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_6_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[6].toString()
                control: "hotcue_7_position"
                text: " 7 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_7_status"
            }
            Mixxx.WaveformMark {
                align: "bottom|center"
                color: TouchTheme.hotcueSlotColors[7].toString()
                control: "hotcue_8_position"
                text: " 8 "
                textColor: TouchTheme.primaryText.toString()
                visibilityControl: root.group + ",hotcue_8_status"
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
                color: TouchTheme.deck1Accent.toString()
                control: "intro_start_position"
                text: "IN"
                textColor: TouchTheme.primaryText.toString()
            }
            Mixxx.WaveformMark {
                align: "top|left"
                color: TouchTheme.deck1Accent.toString()
                control: "outro_start_position"
                text: "OUT"
                textColor: TouchTheme.primaryText.toString()
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
