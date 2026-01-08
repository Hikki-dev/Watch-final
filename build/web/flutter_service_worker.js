'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "328b98612636e91124317be14646329f",
".vercel/project.json": "16179d4c49a94f3ce498064b79e08bcb",
".vercel/README.txt": "2b13c79d37d6ed82a3255b83b6815034",
"version.json": "03d82c74db8161b02fc7dbd109b528be",
"index.html": "b05db9b934637fb76b9e91030aea57f4",
"/": "b05db9b934637fb76b9e91030aea57f4",
"main.dart.js": "fd353c136e2a6265ab6acd5a8536f436",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "844bb3efa155c0449fcef79c8b2d730e",
"assets/AssetManifest.json": "62f86d02716dfaa5aa3f7af80d0a8371",
"assets/NOTICES": "92ee1f656c2972221f05b746784a093b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "cb2a6c1c95b3815a58b579f9566031c9",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "39daaa0ea803667108be522d532827b0",
"assets/fonts/MaterialIcons-Regular.otf": "522b2a4c1990ab8e0a2d8e3b16c4e830",
"assets/assets/images/watches/richard-mille-1.jpg": "7e284a8dfd74b1168f48a43bc00ec550",
"assets/assets/images/watches/ap-royal-oak-1.jpg": "39f6d30009a0423afe0ca4ec20529813",
"assets/assets/images/watches/richard-mille-2.jpg": "674294fc17dbe17ef2757088123a2a64",
"assets/assets/images/watches/ap-royal-oak-2.jpg": "ea5acb9b931658a1031b1ad24ac1f846",
"assets/assets/images/watches/citizen-watch.jpg": "d833f170a5edc5b9e2f35f5c69d8cc78",
"assets/assets/images/watches/casio-gshock.jpg": "7c30e8f0cf77687647c73d8dcd4c277d",
"assets/assets/images/watches/swatch-big-bold-chrono-1.jpg": "b8f7997e91b6f6d5b193163606a59d38",
"assets/assets/images/watches/seiko-watch.jpg": "0dc8f2959b2a2189062898582fe85dc5",
"assets/assets/images/watches/omega-speedmaster-1.jpg": "3127363167aab2e888141d95927d1201",
"assets/assets/images/watches/omega-speedmaster-2.jpg": "a59905c35b13d3ca09e2667da835cdff",
"assets/assets/images/watches/swatch-skin-classic-1.jpg": "0a1e87002f70cc1ec91bbf5c13a9d5f9",
"assets/assets/images/watches/rolex-submariner-1.jpg": "68039f049844a6169c8170dd1c5c0140",
"assets/assets/images/watches/tag-heur-watch.jpg": "bea352cb100a55d9bba3c256bce2f196",
"assets/assets/images/watches/swatch-scubaqua.jpg": "f40167d26b5b5c8bbd6aa31e4b611df8",
"assets/assets/images/watches/rolex-gmt-1.jpg": "be5a04822115c0de952e596b7cb74de2",
"assets/assets/images/watches/rolex-submariner-2.jpg": "d8ec45462fc16920101fc0078cad8d9d",
"assets/assets/images/watches/patek-calatrava-1.jpg": "03f5b98a40b66d909a0224e9ac5a55b3",
"assets/assets/images/watches/swatch-logo.png": "32f608cafdcf369c648259a1cef17e4a",
"assets/assets/images/watches/omega-seamaster-1.jpg": "f6234ee2c6ab223d18e37af114181c20",
"assets/assets/images/watches/patek-nautilus-2.jpg": "82c61f7bfdf01a45c3dcd3d1f3b93cb2",
"assets/assets/images/watches/swatch-sistem51-irony-1.jpg": "74c8e2c000bea0be238d273e3d0dd242",
"assets/assets/images/watches/patek-nautilus-1.jpg": "81c84c721093dafbcaa234c9cd09ee85",
"assets/assets/images/brands/ap.png": "beccbdb5302c69c842760b6e0fae3cd7",
"assets/assets/images/brands/seiko.png": "245ee43fa51d6cf57c1c82ce4272404c",
"assets/assets/images/brands/casio.png": "883455b21bbd670d61ea286a2245c79a",
"assets/assets/images/brands/omega.png": "f136e5389f836ea12589c456ca45621a",
"assets/assets/images/brands/richard_mille.png": "848befa9de86c347719949134692be10",
"assets/assets/images/brands/tag_heuer.png": "ed0cf774c80ad307a8d46c718cd7111f",
"assets/assets/images/brands/swatch.png": "32f608cafdcf369c648259a1cef17e4a",
"assets/assets/images/brands/patek.png": "df8c399a161dfdee27ad6f35d03000b2",
"assets/assets/images/brands/citizen.png": "8b383ce16d619f2732881c6416f6cdcc",
"assets/assets/images/brands/rolex.png": "7115abc763d40903a8808f3e7ee3aa0c",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
