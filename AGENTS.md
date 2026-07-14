# AGENTS.md

TouchQML is an experimental standalone QML skin for Mixxx. Repository root is
the installable skin directory: `main.qml` and `skin.ini` must remain at root.

The current Mixxx source is to be found in ../mixxx/

## Workflow

- Keep implementation changes inside this repository.
- Do not modify Mixxx C++ sources or tests for skin-only work.
- Do not configure, build, or run Mixxx unless the user explicitly requests it.
- Run static lint from repository root with
  `qmllint *.qml Controls/*.qml Deck/*.qml Library/*.qml Performance/*.qml Theme/*.qml`.
- There is no repo-local build, test suite, CI, task runner, or formatter config.
  Upstream `tools/qmlformat.py` depends on a Mixxx checkout and its
  `.qmlformat.ini`; do not replace it with an unconfigured `qmlformat -i` run.
- When runtime verification is explicitly requested, this configured skin uses
  `mixxx --developer`; `--new-ui` loads a different standalone QML frontend.
- Read `docs/architecture.md` before API or behavior changes and
  `docs/design.md` before layout or interaction changes. Keep both synchronized.

## Structure

- `main.qml` owns the window, shared `width / 2` deck split, persistent
  navigation/status header, keyboard shortcuts, and replaceable page loader.
- `Performance/PerformanceView.qml` owns the overview and stacked scrolling
  waveforms; `Library/BrowseView.qml` is the alternate touch browser page.
- The browser filtering uses
  `DelegateModel` groups, and pooled `TrackRow` delegates must reset swipe state.

## Compatibility

- Prefer named `Mixxx 1.0` and `Mixxx.Controls 1.0` modules.
- Do not add relative imports that depend on this repository living under
  Mixxx's source-tree `res/skins/` directory.
- QML skin APIs remain experimental; verify API names against current Mixxx
  source before adding bindings.
- Bind existing engine/application controls with `Mixxx.ControlProxy`. Use
  `Mixxx.SkinControlCreator` only for new skin-owned `[Skin]` state; duplicate
  core-owned `[Skin]` controls are rejected.
- QML auto-reload destroys and recreates skin-owned objects and controls. Never
  rely on their QObject identity or external connections surviving reload.

## Layout

- Target landscape viewports at 1024 x 600, 1280 x 800, 1366 x 768, and
  1920 x 1080 logical pixels; portrait is out of scope.
- Keep normal touch targets at least 48 x 48 logical pixels; compact DeckStatus
  actions at 36 pixels and waveform hotcue strips at 32 pixels are explicit
  height exceptions.
- Preserve performance top-stack heights: navigation 48, deck status 72,
  overview 88. Browse replaces everything below DeckStatus.
- Preserve full-width 32-pixel hotcue strips: Deck 1 above its waveform and Deck
  2 below its waveform, each separated from the waveform by 2 pixels. Use eight
  buttons with 2-pixel gaps, fixed index colors on 2-pixel bottom stripes for set
  cues, neutral stripes for empty slots, and no outer padding. Applying the fixed
  palette updates stored Mixxx cue colors. Hotcue activation must reset on
  release and component destruction.
- Map Deck 1 to EffectUnit 1 and Deck 2 to EffectUnit 2. Preserve existing
  routing and enabled state while selecting a new effect or Quick Effect preset.
  Keep each deck's four effect buttons contiguous with no gaps or outer padding.
- All top rows use the exact center split supplied by `main.qml`; dividers
  overlay that coordinate rather than consuming a layout column.
- Required actions must not depend on hover, right click, or mouse wheel.

## Visual Style

- Dark, high-contrast booth-oriented surfaces.
- Distinct left and right deck accents.
- Square, restrained geometry with centralized theme tokens.
- Do not copy Denon/Engine DJ branding or proprietary assets; use original or
  suitably licensed assets only.
