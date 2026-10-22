# Design system

The app follows one visual language shared with the Laravel web storefront.

## Themes

- **Light is the default.** Dark is a toggle in the app bar (and Account), remembered between launches in `shared_preferences` under `lux-theme`.
- `lib/theme/lux_theme.dart` defines `LuxTheme.light()` and `LuxTheme.dark()`. Palette tokens live in the `LuxColors` theme extension, read with `context.lux`. It falls back to the matching palette under a plain Material theme, so widgets also work in tests and previews.

| Token | Light | Dark |
|---|---|---|
| bg | `#F5F3EF` | `#0B0C0D` |
| panel | `#FFFFFF` | `#131416` |
| line | `#DCD8CE` | `#2A2B2F` |
| text | `#121315` | `#EEEAE2` |
| mute | `#66625A` | `#A09C93` |
| accent | `#7A5C28` | `#C8AE7B` |

## Type

Bundled in `assets/fonts` (no network fetch): Cormorant Garamond for names and headings, Hanken Grotesk for the interface, DM Mono for prices and references. Prices use `PriceText`, small labels use `Eyebrow`.

## Widgets

`lib/widgets/lux_widgets.dart`: `Eyebrow`, `PriceText`, `LuxStage` (studio backdrop behind photography), `BrandLogoPlate`, `ThemeToggleButton`, `StatusPill`, `Reveal` (staggered entrance; respects the system "reduce motion" setting).

## 360 viewer

`SpinViewer` (`lib/widgets/spin_viewer.dart`) scrubs an ordered list of frames as you drag, with momentum, an optional slow auto-spin and a `SpinController` for Front / Angle / Side / Back chips. The watch detail screen shows it when `Watch.spinFrames` holds at least 8 frames, otherwise it shows the photo.

Frames come from the API field `spin_frames` (a list of URLs or paths, ordered through one full turn). Shoot 36 to 120 frames of one watch on a plain background from a fixed camera. No frames are bundled: add them per product on the backend.

## Assets

`assets/images/brands` holds the logos on opaque white, so they are always shown on a white plate (`BrandLogoPlate`). Logos and watch photos were resized and recompressed (about 4 MB of photos down to 2.6 MB, logos 440 KB to 177 KB). Keep new images to about 1400 px on the long side.
