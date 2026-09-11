// BioVerseAR — offline app-shell service worker.
// Precaches every page, model-viewer, the Draco + KTX2 decoders, and the Animal
// Cells model so the whole app (and its in-page 3D render) works with no network.
// NOTE: the Scene Viewer AR handoff is a separate Android app and does NOT read this
// cache; it caches the model itself after the topic is opened online once.
const CACHE_NAME = 'bioversear-app-v85';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './dashboard.html',
  './badges.html',
  './progress.html',
  './profile.html',
  './teacher.html',
  './leaderboard.html',
  './terms.html',
  './topic.html',
  './ar.html',
  './quiz.html',
  './review.html',
  './styles.css',
  './app.js',
  './config.js',
  './topics.js',
  './questions.js',
  './manifest.json',
  './assets/vendor/supabase.min.js',
  './assets/vendor/model-viewer.min.js',
  './assets/vendor/gsap.min.js',
  './assets/vendor/qrcode.min.js',
  './assets/vendor/draco/draco_wasm_wrapper.js',
  './assets/vendor/draco/draco_decoder.wasm',
  './assets/vendor/basis/basis_transcoder.js',
  './assets/vendor/basis/basis_transcoder.wasm',
  './assets/splash/tarsier-hero.webp',
  './assets/splash/tarsier-hero-scene.webp',
  './assets/icons/icon-192.png',
  './assets/icons/icon-512.png',
  './assets/icons/icon-maskable-512.png',
  './assets/icons/apple-touch-icon.png',
  './assets/icons/favicon-32.png',
  './assets/mascot/tarsier-correct.png',
  './assets/mascot/tarsier-wrong.png',
  './assets/mascot/tarsier-celebrate.png',
  './assets/models/animal_cell.glb',
  './assets/models/animal_cell_labeled.glb',
  './assets/models/human_cell.glb',
  './assets/models/solar_system.glb',
  './assets/models/plant_cell.glb',
  './assets/models/pendulum.glb',
  './assets/models/atom.glb',
  './assets/models/wind_turbine.glb',
  './assets/space-stars.svg'
];

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) { return cache.addAll(ASSETS_TO_CACHE); })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(
        keys.filter(function (k) { return k !== CACHE_NAME; })
            .map(function (k) { return caches.delete(k); })
      );
    })
  );
  self.clients.claim();
});

// Network-first for same-origin GETs: always get the latest when online (fixes stale
// CSS/JS during active development) and refresh the cache; fall back to cache offline.
// Big/stable assets (the model + vendored decoders) stay cache-first for speed.
const CACHE_FIRST = /\/assets\/(models|vendor)\//;

self.addEventListener('fetch', function (event) {
  if (event.request.method !== 'GET') return;
  var url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return; // let cross-origin pass through

  if (CACHE_FIRST.test(url.pathname)) {
    event.respondWith(
      caches.match(event.request).then(function (cached) {
        return cached || fetch(event.request).then(function (resp) {
          var copy = resp.clone();
          caches.open(CACHE_NAME).then(function (c) { c.put(event.request, copy); });
          return resp;
        });
      })
    );
    return;
  }

  // network-first for the app shell (HTML/CSS/JS/manifest); {cache:'no-cache'} forces
  // revalidation so GitHub Pages' max-age can't serve a stale file within its window.
  event.respondWith(
    fetch(event.request, { cache: 'no-cache' }).then(function (resp) {
      var copy = resp.clone();
      caches.open(CACHE_NAME).then(function (c) { c.put(event.request, copy); });
      return resp;
    }).catch(function () {
      return caches.match(event.request).then(function (cached) {
        return cached || caches.match('./index.html');
      });
    })
  );
});
