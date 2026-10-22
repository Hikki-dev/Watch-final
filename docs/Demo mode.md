# Demo mode

Demo mode runs the real app with **no Firebase project**. It is how the screenshots in the README were taken.

## What it does

`lib/main_demo.dart` is a second entry point next to `lib/main.dart`. It:

1. Loads `.env` and the Hive cache like the real app.
2. Signs in to the Laravel-Watch API with one of its sample accounts (`customer@example.com`, `seller@example.com` or `admin@example.com`, password `password`) and saves the token.
3. Gives the app a stand-in for the Firebase user, so the app believes you are signed in.
4. Loads the catalogue and your data **before** the first frame, so the splash screen goes straight to your home screen.

It does not call `Firebase.initializeApp`, so the login, register and Google buttons are not used. Everything after sign-in is the real app: the real controller, the real API calls and the real screens.

The real app, `lib/main.dart`, is not changed by any of this.

## Run it

1. Start Laravel-Watch with its sample data. See its [Getting started](https://github.com/Hikki-dev/Laravel-Watch/blob/main/docs/Getting%20started.md).
2. In this project copy `.env.example` to `.env` and set `API_BASE_URL=http://127.0.0.1:8000/api`.
3. Start the app as the account you want:

```bash
flutter run -d chrome -t lib/main_demo.dart --dart-define=DEMO_ROLE=customer
flutter run -d chrome -t lib/main_demo.dart --dart-define=DEMO_ROLE=seller
flutter run -d chrome -t lib/main_demo.dart --dart-define=DEMO_ROLE=admin
```

On the web you can also pick the account in the address, for example `http://localhost:8080/?role=admin`.

## Build it for the web

```bash
flutter build web -t lib/main_demo.dart --release --no-web-resources-cdn
```

`--no-web-resources-cdn` puts the Flutter graphics engine inside the build, so it works without reaching Google's servers. Serve `build/web` with any static server, for example `python3 -m http.server 8080 --directory build/web`. The page must be able to reach the API, and the API must allow its address (see `config/cors.php` in Laravel-Watch).

Do not commit the result over the `build/web` that is already in the repository.

## Limits

* The demo signs in with accounts that have a known password, so only point it at a backend you run yourself. Do not put a demo build on a public address that talks to a real backend.
* The admin Products and Users tiles do not work here. See the [known issues](../README.md#known-issues).
* On a phone or an emulator the API address must be reachable from it. `127.0.0.1` means the phone itself.
