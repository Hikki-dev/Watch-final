# How it works

A map of the code, for people who want to change it.

```
lib/
├── main.dart                    # Env, Firebase and Hive start up, routes, theme
├── firebase_options.dart        # Reads Firebase values from .env
├── controllers/
│   └── app_controller.dart      # Auth state, catalogue, cart, favourites, profile, role
├── models/                      # Watch, Brand, Cart, CartItem, User, MysqlProduct, MysqlUser
├── services/
│   ├── auth_service.dart        # Firebase Auth, and the token trade with the API
│   ├── data_service.dart        # Catalogue, cart, favourites, profile, admin calls, Hive cache
│   ├── api_service.dart         # A plain REST client used by the admin and seller screens
│   └── image_service.dart
├── theme/lux_theme.dart         # Light and dark palettes, fonts
├── views/                       # splash, login, register, home, brand, search, watch detail,
│   ├── admin/                   #   cart, favourites, profile
│   └── seller/                  # dashboards, product and user management, inventory
└── widgets/                     # watch card, 360 viewer, animated heart, shared pieces
assets/                          # brand logos, watch photos, fonts
test/                            # widget, API connection and role tests
```

## The pieces

* **`AppController`** is the one place that holds state. Screens read it with `provider` and call its methods.
* **`AuthService`** wraps Firebase and the call to `POST /auth/google`. The API address comes from `API_BASE_URL`.
* **`DataService`** makes every call to the API with the saved token, and keeps the catalogue in a Hive box.
* **Routes** are `/splash`, `/login`, `/register`, `/home`, `/admin` and `/seller`. A brand page (`/brand`) and a watch page (`/watch`) take an argument.
* **Theme.** `LuxTheme.light()` and `LuxTheme.dark()`. Read colours with `context.lux`. See [Design](DESIGN.md).

## Things to know

* The API base address falls back to an older host if `API_BASE_URL` is missing. Always set the variable.
* `ApiService` uses its own base address constant, so check it as well when you point the app at a new host.
* Responses may be a bare list or wrapped in `{ "data": [...] }`. The code accepts both.
* The API tests in `test/` call a live backend, so they fail offline.
