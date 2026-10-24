# Contributing

Fixes and ideas are welcome. This page says how to set up, check your work and send a change.

## Set up

Follow [Getting started](docs/Getting%20started.md). You need the Flutter SDK (Dart `^3.8.1`), a Firebase project and a `.env` file.

## Check your work

```bash
flutter analyze
flutter test
```

`flutter test` includes tests that call a live API, so they need network access and a working `API_BASE_URL`.

## What we ask

* **One change per pull request**, with a message that says what and why in plain words.
* **A test** for new behaviour, next to the existing ones in `test/`.
* **Stay inside the theme.** Read colours with `context.lux` so light and dark both work. See [Design](docs/DESIGN.md).
* **Look at it.** Run the app, in light and dark, and add screenshots when the look changes.
* **No secrets.** Never commit `.env` or private keys.
* **No pictures you do not own.** The brand logos and watch photos in `assets/` are third party pictures kept for a showcase.

## Good places to start

* A screen that is missing a test.
* The iOS location text described in [Fixing problems](docs/Fixing%20problems.md).
* A sentence in a guide that is not clear. Plain words beat clever ones.

## Questions

Open an [issue](https://github.com/Hikki-dev/Watch-final/issues/new/choose).
