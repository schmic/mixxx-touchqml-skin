# TouchQML Architecture

This document was extracted from the Mixxx source tree with TouchQML. Paths
beginning with `res/`, `src/`, or `tools/` refer to the upstream Mixxx tree.
The former `res/skins/TouchQML/` directory is the repository root here.

This document describes the experimental QML skin mechanism, how it differs
from Mixxx's standalone QML UI, and the state of the in-tree example.

## Summary

A QML skin is a directory under a Mixxx `skins/` search path which contains a
`skin.ini` manifest and a `main.qml` entry point. It appears in the normal skin
selector, but selecting it changes which application frontend is constructed
on the next start: Mixxx creates `mixxx::qml::QmlApplication` and loads the
skin's `main.qml` with `QQmlApplicationEngine` instead of constructing
`MixxxMainWindow` and parsing a legacy `skin.xml` into widgets.

The current examples are:

- [`res/skins/LateNightQML`](res/skins/LateNightQML), an experimental, partial
  QML port of LateNight intended to develop the skin mechanism and reusable QML
  controls. It is not yet a supported replacement for the legacy LateNight
  skin.
- TouchQML, now maintained in this repository, is an experimental touch-first skin
  whose first slice implements a fixed navigation/deck-status/track-overview
  stack for two decks.

Neither example defines a stable third-party skin API.

## TouchQML Agent Work Boundary

When an agent works in this repository, it must not configure, build, or
run Mixxx to verify the skin. It must not create or modify tests, C++ sources,
or other application code for TouchQML work. Changes are limited to the skin
directory and its task/architecture documentation. Static QML inspection,
formatting, and linting are sufficient unless a user explicitly replaces this
constraint.

Do not confuse a selected QML skin with `--new-ui`:

- `mixxx --developer` plus a configured QML skin loads that skin's `main.qml`
  and uses the normal Mixxx 2.x profile/database path.
- `mixxx --new-ui` loads [`res/qml/main.qml`](res/qml/main.qml), the standalone
  work-in-progress Mixxx 3.0 UI. It has a separate profile/database safety gate.
- The old `--qml` spelling is deprecated in favor of `--new-ui`.

## Discovery And Startup

The relevant flow is:

1. `SkinLoader` searches the user `skins/` directory before `res/skins/`.
2. It tries `LegacySkin::fromDirectory()` first. With QML enabled and developer
   mode active, it then tries `QmlSkin::fromDirectory()`.
3. A QML skin is recognized when both `skin.ini` and `main.qml` exist. Current
   validation only checks that the directory and these two files exist.
4. During startup, `src/main.cpp` asks `SkinLoader` for the configured skin.
   If its type is `SkinType::QML`, it constructs `QmlApplication` with the
   skin's absolute `main.qml` path.
5. `QmlApplication` initializes core services, registers/provides Mixxx's QML
   API, adds `:/mixxx.org/imports` as an import path, and loads the entry point
   in a new `QQmlApplicationEngine`.
6. If no root object is created, startup fails. Otherwise controller devices
   are set up after the UI is loaded.

`QmlSkin::loadSkin()` deliberately returns `nullptr`: the class supplies
metadata and the entry-point path to the early startup decision. It is not
loaded through the legacy `QWidget` skin hot-reload path. Switching between a
legacy and QML skin therefore requires a restart.

QML skin discovery is currently guarded twice by `--developer`. Outside
developer mode, QML-only skin directories are omitted from the skin list and a
previously configured QML skin falls back to the default legacy skin. QML also
has to be compiled in (`QML=ON`, default for Qt 6); otherwise `MIXXX_USE_QML`
and the entire path are absent.

## Directory And Manifest Contract

The minimal shape is:

```text
MyQmlSkin/
├── main.qml
└── skin.ini
```

The supported manifest keys are in the `[Skin]` group:

```ini
[Skin]
name = Human-readable name
description = Text shown in Interface preferences
min_pixel_width = 1280
min_pixel_height = 720
color_schemes = First, Second
```

- The directory name is the stable/configured skin name. `name` is only the
  display name and falls back to the directory name when omitted.
- `description` is optional.
- The minimum dimensions are compared directly with Qt's `QScreen::size()`.
  Despite the key names, this is screen geometry in Qt coordinates and may be
  affected by display scaling. If either value is missing or non-positive, the
  skin is considered to fit every screen.
- `color_schemes` is a comma-separated list read through `QSettings`.
- Scheme previews are named `skin_preview_<Scheme>.png`, with spaces replaced
  by underscores. A missing image falls back to the generic placeholder.
- If preview lookup receives an empty scheme, it currently falls back to the
  hard-coded `PaleMoon` name. This is LateNight-specific behavior in the
  otherwise generic `QmlSkin` class and should not be treated as a final API.
- There is no QML-specific launch image; `loadLaunchImage()` returns null and
  the caller uses the default launch image.

The LateNight example has `PaleMoon` and `Classic` schemes and corresponding
preview images. Runtime scheme changes flow through `Mixxx.Config.configScheme`
and do not require restarting when the current skin remains QML.

## QML API Layers

There are three different layers in use. Their stability and portability are
not equivalent.

### `Mixxx 1.0`

The compiled `Mixxx` module exposes application data and operations. Important
skin-facing types include:

- `ControlProxy`: binds a QML object to a `[Group], key` ControlObject; exposes
  `value`, `parameter`, `initialized`, `keyValid`, `reset()`, and `trigger()`.
- `SkinControlCreator`: creates a skin-owned `ControlPushButton`. It accepts
  only the `[Skin]` group, supports persistence, a default value, and push,
  toggle, power-window, long-press-latching, and trigger button modes. Duplicate
  or non-skin controls are rejected. Its lifetime owns the created control.
- `PlayerManager`, `Player`, and `Track`: deck lookup, track state, and loading.
- `Library` and library models, plus `LegacyLibraryItem` for embedding the
  existing QWidget library during migration.
- `EffectsManager`, `Recording`, `PreferencesDialog`, `Config`, `Battery`,
  `SoundManager`, `ControllerManager`, and `KeyUtils`.
- QML waveform display/overview items and renderer configuration types.
- `PlayerDropArea` from the QML portion of the module.

The exact API is defined by `QML_*` declarations in `src/qml/*.h` and by the
`Mixxx` QML module in `CMakeLists.txt`. Treat those definitions and in-tree use
as authoritative; there is not yet a versioned public skin API document.

### `Mixxx.Controls 1.0`

This compiled/resource QML module currently exports reusable `Slider`, `Knob`,
`Fader`, `Spinny`, `WaveformDisplay`, `WaveformOverview`, and overview marker
components from `res/qml/Mixxx/Controls/`. It is available through the
`:/mixxx.org/imports` import path and is the most portable source of shared QML
visual controls for an external skin.

### Relative Imports From `res/qml`

LateNightQML also imports the source tree directly, for example:

```qml
import "../../qml" as Skin
import "../../../qml/Deck" as SharedDeck
```

This supplies the current mixer, deck behavior, button, fader, and other shared
components. These imports work because LateNightQML is bundled at
`res/skins/LateNightQML`. A skin installed in the user's settings directory
does not have the same relative relationship to `res/qml`, so copying the
example there is not currently portable without also copying/reworking its
dependencies. These source-directory imports are internal reuse, not a stable
installed module contract.

## Controller Mappings And QML UI State

ControlObjects are the supported boundary between controller mappings and QML
UI state. A controller mapping must not try to call a function in the QML
JavaScript engine directly. Instead, the mapping changes a control and the skin
observes that control with `Mixxx.ControlProxy`. The same control can provide
output feedback to a controller, such as lighting an LED while a view is active.

There are two kinds of `[Skin]` controls:

1. Core-owned controls are created by `SkinControls` during core-service
   initialization and exist independently of a particular skin. These include
   `show_effectrack`, `show_library_coverart`, `show_microphones`,
   `show_preview_decks`, `show_samplers`, `show_4effectunits`, `show_coverart`,
   `show_maximized_library`, `show_mixer`, `show_settings`, `show_spinnies`, and
   `show_vinylcontrol`. A QML skin should bind to these with `ControlProxy`; it
   must not declare a duplicate `SkinControlCreator`, which will be rejected.
   Many common core-owned UI controls are also listed in the controller mapping
   picker.
2. Skin-owned controls are created by `Mixxx.SkinControlCreator`. Use these for
   presentation state that is specific to one skin and has no suitable
   core-owned control. They may be persistent or transient and may use push,
   toggle, power-window, long-press-latching, or trigger button behavior. Custom
   controls do not automatically get a human-readable entry in the controller
   mapping picker, but controller scripts and explicit mapping files can address
   their `[Skin]` group and key while the skin is loaded.

For example, a QML skin can use the existing controller-mappable library toggle
as its deck/library view state:

```qml
Mixxx.ControlProxy {
    id: libraryViewControl

    group: "[Skin]"
    key: "show_maximized_library"
}

StackLayout {
    currentIndex: libraryViewControl.value > 0 ? 1 : 0

    DeckView {}
    BrowseView {}
}
```

A JavaScript controller mapping can toggle the same state:

```js
if (value) {
    script.toggleControl("[Skin]", "show_maximized_library");
}
```

Mappings may also use `engine.setValue()`, `engine.getValue()`, and control
connections as appropriate. Prefer an existing core-owned key for concepts
shared by multiple skins. Give skin-specific keys an unambiguous name, and use
a toggle control for state or a trigger control for a one-shot UI command.

The initial configured-QML-skin startup loads the UI before setting up
controller devices, so skin-owned controls are available for normal initial
controller setup. They are nevertheless owned by the QML object that declared
them: auto-reload destroys those controls and recreates them with the new QML
engine. Do not rely on their QObject identity surviving a reload, and test any
controller connection to a skin-owned control across auto-reload.

## The LateNightQML Example

[`res/skins/LateNightQML/main.qml`](res/skins/LateNightQML/main.qml) creates an
`ApplicationWindow` and composes:

- A LateNight-specific toolbar with application menus and persistent view
  toggles.
- Two or four decks, including track metadata/time, transport, hotcues, key,
  vinyl, spinny/cover, overview, tempo, loop, and beat-jump controls.
- Shared mixer components from `res/qml` with LateNight-specific styling.
- Two- or four-deck scrolling waveforms.
- A resizable/maximizable library panel backed by `LegacyLibraryItem`.
- Local `PaleMoon` and `Classic` color schemes under `LateNightTheme/`.
- Persistent `[Skin]` controls declared with `Mixxx.SkinControlCreator` rather
  than relying on the legacy XML parser to create them. Keys that are not
  already supplied by the core become skin-owned; declarations that duplicate
  core-owned `SkinControls` keys are rejected. The toolbar also binds common
  core-owned controls such as `show_maximized_library`.

The local theme is split into semantic LateNight tokens and scheme-specific
color files. `LateNightTheme` also centralizes asset URLs. Tests verify that its
color values are valid and its referenced assets exist.

## The TouchQML First Slice

[`main.qml`](../main.qml) is the beginning of
a touch-first, two-deck performance skin. Its visual hierarchy is informed by a
1920 x 1080 Engine DJ deck-view reference, but its components and theme are an
original Mixxx implementation and do not copy proprietary assets.

The performance page uses one compact top-stack profile at every supported
viewport, with three rows at fixed Qt logical-pixel heights:

```text
NavigationBar    48
DeckStatus       72
DeckOverview     88
-------------------
Total           208
```

`main.qml` keeps NavigationBar and DeckStatus persistent, then uses a
`StackLayout` for everything below them. Performance, Browse, Touch FX, and
Samples pages remain instantiated while hidden. This preserves browser source,
filter, sort, selection, and scroll state and avoids rebuilding its model on
each view change, at the cost of retaining page objects in memory.
`PerformanceView` owns DeckOverview and the scrolling waveforms; `BrowseView`
fills the same page host. Performance-page rows receive the same `width / 2`
split coordinate from the application root.
The left side occupies `0..splitX`, the right side occupies
`splitX..width`, and the center divider is drawn over that coordinate instead
of consuming a layout column. This keeps the deck boundary centered at odd and
even widths.

The current components are:

- `NavigationBar`: Browse, Touch FX, Samples, recording, battery, and clock
  presentation.
  Its original monochrome SVG assets occupy consistent 24-pixel icon boxes so
  icons and labels share a visual centerline. Browse, Touch FX, and Samples use
  existing core-owned `[Skin]` controls and load mutually exclusive pages below
  DeckStatus. Touch FX and Samples are currently empty rack placeholders. Search
  lives inside the browser rather than as a global navigation destination.
- `DeckStatus`: a 64-pixel cover or neutral fallback centered in a 72-pixel
  slot, separate title/artist lines, loop and beat-jump size, sync/leader state,
  pitch, rate range, key, BPM, and remaining time. Remaining time, key, and BPM
  form the large right-aligned upper group. A combined 88-to-96-pixel
  pitch/range cell precedes 56-to-64-by-36-pixel Loop, Beat Jump, and Sync cells
  in the flat lower group. Original SVG icons are 18 pixels. Loop triggers
  `reloop_toggle`, while Beat Jump triggers
  `beatjump_forward`. A Sync tap triggers the momentary `beatsync` control
  without latching. A continuous two-second hold toggles the standard
  `sync_leader` control when the partner deck has no leader; when the partner is
  already Lead, it instead enables `sync_enabled` on the held deck so that deck
  becomes a synchronized follower. Releasing after either hold action does not
  also trigger Beat Sync. Remaining time reads `time_remaining` and displays
  whole `mm:ss` values.
- `DeckOverview`: one clipped RGB full-track waveform per deck, showing only
  the upper/left channel with current position and cue/loop markers supplied by
  `Mixxx.Controls.WaveformOverview`. Each active hotcue marker gains a small
  stored-color triangle at the overview's top edge, pointing down at its marker
  line.
- `PerformanceView`: the performance-only page below DeckStatus. It contains
  DeckOverview followed by Deck 1's full-width hotcue strip and waveform, then
  Deck 2's full-width waveform and hotcue strip. The two waveforms divide all
  vertical space remaining after fixed controls equally. They are display-only
  and composed locally from the portable
  `Mixxx.Controls.WaveformDisplay` API with RGB signal, beat, playhead,
  cue/hotcue, loop/intro/outro, preroll, and end-warning renderers. The mark
  renderer's `defaultMark` creates native hotcue marks, preserving each cue's
  number, saved label, stored color, type, and end position. Saved-loop hotcues
  therefore show their range and endpoint. Main cue and active-loop marks remain
  explicit. Intro/outro ranges and both endpoints follow the persistent
  TouchQML-owned `[Skin],show_intro_outro_cues` control. Blue and green 3-pixel
  left accents identify Deck 1 and Deck 2 respectively. The white playhead sits
  at one third of the waveform width, leaving two thirds for upcoming audio.
  Markers appear only while their positions are inside the visible scrolling
  window.
- `DeckHotcueGrid`: a full-width 32-pixel strip of eight equal buttons. Deck 1's
  strip sits 2 pixels above its waveform; Deck 2's sits 2 pixels below. Buttons
  have 2-pixel gaps, no outer padding or outlines, a neutral dark-gray
  background, and a 2-pixel bottom stripe. Set cues show their stored Mixxx cue
  color, matching overview and scrolling-waveform markers; empty slots show a
  neutral gray stripe. Labels are `CUE N` or `LOOP N`, based on `hotcuesModel`;
  empty slots show `CUE N`. Rendering never writes `hotcue_N_color`. Buttons hold
  `hotcue_N_activate` while pressed and reset it on release, disable, or page
  destruction. There is no touch clear gesture.
- `EffectRow`: a fixed 48-pixel center-split row 8 pixels below Deck 2's hotcue
  strip.
  Each deck has buttons for the first three slots of
  one standard effect unit plus its per-deck Quick Effect chain, arranged
  contiguously without gaps or outer padding. Active buttons highlight their
  top/bottom edges with the deck accent; vertical edges are shared neutral gray
  seams. Deck 1 uses EffectUnit 1 and Deck 2 uses EffectUnit 2. Standard buttons
  read existing channel assignment and unit-enabled controls without changing
  routing; an unavailable route is disabled and labeled `Unrouted` or `Unit
  Off`. Tapping toggles the slot or chain `enabled` control. A 250-millisecond
  hold opens a title-free touch selector backed by
  `EffectsManager.visibleEffectsModel` or `quickChainPresetModel`; choosing an
  item changes `EffectSlotProxy.effectId` or `loaded_chain_preset` without
  changing the slot or chain enabled state.
- `BrowseView`: a touch-native all-tracks list backed by
  `Mixxx.LibrarySourceTree`/`LibraryTrackListModel`. Its visible columns show
  track/artist, rating, genre, comment, key, and duration, using live properties
  from each QML track proxy. The input above the columns filters those fields
  through a debounced `DelegateModel` group. Tapping selects a track, and
  starting a left drag selects it before revealing two 96-pixel-wide
  `Load 1`/`Load 2` actions. Those actions call
  `Player.loadTrackFromLocationUrl()`; double-tapping remains an optional next-
  available-deck shortcut. Opening a row closes the previously open row, and
  pooled delegates reset before reuse. A source button beside search opens a
  centered touch tree backed by `LibrarySourceTree.sidebar()` and swaps the
  track model when a source is activated. Current Mixxx QML exposes only the
  creatable `LibraryAllTrackSource`; playlist, crate, and other source wrappers
  are not yet available to an external QML skin, so the picker currently
  contains All Tracks only. Its 48-pixel headers call
  `LibraryTrackListModel.sort()` and preserve selection by URL across ascending
  and descending sorts. Rating, genre, comment, and duration use the verified
  current `ColumnCache` IDs because `TrackListColumn.SQLColumns` does not expose
  those fields yet. Persistent page ownership also preserves ListView position
  while Browse is hidden.
- Controller browse/load bridge: controller mappings open Browse with the
  core-owned `[Skin],show_maximized_library` control. While loaded, `BrowseView`
  mirrors the fixed two-deck portion of Mixxx's QML library control bridge:
  `[Library]` move/go-to controls, deprecated `[Playlist]` encoder/previous/next
  controls, first-stopped loading, and Deck 1/2 `LoadSelectedTrack` plus
  `LoadSelectedTrackAndPlay`. Selection controls move through filtered rows and
  keep the selected row visible. Selection is established after the filtered
  `DelegateModelGroup` updates and synchronizes URL, list index, and current
  item. Loading never changes view controls; controller mappings decide whether
  to remain in Browse or return to Performance. Deck load handlers remain active
  while Browse is hidden so a controller-triggered page transition cannot race
  the load event. Dynamic deck, preview-deck, and sampler load handlers remain
  deferred. This QML observer is necessary because legacy library widget
  handlers are not connected in QML application mode.
- `EffectRackView` and `SampleRackView`: empty page placeholders selected by the
  core-owned `[Skin],show_effectrack` and `[Skin],show_samplers` controls.
- `TouchTheme`: the fixed layout metrics, touch size, colors, and typography
  shared by the first slice.

TouchQML also defines application-wide keyboard shortcuts in its root window:
`Ctrl+P` opens `Mixxx.PreferencesDialog`, and `Ctrl+Q` requests normal
application shutdown through `Qt.quit()`. The root persists its last normal
window width and height in skin-owned `touchqml_window_width` and
`touchqml_window_height` controls, restores them before showing the window, and
leaves window placement to the platform.

The performance-pad feedback visible below the overviews in the design
reference is deliberately not part of `DeckOverview` and does not consume any
of the fixed 208-pixel stack. It belongs to a later component below the new
scrolling waveforms.

## Current State (2026-07-17)

Implemented and usable for development:

- QML skins can be discovered, previewed, selected, and persisted through the
  normal Interface preferences while Mixxx runs with `--developer`.
- Selecting a QML skin causes the next developer-mode start to load its entry
  point automatically; it does not require `--new-ui`.
- Manifest display name, description, minimum screen size, scheme list, and
  scheme-specific previews work.
- Scheme changes can update a running QML skin through `Mixxx.Config`.
- Local QML files are watched by `QmlAutoReload`; a change rebuilds the QML
  engine. A reload that cannot create a root object exits Mixxx.
- LateNightQML has functional toolbar/view state, 2/4 deck layouts, the main
  deck controls, mixer controls, waveforms, overview/spinny/cover support, and
  the embedded legacy library.
- TouchQML has a persistent navigation/deck-status header, replaceable
  Performance/Browse/Touch FX/Samples page host, fixed-height two-deck overview,
  adaptive stacked scrolling waveforms, two touch-operated eight-hotcue strips,
  per-deck standard and Quick Effect buttons with hold selectors, centralized
  touch/theme metrics, controller-mappable view controls, a standard fixed
  two-deck library control bridge, and a touch-native all-tracks browser with
  explicit load actions.
- QML can create and persist its own `[Skin]` controls; focused unit tests cover
  normal creation, defaults, ordering, duplicates, invalid groups, and cleanup.

Still experimental or incomplete:

- The feature is developer-only and explicitly labeled "Experimental" and
  "Developer Preview" in the example manifest/UI.
- There is no stable third-party packaging/import contract. LateNightQML's
  relative imports couple it to the in-tree resource layout.
- Skin switching cannot happen live across the QWidget/QML application split.
- `QmlSkin` validation does not parse/validate the manifest or QML ahead of
  launch, and its preview default is hard-coded to PaleMoon.
- The library remains a QWidget bridge (`LegacyLibraryItem`), not the pure-QML
  library available elsewhere under `res/qml/Library`.
- Sampler and effect rows are commented out in `main.qml`; corresponding toolbar
  toggles exist before their panels do.
- Several deck files retain `Placeholder` names. Many are already wired and
  functional, but this reflects the port's transitional structure rather than
  a finished component API.
- Toolbar menu commands still disabled include Exit, library rescan/search and
  playlist/crate creation, preview deck, Auto DJ, full screen, keyboard shortcut
  enablement, and Help/About links.
- The example is fixed at four engine decks and 64 samplers, with a declared
  minimum width of 1280. It aims to match LateNight, not demonstrate a small
  minimal skin.
- TouchQML is still an early slice: Browse has a source-picker overlay, but the
  current Mixxx QML API exposes only All Tracks rather than playlists, crates,
  and other sources. Touch FX and Samples pages are empty, and transport, mixer,
  additional pad modes, and the rest of the performance view are still absent.
- Some scene-graph waveform renderer combinations remain unsupported; see the
  FIXMEs in `src/qml/qmlwaveformrenderer.cpp` and
  `src/qml/qmlwaveformdisplay.cpp`.
- QML integration has targeted unit coverage, but there is no end-to-end test
  that launches an arbitrary skin, exercises restart selection, or validates an
  external user-installed QML skin.

## Running The Example

The commands in this section document the general QML skin mechanism for human
developers. They must not be executed by an agent while working on TouchQML;
see **TouchQML Agent Work Boundary** above.

Build with Qt 6 and QML enabled (the defaults):

```sh
cmake -S . -B build -DQML=ON
cmake --build build --parallel
```

Then:

1. Start `build/mixxx --developer`.
2. Open Preferences > Interface.
3. Select `LateNight QML (Experimental)`, choose a scheme, and apply.
4. Restart with `build/mixxx --developer`.

For isolated development, add `--settings-path /path/to/test-profile` so the
experimental UI does not reuse the normal settings directory. Do not add
`--new-ui`: that bypasses the configured skin entry point and loads the
standalone QML UI instead.

During a run, edits to loaded local QML files should trigger auto-reload. C++
API or QML module changes still require rebuilding and restarting.

Useful focused tests in an existing test build are:

```sh
build/mixxx-test \
  --gtest_filter='ThemeQmlTest.*:QmlSkinControlCreatorTest.*'
```

Use `tools/qmlformat.py` and the repository `.qmlformat.ini` for QML formatting.

## Code Map

- `src/main.cpp`: chooses the legacy application, configured QML skin, or
  standalone `--new-ui` application path.
- `src/skin/skin.h`: shared `Skin` abstraction and `SkinType`.
- `src/skin/skinloader.{h,cpp}`: search order, developer gating, configured-skin
  fallback, and legacy/QML discovery.
- `src/skin/qml/qmlskin.{h,cpp}`: QML manifest metadata and entry-point path.
- `src/qml/qmlapplication.{h,cpp}`: QML frontend initialization, engine loading,
  shared services, image provider, and auto-reload.
- `src/qml/qmlautoreload.{h,cpp}`: watches local QML dependencies.
- `src/qml/qmlcontrolproxy.*`: ControlObject access from QML.
- `src/qml/qmlskincontrolcreator.*`: QML-owned `[Skin]` controls.
- `src/qml/qmllegacylibraryitem.*`: QWidget library bridge.
- `res/qml/Mixxx/Controls/`: resource-backed reusable QML controls.
- `res/qml/`: standalone QML UI and internal shared source components.
- `res/skins/LateNightQML/`: the current skin example.
- This repository: touch-first skin, currently the fixed three-row top
  stack.
- `src/test/themeqml_test.cpp` and
  `src/test/qmlskincontrolcreatortest.cpp`: focused current tests.

## Guidance For Further Work

- Preserve the distinction between the configured QML skin path and
  `--new-ui`; changes to one can unintentionally affect profile safety or
  startup behavior in the other.
- Keep manifest behavior generic. Do not add more LateNight assumptions to
  `QmlSkin`.
- Prefer a named resource QML module such as `Mixxx.Controls` for APIs intended
  for external skins. A relative import from `res/qml` is only suitable for
  bundled in-tree code until an installation contract exists.
- Use `SkinControlCreator` only for `[Skin]` state that the skin owns. Use
  `ControlProxy` for existing engine/application controls.
- Preserve Mixxx control conventions across touch, keyboard, and controller
  paths. Prefer observing or triggering existing core controls over creating a
  TouchQML-only API; introduce skin-specific controls only for behavior that has
  no suitable Mixxx control.
- Account for QML engine destruction and recreation: QML-owned objects and
  controls are destroyed on auto-reload and must be safely recreated.
- Add focused tests when changing manifest parsing, QML registrations, control
  lifetime, theme assets, or the startup selection boundary.
- For TouchQML-only work, do not build or run Mixxx and do not add or modify
  tests or application source. Keep implementation changes inside this
  repository and use static QML checks only.
