# Watch-final

A luxury **watch store** app built with Flutter. Customers browse by brand, search, save favourites and build a cart. Sellers manage inventory and admins manage products and users. Sign-in uses **Firebase Authentication**, and the catalogue, cart and accounts are served by a **Laravel + MySQL** API.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Auth-Firebase-FFCA28?logo=firebase&logoColor=black)
![Backend](https://img.shields.io/badge/Backend-Laravel%20%2B%20MySQL-FF2D20?logo=laravel&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

## Features

**Customers**
- Register and sign in with email/password or **Google**.
- Browse the catalogue by **brand**, **search**, and open a detail page.
- **Favourites** with an animated heart button, and a **cart** with quantities, both stored per account on the backend.
- Profile with **profile-picture upload** (camera or gallery), current location address and device battery level.
- **Offline cache**: the last catalogue is stored with Hive and shown immediately while fresh data loads.
- Light and dark themes (light by default).

**Sellers**
- Seller dashboard with inventory management.

**Admins**
- Admin dashboard to manage **products** and **users**, including changing a user's role.

Roles are `customer` (default), `seller` and `admin`. After sign-in the app opens the matching screen.

## Design

Light by default with a dark toggle, bundled fonts, a drag-to-rotate 360 viewer and a shared photo and logo treatment. See **[docs/DESIGN.md](docs/DESIGN.md)**.

## Architecture in one picture

```
Flutter app ── Firebase Auth (Email / Google) ──▶ identity
     │
     └── HTTPS + Bearer token ──▶ Laravel API (Railway) ──▶ MySQL
            products, cart, favourites, profile photo, admin users
     └── Hive ──▶ local catalogue cache
```

The backend lives in the companion repository **[Laravel-Watch](https://github.com/Hikki-dev/Laravel-Watch)**. After Firebase sign-in the app exchanges the user's details for an API token (`POST /api/auth/google`) and stores it in `shared_preferences`.

## Tech stack

| Area | Packages |
|---|---|
| State | `provider` (`AppController` is a `ChangeNotifier`) |
| Identity | `firebase_auth`, `google_sign_in` |
| Backend API | `http` against the Laravel API |
| Local storage | `hive`, `hive_flutter`, `shared_preferences` |
| Images | `cached_network_image`, `image_picker` |
| Device | `geolocator`, `battery_plus`, `connectivity_plus` |
| Config | `flutter_dotenv` |

## Quick start

```bash
git clone https://github.com/Hikki-dev/Watch-final.git
cd Watch-final
flutter pub get
```

Create a `.env` file in the repo root (it is a declared asset, so the build fails without it) with your Firebase values and API URL, then run. See **[docs/SETUP.md](docs/SETUP.md)** for the exact keys.

```bash
flutter run             # device or emulator
flutter run -d chrome   # web
```

## Project structure

```
lib/
├── main.dart                    # Env, Firebase and Hive init, routes, theme
├── firebase_options.dart        # Reads Firebase values from .env
├── controllers/
│   └── app_controller.dart      # Auth state, catalogue, cart, favourites, profile
├── models/                      # Watch, Brand, Cart, CartItem, User, MysqlProduct, MysqlUser
├── services/
│   ├── auth_service.dart        # Firebase Auth + backend token exchange
│   ├── data_service.dart        # Catalogue, cart, favourites, profile, admin calls + Hive cache
│   ├── api_service.dart         # Generic REST client for admin/seller screens
│   └── image_service.dart
├── views/                       # splash, login, register, home, brand, search, detail,
│   ├── admin/                   # cart, favourites, profile
│   └── seller/                  # dashboards, product and user management, inventory
└── widgets/                     # watch_card, universal_image, animated_favorite_button
assets/images/                   # brand logos and watch photos
test/                            # widget, API-connection and role integration tests
vercel.json                      # SPA rewrite for the Flutter web build
```

## Routes

`/splash`, `/login`, `/register`, `/home`, `/admin`, `/seller`.

## Tests

```bash
flutter test
```

`test/` has a widget test, an API connection test and role-based integration tests. The API tests call the live backend, so they need network access.

## Web deployment

The web build deploys to **GitHub Pages** for free through `.github/workflows/deploy-web.yml`. Setup steps are in **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)**. To build locally:

```bash
flutter build web --release
```

`vercel.json` rewrites every path to `index.html` if you prefer to deploy `build/web` to Vercel or another static host.

## Notes

- The default API base URL (`https://laravel-watch-production.up.railway.app`) is hard-coded as a fallback in `lib/services/`. Override it with `API_BASE_URL` in `.env`.
- Catalogue refresh polls the API every 30 seconds rather than streaming.
- `build/` is no longer committed. CI builds it.

## Author

Built by [Yusuf (Hikki-dev)](https://github.com/Hikki-dev).
