// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * restricted event names? would be a constructor parameter
// * more argument validation
// * Utility functions (on the module?) for throttled/debounced listeners, one-time listeners.
// * think about the role of async (publisher? subscriber? always?)

"use strict";

var dict = require("dict");
var emitter = require("./emitter");

exports.Publisher = function () {
    var that = this;

    var listeners = dict();
    var onSubscriberError = function () { };

    function callListener(listener, args) {
        try {
            listener.apply(null, args);
        } catch (e) {
            onSubscriberError(e);
        }
    }

    // TODO constructor injection instead of setter injection?
    that.setSubscriberErrorCallback = function (newOnSubscriberError) {
        onSubscriberError = newOnSubscriberError;
    };

    that.publish = function (eventName, args) {
		if (typeof eventName !== "string") {
            throw new TypeError("eventName argument must be a string.");
		}

        if (listeners.has(eventName)) {
            var errorsThrown = [];

            // .slice() is important to deal with self-unsubscribing listeners
            listeners.get(eventName).slice().forEach(function (listener) {
                callListener(listener, args);
            });
        }
    };

    that.emitter = emitter(listeners);
};
