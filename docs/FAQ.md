# Questions and answers

**Is this a real shop?**
No. It is a portfolio and learning project. The watches, prices and photographs are sample content. Nothing is for sale.

**Can I try it without a Firebase project?**
Yes. See [Demo mode](Demo%20mode.md). It needs the Laravel-Watch backend running on your computer.

**Where is the backend?**
In [Laravel-Watch](https://github.com/Hikki-dev/Laravel-Watch). It serves the catalogue, carts, favourites, profiles and roles, and it has its own website too.

**Why Firebase and Laravel?**
The app started with Firebase for everything. In January 2026 the data moved to the Laravel API and MySQL, and Firebase stayed for sign-in. See [How it works](How%20it%20works.md).

**Can I pay in the app?**
Not yet. The **Checkout** button only shows a message and clears the cart. Paying with Stripe is built into the Laravel-Watch website.

**How do I become a seller or an admin?**
An admin can change a user's role, or you can change `users.role` in the backend database. The role comes from the API when you sign in.

**Which sample accounts exist?**
Only in the backend, after `php artisan migrate --seed`: `admin@example.com`, `seller@example.com` and `customer@example.com`, with the password `password`. They are for your own computer only.

**Does it work offline?**
Partly. The last catalogue is kept on the device and shown at once. Carts, favourites and sign-in need the network.

**Which platforms are supported?**
Android, iOS and the web. The folders for Windows, macOS and Linux are there from the Flutter template, but the project is not set up or tested for them.

**Can I use the code?**
There is no licence file yet, so all rights are reserved for now. Ask first.
