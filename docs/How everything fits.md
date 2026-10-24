# How everything fits

![The app, Firebase sign in and the Laravel-Watch API](images/how-it-fits.svg)

This page follows one shopper from opening the app to a cart that is waiting on another phone, so you can see which part does what.

## 1. The app starts

`main.dart` loads the `.env` file, starts Firebase and Hive, then builds the app. If any of that fails, the app shows the error on screen instead of a blank page. The saved theme (light unless you chose dark) is read from `shared_preferences`.

## 2. The shopper signs in

The shopper uses email and password or Google. **Firebase** checks them. The app takes Firebase's ID token and sends it to the marketplace at `POST /api/auth/google`. The marketplace checks that token with Google, finds or creates the account and answers with its own API token. The app keeps that token in `shared_preferences` under `auth_token`.

## 3. The catalogue arrives

`AppController` first shows the catalogue saved in Hive, so there is something on screen at once. It then asks `GET /api/products` and replaces the list, saving the new one for next time. While a screen is listening, it asks again every 30 seconds.

## 4. The shopper picks a watch

Browsing is done on the device, from the list already loaded: brand pages, search and the watch page all read it. If the watch has at least eight 360° frames, the page shows a viewer you can drag.

## 5. Favourites and the cart

A heart or **Add to cart** is sent to the marketplace with the API token. The marketplace stores it against the account, so the same cart and the same hearts appear on any device where the person signs in.

## 6. Roles decide what you see

The marketplace says what role the person has: `customer`, `seller` or `admin`. The app opens the screens that fit. The marketplace is the one that enforces the rules, because an API token only carries the abilities of its role.

## 7. Checkout

The app's **CHECKOUT** is a placeholder that shows a thank you message and clears the cart. Real orders and Stripe payments happen on the marketplace website.

## Why it is built this way

* **One source of truth.** The marketplace holds all the data, so the website and the app never disagree.
* **Fast start.** Hive keeps the last catalogue, so the first screen never waits for the network.
* **Plain state.** One `ChangeNotifier` (`AppController`) holds the state, which keeps the screens simple to read.
