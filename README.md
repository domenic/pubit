Pubit
=====
Responsible publish/subscribe. Hide the event publisher, only exposing the event emitter.

Why is this cool?
-----------------

Most pub/sub frameworks conflate the roll of publisher and emitter. This means that if someone gets ahold of your emitter object, they can not only subscribe to events, but also fake out all other subscribers by emitting an artificial event:

```javascript

// server.js
process.on("exit", cleanupServerStuff);

// thirdParty.js
process.emit("exit");
// uh oh, now the server stuff's been all cleaned up!
```

With **pubit**, the publisher and emitter are separate, allowing you to keep the publisher private while exposing emitter functionality. Here's a hypothetical implementation of a `process` module using pubit:

```javascript
var pubit = require("pubit");

var publish = pubit.makeEmitter(exports);

exports.exit = function (exitCode) {
  publish("exit", exitCode);
};
```

This module only exports the emitter interface (`on`, `off`, and `onNext`); the publish function is kept private.

Aren't you being paranoid?
--------------------------

There's [some argument][1] as to what role encapsulation has to play in JavaScript. Some might say, “if you don't want the event to be emitted outside the emitter … don't emit the event outside the emitter.”

But encapsulation isn't about being paranoid. It's about _hiding complexity_: exposing a solution, without requiring the consumer to grok the gory details of the problem. An emitter by itself is simple and easy to interface with, but when you add nobs for publishing or introspection, you're no longer solving a problem, but instead creating option paralysis and fragility. Someone should be able to understand that an object emits events, without worrying about who could be publishing those events in the first place.

Pubit is [ポカヨケ][2].


API
---

Coming soon to a GitHub wiki near you!

[1]: https://mail.mozilla.org/pipermail/es-discuss/2011-November/017872.html
[2]: http://blog.ploeh.dk/2011/05/24/PokayokeDesignFromSmellToFragrance.aspx
