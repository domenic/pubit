Pubit-as-promised
=====
Responsible publish/subscribe. Hide the event publisher, only exposing the event emitter.
Now with added Q promise goodness!


Why is this cool?
-----------------

Most pub/sub frameworks conflate the role of publisher and emitter. This means that if someone gets ahold of your 
emitter object, they can not only subscribe to events, but also fake out all other subscribers by emitting an 
artificial event:

```javascript

// server.js
process.on("exit", cleanupServerStuff);

// thirdParty.js
process.emit("exit");
// uh oh, now the server stuff's been all cleaned up!
```

With **pubit-as-promised**, the publisher and emitter are separate, allowing you to keep the publisher private while
exposing emitter functionality. Here's a hypothetical implementation of a `process` module using pubit-as-promised, 
including the use of the new Q promise return value of `publish`:

```javascript
var pubit = require("pubit-as-promised");

var publish = pubit.makeEmitter(exports);

exports.exit = function (exitCode) {
  publish("exit", exitCode).done(function () {
    window.close();
  });
};
```

An example of a subscriber that returns a promise looks like this:

```javascript
var process = require("./process");

process.on("exit", function () {
  return sendLogsToCloudAsync();
});
```

This module only exports the emitter interface (`on`, `off`, and `once`); the publish function is kept private.


Aren't you being paranoid?
--------------------------

There's [some argument][1] as to what role encapsulation has to play in JavaScript. Some might say, “if you don't 
want the event to be emitted outside the emitter … don't emit the event outside the emitter.”

But encapsulation isn't about being paranoid. It's about _hiding complexity_: exposing a solution, without requiring 
the consumer to grok the gory details of the problem. An emitter by itself is simple and easy to interface with, 
but when you add knobs for publishing or introspection, you're no longer solving a problem, but instead creating 
option paralysis and fragility. Someone should be able to understand that an object emits events, without worrying 
about who could be publishing those events in the first place.

Pubit-as-promised is [ポカヨケ][2].


More docs and examples
----------------------

* Check out [a simple example][3] of using pubit-as-promised for responsible pub/sub.
* Be sure to check out the [listener helper examples][4] to get a look at a nice feature pubit-as-promised provides 
to solve a common use case.
* If you like that sort of thing, we also have an [API reference][5].
* Perhaps most educational would be checking out [the unit tests][6]—they're very readable, I promise! 
Run them with `npm test` if you'd like.



[1]: https://mail.mozilla.org/pipermail/es-discuss/2011-November/017872.html
[2]: http://blog.ploeh.dk/2011/05/24/PokayokeDesignFromSmellToFragrance.aspx
[3]: https://github.com/NobleJS/pubit-as-promised/wiki/Simple-Example
[4]: https://github.com/NobleJS/pubit-as-promised/wiki/Listener-Helper-Examples
[5]: https://github.com/NobleJS/pubit-as-promised/wiki/API-Reference
[6]: https://github.com/NobleJS/pubit-as-promised/tree/master/test
