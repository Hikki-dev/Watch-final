# Changes

## Docs and demo mode

1. New README with a hero picture, a tour of every role, two diagrams and an honest list of known issues.
2. New guides: Demo mode, How it works, Fixing problems and Questions and answers, next to the setup guide.
3. New `lib/main_demo.dart`, a Firebase-free entry point that runs the real app against a local Laravel-Watch with its sample accounts. The real `main.dart` is unchanged.
4. New `.env.example`, a Checks workflow, CONTRIBUTING, SECURITY and issue and pull request templates.

## Backend sign-in

1. The Google sign-in now sends the Firebase ID token to the backend, which checks it with Google. Before, the app sent an email address the backend had to trust.

## Laravel API and MySQL (January 2026)

1. Firestore was removed. Products, carts, favourites and profiles now come from the Laravel-Watch API on MySQL.
2. Sensitive values moved into `.env`, and the app now points at the hosted API.
3. Roles (customer, seller, admin) with their own dashboards, and pictures stored as base64.
4. Favourites with an animated heart, profile name editing, a dynamic brand grid and the battery level on the profile page.
5. Images are loaded through `/api/image-proxy`, which fixes CORS on the web.
6. The default theme is light, and dark mode was checked.
7. Cart, search and sign-in automation tests, and better sign-in error messages.

## Firebase version (November 2025)

1. Firebase sign-in, per-user carts and favourites, profile pictures and the current location.
2. Cart clears after checkout.
3. A `vercel.json` so the Flutter web build opens deep links.

## First version (September and October 2025)

1. The Flutter project, brand cards, the complete sign-in system and the core screens.
2. Brand logos and watch pictures for every brand, a dark and light theme switch and a favourites view.
3. The old pages were folded into one `views` folder and an app controller.
