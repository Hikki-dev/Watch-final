# Setup guide

## 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.8.1`)
- A [Firebase](https://console.firebase.google.com/) project (Authentication only)
- A running instance of the Laravel API from [Laravel-Watch](https://github.com/Hikki-dev/Laravel-Watch), or access to the hosted one

## 2. Firebase Authentication

1. Create a Firebase project and register your platforms (Android, iOS, Web, macOS, Windows as needed).
2. **Authentication > Sign-in method**: enable **Email/Password** and **Google**.
3. For Android, add your debug and release **SHA-1** fingerprints and place `google-services.json` in `android/app/`.
4. For iOS, add `GoogleService-Info.plist` and the reversed client ID as a URL scheme in `Info.plist`.

## 3. Create the `.env` file

`lib/firebase_options.dart` reads its values from `.env`, and `.env` is listed as an asset in `pubspec.yaml`. **The file must exist or the app will not build or start.** It is git-ignored.

| Key | Notes |
|---|---|
| `API_BASE_URL` | Laravel API root including `/api`, for example `https://your-host/api` |
| `FIREBASE_PROJECT_ID` | |
| `FIREBASE_MESSAGING_SENDER_ID` | |
| `FIREBASE_STORAGE_BUCKET` | |
| `FIREBASE_ANDROID_API_KEY`, `FIREBASE_ANDROID_APP_ID` | Android |
| `FIREBASE_IOS_API_KEY`, `FIREBASE_IOS_APP_ID`, `FIREBASE_IOS_BUNDLE_ID`, `FIREBASE_IOS_CLIENT_ID` | iOS |
| `FIREBASE_MACOS_API_KEY`, `FIREBASE_MACOS_APP_ID`, `FIREBASE_MACOS_BUNDLE_ID`, `FIREBASE_MACOS_CLIENT_ID` | macOS |
| `FIREBASE_WEB_API_KEY`, `FIREBASE_WEB_APP_ID`, `FIREBASE_WEB_AUTH_DOMAIN`, `FIREBASE_WEB_MEASUREMENT_ID` | Web |
| `FIREBASE_WINDOWS_API_KEY`, `FIREBASE_WINDOWS_APP_ID`, `FIREBASE_WINDOWS_AUTH_DOMAIN`, `FIREBASE_WINDOWS_MEASUREMENT_ID` | Windows |

Only fill in the platforms you build for. Get the values from Firebase project settings, or from the output of `flutterfire configure`.

```env
API_BASE_URL=https://your-host/api
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_MESSAGING_SENDER_ID=...
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_WEB_API_KEY=...
FIREBASE_WEB_APP_ID=...
FIREBASE_WEB_AUTH_DOMAIN=your-project-id.firebaseapp.com
```

Firebase client keys are identifiers rather than secrets, but restrict them (authorised domains, app restrictions) in the Firebase and Google Cloud consoles.

## 4. Backend

The app needs these Laravel endpoints (see the [Laravel-Watch](https://github.com/Hikki-dev/Laravel-Watch) repo):

| Purpose | Endpoint |
|---|---|
| Exchange Firebase sign-in for an API token | `POST /api/auth/google` |
| Catalogue | `GET /api/products` |
| Seller inventory | `/api/seller/products` |
| Admin users | `GET /api/admin/users`, `PATCH /api/admin/users/{id}/role`, delete |
| Profile photo | `POST /api/profile/photo` |
| Cart | `GET /api/cart`, `POST /api/cart/add/{id}`, `PATCH/DELETE /api/cart/product/{id}`, `DELETE /api/cart/clear` |
| Favourites | per-user endpoints under `/api` |

Responses may be a bare list or wrapped in `{ "data": [...] }`. A product looks like:

```json
{ "id": 1, "seller_id": 2, "name": "Submariner Date", "brand": "Rolex",
  "price": "14500.00", "stock_quantity": 5, "description": "..." }
```


## 5. Roles

Roles live on the backend user: `customer` (default), `seller`, `admin`. Promote someone through the admin dashboard, or directly in the MySQL `users` table.

## 6. Permissions

- **Android**: camera, gallery and location are requested at runtime.
- **iOS**: `ios/Runner/Info.plist` already has the camera and photo-library descriptions. It does **not** yet have `NSLocationWhenInUseUsageDescription`, which the "current location" feature needs on iPhone. Add it before shipping.

## 7. Run

```bash
flutter pub get
flutter run             # device or emulator
flutter run -d chrome   # web
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `unable to find asset .env` or Firebase init error | Create `.env` with the keys above. |
| Empty catalogue | The API is unreachable or `API_BASE_URL` is wrong. Check the network and the API. |
| Signed in with Google but app shows an error | The backend token exchange failed (`/auth/google`). Check the API logs. |
| "Token is null" on photo upload | Sign out and back in to refresh the API token. |
| Everyone lands on the customer screen | The backend role is not exactly `admin` or `seller`. |
