# TouchQML Design Brief

This document preserves the original design goals and acceptance criteria.
The former `res/skins/TouchQML/` directory is the repository root here.

## Goal

Create a new QML-based Mixxx skin optimized for landscape touchscreens in the
10–14 inch range. Its interaction model and visual direction should feel
familiar to users of Denon DJ's Engine DJ 5.x interface, while remaining an
original Mixxx design and using only Mixxx-owned or suitably licensed assets.

The skin should prioritize the controls needed during a performance, make them
easy to operate by touch, and remain readable on relatively small displays.

## Deliverable

Maintain the standalone experimental skin in this repository:

```text
mixxx-touchqml-skin/
```

It must have its own `skin.ini`, `main.qml`, components, theme, and preview
image(s). Do not turn `LateNightQML` into the touchscreen skin. Reuse suitable
Mixxx QML APIs and shared controls instead of duplicating their behavior.

The initial implementation is an MVP, but it must be coherent and usable for a
basic two-deck mixing workflow rather than being a static visual mock-up.

## Target Displays

Physical screen size alone is not available reliably to QML and varies with
display scaling, so design and test using Qt logical pixels.

- Minimum supported landscape viewport: 1024 × 600 logical pixels.
- Primary design viewport: 1280 × 800 logical pixels.
- Also verify scaling at 1366 × 768 and 1920 × 1080.
- Restore the last normal window width and height across launches; let the
  platform manage window placement.
- Treat the supplied Engine DJ visual reference as a 1920 × 1080 composition at
  100% display scaling. Use it for hierarchy and proportions, not for literal
  pixel sampling from the photograph.
- Portrait layout is out of scope for the MVP.
- Essential controls must not overlap, clip, or require precise pointer input at
  the minimum viewport.

## Experience And Visual Direction

Use Engine DJ 5.x as a high-level reference for information hierarchy,
touch-first interaction, dense but legible deck presentation, and a dark
performance-oriented appearance. Do not make a pixel-for-pixel clone and do not
copy Denon/Engine DJ branding, icons, screenshots, fonts, or other proprietary
assets.

The original Mixxx design should have:

- A dark, high-contrast theme suitable for a booth.
- Clear visual separation and color identity for the left and right decks.
- Large, glanceable track, time, BPM, pitch, loop, and sync state.
- Strong pressed, active, disabled, and focus states.
- A restrained hierarchy: performance-critical state is prominent; secondary
  configuration is behind panels or menus.
- Consistent spacing, typography, radii, colors, and icon sizing through
  centralized theme tokens.
- Use Mixxx's bundled Ubuntu family for interface text.

## Touch Interaction Requirements

- Normal interactive targets should be at least 48 × 48 logical pixels.
- Compact DeckStatus actions at 36 pixels and waveform hotcue strips at 32
  pixels are explicit height exceptions.
- No required action may depend on hover, a right click, or a mouse wheel.
- Provide immediate visual feedback on press and a persistent indication for
  toggled state.
- Avoid adjacent destructive or mutually disruptive actions without adequate
  spacing or a deliberate gesture.
- Use drag gestures only where they are natural and provide a tap alternative
  where practical.
- Tooltips may help mouse users but must not contain information required to
  operate the skin.
- Keyboard and controller operation must continue to work through Mixxx's
  existing controls; the skin must not replace engine behavior with local-only
  state.

## MVP Layout And Features

Build a responsive landscape layout with these areas:

1. **Global/status bar**
   - Current time/status information available from existing Mixxx APIs.
   - Buttons for library access, preferences, recording, and a compact overflow
     menu where the APIs already support those actions.

2. **Two deck headers**
   - Track title and artist.
   - Cover art when available.
   - Elapsed/remaining time, BPM, pitch/rate, key, and loop size/state.
   - Clear loaded, playing, sync, and master state.

3. **Waveform area**
   - Scrolling waveforms for both active decks with play position and useful
     beat/cue markers.
   - Waveform overview or track-position indication where space permits.
   - At the minimum viewport, preserve the waveform and core transport controls
     before optional metadata or decoration.

4. **Deck controls**
   - Play/pause, cue, sync, and rate controls.
   - Loop enable and loop-size adjustment.
   - Beat jump controls.
   - At least eight hotcues per deck, reachable through a performance-pad area
     or banked layout.
   - Controls must bind to existing Mixxx `ControlObject`s through
     `Mixxx.ControlProxy` or an existing shared component.

5. **Mixer**
   - Per-deck gain, three-band EQ, channel volume, PFL/headphone cue, and VU
     meters.
   - Crossfader and main/headphone controls.
   - At small sizes, a deliberate compact or overlay presentation is acceptable
     as long as the active state remains obvious.

6. **Library**
   - A touch-accessible library panel or full-screen mode.
   - Browse/search, select a track, and load it into either deck without relying
     on drag and drop.
   - Reuse the best currently available QML/library integration. If the legacy
     QWidget bridge prevents an interaction from being genuinely touch usable,
     document the limitation rather than hiding it.

Sampler pads, four-deck operation, effects editing, custom waveform settings,
and portrait mode are follow-up work unless they are inexpensive consequences
of reused components.

## First Implementation Slice: Fixed Top Stack

In `PerformanceView`, the top three components form one fixed-height stack and
must share exactly the same horizontal deck split:

```text
┌────────────────────── NavigationBar: 48 ────────────────────────┐
│ global navigation                         status and clock      │
├───────────────────────────┬─────────────────────────────────────┤
│       DeckStatus 1        │          DeckStatus 2               │  72
├───────────────────────────┼─────────────────────────────────────┤
│      DeckOverview 1       │         DeckOverview 2              │  88
└───────────────────────────┴─────────────────────────────────────┘
                              fixed total: 208 logical pixels
```

The performance-pad feedback visible below the track overviews in the visual
reference is not part of this slice and is not included in the 208-pixel total.
It will be designed as a separate component below this fixed top stack.

Define these heights as centralized theme/layout metrics rather than repeating
numeric literals:

```qml
readonly property int navigationBarHeight: 48
readonly property int deckStatusHeight: 72
readonly property int deckOverviewHeight: 88
```

This is the only layout profile: the heights are fixed in Qt logical pixels at
every supported viewport. They must not use `Layout.fillHeight`, ratios based
on window height, or implicit content height. Width remains responsive.

### Shared Center Split

The performance-view root owns one split coordinate:

```qml
readonly property real deckSplitX: width / 2
```

Pass that value to all three components. Each deck-aware row lays out its left
side from `0` to `deckSplitX` and its right side from `deckSplitX` to `width`.
Draw any center divider on top of that coordinate; do not give the divider its
own layout column or independently round the split in each component. Internal
padding must be symmetric so the visual boundary remains centered at odd as
well as even window widths.

The `NavigationBar` spans the full width rather than becoming two independent
toolbars, but its bottom deck-accent rule must change from the left-deck color
to the right-deck color at the same `deckSplitX` coordinate.

### `NavigationBar`

- Fixed height: 48 logical pixels, including its bottom accent rule.
- Left-aligned primary destinations: Browse and Touch FX or the closest
  functionality supported by current Mixxx APIs.
- Right-aligned global status/actions: recording state, other available status
  indicators, and clock. Unsupported status indicators should be omitted rather
  than mocked.
- Interactive targets must remain at least 48 logical pixels high and must show
  pressed and active state without relying on hover.
- Use self-contained original monochrome SVG icons in fixed 24 × 24 containers
  and short labels aligned on the same vertical centerline.
- Keep the center visually quiet; left and right clusters must not cross or
  displace the shared center split.

### `DeckStatus`

- Fixed row height: 72 logical pixels, split into two 36-pixel rows.
- Render two instances with equal responsive widths, one for each active deck.
- Center 64 × 64 cover art or a neutral placeholder in a 72-pixel-wide slot
  spanning both rows.
- Use a two-level hierarchy inspired by the reference:
  - Upper line: a large elided title followed by unlabeled, right-aligned
    remaining-time, key, and BPM values.
  - Lower line: an elided artist followed by a combined
    `pitch icon / current pitch / ± / range` cell, then Loop, Beat Jump, and
    Sync/Lead cells; use muted text for inactive values.
- Text-only metadata is not a touch target. Compact Loop, Beat Jump, and Sync
  controls use the full 36-pixel row height.
- Tapping Sync triggers the momentary `beatsync` control and must not latch
  Sync. Holding it continuously for 2 seconds sets the explicit-leader
  `sync_mode` if the partner deck has no leader. If the partner is already
  Lead, the same hold enables `sync_enabled` on the held deck, preserving the
  partner as Lead and making the held deck a follower. Do not use
  `sync_leader` for the Lead hold because it currently requests only a soft
  leader that may be re-elected when a stopped follower joins Sync. Releasing
  after either hold action must not also trigger Beat Sync.
- Scale the combined Pitch/Range cell from 88 × 36 to 96 × 36, and Loop, Beat
  Jump, and Sync/Lead from 56 × 36 to 64 × 36. Use 18-pixel icons and open
  spacing instead of cell borders or full-height dividers.
- Present Loop and Beat Jump as flat SVG-icon/value cells. Do not distinguish
  them with boxed or contrasting backgrounds; use opacity for momentary press
  feedback.
- At 1024 pixels wide, preserve time, BPM, pitch, key, sync state, and an elided
  title before showing secondary metadata.

### `DeckOverview`

- Fixed row height: 88 logical pixels.
- Render one waveform overview in each deck half, aligned to the same center
  split as `DeckStatus`.
- Show only the upper/left-channel waveform half, scaled to the overview height.
- Show the complete track, current position/playhead, played-versus-upcoming
  position, hotcue markers, and active loop range where the existing waveform
  API supports them.
- Add a small downward-pointing triangle at the top of each active hotcue marker,
  using the cue's stored color and aligned with its vertical marker line.
- Keep cue and loop markers within the waveform overview itself. Do not add the
  two rows of performance-pad names, colors, or empty-slot indicators shown
  beneath the overview in the reference.
- Clip each deck overview to its own half so waveforms, labels, and gestures
  cannot paint across the center boundary.
- If seeking or another gesture is enabled, keep its handler inside that deck's
  half and provide clear pressed/drag feedback.

### First-Slice Acceptance Criteria

- `Ctrl+P` opens Preferences and `Ctrl+Q` quits the application, regardless of
  which TouchQML view currently has focus.
- In `PerformanceView`, the three top components occupy exactly 208 logical
  pixels vertically at every target resolution.
- Their shared deck boundary remains at exactly half the available width while
  resizing through 1024 × 600, 1280 × 800, 1366 × 768, and 1920 × 1080.
- No title, waveform, marker, background, hit area, or divider crosses the deck
  boundary.
- Performance-pad feedback does not consume any space inside the 208-pixel top
  stack.
- Navigation actions retain 48-pixel-high targets; compact deck-status controls
  use 36-pixel-high targets and work without hover.
- Long track metadata elides without changing row height or moving the center
  split.
- Both overviews remain synchronized with their respective loaded tracks and
  update without QML binding or runtime warnings.

## Second Implementation Slice: Browse And Load

The Browse navigation button toggles the core-owned
`[Skin],show_maximized_library` control. While active, the content area below
the persistent 120-pixel navigation/status header replaces `PerformanceView`
with a touch-native all-tracks list backed by Mixxx's QML library model. The
performance-only overview and scrolling waveforms are unloaded while browsing.

- Track rows are 56 logical pixels high and support touch flicking.
- The browser aligns track/artist, rating, genre, comment, key, and duration
  under a persistent column header. Long text elides within its column.
- A tap selects a track. Starting a left drag selects that track as well, before
  the row begins revealing its actions.
- Dragging a row left reveals a 192-pixel action pane containing 96-pixel-wide
  `Load 1` and `Load 2` targets. The row snaps open after crossing its threshold,
  only one row remains open, and recycled rows reset to the closed position.
- Loading uses `Player.loadTrackFromLocationUrl()` and does not rely on drag and
  drop, hover, right click, or a double-click gesture.
- Deck-specific controller triggers open Browse when Performance is visible.
  When Browse is visible, the same trigger loads its selected track into that
  deck and returns to Performance. If no track is selected, Browse remains
  visible.
- Double-tap is retained only as an optional shortcut for loading the selected
  track into Mixxx's next available deck.
- A 48-pixel-high text input filters title, artist, genre, comment, and key with
  a short debounce. It replaces both the global Search navigation button and
  the selected-track/load toolbar above the browser.
- A 48-pixel-high source button to the right of search opens a centered modal
  tree. Activating an available source replaces the track model and keeps the
  search filter local to that model. Current Mixxx QML exposes only All Tracks;
  playlist, crate, and other source wrappers remain upstream follow-up work.

## Third Implementation Slice: Performance Waveforms

`PerformanceView` begins below the persistent DeckStatus row. It owns the
88-pixel `DeckOverviewRow`, two full-width stacked scrolling waveforms, and the
remaining space reserved for later transport, pad, and mixer slices.

- Deck 1 is the upper scrolling waveform with a 3-pixel blue left accent.
- Deck 2 is the lower scrolling waveform with a 3-pixel green left accent.
- The two waveforms divide all vertical space remaining after the overview,
  hotcue strips, strip gaps, and effect row equally. No maximum waveform height
  leaves unused page space. At target viewports each waveform is 134, 234, 218,
  and 374 pixels high respectively.
- Use a portable local composition of `Mixxx.Controls.WaveformDisplay` with RGB
  signal, beat grid, playhead at one third of the width, cue/hotcue marks,
  loop/intro/outro ranges, preroll, and end-of-track warning renderers.
- Use native default hotcue marks so cue numbers, saved labels, indexed stored
  colors, and saved-loop ranges/endpoints stay synchronized with Mixxx. Show the
  main cue and active-loop boundaries explicitly. Show both intro and outro
  endpoints and ranges only while `[Skin],show_intro_outro_cues` is active.
- Markers outside the current scrolling-waveform time window are not represented
  by edge indicators.
- Bind zoom to each deck's `waveform_zoom` control and honor Mixxx's synchronized
  waveform-zoom preference.
- Main waveforms are display-only in this slice. Do not copy the upstream mouse
  scratching, right-button bending, or wheel-zoom handlers into the touch UI.
- Load only the active page so scrolling waveforms do not consume scene-graph
  resources behind Browse.

## Fourth Implementation Slice: Hotcue Strips

Give each full-width waveform its own 32-pixel-high hotcue strip. Deck 1's strip
sits 2 pixels above its waveform, while Deck 2's strip sits 2 pixels below its
waveform.

- Eight equal responsive columns span the full viewport width with 2-pixel gaps,
  no outer padding, and no outlines. Button width is `(viewportWidth - 14) / 8`.
- Buttons use the dark-gray control background and pressed background so the
  strips remain distinct from the performance-page background.
- Each button shows one centered label: `LOOP N` for a saved loop or `CUE N` for
  any other or empty slot. Custom Mixxx cue labels are not shown.
- Show the fixed index color only as a 2-pixel bottom stripe on set cues: yellow
  `#F8D200`, orange `#F8A030`, lila `#AF00CC`, red `#C50A08`, dark green
  `#008800`, light green `#32BE44`, turquoise `#42D4F4`, and blue `#0044FF`.
  Empty slots use a neutral gray bottom stripe.
- Write each fixed color to `hotcue_N_color` whenever its slot contains a cue.
  This deliberately replaces stored colors on loaded tracks and newly created
  cues so waveform markers and other Mixxx views use the same indexed palette.
- Hold `hotcue_N_activate` at 1 while pressed and restore it to 0 on release,
  disable, or page destruction. This preserves Mixxx's set/activate behavior and
  prevents a stuck control if the page loader switches during a touch.
- Do not expose a clear gesture in this slice. Clearing remains available from
  keyboard or controller mappings without adding an accidental destructive
  touch action.
- Disable all hotcue buttons while their deck has no loaded track.

## Fifth Implementation Slice: Deck Effects

Add an 8-pixel gap below Deck 2's hotcue strip, then a row split at the shared
deck center. Its height is fixed at 48 pixels at every viewport, matching the
hotcue row. Each half has four equal contiguous buttons without gaps or outer
padding. Vertical edges are shared neutral gray one-pixel seams; active buttons
highlight their top/bottom edges with the deck accent.

- Show standard `FX1`, `FX2`, and `FX3` buttons followed by `Quick FX`.
- Bind Deck 1 standard buttons to EffectUnit 1 and Deck 2 standard buttons to
  EffectUnit 2. Use slots 1 through 3 of each unit.
- Preserve Mixxx's existing effect routing. Read each unit's
  `group_[ChannelN]_enable` assignment and `enabled` state, but do not alter
  either from this row. Disable standard buttons and show `Unrouted` or
  `Unit Off` when their configured unit cannot process that deck.
- Tapping a routed standard button toggles its slot `enabled` control. Tapping
  `Quick FX` toggles the deck's `[QuickEffectRack1_[ChannelN]],enabled` chain.
- Holding a button for 250 milliseconds opens a centered modal selector
  containing only 48-pixel effect rows. Standard selectors use
  `Mixxx.EffectsManager.visibleEffectsModel` and set
  `EffectSlotProxy.effectId`; Quick FX uses `quickChainPresetModel` and sets
  `loaded_chain_preset`.
- Selecting an effect or Quick Effect preset must preserve the slot or chain
  enabled state. Selection changes only `effectId` or `loaded_chain_preset`.
- Keep current effect names visible on the buttons and show deck-colored active
  feedback. Selection and toggling must require no hover, right click, or mouse
  wheel.

## Architecture Constraints

- Read and follow `docs/architecture.md` before implementation.
- This is a configured QML skin. Test it with `mixxx --developer`; do not use
  `--new-ui` as an equivalent launch path.
- Preserve the restart boundary and profile-safety behavior for QML skin
  selection.
- Prefer the named `Mixxx` and `Mixxx.Controls` modules. Relative imports from
  `res/qml` are acceptable only when the skin is intentionally kept as an
  in-tree bundled skin; do not imply that they form a portable third-party API.
- Use `Mixxx.SkinControlCreator` only for persistent `[Skin]` presentation
  preferences. Use existing application/engine controls for Mixxx state.
- Account for QML engine destruction and recreation during auto-reload.
- Do not allocate, block, or add UI ownership to the real-time engine thread.
- Keep reusable visuals and behavior in focused components; avoid a monolithic
  `main.qml`.
- Keep `docs/architecture.md` synchronized if this work changes documented behavior,
  architecture, limitations, or the list/state of bundled examples.

## Suggested Structure

```text
mixxx-touchqml-skin/
├── Controls/
├── Deck/
├── Library/
├── Mixer/
├── Performance/
├── Theme/
├── main.qml
├── skin.ini
└── skin_preview_<Scheme>.png
```

The exact component split may change as implementation reveals better
boundaries.

## Acceptance Criteria

- The skin is discovered in Preferences > Interface when Mixxx is run with
  `--developer` and QML support enabled.
- Selecting it and restarting with `--developer` opens its `main.qml`; the
  implementation does not rely on `--new-ui`.
- A user can browse for tracks, load both decks, play/cue/sync them, adjust the
  mix, set/trigger hotcues, loop, beat jump, and monitor useful deck state using
  touch input.
- The complete core workflow is usable at 1024 × 600, 1280 × 800,
  1366 × 768, and 1920 × 1080 logical pixels without essential controls being
  clipped or overlapping.
- Core targets meet the 48 × 48 logical-pixel goal except the documented compact
  DeckStatus and hotcue-strip height exceptions. All required actions work
  without hover, right click, or a mouse wheel.
- QML files load without runtime errors or unresolved imports. Auto-reloading
  the skin does not leave duplicate skin controls or invalid bindings.
- The theme is centralized, referenced assets exist, and no Denon/Engine DJ
  proprietary assets or branding are included.
- No tests, C++ sources, or application code outside this repository are
  created or modified for skin-only work.
- `docs/architecture.md` accurately reflects the resulting state.

## Verification Boundary

Do not configure, build, or run Mixxx to verify TouchQML. Do not create or
modify tests, C++ sources, or other application code. Keep implementation
changes inside this repository and documentation changes inside `docs/`.

Use static inspection, `tools/qmlformat.py`, and `qmllint` for QML-only checks.
Manual runtime and touchscreen verification is left to the user. Record any
unavailable Mixxx QML API or library limitation discovered during static
implementation as a follow-up item in the final handoff.
