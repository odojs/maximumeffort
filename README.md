# Maximum Effort
Dispatch tasks to Web Workers

Dispatcher:
```js
var maximumeffort = require('maximumeffort');
var worker = maximumeffort('dist/worker.js');
var payload = { content: [1, 2, 3] };
worker.emit('eventname', payload, function (error, result) {
    console.log(result); // { event: 'eventname', payload: { content: [1, 2, 3] } }
});
worker.stop(['events', 'tocancel']);
console.log(worker.info()); // { available: 15, pending: 0, busy: 1 }
```

Worker:
```js
self.addEventListener('message', function (e) {
  post = function() { self.postMessage(e.data); }
  setTimeout(post, 2000);
});
```

`maximumeffort(url, maxWorkers (optional))`

Better worker:
```js
var hub = require('odo-hub');
hub = hub()
hub.every('eventname', function (p, cb) {
    cb();
    post = function() {
        self.postMessage('finished');
    }
    setTimeout(post, 2000);
})
self.addEventListener('message', function (e) {
    hub.emit(e.event, e.payload);
});
```