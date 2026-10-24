# Security

## Reporting a problem

Please do not open a public issue for a security problem. Use GitHub's private reporting: **Security, Report a vulnerability** on this repository. Say what you found, how to repeat it and what it could allow.

## What to know

* This is a portfolio project. Checkout in the app is a placeholder: it shows a thank you message and empties the cart. No payment is taken in the app.
* Sign in is handled by **Firebase Authentication**. The app then holds an API token from the store in `shared_preferences` on the device.
* Roles are decided by the store's API. The app only hides screens, so never rely on the app to protect data.
* The Firebase client files `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` and the macOS twin are committed. They hold client identifiers, not server secrets, but you should restrict the keys (app restrictions, authorised domains) in the Firebase and Google Cloud consoles.
* `.env` is never committed. The Pages workflow builds one from repository variables.

## Keys and settings

Real keys belong in your own `.env` or the host's settings, never in git. See [Getting started](docs/Getting%20started.md).
