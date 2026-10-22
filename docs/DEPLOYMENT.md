# Free hosting

The web build is deployed to **GitHub Pages**, which is free for public repositories. Vercel's free Hobby plan is limited to non-commercial use, so Pages is the safer default. `vercel.json` is kept if you prefer Vercel.

The API runs separately, see the Laravel-Watch repository's `docs/DEPLOYMENT.md` (Render free web service plus a free TiDB Cloud MySQL database). Free tiers change, so check current limits.

## One-time setup

1. **Enable Pages**: repository **Settings > Pages > Build and deployment > Source: GitHub Actions**.
2. **Add repository variables** under **Settings > Secrets and variables > Actions > Variables**:

   | Variable | Value |
   |---|---|
   | `API_BASE_URL` | The API root including `/api`, for example `https://luxwatch-api.onrender.com/api` |
   | `FIREBASE_PROJECT_ID` | From Firebase project settings |
   | `FIREBASE_MESSAGING_SENDER_ID` | |
   | `FIREBASE_STORAGE_BUCKET` | |
   | `FIREBASE_WEB_API_KEY` | |
   | `FIREBASE_WEB_APP_ID` | |
   | `FIREBASE_WEB_AUTH_DOMAIN` | |
   | `FIREBASE_WEB_MEASUREMENT_ID` | Optional |

   Firebase web values are public identifiers, so variables are fine. Restrict the key by HTTP referrer in Google Cloud.
3. **Authorise the domain**: in Firebase **Authentication > Settings > Authorized domains** add `<your-user>.github.io`.
4. **Allow the origin on the API**: set `CORS_ALLOWED_ORIGINS=https://<your-user>.github.io` on the API service.
5. Push to `main` (or run **Actions > Deploy web to GitHub Pages**). The site appears at `https://<your-user>.github.io/Watch-final/`.

## How it builds

`.github/workflows/deploy-web.yml` writes `.env` from the variables, runs `flutter build web --release` with `--base-href "/Watch-final/"`, copies `index.html` to `404.html` so deep links work, and publishes `build/web`.
