const C='dm-v1';
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',e=>e.waitUntil(clients.claim()));
self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET'||e.request.url.includes('firebaseio.com'))return;
  e.respondWith(caches.open(C).then(async c=>{
    const m=await c.match(e.request);
    const f=fetch(e.request).then(r=>{if(r.ok||r.type==='opaque')c.put(e.request,r.clone());return r}).catch(()=>m);
    return m||f;
  }));
});
