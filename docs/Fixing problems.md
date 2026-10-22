# Fixing problems

| What you see | What to do |
|---|---|
| `unable to find asset .env`, or a build error about `.env` | Copy `.env.example` to `.env`. It is a declared asset in `pubspec.yaml`, so the build fails without it |
| "Initialization Error" on a plain white screen | `main.dart` could not start Firebase or Hive. Check the Firebase values in `.env` and read the console message |
| The catalogue is empty | The API cannot be reached, or `API_BASE_URL` is wrong. It must include `/api`. Open `<API_BASE_URL>/products` in a browser to check |
| Google sign-in works but the app shows an error | Firebase signed you in, but the API's `/auth/google` swap failed. Check the API logs and that it has `FIREBASE_WEB_API_KEY` |
| "Token is null" on a photo upload | Sign out and in again to get a fresh API token |
| Everyone lands on the customer screen | The role from the API is not exactly `admin` or `seller`. Check the `users` table |
| Pictures do not show on the web | The API must allow the address of the web page in its CORS settings, and `/api/image-proxy` must be reachable |
| Phone or emulator cannot reach my computer | `127.0.0.1` means the phone itself. Use your computer's network address and start Laravel with `php artisan serve --host=0.0.0.0` |
| Location says "Fetching..." | Allow location for the app. On iPhone `NSLocationWhenInUseUsageDescription` must be added to `ios/Runner/Info.plist` first |
| The admin Products or Users tile shows "Error loading" | A known issue. See the [README](../README.md#known-issues) |
| `flutter test` fails | The tests under `test/` call the live API. They need a network and the hosted backend to be up |
| `flutter pub get` changes `pubspec.lock` or `analysis_options.yaml` | Normal when your Flutter version differs. Do not commit that change by accident |

## Reading the app's messages

The app prints what it is doing to the console (`debugPrint`): the requests it sends, the status codes it gets back and what it does with the catalogue. In Chrome open the developer tools and look at the **Console** tab. In an IDE look at the run output.

## Still stuck?

Open an issue and use the **Problem** template. Say what you ran, what you expected and what happened, and paste the console text. Never paste your `.env`.
