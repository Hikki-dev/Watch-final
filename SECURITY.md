# Security

## Reporting a problem

Please do not open a public issue for a security problem. Use the **Report a vulnerability** button on the Security tab of this project on GitHub. Say what you found and how to repeat it.

## What this project protects

1. Sign-in is done by Firebase Auth. The app never stores a password.
2. The API token is kept on the device in `shared_preferences` and is sent as a bearer token. It is removed when you sign out.
3. Secrets and keys are read from `.env`, which is git-ignored.

## What to keep in mind

1. Firebase client keys identify your app, they are not secrets. Restrict them in the Firebase and Google Cloud consoles (authorised domains, app restrictions).
2. `lib/services/api_service.dart` has the hosted API address hard-coded and sends no token. See the [known issues](README.md#known-issues).
3. `lib/main_demo.dart` signs in with sample accounts that have a known password. Use it only against a backend you run yourself, and never publish a demo build that points at a real backend.
4. `build/web` is committed. Only publish a build that you made from `lib/main.dart`.
5. Keep your `.env`, Firebase keys and API tokens out of screenshots and bug reports.
