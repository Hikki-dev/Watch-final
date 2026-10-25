# Fixing problems

Find what you see, then try the fix. Most problems here are small.

## "unable to find asset .env", or a Firebase error at start

Create the `.env` file in the project folder. It is a declared asset, so the build fails without it. The keys are in [Getting started](Getting%20started.md#3-create-the-env-file). The app shows an "Initialization Error" screen with the reason when it can start but cannot load the settings.

## The catalogue is empty

The API cannot be reached, or `API_BASE_URL` is wrong. Open `https://<your-host>/api/products` in a browser. If you see JSON, the store is fine and the address in `.env` is the problem. Remember it must end in `/api`, or in `/api/api` for a store hosted on Vercel.

## I signed in with Google but the app shows an error

The token trade failed at `/auth/google`. Look at the API's logs. The store needs `FIREBASE_WEB_API_KEY` set to check the token. The live Laravel-Watch demo has the key now (a bad token gets a 401). A real Google sign in from the app was not tried for this guide.

## "Token is null" when I change my photo

Sign out and in again to get a fresh API token.

## Everyone lands on the customer screen

The role stored on the marketplace is not exactly `admin` or `seller`. Change it in the admin screen or in the database.

## The web version cannot reach the API

The marketplace must allow the web address. Set `CORS_ALLOWED_ORIGINS` on the API to the address the app is served from, and add that address to **Authorized domains** in Firebase Authentication.

## The iPhone says nothing when I ask for my location

`ios/Runner/Info.plist` has no `NSLocationWhenInUseUsageDescription`. Add one with a sentence that says why you need the location.

## The GitHub Pages deploy stops with "Not Found"

Pages is not switched on for the repository. Open **Settings, Pages** and choose **GitHub Actions** as the source, then run the workflow again. That was the reason for the first failed run.

## `flutter test` fails

The API tests call a live backend. They need network access and a working `API_BASE_URL`.
