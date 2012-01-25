// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * restricted event names? would be a constructor parameter
// * more argument validation
// * Utility functions (on the module?) for throttled/debounced handlers, one-time handlers.
// * think about the role of async (publisher? subscriber? always?)

"use strict";

var dict = require("dict");
var emitter = require("./emitter");

exports.Publisher = function () {
    var that = this;

    var handlerDict = dict();
    var onSubscriberError = function () { };

    function callHandler(handler, args) {
        try {
            handler.apply(null, args);
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

        if (handlerDict.has(eventName)) {
            var errorsThrown = [];

            // .slice() is important to deal with self-unsubscribing handlers
            handlerDict.get(eventName).slice().forEach(function (handler) {
                callHandler(handler, args);
            });
        }
    };

    that.emitter = emitter(handlerDict);
};
