/* ATHAR service worker — app shell cache (network-first for HTML). */
const CACHE = 'athar-v113';
const SHELL = ['./Athar-Platform.html', './manifest.json', './icon-192-v4.png', './icon-512-v4.png', './icon-maskable-512-v4.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).catch(() => {}));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // Never cache Supabase / API / cross-origin dynamic calls
  if (url.origin !== self.location.origin) return;
  // Network-first for the app HTML; cache fallback offline
  if (req.mode === 'navigate' || req.destination === 'document' || url.pathname.endsWith('.html')) {
    e.respondWith(
      fetch(req).then(res => { const cp = res.clone(); caches.open(CACHE).then(c => c.put(req, cp)); return res; })
        .catch(() => caches.match(req).then(r => r || caches.match('./Athar-Platform.html')))
    );
    return;
  }
  // Cache-first for static same-origin assets (icons/manifest)
  e.respondWith(caches.match(req).then(r => r || fetch(req)));
});
