# How it works

This is the map for anyone who wants to change the code.

## The big idea

Watch-final is only the front end. It keeps no database of its own.

* **Firebase Auth** says who you are (email and password, or Google).
* **The Laravel-Watch API** keeps products, carts, favourites, profiles and roles. See [Laravel-Watch](https://github.com/Hikki-dev/Laravel-Watch).
* **Hive and shared preferences** keep a copy of the last catalogue and the API token on the device.

<p align="center"><a href="images/how-it-fits.svg"><img src="images/how-it-fits.svg" alt="How the app fits together" width="100%"></a></p>

## Starting up

`lib/main.dart` loads `.env`, starts Firebase and Hive, creates an `AuthService` and an `AppController`, and shows the `SplashView`. The routes are `/splash`, `/login`, `/register`, `/home`, `/admin` and `/seller`, plus `/brand` and `/watch`, which take an argument.

## Signing in

`AuthService` (`lib/services/auth_service.dart`) does two things on every sign-in.

1. It signs in with **Firebase**. For email it calls `signInWithEmailAndPassword`. For Google it uses `google_sign_in`.
2. It signs in to the **API**. For email it posts the email and password to `/login`. For Google it posts the Firebase ID token to `/auth/google`, and the API checks that token with Google. Either way the answer holds an API token, which the app saves in `shared_preferences` as `auth_token`.

<p align="center"><a href="images/sign-in-flow.svg"><img src="images/sign-in-flow.svg" alt="From sign-in to the right screen" width="100%"></a></p>

## The controller

`AppController` (`lib/controllers/app_controller.dart`) is a `ChangeNotifier` that the screens watch with `provider`. It holds:

* the signed-in user and their role,
* the whole catalogue, and the brands made from it,
* the cart and the favourites,
* loading and error state.

When the sign-in state changes it asks the API for your profile (`/user`), your cart (`/cart`) and your favourites, and then builds the `User` model. The **role** in that answer decides the home screen: `admin` goes to `/admin`, `seller` to `/seller`, anyone else to `/home`.

## The catalogue and the cache

1. On start the controller reads the last catalogue from Hive, so something shows at once.
2. It then fetches `/products` from the API and saves the fresh list to Hive.
3. It asks again every 30 seconds.

Brands are made from the products, so a brand with no watches does not show.

## Pictures

Product pictures come from `/api/image-proxy?path=...` on the API, which avoids browser CORS problems on the web. `UniversalImage` (`lib/widgets`) picks the right way to show an address, an asset or a stored picture. Brand logos are bundled in `assets/images/brands`.

## Where things are

```
lib/
├── main.dart                    # env, Firebase and Hive start-up, routes, theme
├── main_demo.dart               # Firebase-free entry point, see docs/Demo mode.md
├── firebase_options.dart        # reads Firebase values from .env
├── controllers/app_controller.dart
├── models/                      # Watch, Brand, Cart, CartItem, User, MysqlProduct, MysqlUser
├── services/
│   ├── auth_service.dart        # Firebase + API token swap
│   ├── data_service.dart        # catalogue, cart, favourites, profile, Hive cache
│   ├── api_service.dart         # plain REST client for the admin and seller screens
│   └── image_service.dart
├── views/                       # splash, login, register, home, brand, search, detail,
│   ├── admin/                   # cart, favourites, profile
│   └── seller/                  # dashboards, product and user management, inventory
└── widgets/                     # watch_card, universal_image, animated_favorite_button
test/                            # widget, API connection and role tests
```

## Two clients, one history

The app used to keep carts and favourites in Firebase. In January 2026 that was replaced with the Laravel API (see [Changes](../CHANGELOG.md)). `DataService` is the new client. `ApiService` is an older, simpler one that the admin tiles still use, which is why it has its own hard-coded address. Moving the admin tiles onto `DataService` is the natural next step.
