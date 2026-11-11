const C = 'dm-v2';
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== C).map(k => caches.delete(k)))).then(() => clients.claim())));
self.addEventListener('fetch', e => {
  const r = e.request;
  if (r.method !== 'GET' || r.url.includes('firebaseio.com') || r.url.includes('firebasedatabase.app')) return;
  if (new URL(r.url).origin === location.origin) {
    // নিজের ফাইল: আগে নেট থেকে নতুনটা, নেট না থাকলে জমানো কপি
    e.respondWith(fetch(r, { cache: 'no-cache' }).then(res => { const c = res.clone(); caches.open(C).then(x => x.put(r, c)); return res; }).catch(() => caches.match(r)));
    return;
  }
  e.respondWith(caches.open(C).then(async c => {
    const m = await c.match(r);
    const f = fetch(r).then(res => { if (res.ok || res.type === 'opaque') c.put(r, res.clone()); return res; }).catch(() => m);
    return m || f;
  }));
});
