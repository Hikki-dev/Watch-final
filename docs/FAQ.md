# Questions and answers

**Is this a real shop?**
No. It is a portfolio project that shows a Flutter shopper app talking to a real backend. Nothing is sold.

**Where is the live demo?**
Not online right now. The planned address answers "deployment not found", and the GitHub Pages deploy needs Pages to be switched on. See the [README](../README.md#the-live-demo). The [Laravel-Watch demo](https://luxwatch-livid.vercel.app) shows the marketplace the app uses.

**Do I need Laravel-Watch to run the app?**
Yes, or another API with the same routes. The app has no data of its own. See [How everything fits](How%20everything%20fits.md).

**Do payments work?**
Not in the app. **CHECKOUT** is a placeholder that shows a thank you and clears the cart. Payments with Stripe are on the marketplace website.

**Why Firebase and an API token?**
Firebase handles sign in well, on every platform. The marketplace then needs its own token to know what the person may do. The app trades one for the other.

**Does it work offline?**
Partly. The last catalogue is kept on the device and shown first. Everything that needs the server, such as the cart, needs a connection.

**How do I change the colours or fonts?**
In `lib/theme/lux_theme.dart`. See [Design](DESIGN.md).

**Where do 360° views come from?**
The marketplace sends a list of frame pictures with a watch. The app shows the viewer when there are at least eight. No frames are bundled in this repository.

**Which platforms are supported?**
The README badges list Android, iOS and web, and those are the ones this guide covers. The project folder also holds macOS, Windows and Linux folders from the Flutter template. They are not described or checked here.
