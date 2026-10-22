# Contributing

Thank you for helping. This page explains how to make a change that is easy to accept.

## What we ask of every change

1. Never put a password, an API key or a real person's details in the code, the docs, a test or a screenshot. Secrets belong in `.env`, which is not committed.
2. Anything a person reads, in the app or in the docs, should be in plain English with short sentences.
3. Do not call the hosted API from new code with a hard-coded address. Read `API_BASE_URL` instead.
4. Keep `lib/main.dart` working. `lib/main_demo.dart` is for demos and must never be the default.
5. Add or update a test when you change behaviour.

## Where things are

1. `lib/` is the app. Read [How it works](docs/How%20it%20works.md) first.
2. `docs/` is the written help, and `docs/images` holds the screenshots and diagrams.
3. `test/` holds the tests.

## Running the checks

```bash
cp .env.example .env
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build web --release --no-web-resources-cdn
```

The same two checks run on every pull request: no analyzer errors, and the web build compiles. The tests under `test/` need the live API, so they are not part of the checks.

## Taking new screenshots

Start Laravel-Watch with its sample data, run the app in [demo mode](docs/Demo%20mode.md) and take the pictures from there. That way no real person's data is ever in a screenshot.

## Sending a change

1. Make a branch.
2. Keep the change small and about one thing.
3. Run the checks.
4. Open a pull request. Say what changed, why, and how you tested it.

## Reporting a problem

Open an issue and choose the right form. Say what you expected and what happened. Never paste your `.env`, passwords or keys.
